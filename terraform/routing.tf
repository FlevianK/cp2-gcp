resource "google_compute_global_address" "cp2-entrance-ip" {
  name = "${var.env_name}-cp2-entrance-ip"
}
 
resource "google_compute_global_forwarding_rule" "cp2-http" {
  name= "${var.env_name}-cp2-http"
  ip_address = "${google_compute_global_address.cp2-entrance-ip.address}"
  target = "${google_compute_target_http_proxy.cp2-http-proxy.self_link}"
  port_range = "80"
} 

resource "google_compute_target_http_proxy" "cp2-http-proxy" {
  name = "${var.env_name}-cp2-http-proxy"
  url_map = "${google_compute_url_map.cp2-http-url-map.self_link}"
}

resource "google_compute_url_map" "cp2-http-url-map" {
  name = "${var.env_name}-cp2-http-url-map"
  default_service = "${google_compute_backend_service.cp2-website.self_link}"

  host_rule {
    hosts = ["${google_compute_global_address.cp2-entrance-ip.address}"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.cp2-website.self_link}"

    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.cp2-website.self_link}"
    }
  }
}



resource "google_compute_firewall" "cp2-internal-firewall" {
  name = "${var.env_name}-cp2-internal-network"
  network = "${google_compute_network.cp2-network.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["0-65535"]
  }

  source_ranges = ["${var.ip_cidr_range}"]
}

resource "google_compute_firewall" "cp2-public-firewall" {
  name = "${var.env_name}-cp2-public-firewall"
  network = "${google_compute_network.cp2-network.name}"

  allow {
    protocol = "tcp"
    ports = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["${var.env_name}-cp2-lb"]
}

resource "google_compute_firewall" "cp2-allow-healthcheck-firewall" {
  name = "${var.env_name}-cp2-allow-healthcheck-firewall"
  network = "${google_compute_network.cp2-network.name}"

  allow {
    protocol = "tcp"
    ports = ["8080"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags = ["${var.env_name}-cp2-app-server", "cp2-app-server"]
}