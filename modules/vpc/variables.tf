variable "vpc_cidr_block" {
  description = "CIDR VPC"
  type        = string
}

variable "public_subnets" {
  description = "CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}