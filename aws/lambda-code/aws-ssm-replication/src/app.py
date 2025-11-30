import os
import logging
from datetime import datetime, timedelta, timezone
import boto3
from botocore.config import Config
from botocore.exceptions import ClientError

# ---- Logging (as requested) ----
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ---- Env ----
SRC_REGION = os.getenv("SRC_REGION", "us-west-1")
DST_REGION = os.getenv("DST_REGION", "us-east-2")
PREFIX = os.getenv("PREFIX", "").strip()
OVERWRITE = os.getenv("OVERWRITE", "true").lower() == "true"
DEST_KMS_KEY_ID = os.getenv("DEST_KMS_KEY_ID", "").strip() or None
PAGE_SIZE = max(1, min(int(os.getenv("PAGE_SIZE", "50")), 50))
DRY_RUN = os.getenv("DRY_RUN", "false").lower() == "true"
SINCE_ISO = os.getenv("SINCE_ISO", "").strip() or None  # e.g., 2025-09-01T00:00:00Z
SINCE_DAYS = os.getenv("SINCE_DAYS", "").strip() or None  # e.g., "7"

cfg = Config(retries={"max_attempts": 10, "mode": "standard"})
ssm_src = boto3.client("ssm", region_name=SRC_REGION, config=cfg)
ssm_dst = boto3.client("ssm", region_name=DST_REGION, config=cfg)

# ---- Helpers ----
def _validate_config():
    if not PREFIX or not PREFIX.startswith("/"):
        raise ValueError("PREFIX env var is required and must start with '/' (e.g., /prod/)")
    if SINCE_DAYS and SINCE_ISO:
        raise ValueError("Specify only one of SINCE_DAYS or SINCE_ISO, not both.")

def _parse_since():
    if SINCE_DAYS:
        try:
            d = int(SINCE_DAYS)
            return datetime.now(timezone.utc) - timedelta(days=d)
        except ValueError:
            raise ValueError("SINCE_DAYS must be an integer number of days.")
    if SINCE_ISO:
        iso = SINCE_ISO.replace("Z", "+00:00")
        try:
            dt = datetime.fromisoformat(iso)
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
            return dt.astimezone(timezone.utc)
        except Exception:
            raise ValueError("SINCE_ISO must be ISO-8601, e.g. 2025-09-01T00:00:00Z")
    return None

def _iter_meta_under_prefix(path: str):
    token = None
    flt = [{"Key": "Name", "Option": "BeginsWith", "Values": [path]}]
    while True:
        kwargs = {"ParameterFilters": flt, "MaxResults": PAGE_SIZE}
        if token:
            kwargs["NextToken"] = token
        resp = ssm_src.describe_parameters(**kwargs)
        for m in resp.get("Parameters", []):
            yield m
        token = resp.get("NextToken")
        if not token:
            break

def _get_value(name: str) -> str:
    return ssm_src.get_parameter(Name=name, WithDecryption=True)["Parameter"]["Value"]

def _get_tags_src(name: str):
    try:
        return ssm_src.list_tags_for_resource(ResourceType="Parameter", ResourceId=name).get("TagList", [])
    except ClientError:
        return []

def _resolve_dest_key(meta: dict):
    if meta["Type"] != "SecureString":
        return None
    # Prefer explicit DEST_KMS_KEY_ID; fall back to source KeyId if present.
    key = DEST_KMS_KEY_ID or meta.get("KeyId")
    if not key:
        logger.info(f"SecureString {meta['Name']} has no DEST_KMS_KEY_ID and no source KeyId; "
                    "destination will use account default key if configured.")
    return key

def _put_to_dest(meta: dict, value: str):
    kwargs = {
        "Name": meta["Name"],
        "Value": value,
        "Type": meta["Type"],  # String | StringList | SecureString
        "Overwrite": OVERWRITE,
        "Description": meta.get("Description", "") or "",
        "Tier": meta.get("Tier", "Standard"),
        "DataType": meta.get("DataType", "text"),
    }
    if meta["Type"] == "SecureString":
        key = _resolve_dest_key(meta)
        if key:
            kwargs["KeyId"] = key
    if DRY_RUN:
        return  # simulate success
    ssm_dst.put_parameter(**kwargs)

def _copy_tags(name: str, tags):
    if tags and not DRY_RUN:
        ssm_dst.add_tags_to_resource(ResourceType="Parameter", ResourceId=name, Tags=tags)

def _bytes_of(value: str) -> int:
    # UTF-8 bytes written—helps approximate payload size
    return len(value.encode("utf-8"))

def _copy_prefix(path: str, since_dt):
    stats = {
        "evaluated": 0,
        "copied": 0,
        "skipped_existing": 0,
        "skipped_since": 0,
        "errors": 0,
        "dry_run": DRY_RUN,
        "types": {"String": 0, "StringList": 0, "SecureString": 0},
        "bytes_total": 0,
        "bytes_by_type": {"String": 0, "StringList": 0, "SecureString": 0},
    }

    for meta in _iter_meta_under_prefix(path):
        stats["evaluated"] += 1
        name = meta["Name"]

        # LastModified filtering (metadata-side)
        if since_dt is not None:
            last_mod = meta.get("LastModifiedDate")
            # If metadata missing, treat as needs-copy; otherwise check timestamp
            if last_mod and last_mod < since_dt:
                stats["skipped_since"] += 1
                continue

        try:
            value = _get_value(name)
            size = _bytes_of(value)

            _put_to_dest(meta, value)
            _copy_tags(name, _get_tags_src(name))

            stats["copied"] += 1
            t = meta.get("Type", "String")
            stats["types"][t] = stats["types"].get(t, 0) + 1
            stats["bytes_total"] += size
            stats["bytes_by_type"][t] = stats["bytes_by_type"].get(t, 0) + size

        except ClientError as e:
            code = e.response.get("Error", {}).get("Code", "")
            if code == "ParameterAlreadyExists" and not OVERWRITE:
                stats["skipped_existing"] += 1
            else:
                stats["errors"] += 1
                logger.error(f"Error copying {name}: {e}")

    return stats

def lambda_handler(_event, _context):
    _validate_config()
    since_dt = _parse_since()
    if since_dt:
        logger.info(f"Filtering by LastModifiedDate >= {since_dt.isoformat()}")

    stats = _copy_prefix(PREFIX, since_dt)
    logger.info(f"Successfully copied {stats['copied']} parameters")
    return {
        "src_region": SRC_REGION,
        "dst_region": DST_REGION,
        "prefix": PREFIX,
        "since": since_dt.isoformat() if since_dt else None,
        **stats,
    }
