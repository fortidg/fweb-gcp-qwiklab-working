# # Output
output "FortiWeb-IP" {
  value = module.instances.fweb_ip
}

output "FortiWeb-Username" {
  value = "admin"
}

output "FortiWeb-InstanceId" {
  value = module.instances.fweb_instance_id
}