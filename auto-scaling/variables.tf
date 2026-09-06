variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
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

variable "public_subnet_az_2a" {
  type = string
}

variable "public_subnet_az_2b" {
  type = string
}

variable "jupiter_app_tg_arn" {
  type = list(string)
}