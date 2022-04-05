#
# Create AWS instances for Jupyter lab and dask cluster
# Creates 
#   1 jupyter lab machine
#     - launches screen session looping to run jupyter lab
#   1 dask scheduler
#     - launches screen session looping to run dask-scheduler
#   n dask workers
#     - launches n workers looping in screen to run dask-worker with correct scheduler IP
#   all nodes are started in cluster placement group and have EFA and nitro networking.
#

#
# VPC 
#   - Find VPC and subnet to use based on VPC and subnet name tag parameters
#     this VPC should already have an internet gateway and a public subnet set to allow internet gateway ingress traffic from outside
#     to nodes with public IP (sshgw). There should also be a private subnet should with a nat gateway route attached to 
#     allow outgoing traffic to the Internet the nat gateway should be located on the subnet with the internet gateway.
#
data "aws_vpc" "current-vpc" {
   filter {
     name = "tag:Name"
     values = ["${var.AWS_VPC_NAME}"]
   }
}

data "aws_subnet" "current-subnet" {
  filter {
    name   = "tag:Name"
    values = ["${var.AWS_SUBNET_NAME}"]
  }
}

data "aws_subnet" "current-priv-subnet" {
  filter {
    name   = "tag:Name"
    values = ["${var.AWS_PRIV_SUBNET_NAME}"]
  }
}

data "aws_internet_gateway" "current-gw" {
  filter {
   name   = "attachment.vpc-id"
   values = ["${data.aws_vpc.current-vpc.id}"]
  }
}

data "aws_ami" "current-jlab-ami" {
  # owners = ["self"]
  owners = ["099720109477"]
  filter {
    name   = "name"
    values = ["${var.AWS_JLAB_AMI}"]
  }
}

data "aws_ec2_instance_type" "current-jlab-itype" {
  instance_type = "${var.AWS_JLAB_ITYPE}"
}

data "aws_ec2_instance_type" "current-dsched-itype" {
  instance_type = "${var.AWS_DSCHED_ITYPE}"
}

data "aws_ec2_instance_type" "current-sshgw-itype" {
  instance_type = "${var.AWS_SSHGW_ITYPE}"
}

# Get the key to use
data "aws_key_pair" "current-key-pair" {
  key_name = "${var.AWS_SSH_KEY_NAME}"
}

# Need to create PG
resource "aws_placement_group" "current-pg" {
  name = "${var.AWS_PG_NAME}"
  strategy = "cluster"
}

#  o create security groups
#  1. publicly accessible instances allow ssh
resource "aws_security_group" "ssh-allowed" {
    vpc_id = "${data.aws_vpc.current-vpc.id}"
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8888
        to_port = 8888
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "internal-allowed" {
    vpc_id = "${data.aws_vpc.current-vpc.id}"
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${data.aws_vpc.current-vpc.cidr_block}"]
    }
}

#  o create sshgw instance
resource "aws_instance" "current-sshgw-instance" {
  ami = data.aws_ami.current-jlab-ami.id
  instance_type = data.aws_ec2_instance_type.current-sshgw-itype.id
  # placement_group = resource.aws_placement_group.current-pg.id
  # the Public SSH key
  key_name = "${data.aws_key_pair.current-key-pair.key_name}"
  associate_public_ip_address = true
  subnet_id       = data.aws_subnet.current-subnet.id
  security_groups = ["${resource.aws_security_group.ssh-allowed.id}",
                     "${resource.aws_security_group.internal-allowed.id}"
                    ]
  root_block_device {
   volume_size = 20
  }
  user_data = "${file("user-data.web")}"
}

output "sshgwip" {
       value=resource.aws_instance.current-sshgw-instance.public_ip
       description="sshgw ip ="
}

output "sshgwid" {
       value=resource.aws_instance.current-sshgw-instance.id
       description="sshgw id ="
}

output "sshgwaz" {
       value=resource.aws_instance.current-sshgw-instance.availability_zone
       description="sshgw az ="
}

data "aws_route53_zone" "current-zone" {
       name="${var.HTTPS_SERVER_ZONE}"
}

resource "aws_route53_record" "current-arecord" {
     zone_id = data.aws_route53_zone.current-zone.zone_id
     name    = "${resource.aws_instance.current-sshgw-instance.id}.${resource.aws_instance.current-sshgw-instance.availability_zone}.${data.aws_route53_zone.current-zone.name}"
     type    = "A"
     ttl     = "60"
     records = ["${resource.aws_instance.current-sshgw-instance.public_ip}"]
}

output "cur-zone" {
       value=data.aws_route53_zone.current-zone
}

output "cur-url" {
       value=resource.aws_route53_record.current-arecord.name
}
