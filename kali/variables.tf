# GCP region string
variable "gcp_region" {
  type    = string
}
# GCP zone
variable "gcp_zone" {
  type    = string
}
# GCP project name
variable "gcp_project_id" {
  type    = string
}

# GCP oauth access token
/* variable "token" {
  type    = string
} */


variable "kali-image" {
  type    = string
  default = "projects/techlatest-public/global/images/kali-linux-in-browser-v01"
}


# GCP instance machine type standard
variable "machine" {
  type    = string
  default = "n2-standard-4"
}

# Public Subnet CIDR
variable "public_subnet" {
  type    = string
  default = "192.168.128.0/24"
}


