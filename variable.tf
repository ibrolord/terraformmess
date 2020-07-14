variable "var_project" {
        default = "otl-eng-core-share-ops"
    }

variable "backend_bucket" {
        default = "ot-core-share-terraform"
    }

variable "region" {
    default = "us-central1"
}

variable "var_env" {
        default = "dev"
    }

variable "var_company" { 
        default = "core-share"
    }

variable "re1_private_subnet" {
        type = list
        default = ["10.26.1.0/24", "us-central1", "us-central1-c"]
    }

variable "re1_public_subnet" {
        type = list
        default = ["10.26.2.0/24", "us-central1", "us-central1-c"]
    }

variable "re2_private_subnet" {
        type = list
        default = ["10.26.3.0/24", "us-east1", "us-east1-a"]
    }

variable "re2_public_subnet" {
        type = list
        default = ["10.26.4.0/24", "us-east1", "us-east1-b"]
    }

variable "postgresql" {
        type = map
        default = {
            ami = "ubuntu-os-cloud/ubuntu-1804-lts"
            machine_type = "n1-standard-16"
            ingress = ""
            egress = ""
            amount = "3"
            disk_size = "10"
        }
}

variable "cassandra" {
        type = map
        default = {
            ami = "ubuntu-os-cloud/ubuntu-1804-lts"
            machine_type = "n1-standard-16"
            ingress = ""
            egress = ""
            amount = "3" 
            disk_size = "50"
        }
}

variable "elasticsearch" {
        type = map
        default = {
            ami = "ubuntu-os-cloud/ubuntu-1804-lts"
            machine_type = "n1-standard-1"
            ingress = ""
            egress = ""
            amount = "3"
            disk_size = "10"
        }
}

variable "bastion" {
        type = map
        default = {
            ami = "ubuntu-os-cloud/ubuntu-1804-lts"
            machine_type = "n1-standard-2"
            addr_type = "EXTERNAL"
            ip_addr = "10.0.42.42"
            ingress = ""
            egress = ""
        }
}

variable "gke" {
    type = map
    default = {
        node_vers = "1.15.12-gke.6"
        release = "REGULAR"
        node_amt = 3
        node_max = 6
        machine_type = "n1-standard-2"
    }
}