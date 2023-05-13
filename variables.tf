variable "enable_ngw" {
  description = "true if create NAT gateway"
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "true if VPC flow logs should be created"
  type        = bool
  default     = true
}

variable "s3_vpc_flow_logs_bucket_arn" {
  description = "S3 bucket arn to store VPC flow logs"
  type        = string
  default     = "arn:aws:s3:::abrigo1-logs-us-east-1"
}
