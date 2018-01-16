google_project_id = "cp2-document-management-system" 
region  = "europe-west1" 
zone = "europe-west1-b"
cp2_disk_image = "flevian-cp-image-javascript-1516094385" 
machine_type = "n1-standard-1" 
env_name = "development"
ip_cidr_range = "10.0.0.0/24"
max_instances = 2
min_instances = 1
healthy_threshold = 1
unhealthy_threshold = 5
timeout_sec = 3
check_interval_sec = 5
request_path = "/"
vof_disk_size = 10
vof_disk_type = "pd-ssd"
bucket = "cp2-flevian"
