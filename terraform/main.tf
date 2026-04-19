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
	count				= 6
	name				= var.instance_names[count.index]
	flavor_name			= "aem.2c2r.50g"
	
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

  # ingen volume kvoter brukes
  block_device {
    uuid			= "414d4efa-e67d-43cc-b484-3d88817bcec1"
    source_type			= "image"
    destination_type		= "local"
    boot_index			= 0
    delete_on_termination	= true
    volume_size = 25
  }

  # deler ekstra disk 1 til worker (basert på variables.tf sin rekkefølge)
  # runde 0-2 = control... 3-5 = worker
  # count.index > 2 = ? [1] : [] = ternary operation, hvis 3,4,5 return list [1]
  # er tallet høyere enn 2? hvis ja returner listen som ikke ertom, da vil dynamic "block_device" kjøre
  dynamic "block_device" {
    for_each = count.index > 2 ? [1] : []
    content {
      source_type		= "blank"
      destination_type		= "volume"
      volume_size		= 25
      boot_index		= -1
      delete_on_termination	= true
    }
  }

  # Ekstra disk 2 for workers
  dynamic "block_device" {
    for_each = count.index > 2 ? [1] : []
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
