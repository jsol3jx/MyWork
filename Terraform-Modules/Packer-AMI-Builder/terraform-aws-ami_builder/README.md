# AMI Builder Pipeline Project

## Summary

This repository contains the terraform code that creates the AMI builder pipeline on a given AWS account. The pipeline works by using CodePipeline to orchestrate the process, using CodeBuild and Packer to build the AMI based on specifications hosted in a Github repository.

The pipeline runs on a given schedule and builds an AMI that has any required agents installed. After the AMI is built, it is then shared with an organizational unit within the company's AWS organization.

## General Architecture
The pipeline makes use of the following AWS service and external solutions:

- **Github**: a dedicated repository contains the buildspec.yaml file for CodeBuild, the template for Packer and multiple dedicated scripts for installing the agents for Rapid7, Crowdstrike and NewRelic.
- **CodeStar**: enables CodePipeline to retrieve the code from the BitBucket repository described above.
- **CodePipeline**: orchestrates the entire process, leveraging other supporting AWS services
- **Secrets Manager**: contains sensitive information that needs to be supplied to the agents as part of the installation process
- **S3**: provides the storage of the artifacts for the pipeline, and is also the location from where the agents are retrieved during the build stage
- **CodeBuild**: builds the AMI using Packer
- **CloudWatch Logs**: stores the logs from CodeBuild for each execution of the pipeline
- **VPC**: existing environment in the AWS account where the pipeline will be deployed, where CodeBuild will run its containers during the build stage and also where Packer will launch temporary ec2 instances to build the AMI's.. This VPC needs to meet certain requirements that will be described later.

