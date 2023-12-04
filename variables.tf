variable "project_name" {
  type        = string
  description = "Project name"
}

variable "region" {
  type        = string
  default     = "europe-west1"
  description = "GCP region"
}

variable "ai_notebook_instance_owner" {
  type        = string
  description = "Vertex AI workbench owner"
}

variable "machine_type" {
	type = string
	default = "e2-standard-2"
	description = "Type of machine"
}

variable "dataproc_machine_type" {
  type        = string
  default     = "e2-medium"
  description = "Machine type to use for both worker and master nodes"
}

variable "vertex_machine_type" {
	type = string
	default = "e2-standard-2"
	description = "Type of machine"
}

variable "num_workers" {
  type = number
  default = 2
  description = "number of dataproc workers"
}

variable "num_preemptible_workers" {
  type = number
  default =  0
  description = "number of preemptible dataproc workers"
}