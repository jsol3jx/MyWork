locals {
  #create_origin_access_identity = var.create_origin_access_identity && length(keys(var.origin_access_identities)) > 0
  files   = fileset("${path.module}/files", "**")
  folders = distinct([for f in local.files : dirname(f) != "." ? "${dirname(f)}/" : null])
  fqdn    = "${var.distribution_hostname}.${var.domain_name}"
}
