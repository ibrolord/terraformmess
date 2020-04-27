provider "aws" {
    region = "us-east-1"
    profile = "coresign-europe"
}

resource "aws_instance" "test" {
    ami = "ami-2757f631"
    instance_type = "t2.micro"
    
    tags = {
        Name = "terraform-test"
    }
}
