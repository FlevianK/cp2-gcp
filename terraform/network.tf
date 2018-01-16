resource "google_compute_network" "cp2-network" {
  name = "${var.env_name}-cp2-network"
}

resource "google_compute_subnetwork" "cp2-private-subnetwork" {
  name = "${var.env_name}-cp2-private-subnetwork"
  region = "${var.region}"
  network = "${google_compute_network.cp2-network.self_link}"
  ip_cidr_range = "${var.ip_cidr_range}"
}

output "network_name" {
  value = "${google_compute_network.cp2-network.name}"
}

output "private_subnetwork_name" {
  value = "${google_compute_subnetwork.cp2-private-subnetwork.name}"
}