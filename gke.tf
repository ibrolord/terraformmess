resource "google_container_cluster" "primary" {
    name     = "gke-cluster-${var.var_company}"
    location = var.region

    # We can't create a cluster with no node pool defined, but we want to only use
    # separately managed node pools. So we create the smallest possible default
    # node pool and immediately delete it.
    remove_default_node_pool = true
    initial_node_count       = 1
    provider = google-beta
    network = "core-share"
    subnetwork = "subnet-priv-re1"
    min_master_version = var.gke.node_vers
    logging_service    = "logging.googleapis.com/kubernetes"
    monitoring_service = "monitoring.googleapis.com/kubernetes"

    release_channel {
        channel = var.gke.release
    }

    addons_config {

        http_load_balancing {
            disabled = false
        }

        horizontal_pod_autoscaling {
            disabled = false
        }

        istio_config {
            disabled = false
            auth = "AUTH_MUTUAL_TLS"
        }
    }

    vertical_pod_autoscaling {
        enabled = true
    }

    cluster_autoscaling {
        enabled = true
        resource_limits {
            resource_type = "memory"
            minimum = var.gke.min_res_mem
            maximum = var.gke.max_res_cpu   
            }

        resource_limits {
            resource_type = "cpu"
            minimum = var.gke.min_res_cpu
            maximum = var.gke.max_res_cpu
            }

        }
    
    timeouts {
        create = "30m"
        update = "40m"
        delete = "60m"
    }

    master_auth {
        username = ""
        password = ""

    client_certificate_config {
        issue_client_certificate = false
        }
    }
}

resource "google_container_node_pool" "primary_nodes" {
    name       = "gke-node-${var.var_company}"
    location   = var.region
    cluster    = google_container_cluster.primary.name
    node_count = var.gke.node_amt

    autoscaling {
        min_node_count = var.gke.node_amt
        max_node_count = var.gke.node_max
    }

    node_config {
        preemptible  = true
        machine_type = var.gke.machine_type
        oauth_scopes = [
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/service.management.readonly",
            "https://www.googleapis.com/auth/trace.append"

        ]

        labels = {
            environment = "prod"
            tier = "container-cluster"
        }


        tags = ["gke", "application"]



        metadata = {
          disable-legacy-endpoints = "true"
        }
 
  }
}

