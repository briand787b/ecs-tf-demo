variable "private_subnet_ids" {
    type = list(string)
}

variable "public_subnet_ids" {
    type = list(string)
}

variable "sg_id" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "igw" {
    description = "the internet gateway"
}

variable "go-svc_env_arn" {
    type = string
}