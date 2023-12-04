variable "project_name" {
  type        = string
  description = "Project name"
}

variable "region" {
  type        = string
  default     = "europe-west1"
  description = "GCP region"
}

variable "subnet" {
  type        = string
  description = "VPC subnet used for deployment"
}

variable "image_version" {
  type    = string
  default = "2.1.27-ubuntu20"
}

variable "dataproc_num_workers" {
  type = number
  default = 2
  description = "number of dataproc workers"
}

variable "dataproc_num_masters" {
  type = number
  default = 1
  description = "number of dataproc workers"
}

variable "num_preemptible_workers" {
  type = number
  default =  0
  description = "number of preemptible dataproc workers"
}

variable "dataproc_master_machine_type" {
  type        = string
  default     = "e2-standard-2"
  description = "Machine type to use for master nodes"
}

variable "dataproc_worker_machine_type" {
  type        = string
  default     = "e2-medium"
  description = "Machine type to use for worker nodes"
}