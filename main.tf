/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  service_config = {
    bigtable = {
      tables = jsondecode(file("${path.module}/example/bt_person.json"))
    }
    bigquery = {
      tables = merge(
        { person = {
            schema = file("${path.module}/example/person.json")
          }
        },
        jsondecode(file("${path.module}/example/bq_person.json")),
      )
    }
    dataflow = {
      worker_sa 	= var.worker_sa
      template_path	= "gs://dataflow-templates/latest/GCS_Text_to_BigQuery"
      network           = var.network_self_link
      subnetwork        = var.subnetwork_self_link
      machine_type      = "n1-standard-1"
      parameters = {
        javascriptTextTransformFunctionName="transform",
        JSONPath="gs://${var.tmp_dir_bucket}/config/person_schema.json",
        javascriptTextTransformGcsPath="gs://${var.tmp_dir_bucket}/config/person_udf.js",
        inputFilePattern="gs://${var.tmp_dir_bucket}/input/person.csv",
        outputTable="${var.project_id}:eaut_bl_bq_0.person",
        bigQueryLoadingTemporaryDirectory="gs://${var.tmp_dir_bucket}/temp"
      }
    }
  }
}

module "dataplatform" {
  source 	= "../modules/dataplatform-factory"
  project_id 	= var.project_id
  prefix	= var.prefix
  region	= var.region
  service_config = local.service_config
} 
