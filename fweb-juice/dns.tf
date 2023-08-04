 resource "google_dns_managed_zone" "default" {
   name          = "${module.random.random_string}-fwebtraincse-zone"
   dns_name      = "${module.random.random_string}.fwebtraincse.com."
   description   = "fortiweb public dns zone"
 }

resource "google_dns_record_set" "a-record" {
  name         = google_dns_managed_zone.default.dns_name
  managed_zone = google_dns_managed_zone.default.name
  type         = "A"
  ttl          = 300
  rrdatas = [
    module.instances.fweb_ip
  ]
}

resource "google_dns_record_set" "ns-record" {
  name         = google_dns_managed_zone.default.dns_name
  managed_zone = google_dns_managed_zone.default.name
  type         = "NS"
  ttl          = 21600
  rrdatas = [
   "ns-cloud-c1.googledomains.com.",
   "ns-cloud-c2.googledomains.com.",
   "ns-cloud-c3.googledomains.com.",
   "ns-cloud-c4.googledomains.com.",
  ]
}

resource "google_dns_record_set" "soa-record" {
  name         = google_dns_managed_zone.default.dns_name
  managed_zone = google_dns_managed_zone.default.name
  type         = "SOA"
  ttl          = 21600
  rrdatas = [
   "ns-cloud-c1.googledomains.com. cloud-dns-hostmaster.google.com. 1 21600 3600 259200 300"
  ]
}