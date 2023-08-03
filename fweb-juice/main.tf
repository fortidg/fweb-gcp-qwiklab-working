terraform {
  required_version = ">= 0.13.1"

  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

module "random" {
  source = "./modules/random-generator"
}

module "vpc" {
  source = "./modules/vpc"
  # Pass Variables
  name = var.name
  vpcs = var.vpcs
  # Values fetched from the Modules
  random_string = module.random.random_string
}

module "subnet" {
  source = "./modules/subnet"

  # Pass Variables
  name                     = var.name
  region                   = var.gcp_region
  subnets                  = var.subnets
  subnet_cidrs             = var.subnet_cidrs
  private_ip_google_access = null
  # Values fetched from the Modules
  random_string = module.random.random_string
  vpcs          = module.vpc.vpc_networks
}

module "firewall" {
  source = "./modules/firewall"

  # Values fetched from the Modules
  random_string = module.random.random_string
  vpcs          = module.vpc.vpc_networks
}

module "static-ip" {
  source = "./modules/static-ip"

  # Pass Variables
  name   = var.name
  region = var.gcp_region
  # Values fetched from the Modules
  random_string = module.random.random_string
}

# Find the public image to be used for deployment.
data "google_compute_image" "fweb_image" {
  project = "fortigcp-project-001"
  name    = var.image
}

# FortiWeb
module "instances" {
  source = "./modules/fortiweb"

  # Pass Variables
  name         = var.name
  zone         = var.gcp_zone
  machine      = var.machine
  image        = data.google_compute_image.fweb_image.self_link
  license_file = var.license_file
  # Values fetched from the Modules
  random_string       = module.random.random_string
  public_vpc_network  = module.vpc.vpc_networks[0]
  private_vpc_network = module.vpc.vpc_networks[1]
  mgmt_vpc_network    = module.vpc.vpc_networks[2]
  public_subnet       = module.subnet.subnets[0]
  private_subnet      = module.subnet.subnets[1]
  mgmt_subnet         = module.subnet.subnets[2]
  static_ip           = module.static-ip.static_ip
}

#########################
# Juice Shop Container  #
#########################

module "gce-container" {
  source = "terraform-google-modules/container-vm/google"

  container = {
    image = var.juice_shop_image_name
  }

  restart_policy = "Always"
}

resource "google_compute_instance" "juice_shop" {
  project      = var.gcp_project_id
  name         = "${var.name}-juice-shop-${module.random.random_string}"
  machine_type = var.juice_shop_machine
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
    }
  }

  network_interface {
    network    = module.vpc.vpc_networks[2]
    subnetwork = module.subnet.subnets[2]
    access_config {}
  }

  tags = ["fweb-juice-shop-container"]

  metadata = {
    gce-container-declaration = module.gce-container.metadata_value
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  labels = {
    container-vm = module.gce-container.vm_container_label
  }
}

 resource "google_dns_managed_zone" "default" {
   name          = "fortiwebcloudtrain-zone"
   dns_name      = "fwebcloudtrain-${module.random.random_string}.com."
   description   = "fortiweb public dns zone"
   force_destroy = "true"
 }

resource "google_dns_record_set" "default" {
  name         = google_dns_managed_zone.default.dns_name
  managed_zone = google_dns_managed_zone.default.name
  type         = "A"
  ttl          = 300
  rrdatas = [
    module.instances.fweb_ip
  ]
}