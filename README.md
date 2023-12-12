# Terraform Managed Dataflow

This is an example how to use [dataplatform-factory](https://github.com/majduk/tf-dataplatform-factory).
Prerequisite is [Terraform Dataflow Project](https://github.com/majduk/tf-dataflow-project) created.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.43.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.43.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dataplatform"></a> [dataplatform](#module\_dataplatform) | ../modules/dataplatform-factory | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_automation_sa"></a> [automation\_sa](#input\_automation\_sa) | Automation Service Account | `string` | n/a | yes |
| <a name="input_network_self_link"></a> [network\_self\_link](#input\_network\_self\_link) | Network resource url | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Resource name prefix | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Project region | `string` | n/a | yes |
| <a name="input_subnetwork_self_link"></a> [subnetwork\_self\_link](#input\_subnetwork\_self\_link) | Subnetwork resource url | `string` | n/a | yes |
| <a name="input_tfstate_bucket"></a> [tfstate\_bucket](#input\_tfstate\_bucket) | Automation State Bucket | `string` | n/a | yes |
| <a name="input_tmp_dir_bucket"></a> [tmp\_dir\_bucket](#input\_tmp\_dir\_bucket) | Temporary storage bucket | `string` | n/a | yes |
| <a name="input_worker_sa"></a> [worker\_sa](#input\_worker\_sa) | Worker Service Account | `string` | n/a | yes |

## Outputs

No outputs.
