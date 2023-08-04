 resource "google_dns_managed_zone" "default" {
   name          = "${module.random.random_string}-fwebtraincse-zone"
   dns_name      = "${module.random.random_string}.fwebtraincse.com."
   description   = "fortiweb public dns zone"
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