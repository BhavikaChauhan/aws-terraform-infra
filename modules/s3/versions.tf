terraform {
  required_providers {
    random = { source = "hashicorp/random" }
  }
}
variable "project_name" { type = string }
variable "environment" { type = string }
