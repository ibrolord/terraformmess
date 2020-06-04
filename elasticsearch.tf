resource "google_compute_instance_template" "instance_template_es" {
    count = 1
    name = "elasticsearch-${var.var_company}-${count.index+1}"
    description = "Autoscaling group for Elasticsearch"
    region = var.region
    project = var.var_project
    tags = ["backend", "elasticsearch"]    

    labels = {
        environment = "prod"
        tier = "backend"
    }
    
    instance_description = "Elasticsearch in autoscale"
    machine_type = var.elasticsearch.machine_type
    
    scheduling {
        automatic_restart = true
        on_host_maintenance = "MIGRATE"
    }

    disk {
        source_image = var.elasticsearch.ami
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


resource "google_compute_region_instance_group_manager" "instance_group_manager_es" {
    name = "elasticsearch-group-manager"
    version {
        instance_template = google_compute_instance_template.instance_template_es[0].self_link
    }
    base_instance_name = "elasticsearch-group-manager"
    region = var.region
    project = var.var_project
}


resource "google_compute_region_autoscaler" "autoscaler_es" {
    name = "elasticsearch-autoscaler"
    count = 1
    project = var.var_project
    region = var.region
    target = google_compute_region_instance_group_manager.instance_group_manager_es.self_link

    autoscaling_policy {
        max_replicas = 5
        min_replicas = 5
        
        cooldown_period = 60
        
        cpu_utilization {
            target = "0.9"
        }
    }
}
