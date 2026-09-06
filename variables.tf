variable "vpc_cidr_block" {
  type = string
}

variable "public_subnets_cidr_block" {
  type = list(string)
}

variable "availability_zone" {
  type = list(string)
}

variable "private_subnets_cidr_block" {
  type = list(string)
}

variable "db_subnets_cidr_block" {
  type = list(string)
}

variable "image_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "ssl_policy" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "db_name" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "parameter_group_name" {
  type = string
}