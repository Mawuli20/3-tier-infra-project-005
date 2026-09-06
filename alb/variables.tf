variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "public_subnet_az_2a" {
  type = string
}

variable "public_subnet_az_2b" {
  type = string
}

variable "ssl_policy" {
  type = string
}

variable "certificate_arn" {
  type = string
}