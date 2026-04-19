variable "instance_names" {
	type		= list(string)
	default		= ["control1", "control2", "control3", "worker1", "worker2", "worker3"]
}

variable "ssh_public_key" {
	description	= "public key from master"
	type		= string
	default		= "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBC8GzumXpv9/G5SdKEnjLN/GSjNpmEX6rINRkEza+z ubuntu@master"
}
