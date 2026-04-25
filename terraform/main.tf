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
	count				= length(var.instance_names)
	name				= var.instance_names[count.index]
	flavor_name			= "aem.4c8r.50g"
	
  image_id = "414d4efa-e67d-43cc-b484-3d88817bcec1"

  key_pair			= "master"
	security_groups		= ["default"]

	user_data = <<-EOF
		#cloud-config
		users:
			- default
			- name: ubuntu
			  sudo: ALL=(ALL) NOPASSWD:ALL
			  ssh_authorized_keys:
				- ${var.ssh_public_key}
	EOF

  # ephemeral voles
  block_device {
    uuid			= "414d4efa-e67d-43cc-b484-3d88817bcec1"
    source_type			= "image"
    destination_type		= "local"
    boot_index			= 0
    delete_on_termination	= true
    volume_size = 25
  }

  # extra disc 1 for all nodes
  dynamic "block_device" {
    for_each = [1]
    content {
      source_type		= "blank"
      destination_type		= "volume"
      volume_size		= 25
      boot_index		= -1
      delete_on_termination	= true
    }
  }

  # Extra disc 2 for all nodes
  dynamic "block_device" {
    for_each = [1]
    content {
      source_type = "blank"
      destination_type = "volume"
      volume_size = 25
      boot_index  = -1
      delete_on_termination = true
    }
  }

  network {
    name = "oslomet"
  }
}
