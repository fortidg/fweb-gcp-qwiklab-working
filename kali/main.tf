### GCP terraform
terraform {
  required_version = ">=0.12.0"
  required_providers {
    google      = ">=2.11.0"
    google-beta = ">=2.13"
  }
}
provider "google" {
  project      = var.gcp_project_id
  region       = var.gcp_region
  zone         = var.gcp_zone
  /* access_token = var.token */
}
provider "google-beta" {
  project      = var.gcp_project_id
  region       = var.gcp_region
  zone         = var.gcp_zone
  /* access_token = var.token */
}

# Create log disk


### VPC ###
resource "google_compute_network" "untrust" {
  name                    = "untrust-kali"
  auto_create_subnetworks = false
}

### Public Subnet ###
resource "google_compute_subnetwork" "untrust" {
  name                     = "untrust-subnet-kali"
  region                   = var.gcp_region
  network                  = google_compute_network.untrust.name
  ip_cidr_range            = var.public_subnet
  private_ip_google_access = true
}




# Firewall Rule External
resource "google_compute_firewall" "allow-https-kali" {
  name    = "allow-kali"
  network = google_compute_network.untrust.name

  allow {
    protocol = "tcp"
    ports = ["443", "80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-kali"]
}


# Create Static Public IP
resource "google_compute_address" "static" {
  name = "kali-pip"
}



# Create kali compute instance
resource "google_compute_instance" "kali" {
  name           = "kali"
  machine_type   = var.machine
  zone           = var.gcp_zone
  can_ip_forward = "false"

  tags = ["allow-kali"]

  boot_disk {
    initialize_params {
      image = var.kali-image
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.untrust.name
    access_config {
          nat_ip = google_compute_address.static.address
    }
  }
 }


