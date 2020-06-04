resource "google_compute_instance_template" "instance_template_cas" {
    count = 1
    name = "cassandra-${var.var_company}-${count.index+1}"
    description = "Autoscaling group for cassandra"
    region = var.region
    project = var.var_project
    tags = ["backend", "cassandra"]    

    labels = {
        environment = "prod"
        tier = "backend"
    }
    
    instance_description = "Cassandra in autoscale"
    machine_type = var.cassandra.machine_type
    
    scheduling {
        automatic_restart = true
        on_host_maintenance = "MIGRATE"
    }

    disk {
        source_image = var.cassandra.ami
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
        subnetwork = "subnet-priv-re1"
        #subnetwork = module.network.subnets[0].subnet_name
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


resource "google_compute_region_instance_group_manager" "instance_group_manager_cas" {
    name = "cassandra-group-manager"
    version {
        instance_template = google_compute_instance_template.instance_template_cas[0].self_link
    }
    base_instance_name = "cassandra-group-manager"
    region = var.region
    project = var.var_project
}


resource "google_compute_region_autoscaler" "autoscaler_cas" {
    name = "cassandra-autoscaler"
    count = 1
    project = var.var_project
    region = var.region
    target = google_compute_region_instance_group_manager.instance_group_manager_cas.self_link

    autoscaling_policy {
        max_replicas = 5
        min_replicas = 5
        
        cooldown_period = 60
        
        cpu_utilization {
            target = "0.9"
        }
    }
}