![AMI Pipeline Design](https://user-images.githubusercontent.com/87327746/155984765-c0b813c0-baf6-4ace-9966-73afb088351f.jpg)

## Scope Definition

The terraform code in this repository will provision most of the resources required to run the pipeline, while the following are out of scope and assumed to exist before making the deployment:

- **Github repository**
- **VPC and associated resources**

## Networking Requirements

The pipeline has a build stage where CodeBuild will launch a container to run the steps declared in the buildspec.yaml. Upon reaching this stage, Packer will run on this container and after launching a temporary ec2 instance, it will connect to it through SSH, install the agents and complete the process of building the AMI based on this temporary instance.

In order to keep the communications internal and avoid routing any traffic through external networks, the CodeBuild project needs to be configured to run in an existing VPC. By doing this, the containers launched by CodeBuild will be able to access the temporary ec2 instances launched by Packer, and these communciations will happen internally in the context of the same private subnet.

In addition to supplying the aws resource id for each networking resource (described later), the following requirements must be met for the VPC that is defined for this pipeline:

- An Internet Gateway to provide internet access.
- A NAT Gateway that can be used from private subnets to reach the public internet (and the Elastic IP allocated for this component).
- A public subnet with the NAT Gateway deployed, and a route table that allows to reach the public internet through the Internet Gateway.
- A private subnet with a route table that allows reaching the NAT Gateway deployed in the public subnet.
- A security group that allows outgoing traffic to any destination, and allows incoming traffic from any instance that has the same security group. The only rule that we need for incoming traffic is to allow SSH access, since Packer will be connecting from the container to the temporary instance launched during each execution of the pipeline.

## Instructions for Use

1. Clone the repository.
2. Configure AWS access keys in the local environment.
3. Change directory into the local repository and initialize terraform (terraform init).
4. Create a new file with the values for the variables expected as inputs.
5. Validate and run the code (terraform plan/apply).
6. Perform the post installation steps

#### Exmple tfvars file
The complete list of inputs can be found further down in this README. This example ***terraform.tfvars***  file provides an example of the minimum required elements to create the pipeline.

```
bitbucket_repository="sample_account/sample_repository"
name="sample_name"
security_group_id="sg-..."
subnet_id="subnet-..."
vpc_id="vpc-..."
s3_bucket_name="sample_bucket_name"
```

These inputs are not mandatory, but allow the pipeline to fulfill the initial requirements of being triggered on-schedule and sharing the AMI's with other OU's/accounts. More information on how to customize these settings is provided in the inputs section of this readme.

```
...
schedules=["0/10 * * * ? *", ...]
share_ami_accounts="123456789012,..."
share_ami_organizational_units="arn:aws:organizations::123456789012:ou/o-abcdefghij/ou-123example,..."
...
```

In order to get notifications, an SNS topic can be created with the following variable. A preset list of events will be configured, and these can also be customized with another variable (refere to the inputs section for details).
```
...
enable_notifications="true"
...
```

#### Post Installation Steps
Once the pipeline has been successfully created, additional activities need to be performed to get the pipeline in a fully working state.

+ **Finish setting up the CodeStar connection to BitBucket**
    * The connection to BitBucket uses OAuth and requires that an administrator completes the setup in order to be functional.
	  * Using the same browser session, log into BitBucket with an account that has access to the repository.
	  * Go to CodePipeline and find the CodeStar connection in the settings menu.
	  * The connection will initially remain in a _pending_ state. Follow the instructions provided by AWS to complete the connection (BitBucket will ask for authorization to grant AWS with the access it is requesting)
+ **Configure the secrets in Secrets Manager**
    * Although the secret resource in Secrets Manager is created automatically, the resource will be empty. The same secret will be used for all the agents, since multiple key/value pairs can be loaded into it.
	  * Create a key named _CROWDSTRIKE_CID_ and input the customer id from Crowdstrike as the value for this key.
	  * Note that Rapid7 does not require any license keys, tokens or other sensitive information stored in this secret. The installation bundle has the certificates required to enroll the agent into the solution (everything is supplied as a zip file by the vendor when using this installation method).
+ **Upload the installers for the agents in the S3 bucket**
    * The bucket will already have an _/agents_ prefix, under which three separate subkeys can be found (_/newrelic_, _/crowdstrike_, _/rapid7_). 
    * The installer packages need to be renamed to accommodate to what the installation scripts are expecting. Proceed to rename them as instructed below and upload them to the bucket.
	  * **CrowdStrike**
	    * Original name example: falcon-sensor-6.34.0-13108.amzn2.x86_64.rpm
		* Expected name:  falcon-sensor.amzn2.x86_64.rpm
		* Source: (solution console)
	  * **Rapid7**
	    * Original name example: linux__Insight_Agent.zip
		* Expected name:  linux__Insight_Agent.zip
		* Source: (solution console)
    * Since generic names are used, it is advised that tags are included to each uploaded object in S3 reflecting the version number of the agent. The bucket has versioning enabled, and by doing this it will be possible to keep track of the version numbers for the different agents as new versions are uploaded to the bucket.

## Detailed Information

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_notifications"></a> [notifications](#module\_notifications) | ./modules/notifications | n/a |
| <a name="module_schedules"></a> [schedules](#module\_schedules) | ./modules/schedules | n/a |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bitbucket_repository"></a> [bitbucket\_repository](#input\_bitbucket\_repository) | Bitbucket repository containing the Packer and CodeBuild files in <account>/<repository-name> format. | `string` | n/a | yes |
| <a name="input_branch_name"></a> [branch\_name](#input\_branch\_name) | Source code repository branch name. | `string` | `"master"` | no |
| <a name="input_build_compute_type"></a> [build\_compute\_type](#input\_build\_compute\_type) | Build environment compute type. | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_build_image"></a> [build\_image](#input\_build\_image) | Build environment image. | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:3.0"` | no |
| <a name="input_build_timeout"></a> [build\_timeout](#input\_build\_timeout) | Build timeout (in minutes). | `number` | `60` | no |
| <a name="input_copy_ami_regions"></a> [copy\_ami\_regions](#input\_copy\_ami\_regions) | A string of comma separated list of additional AWS Regions to copy the AMI to. | `string` | `""` | no |
| <a name="input_deprecate_ami_days"></a> [deprecate\_ami\_days](#input\_deprecate\_ami\_days) | Days since the date the AMI was built to deprecate it (disabled by default). | `number` | `0` | no |
| <a name="input_enable_notifications"></a> [enable\_notifications](#input\_enable\_notifications) | Enable pipeline notifications to an SNS topic (disabled by default). | `bool` | `false` | no |
| <a name="input_enable_push_trigger"></a> [enable\_push\_trigger](#input\_enable\_push\_trigger) | Trigger the pipeline when a change is pushed to the source code repository. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique name used for deployed resources. | `string` | n/a | yes |
| <a name="input_notification_events"></a> [notification\_events](#input\_notification\_events) | Events for notification rules on pipelines. | `list(string)` | <pre>[<br>  "codepipeline-pipeline-pipeline-execution-failed",<br>  "codepipeline-pipeline-pipeline-execution-canceled",<br>  "codepipeline-pipeline-pipeline-execution-started",<br>  "codepipeline-pipeline-pipeline-execution-resumed",<br>  "codepipeline-pipeline-pipeline-execution-succeeded",<br>  "codepipeline-pipeline-pipeline-execution-superseded"<br>]</pre> | no |
| <a name="input_packer_version"></a> [packer\_version](#input\_packer\_version) | Version of Hashicorp Packer to use. | `string` | `"1.7.10"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region where resources will be deployed. | `string` | `"us-east-1"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Creates a custom S3 bucket name instead of using the default name. | `string` | `""` | no |
| <a name="input_s3_paths"></a> [s3\_paths](#input\_s3\_paths) | List of paths to create inside the S3 bucket. | `list(string)` | <pre>[<br>  "packer",<br>  "agents/newrelic",<br>  "agents/crowdstrike",<br>  "agents/rapid7"<br>]</pre> | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | EventBridge Cron expressions to run the pipeline on certain schedules. | `list(string)` | `[]` | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Security Group ID to assign to running builds. It must allow inbound (ingress) traffic on port 22 from the same SG. | `string` | n/a | yes |
| <a name="input_share_ami_accounts"></a> [share\_ami\_accounts](#input\_share\_ami\_accounts) | A string of comma separated list of Accounts' ARNs to share the AMI with. | `string` | `""` | no |
| <a name="input_share_ami_organizational_units"></a> [share\_ami\_organizational\_units](#input\_share\_ami\_organizational\_units) | A string of comma separated list of Organizational Units' ARNs to share the AMI with. | `string` | `""` | no |
| <a name="input_share_ami_organizations"></a> [share\_ami\_organizations](#input\_share\_ami\_organizations) | A string of comma separated list of Organizations' ARNs to share the AMI with. | `string` | `""` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID within which to run builds. It should be a private subnet with Internet access trhough a NAT Gateway/Instance. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags to assign to resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID within which to run builds. It should contains at least one private and one public subnets. | `string` | n/a | yes |

### Resources

| Name | Type |
|------|------|
| [aws_codebuild_project.ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codepipeline.ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_codestarconnections_connection.ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarconnections_connection) | resource |
| [aws_iam_instance_profile.ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.codebuild_ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.codepipeline_ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ec2_ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eventbridge_ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.codebuild_ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.codepipeline_ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ec2_ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.eventbridge_ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.paths](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_secretsmanager_secret.ami_builder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.codebuild_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codebuild_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codepipeline_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ec2_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ec2_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eventbridge_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eventbridge_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuild_arn"></a> [codebuild\_arn](#output\_codebuild\_arn) | CodeBuild ARN. |
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | CodePipeline ARN. |
| <a name="output_codepipeline_name"></a> [codepipeline\_name](#output\_codepipeline\_name) | CodePipeline name. |
| <a name="output_eventbridge_rules_arns"></a> [eventbridge\_rules\_arns](#output\_eventbridge\_rules\_arns) | EventBridge rules ARNs. |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | S3 bucket ARN. |
| <a name="output_secretsmanager_secret_arn"></a> [secretsmanager\_secret\_arn](#output\_secretsmanager\_secret\_arn) | Secret Manager's secret ARN. |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | SNS Topic ARN for notifications. |

### Updates to Readme file

Sections within this part of the README have been automatically generated with [terraform-docs](https://github.com/terraform-docs/terraform-docs). The following commannd will run the tool as a Docker image, and output a doc.md file with the markdown for the previous sections.

```
docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.16.0 markdown /terraform-docs > doc.md
```
