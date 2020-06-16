provider "google" {
    credentials = file("~/terraform_account.json")
    region = var.region
    project = var.var_project
}

# VPC
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

# Route between Subnets
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
    project = var.var_project
    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_tags = ["bastion"]
    target_tags = ["backend"]
}
 

