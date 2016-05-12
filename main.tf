// Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

// VPC
resource "aws_vpc" "vpc_demo" {
  cidr_block = "${var.aws_vpc.cidr_block}"
  tags {
    Name     = "${lookup(var.vpc_tags,"Name")}"
  }
}

// Public and Private Subnets
resource "aws_subnet" "public_sub" {
  vpc_id                  = "${aws_vpc.vpc_demo.id}"
  cidr_block              = "${var.aws_subnet_public.cidr_block}"
  map_public_ip_on_launch = "${var.aws_subnet_public.map_public_ip_on_launch}"
  availability_zone       = "${var.aws_subnet_public.availability_zone}"
  tags {
    Name                  = "${lookup(var.public_sub_tags,"Name")}"
    VPC                   = "${lookup(var.vpc_tags,"Name")}"
  }
}

// Internet gateway 
resource "aws_internet_gateway" "igw_demo" {
  vpc_id = "${aws_vpc.vpc_demo.id}"
  tags {
    Name = "${lookup(var.igw_tags,"Name")}"
    VPC  = "${lookup(var.vpc_tags,"Name")}"
  }
}

// Route Tables
resource "aws_route_table" "public_rtb" {
  vpc_id       = "${aws_vpc.vpc_demo.id}"
  route {
    cidr_block = "${lookup(var.public_route_1,"cidr_block")}"
    gateway_id = "${aws_internet_gateway.igw_demo.id}"
  }
  tags {
    Name       = "${lookup(var.public_rtb_tags,"Name")}"
    VPC        = "${lookup(var.vpc_tags,"Name")}"
  }
}



//Route table association
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = "${aws_subnet.public_sub.id}"
  route_table_id = "${aws_route_table.public_rtb.id}"
}


// Create ACL Public
resource "aws_network_acl" "acl_public_tier" {
  vpc_id       = "${aws_vpc.vpc_demo.id}"
  subnet_ids   = ["${aws_subnet.public_sub.id}"]
  ingress {
    protocol   = "${var.acl_public_tier_ingress_protocol10}"
    rule_no    = "${var.acl_public_tier_ingress_rule_no10}"
    action     = "${var.acl_public_tier_ingress_action10}"
    cidr_block = "${var.acl_public_tier_ingress_cidr_block10}"
    from_port  = "${var.acl_public_tier_ingress_from_port10}"
    to_port    = "${var.acl_public_tier_ingress_to_port10}"
  }
  ingress {
    protocol   = "${var.acl_public_tier_ingress_protocol20}"
    rule_no    = "${var.acl_public_tier_ingress_rule_no20}"
    action     = "${var.acl_public_tier_ingress_action20}"
    cidr_block = "${var.acl_public_tier_ingress_cidr_block20}"
    from_port  = "${var.acl_public_tier_ingress_from_port20}"
    to_port    = "${var.acl_public_tier_ingress_to_port20}"
  }
  egress {
    protocol   = "${var.acl_public_tier_egress_protocol10}"
    rule_no    = "${var.acl_public_tier_egress_rule_no10}"
    action     = "${var.acl_public_tier_egress_action10}"
    cidr_block = "${var.acl_public_tier_egress_cidr_block10}"
    from_port  = "${var.acl_public_tier_egress_from_port10}"
    to_port    = "${var.acl_public_tier_egress_to_port10}"
  }
  tags {
    Name       = "${lookup(var.public_tier_acl,"Name")}"
    VPC        = "${lookup(var.vpc_tags,"Name")}"
  }
}

// Create key pair
resource "aws_key_pair" "kp_demo" {
  key_name = "${var.aws_key_pair_name}" 
  public_key = "${var.aws_key_pair}"
}

// Create s3 bucket
resource "aws_s3_bucket" "s3_test_bucket" {
    bucket = "${var.aws_s3_bucket}"
    acl = "${var.aws_s3_bucket_acl}"
    policy = "${template_file.s3_bucket_policy.rendered}"
    tags {
        Name = "${var.aws_s3_bucket_tag}"
    }
}

// Custom s3 policy
resource "template_file" "s3_bucket_policy" {
  template = "${file("s3_bucket_policy.tpl")}"
    vars {
      server_1_public_ip = "${aws_instance.server_1.public_ip}"
    }
}

// Upload file to s3
resource "aws_s3_bucket_object" "test_file" {
    bucket = "${var.aws_s3_bucket}"
    key = "${var.aws_s3_bucket_object_key}"
    source = "${var.aws_s3_bucket_object_source}"
    content_type = "${var.aws_s3_bucket_object_content_type}"
    depends_on = ["aws_s3_bucket.s3_test_bucket"]
}

//////////////////////////////////////// Server ///////////////////////////////////////////////////
resource "aws_instance" "server_1" {
  count                   = "${var.number_of_instances}"
  ami                     = "${var.ami_id}" 
  instance_type           = "${var.instance_type}"
  subnet_id               = "${aws_subnet.public_sub.id}"
  root_block_device {
    volume_type           = "${var.root_volume_type}"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "${var.root_volume_delete_on_termination}"
  }
  key_name                = "${aws_key_pair.kp_demo.id}"
  security_groups         = ["${aws_security_group.sg_demo_server.id}"]
  user_data               = "${template_file.stack_userdata.rendered}"
  tags {
    Name                  = "${lookup(var.name_prefix_category,"server")}-${var.project}${var.operating_system}${var.name_suffix_aza}"
  }
}

// Custom stack file userdata script
resource "template_file" "stack_userdata" {
  template = "${file("stack_userdata_aws_main.sh.tpl")}"
    vars {
      instance_name = "${lookup(var.name_prefix_category,"server")}-${var.project}${var.operating_system}${var.name_suffix_aza}"
      aws_s3_bucket = "${var.aws_s3_bucket}"
      aws_s3_bucket_region = "${var.aws_s3_bucket_region}"
    }
}

resource "aws_security_group" "sg_demo_server" {
  name = "SG_DEMO_SERVER_T1_PUB"
  vpc_id = "${aws_vpc.vpc_demo.id}"
  ingress {
      from_port = "${var.sg-demo-server_ingress_from_port10}"
      to_port = "${var.sg-demo-server_ingress_to_port10}"
      protocol = "${var.sg-demo-server_ingress_protocol10}"
      cidr_blocks = ["${var.sg-demo-server_ingress_cider_block10}"]
  }
  ingress {
      from_port = "${var.sg-demo-server_ingress_from_port20}"
      to_port = "${var.sg-demo-server_ingress_to_port20}"
      protocol = "${var.sg-demo-server_ingress_protocol20}"
      cidr_blocks = ["${var.sg-demo-server_ingress_cider_block20}"]
  }  
  egress {
      from_port = "${var.sg-demo-server_egress_from_port10}"
      to_port = "${var.sg-demo-server_egress_to_port10}"
      protocol = "${var.sg-demo-server_egress_protocol10}"
      cidr_blocks = ["${var.sg-demo-server_egress_cider_block10}"]
  }
  tags {
    Name = "SG_DEMO_SERVER_T1_PUB"
  }
}
