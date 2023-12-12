/**
 * Copyright 2023 Google. This software is provided as-is,
 * without warranty or representation for any use or purpose.
 * Your use of it is subject to your agreement with Google.
 */

variable "region" {
  description = "Project region"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "automation_sa" {
  description = "Automation Service Account"
  type        = string
}

variable "tmp_dir_bucket" {
  description = "Temporary storage bucket"
  type        = string
}

variable "tfstate_bucket" {
  description = "Automation State Bucket"
  type        = string
}

variable "worker_sa" {
  description = "Worker Service Account"
  type        = string
}

variable "project_id" {
  description = "Project ID"
  type        = string
}

variable "network_self_link" {
  description = "Network resource url"
  type        = string
}

variable "subnetwork_self_link" {
  description = "Subnetwork resource url"
  type        = string
}
