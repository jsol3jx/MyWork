# AMI Builder Pipeline Auxiliary Repository

## Summary

The AMI Builder Pipeline relies on this auxiliary repository to retrieve the specifications for the Build stage executed with CodeBuild, along with the template and agent installation scripts used by Packer when building AMI'S.

## Repository Contents

The contents of this repository are listed below:
- **scripts/**: contains auxiliary scripts invoked by Packer (installation scripts for Rapid7, Crowdstrike and NewRelic, and operating system update script)
- **buildspec.yml**: specs for CodeBuild (installs Packer, validates the template and launches Packer to build the AMI)
- **aws-dockeral2.pkr.hcl**: template used by Packer

## Updates and Maintenance
Once the pipeline has been deployed, CodePipeline will fetch the contents of this repository during the "source" stage of the pipeline. Changes made to the contents of this repository will be automatically picked up during the execution of the pipeline that follows.

### Target Branch
The terraform code that deploys the pipeline will target the default branch in this repository for the source stage, unless a different one is specified through the appropriate terraform variable.

### Installation of new agents
Even if the pipeline was created to handle the installation of Rapid7, CrowdStrike and NewRelic, it can be easily extended to install other applications. The following summary provides guidance on the necessary steps that allow to do so:

1. Include the new script in the "scripts/" folder with the instructions for installing the agent.
2. Adjust the terraform code that creates the pipeline, so that a new prefix is created in S3 for the new agent (subkey within the /agents). This is the code maintained in the other repository.
3. If the agent relies on a license, authentication token or other sensitive information that can be stored in Secrets Manager, create the new key/value pair in the existing secret.
4. Make sure that the installation script for the new agent references the correct location in S3 and the correct name for the key within the Secrets Manager secret (if applicable).
5. If a new secret value is required, adjust the Packer template to include a new environment variable using the name of the new key in the Secrets Manager secret. For example:
```
build {
  sources = ["source.amazon-ebs.docker_al2"]

  provisioner "shell" {
    environment_vars = [
      "S3_BUCKET=${var.s3_bucket}",
      "CROWDSTRIKE_CID=${aws_secretsmanager(var.secretsmanager_secret, "CROWDSTRIKE_CID")}",
      "NEW_KEY=${aws_secretsmanager(var.secretsmanager_secret, "NEW_KEY")}"
    ]

    scripts = fileset(".", "scripts/*")
  }
}
```