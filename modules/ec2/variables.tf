variable "namespace" {
  type = string
}

variable "vpc" {
  type = any
}

variable key_name {
  type = string
}

variable "sg_pub_id" {
  type = any
}

variable "sg_priv_id" {
  type = any
}

/*
variable "hostname" {
  description  = "Oracle Host"
  default      = {
    "0"     = "USDTC2DXORDB001" 
    "1"     = "USDTC2DXORDB002"
    "2"     = "USDTC2DXORDB003"
    "3"     = "USDTC2PXORDB001"
    "4"     = "USDTC2PXORDB002"
    "5"     = "USDTC2PXORDB003"
  }
}
*/
