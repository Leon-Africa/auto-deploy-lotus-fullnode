terraform {
  required_providers {
    equinix = {
      source = "equinix/equinix"
    }
  }
}

# Credentials for Equinix Metal resources
provider "equinix" {
  #auth token
  ## client_id and client_secret can be omitted when the only
  ## Equinix service consumed are Equinix Metal resources
  # client_id     = "someEquinixAPIClientID"
  # client_secret = "someEquinixAPIClientSecret"
}

resource "equinix_metal_project" "project" {
  name            = "LotusFullNode"
  #organization_id = ""
}

resource "equinix_metal_device" "device" {
  hostname         = "tf-device"
  plan             = var.plan
  metro            = var.metro
  operating_system = var.os
  billing_cycle    = "hourly"
  project_id       = equinix_metal_project.project.id
  depends_on       = [equinix_metal_project_ssh_key.public_key]
}

resource "equinix_metal_project_ssh_key" "public_key" {
  name       = "terraform-rsa"
  public_key = chomp(tls_private_key.ssh_key_pair.public_key_openssh)
  project_id = equinix_metal_project.project.id
}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = chomp(tls_private_key.ssh_key_pair.private_key_pem)
  filename        = pathexpand(format("~/.ssh/%s", "equinix-metal-terraform-rsa"))
  file_permission = "0600"
}
