provider "google" {
  credentials = "${file("service_account.json")}"
  project     = "cp2-document-management-system"
  region      = "${var.region}"
}
terraform {
  backend "gcs" {
    bucket = "cp2-flevian"
    path ="/staging-state/terraform.tfstate"
    project = "cp2-document-management-system"
    credentials = "service_account.json"
  }
}

data "terraform_remote_state" "cp2" {
  backend = "gcs"
  config {
    bucket = "cp2-flevian"
    path = "${var.state_path}"
    project = "cp2-document-management-system"
    credentials = "${file("service_account.json")}"
  }
}