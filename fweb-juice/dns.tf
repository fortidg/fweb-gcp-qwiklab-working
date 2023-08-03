
 resource "google_dns_managed_zone" "default" {
   name          = "fortiwebcloudtrain-zone"
   dns_name      = "fortiwebcloudtrain-${module.random.random_string}.com"
   description   = "fortiweb public dns zone"
   force_destroy = "true"
 }

resource "google_dns_record_set" "default" {
  name         = google_dns_managed_zone.default.dns_name
  managed_zone = google_dns_managed_zone.default.name
  type         = "A"
  ttl          = 300
  rrdatas = [
    google_compute_instance.fweb_instance.network_interface.0.access_config.0.nat_ip
  ]
}
 