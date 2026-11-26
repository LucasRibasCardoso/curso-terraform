variable "cidr_block" {
  type        = string
  description = "Network CIDR block for the VPC"
}

variable "availability_zones" {
  type = map(object({
    az     = string
    netnum = number
  }))
  description = "Availability zones and subnet index offsets"
}
