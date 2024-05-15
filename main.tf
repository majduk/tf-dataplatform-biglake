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

module "gcs-dp-tmp" {
  source         = "../../cloud-foundation-fabric/modules/gcs"
  project_id     = var.project_id
  name	         = replace("${var.prefix}_bl_dp_tmp_0","_","-")
  location       = var.region
  storage_class  = "REGIONAL"
  force_destroy  = true
}

module "gcs-dp-stg" {
  source         = "../../cloud-foundation-fabric/modules/gcs"
  project_id     = var.project_id
  name	         = replace("${var.prefix}_bl_dp_stg_0","_","-")
  location       = var.region
  storage_class  = "REGIONAL"
  force_destroy  = true
}

module "gcs-dp-init" {
  source         = "../../cloud-foundation-fabric/modules/gcs"
  project_id     = var.project_id
  name	         = replace("${var.prefix}_bl_dp_init","_","-")
  location       = var.region
  storage_class  = "REGIONAL"
  force_destroy  = true
}

resource "google_storage_bucket_object" "deploy_folder" {
  name   = "deploy/" 
  content = " "
  bucket = "${module.gcs-dp-init.name}"
}

variable "init_revision" {
  default = 2
}

resource "null_resource" "bucket_sync" {
  triggers = {
    always_run = var.init_revision
  }
  provisioner "local-exec" {
    command = "gsutil rsync -r ${path.module}/repo gs://${module.gcs-dp-init.name}/repo" 
  }
  provisioner "local-exec" {
    command = "gsutil rsync -r ${path.module}/scripts gs://${module.gcs-dp-init.name}/scripts" 
  }
}

module "dataproc" {
  source     = "../../cloud-foundation-fabric/modules/dataproc"
  project_id = var.project_id
  name       = "dataproc-dev-1"
  region     = var.region
  dataproc_config = {
    cluster_config = {
      staging_bucket = module.gcs-dp-stg.name
      temp_bucket    = module.gcs-dp-tmp.name
      initialization_action = {
        script      = "gs://${module.gcs-dp-init.name}/scripts/01_os_config.sh"
        timeout_sec = 60
      }
      initialization_action = {
        script      = "gs://${module.gcs-dp-init.name}/scripts/02_oozie_offline.sh"
        timeout_sec = 600
      }
      gce_cluster_config = {
        subnetwork             = var.subnetwork_self_link
        zone                   = "${var.region}-b"
        service_account        = var.worker_sa
        service_account_scopes = ["cloud-platform"]
        internal_ip_only       = true
        shielded_instance_config = {
          enable_secure_boot          = true
          enable_vtpm                 = true
          enable_integrity_monitoring = true
        }
        metadata = {
          "enable-oslogin" = "True"
          "os-group" = "svcgroup"
          "os-user" =  "svcuser"
          "authorized_keys_url" = "gs://${module.gcs-dp-init.name}/scripts/authorized_keys"
          "deploy_bucket_url" =   "gs://${module.gcs-dp-init.name}/deploy"
          "oozie-repo-url" =      "gs://${module.gcs-dp-init.name}/repo"
        }
      }
      worker_config = {
        num_instances    = 0
        machine_type     = null
        min_cpu_platform = null
        image_uri        = null
      }
      software_config = {
        image_version = "2.2"
        override_properties = {
          "dataproc:dataproc.allow.zero.workers" = "true"
          "dataproc:job.history.to-gcs.enabled"  = "true"
          "spark:spark.history.fs.logDirectory" = (
            "gs://${module.gcs-dp-stg.name}/*/spark-job-history"
          )
          "spark:spark.eventLog.dir" = (
            "gs://${module.gcs-dp-stg.name}/*/spark-job-history"
          )
          "spark:spark.history.custom.executor.log.url.applyIncompleteApplication" = "false"
          "spark:spark.history.custom.executor.log.url" = (
            "{{YARN_LOG_SERVER_URL}}/{{NM_HOST}}:{{NM_PORT}}/{{CONTAINER_ID}}/{{CONTAINER_ID}}/{{USER}}/{{FILE_NAME}}"
          )
        }
      }
      endpoint_config = {
        enable_http_port_access = "true"
      }
      tags = ["dataproc"]
    }
  }
  depends_on = [
    null_resource.bucket_sync,
    google_storage_bucket_object.deploy_folder
  ]
} 
