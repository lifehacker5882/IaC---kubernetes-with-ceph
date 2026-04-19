terraform {
  #backend "http" {}
        required_providers {
                openstack = {
                        source = "terraform-provider-openstack/openstack"
                }
        }
}

provider "openstack" {
        cloud = "openstack" # defined in ~/.config/openstack/clouds.yaml
}

resource "openstack_compute_instance_v2" "kubernetes" {
  count		  = 6
  name		  = var.instance_names[count.index]
  flavor_name     = "aem.2c2r.50g"
  key_pair        = "master"
  security_groups = ["default"]

  user_data = <<-EOF
    users:
      - default
      - name: ubuntu
	sudo: ALL=(ALL) NOPASSWD:ALL
	ssh_authorized_keys:
	  - ${var.ssh_public_key}
  EOF

  block_device {
    uuid                  = "414d4efa-e67d-43cc-b484-3d88817bcec1"
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = 25
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    name = "oslomet"
  }
}
