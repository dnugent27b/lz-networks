variable "enable_ngw" {
  description = "true if create NAT gateway"
  type        = bool
  default     = true
}

variable "enable_firewalls" {
  description = "true if create ingress and egress firewall endpoints"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "true if VPC flow logs should be created"
  type        = bool
  default     = true
}

variable "s3_logs_bucket_name" {
  description = "S3 bucket name to store logs"
  type        = string
  default     = "abrigo1-logs-us-east-1"
}
