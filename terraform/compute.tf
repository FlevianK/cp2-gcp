resource "google_compute_backend_service" "cp2-website" {
  name = "${var.env_name}-cp2-lb"
  description = "the cp2 load balancer"
  port_name = "customhttp"
  protocol = "HTTP"
  enable_cdn = false

  backend {
    group = "${google_compute_instance_group_manager.cp2-app-server-group-manager.instance_group}"
  }
  health_checks = ["${google_compute_http_health_check.cp2-app-healthcheck.self_link}"]
}

resource "google_compute_instance_group_manager" "cp2-app-server-group-manager" {
  name = "${var.env_name}-cp2-app-server-group-manager"
  base_instance_name = "${var.env_name}-cp2-app-instance"
  instance_template = "${google_compute_instance_template.cp2-app-server-template.self_link}"
  zone = "${var.zone}"
  update_strategy = "NONE"
  target_size = 1
  
  named_port {
    name = "customhttp"
    port = 8080
  }

}

resource "google_compute_instance_template" "cp2-app-server-template" {
  name = "${var.env_name}-cp2-app-server-template"
  machine_type = "${var.machine_type}"
  region = "${var.region}"
  description = "Base template to create cp2 instances"
  instance_description = "Instance created from base template"
  depends_on = ["google_compute_subnetwork.cp2-private-subnetwork"]
  tags = ["${var.env_name}-cp2-app-server", "cp2-app-server"]



  network_interface {
    subnetwork =  "${var.env_name}-cp2-private-subnetwork"
    access_config {}
  }
  
  disk {
    source_image = "${var.cp2_disk_image}"
    auto_delete = true
    boot = true
    disk_type = "${var.cp2_disk_type}"
    disk_size_gb = "${var.cp2_disk_size}"
  }

  metadata {
    startup-script = "/home/cp2/start_cp2.sh"
    serial-port-enable = 1
	}

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_autoscaler" "cp2-app-autoscaler"{
  name = "${var.env_name}-cp2-app-autoscaler"
  zone = "${var.zone}"
  target = "${google_compute_instance_group_manager.cp2-app-server-group-manager.self_link}"
  autoscaling_policy = {
    max_replicas = "${var.max_instances}"
    min_replicas = "${var.min_instances}"
    cooldown_period = 60
    cpu_utilization {
      target = 0.7
   }
 }
}

resource "google_compute_http_health_check" "cp2-app-healthcheck"{
   name = "${var.env_name}-cp2-app-healthcheck"
   port = 8080
   request_path = "${var.request_path}"
   check_interval_sec = "${var.check_interval_sec}"
   timeout_sec = "${var.timeout_sec}"
   unhealthy_threshold = "${var.unhealthy_threshold}"
   healthy_threshold = "${var.healthy_threshold}"
} 
