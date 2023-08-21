variable "plan" {
  type        = string
  description = "device type/size"
  default     = "c3.small.x86"
}

variable "metro" {
  type        = string
  description = "Equinix metro code"
  default     = "SV"
}

variable "os" {
  type        = string
  description = "Operating system"
  default     = "ubuntu_20_04"
}
