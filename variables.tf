variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}


variable "namespace" {
  description = "The project namespace to use for unique resource naming"
  default     = "rtan"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-west-2"
  type        = string
}