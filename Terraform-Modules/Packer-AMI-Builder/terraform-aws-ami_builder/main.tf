# Codestar Connection
resource "aws_codestarconnectsion_connection" "ami_builder" {
  name          = local.full_name
  provider_type = "Bitbucket"
}

# Codepipeline
resource "aws_codepipeline" "ami_builder" {
  name     = local.full_name
  role_arn = aws_iam_role.codepipeline_ami_builder.arn

  artifact_store {
    location = aws_s3_bucket.ami_builder.id
    type     = "S3"
  }

  #Bitbucket  
  stage {
    name = "Source"

    action {
      name            = "Source"
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeStarSourceConnection"
      version         = "1"
      input_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.ami_builder.arn
        FullRepositoryId = var.bitbucket_repository
        BranchName       = var.branch_name
        DetectChanges    = var.enable_push_trigger
      }
    }
  }

  #Codebuild
  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_ouput"]

      configuration = {
        ProjectName = aws_codebuild_project.ami_builder.name
      }
    }
  }
}


# CodeBuild

resource "aws_codebuild_project" "ami_builder" {
  name           = local.full_name
  description    = "Project to build a custom AMI using Packer"
  build_timeout  = var.build_timeout
  service_role   = aws_iam_role.codebuild_ami_builder.arn
  source_version = var.branch_name

  #Codebuilds container runs inside a VPC
  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = [var.var.subnet_id]
    security_group_ids = [var.var.security_group_id]
  }

  #where to get buildspec.yml file
  source {
    type = "CODEPIPELINE"
  }

  #If the type for source is CODEPIPELINE, the type for artifacts must be the same.artifacts 
  artifacts {
    type = "CODEPIPELINE"
  }

  # CodeBuild's env var's (used to configure Packer)
  environment {
    compute_type                = var.build_compute_type
    image                       = var.build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "PACKER_VERSION"
      value = var.packer_version
    }

    dynamic "environment_variable" {
      for_each = local.packer_vars

      content {
        name  = "PKR_VAR_${environment_variable.key}"
        value = environment_variable.value
      }
    }
  }

  #Cloudwatch Logs
  logs_config {
    cloudwatch_logs {
     group_name = local.cloudwatch_log_group_name 
    }
  }
}

#S3 Creation
resource "aws_s3_bucket" "ami_builder" {
  bucket = local.bucket_name
}

#block public access
resource "aws_s3_bucket_public_access_block" "ami_builder" {
  bucket                  = aws_s3_bucket.ami_builder.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#encrypt objects w/ default KMS Key
resource "aws_s3_bucket_server_side_encryption_configuration" "ami_builder" {
  bucket = aws_s3_bucket.ami_builder.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

#Bucket Versioning
resource "aws_s3_bucket_versioning" "ami_builder" {
  bucket = aws_s3_bucket.ami_builder.id

  versioning_configuration {
    status = "Enabled"
  }
}

#Create default paths
resource "aws_s3_object" "paths" {
  count  = length(var.s3_paths)
  bucket = aws_s3_bucket.ami_builder.id
  key    = "${var.s3_paths[count.index]}/"
}

# Secrets Manager
resource "aws_secretsmanager_secret" "ami_builder" {
  name        = local.full_name
  description = "Secrets for the Ami Pipeline"
}

# EventBridge Schedules
module "schedules" {
  source              = "./modules/schedules"
  count               = length(var.schedules)
  name                = "Schedule-${local.fullname}-${count.index + 1}"
  schedule_expression = var.schedules[count.index]
  target_arn          = aws_codepipeline.ami_builder.arn
  role_arn            = aws.iam_role.eventbridge_ami_builder[0].arn
}

#Codestar & SNS Notifications
module "notifications" {
  source              = "./modules/notifications"
  count               = var.enable_notifications ? 1 : 0
  name                = "${local.full_name}-Nofications"
  display_name        = local.full_name
  codepipeline_arn    = aws_codepipeline.ami_builder.arn
  notification_events = var.notification_events
}