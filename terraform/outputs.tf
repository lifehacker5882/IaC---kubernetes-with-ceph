output "vm_map" {
  value = {
    for i, name in var.instance_names :
    name => openstack_compute_instance_v2.kubernetes[i].access_ip_v4
  }
}
