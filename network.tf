module "network" {
    source = "terraform-google-modules/network/google"
    version = "~> 2.3"

    project_id = var.var_project
    network_name = var.var_company
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name = "subnet-pub-re1"
            subnet_ip = var.re1_public_subnet[0]
            subnet_region = var.re1_public_subnet[1]
            subnet_flow_logs = "true"
            description = "This is the Public Subnet"
        },

        {
            subnet_name = "subnet-priv-re1"
            subnet_ip = var.re1_private_subnet[0]
            subnet_region = var.re1_private_subnet[1]
            subnet_private_access = "true"
            subnet_flow_logs = "true"
            description = "This is the Private Subnet"
        },

        {
            subnet_name = "subnet-priv-re2"
            subnet_ip = var.re2_private_subnet[0]
            subnet_region = var.re2_private_subnet[1]
            subnet_private_access = "true"
            subnet_flow_logs = "true"
            description = "This is the Private Subnet"
        },

        {
            subnet_name = "subnet-pub-re2"
            subnet_ip = var.re2_public_subnet[0]
            subnet_region = var.re2_public_subnet[1]
            subnet_flow_logs = "true"
            description = "This is the Public Subnet"
        },
    ]  

#    secondary_ranges = {
#        subnet-01 = []
#    }
}

# Route between Subnets (Next Hop to the internet)
module "network_routes" {
    source = "terraform-google-modules/network/google//modules/routes"
    version = "2.1.1"
    network_name = module.network.network_name
    project_id = var.var_project

    routes = [
        {
            name = "egress-internet"
            description = "Route through IGW to access internet"
            destination_range = "0.0.0.0/0"
            tags = "egress-intet"
            next_hop_internet = "true"
        },
    ]
}

# Create a Cloud Router to use with Cloud NAT
resource "google_compute_router" "router" {
  name    = "router-${var.var_company}"
  network = module.network.network_name 
  description = "Cloud Router to use with Cloud NAT"

  bgp {
    asn = 64514
  }
} 

# Create firewall to tags ssh https http icmp-subnet
module "re1-net-firewall" {
    source = "terraform-google-modules/network/google//modules/fabric-net-firewall"
    project_id = var.var_project
    network = module.network.network_name
    internal_ranges_enabled = true
    internal_ranges = [var.re1_private_subnet[0]]
    version = "~> 2.3.0"
}

# Add bastion firewall rule
resource "google_compute_firewall" "allow-bastion-ssh" {
    name = "${var.var_company}-fw-allow-bastion"
    network = module.network.network_name 
    description = "Allows Bastion tags communicate with Backend tags"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_tags = ["bastion"]
    target_tags = ["backend"]
}

# Add Cassandra firewall rule
resource "google_compute_firewall" "allow-cassandra-ssh" {
    name = "${var.var_company}-fw-allow-cassandra"
    network = module.network.network_name 
    description = "Allow communication within Cassandra cluster"

    allow {
        protocol = "tcp"
        ports = ["9042", "7002", "7000", "9160", "7001", "57311", "57312", "8080", "7199"]
    }
# List of Cassandra ports came from https://stackoverflow.com/questions/2359159/cassandra-port-usage-how-are-the-ports-used 
# ^^^ https://cassandra.apache.org/doc/latest/faq/index.html#what-ports

    allow {
        protocol = "icmp"
    }

    source_tags = ["cassandra"]
    target_tags = ["cassandra"]
}

# Add Postgresql firewall rule
resource "google_compute_firewall" "allow-postgresql-ssh" {
    name = "${var.var_company}-fw-allow-postgresql"
    network = module.network.network_name 
    description = "Allow Commuincation within Postgresql"

    allow {
        protocol = "tcp"
        ports = ["5432", "5433"]
    }

    source_tags = ["postgresql"]
    target_tags = ["postgresql"]
}

# Add Bastion Postgresql firewall rule egress (Needed for Ansible)
resource "google_compute_firewall" "allow-postgresql-egress" {
    name = "${var.var_company}-fw-allow-bastion-postgresql-egress"
    network = module.network.network_name 
    description = "Allow Postgresql make egress communications"

    allow {
        protocol = "tcp"
        ports = ["5432", "5433"]
    }

    direction = "EGRESS"

    target_tags = ["postgresql"]
    destination_ranges = [var.re1_private_subnet[0]]
}

# Add ElasticSearch firewall rule
resource "google_compute_firewall" "allow-elasticsearch-ssh" {
    name = "${var.var_company}-fw-allow-elasticsearch"
    network = module.network.network_name 
    description = "Allow communication within ES Cluster"

    allow {
        protocol = "tcp"
        ports = ["9300", "9200"]
    }

    source_tags = ["elasticsearch"]
    target_tags = ["elasticsearch"]
}

# External IP Address for Bastion
resource "google_compute_address" "static" {
  name = "bastion-staticips-${var.var_company}"
  description = "External IP pool for Bastion machine"
}

# Cloud NAT for only 
resource "google_compute_router_nat" "nat" {
  name                               = "cloudnat-${var.var_company}"
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = module.network.subnets_names[0]
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

