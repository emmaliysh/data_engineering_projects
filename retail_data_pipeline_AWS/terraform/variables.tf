#################################
# Variables
#################################
variable "project_name" {
  default = "retail-etl"
}

variable "alert_email" {
  description = "Email address for SNS alerts"
  type        = string
}