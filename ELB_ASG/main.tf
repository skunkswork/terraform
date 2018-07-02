# __author__="Tong-alish"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE ALL THE RESOURCES TO DEPLOY AN APP IN AN AUTO SCALING GROUP WITH AN ELB
# This template runs a simple "Hello, World" web server in Auto Scaling Group (ASG) with an Elastic Load Balancer
# (ELB) in front of it to distribute traffic across the EC2 Instances in the ASG.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------
# AWS CONNECTION: configure the aws basic connection info
# ------------------------------------------------------------------------------

provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Get the list of AZ in the current region
# Every AWS accout has slightly different availability zones in each region. For example, one account might have
# us-east-1a, us-east-1b, and us-east-1c, while another will have us-east-1a, us-east-1b, and us-east-1d. This resource
# queries AWS to fetch the list for the current account and region.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "all" {}

# ---------------------------------------------------------------------------------------------------------------------
# AUTO SCALING GROUP: create the ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_group" "tara_aws_asg" {
  name_prefix = "Tara-Machine"
  launch_configuration = "${aws_launch_configuration.tara_launch_config.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  min_size = 2
  max_size = 15

  load_balancers = ["${aws_elb.tara_elb.name}"]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "Tara-Machine"
    propagate_at_launch = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LAUNCH CONFIGURATION: create a launch config that defines each ec2 in the ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "tara_launch_config" {
  # Ubuntu Server 14.04 LTS (HVM), SSD Volume Type in us-east-2
  image_id = "ami-7d132e18"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "<h2>Hello, Cloud gurus. Today is Friday!</h2><br /><img src='https://quotesblog.net/wp-content/uploads/2015/04/Hands-up-if-you-love-friday-quotes.jpg'>" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  # @@@Important note: whenever using a launch configuration with an auto scaling group, you must set
  # create_before_destroy = true. However, as soon as you set create_before_destroy = true in one resource, you must
  # also set it in every resource that it depends on, or you'll get an error about cyclic dependencies (especially when
  # removing resources). For more info, please see:
  #
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  # https://terraform.io/docs/configuration/resources.html

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ELASTIC LOAD BALANCER: create an ELB to route traffic across the ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_elb" "tara_elb" {
  name = "tara-asg"
  security_groups = ["${aws_security_group.elb.id}"]
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }

  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# SG: create the sg applied to each ec2 in the ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "instance" {
  name = "tara-ec2"

  # Inbound HTTP from anywhere
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP THAT CONTROLS WHAT TRAFFIC AN GO IN AND OUT OF THE ELB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "elb" {
  name = "tara-elb"

  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}