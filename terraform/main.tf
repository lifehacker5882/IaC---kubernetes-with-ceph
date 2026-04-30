terraform {
  #backend "http" {}
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  cloud = "openstack" 
}

resource "openstack_compute_instance_v2" "kubernetes" {
  count           = length(var.instance_names)
  name            = var.instance_names[count.index]
  flavor_name     = "aem.4c8r.50g"
  image_id        = "414d4efa-e67d-43cc-b484-3d88817bcec1"
  key_pair        = "nahom_master_key"
  security_groups = ["default"]

  user_data = <<-EOF
    #cloud-config
    users:
      - default
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
          - ${var.ssh_public_key}
  EOF

  # Root disk (Disk 1)
  block_device {
    uuid                  = "414d4efa-e67d-43cc-b484-3d88817bcec1"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = 25
  }

  # Extra disk (Disk 2 - for Ceph/Rook)
  dynamic "block_device" {
    for_each = [1]
    content {
      source_type           = "blank"
      destination_type      = "volume"
      volume_size           = 25
      boot_index            = -1
      delete_on_termination = true
    }
  }

  network {
    name = "oslomet"
  }
}

# Denne blokken sørger for at IP-ene havner i hosts.ini automatisk
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../hosts.ini"
  content  = <<-EOT
[stacked]
node1 ansible_host=${openstack_compute_instance_v2.kubernetes[0].access_ip_v4}
node2 ansible_host=${openstack_compute_instance_v2.kubernetes[1].access_ip_v4}
node3 ansible_host=${openstack_compute_instance_v2.kubernetes[2].access_ip_v4}

[control]
node1
node2
node3

[workers]
node1
node2
node3

[all:vars]
ansible_user=ubuntu
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOT
}
