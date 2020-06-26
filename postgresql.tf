resource "google_compute_instance_template" "instance_template_ps" {
    count = 1

    name = "postgresqltemplate-${var.var_company}-${count.index+1}"
    description = "Stateful Managed Instance group for Postgresql"
    tags = ["backend", "postgresql"]    

    labels = {
        environment = "prod"
        tier = "backend"
    }
    
    instance_description = "Postgresql in Stateful Deployment"
    machine_type = var.postgresql.machine_type
    
    scheduling {
        automatic_restart = true
        on_host_maintenance = "MIGRATE"
    }

    disk {
        source_image = var.postgresql.ami
        auto_delete = true
        boot = true
    }

    disk {
        auto_delete = false
        disk_size_gb = var.postgresql.disk_size
        type = "PERSISTENT"
        device_name = "postgresql-persdisk-${var.var_company}"
    }

    network_interface {
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


resource "google_compute_region_instance_group_manager" "instance_group_manager_ps" {
    name = "postgresql-group-manager"
    count = 1

    version {
        instance_template = google_compute_instance_template.instance_template_ps[count.index].self_link
    }

    base_instance_name = "postgresql-group-manager"
    region = var.region
    project = var.var_project
    provider = google-beta

    update_policy {
        type                         = "OPPORTUNISTIC"
        instance_redistribution_type = "NONE"
        minimal_action               = "REPLACE"
        max_unavailable_fixed        = 0
        max_surge_fixed              = 3
        #min_ready_sec                = 50
    }


    target_size = var.postgresql.amount

    stateful_disk {
        #device_name = google_compute_instance_template.instance_template_ps.disk[0].device_name
        device_name = "postgresql-persdisk-${var.var_company}"
    }
}





# I know this violates the DRY principle, planning to refactor with For Each, and more dynamic loops.
# Also contemplating if to add this behind a load balancer or if this is a master / slave arhitecture