# **terraform-aws-ram**

## Purpose

This module builds and shares secrets with AWS Secrets Manager to be used elsewhere. The module is variable-ized so that the secrets can be built per use case and tagged accordingly. 

- Data.tf - Pulls the secrets information once built by main.tf. 
- main.tf - creates the secrets based of a map string provided by terraform.tfvars.
- variables.tf - contains all variables used in the module. 

## Dependencies

## Resources
