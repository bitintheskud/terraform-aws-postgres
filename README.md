# terraform-aws-postgres


## Description

Use the [terraform-aws-rds](https://github.com/terraform-aws-modules/terraform-aws-rds) module to build a postgres instance. 

Used with terragrunt (see examples/terragrunt.hcl)## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| aws\_region | n/a | `string` | n/a | yes |
| custom\_tags | Custom tags to add to all the resource | `map(string)` | `{}` | no |
| db | List of variable to apply to postgres | `map` | `{}` | no |
| env | Environment of the project (production, developement, staging) | `string` | n/a | yes |
| identifier | A code or identifier to identify this resource | `string` | n/a | yes |
| project | Project code or identifier | `string` | n/a | yes |
| publicly\_accessible | Bool to control if instance is publicly accessible | `bool` | `false` | no |
| subnet\_ids | A list of VPC subnet IDs | `list(string)` | `[]` | no |
| vpc\_id | VPC id to create the db in | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| db\_instance\_address | DB instance address |
| db\_instance\_endpoint | DB instance endpoint |
| db\_instance\_username | DB instance username |
| db\_password | The password for logging in to the database. |

