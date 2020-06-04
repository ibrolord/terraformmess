variable "var_project" {
        default = "ibrobaba"
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
            ami = "ubuntu-os-cloud/ubuntu-1604-lts"
            machine_type = "f1-micro"
            ingress = ""
            egress = ""
        }
}

variable "cassandra" {
        type = map
        default = {
            ami = "ubuntu-os-cloud/ubuntu-1604-lts"
            machine_type = "f1-micro"
            ingress = ""
            egress = ""
        }
}

variable "elasticsearch" {
        type = map
        default = {
            ami = "ubuntu-os-cloud/ubuntu-1604-lts"
            machine_type = "f1-micro"
            ingress = ""
            egress = ""
        }
}
