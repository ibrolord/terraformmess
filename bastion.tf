
resource "google_compute_address" "static" {
  name = "bastion-staticips-${var.var_company}"
  project = var.var_project
  region = var.region
}

resource "google_compute_instance_template" "instance_template_bas" {
    count = 1
    name = "bastion-${var.var_company}-${count.index+1}"
    description = "Autoscaling group for Bastion"
    region = var.region
    project = var.var_project
    tags = ["ssh", "bastion"]    

    labels = {
        environment = "security"
        tier = "bastion"
    }
    
    instance_description = "Bastion in autoscale"
    machine_type = var.bastion.machine_type
    
    scheduling {
        automatic_restart = true
        on_host_maintenance = "MIGRATE"
    }

    disk {
        source_image = var.bastion.ami
        auto_delete = true
        boot = true
    }

    disk {
        auto_delete = false
        disk_size_gb = "10"
        type = "PERSISTENT"
    }

    network_interface {
        #network = "default"
        subnetwork_project = var.var_project
        network = module.network.network_name
        subnetwork = "subnet-pub-re1"
        #subnetwork = module.network.subnets[0].subnet_name
        access_config {
            nat_ip = google_compute_address.static.address
        }
    }

    lifecycle {
        create_before_destroy = true
    }

    metadata = {
        foo = "bar"
    }

    service_account {
        scopes = ["userinfo-email", "compute-ro", "storage-ro"]    
    }

}


resource "google_compute_region_instance_group_manager" "instance_group_manager_bas" {
    name = "bastion-group-manager"
    version {
        instance_template = google_compute_instance_template.instance_template_bas[0].self_link
    }
    base_instance_name = "bastion-group-manager"
    region = var.region
    project = var.var_project
}


resource "google_compute_region_autoscaler" "autoscaler_bas" {
    name = "bastion-autoscaler"
    count = 1
    project = var.var_project
    region = var.region
    target = google_compute_region_instance_group_manager.instance_group_manager_bas.self_link

    autoscaling_policy {
        max_replicas = 1
        min_replicas = 1
        
        cooldown_period = 60
        
        cpu_utilization {
            target = "0.9"
        }
    }
}

## Things to add naybe
# Health Check