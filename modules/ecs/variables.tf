variable "vpc_id" {
  type = string
}

# variable "lb_log_bucket" {
#   type = string
# }

variable "public_subnets" {
  type = list(object({
    id                             = string,
    arn                            = string,
    ipv6_cidr_block_association_id = string,
    owner_id                       = string,
    })
  )
}

variable "private_subnets" {
  type = list(object({
    id                             = string,
    arn                            = string,
    ipv6_cidr_block_association_id = string,
    owner_id                       = string,
    })
  )
}