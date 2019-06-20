variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "env" {
  description = "Environment"
  default     = "dev"
}

variable "my_ui_bucket_name" {
  description = "UI bucket name"
}


variable "lambda_webapi_vpc_subnets" {
  type        = "list"
  description = "Subnets for Lambda Web API"
}

variable "lambda_webapi_vpc_sec_groups" {
  type        = "list"
  description = "Security groups for Lambda Web API"
}

variable "lambda_webapi_role" {
  description = "Lambda Web API Roles"
}

variable "lambda_extractapi_vpc_subnets" {
  type        = "list"
  description = "Subnets for Lambda Extract API"
}

variable "lambda_extractapi_vpc_sec_groups" {
  type        = "list"
  description = "Security groups for Lambda Extract API"
}

variable "lambda_extractapi_role" {
  description = "Lambda Extract API Roles"
}

variable "webacl_allow_ip_address" {
  description = "Lambda Extract API Roles"
}

variable "my_ui_cf_origin_domain_name" {
  description = "Origin Domain Name"
}

variable "my_ui_cf_origin_id" {
  description = "Origin ID"
}
