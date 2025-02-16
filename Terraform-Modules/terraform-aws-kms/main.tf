resource "aws_kms_key" "key" {
  description = "${var.eb_name}-${var.eb_env}-KMS-key"
  policy = jsonencode({
    "Id" : "key-consolepolicy-3",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for Key Administrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/us-west-2/${element(tolist(data.aws_iam_roles.admin_role_name.names), 0)}",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole",
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Harness-Role"
          ]
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:GenerateDataKey",
          "kms:Decrypt",
          "kms:ReEncrypt",
          "kms:GenerateDataKeyPairWithoutPlaintext"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow use of the key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ec2_instance_profile_role_name}",
            "${data.aws_caller_identity.current.arn}"
          ]
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "kms:CallerAccount" : "${data.aws_caller_identity.current.account_id}",
            "kms:ViaService" : "secretsmanager.us-west-1.amazonaws.com"
          }
        }
      },
      {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.ec2_instance_profile_role_name}"

          ]
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "alias" {
  name          = "alias/${var.eb_name}-${var.eb_env}"
  target_key_id = aws_kms_key.key.key_id
}