//Variables

//////////////////////// VPC General /////////////////////////////////
variable "aws_region" { default = "<region>"}
variable "aws_access_key" { default = "<access key>" }
variable "aws_secret_key" { default = "<secret key>" }

// VPC
variable "aws_vpc" {
  default = {
    "cidr_block"  = "<vpc cidr>"
  }
}
variable "vpc_tags" {
  default = { 
    Name = "VPC_DEMO"
  }
}

// Public and Private Subnets
variable "aws_subnet_public" {
  description = "VPC subnet aza"
  default = {
    "cidr_block"  = "<subnet cidr>"
    "map_public_ip_on_launch" = "true"
    "availability_zone" = "<az>"
  }
}
variable "public_sub_tags" {
  default = { 
    Name = "SUB_DEMO_T1_PUB_A"
  }
}


// Internet gateway and NAT
variable "igw_tags" {
  default = { 
    Name = "IGW_DEMO"
  }
}


// Public and Private Route Tables
variable "public_route_1" {
  description = "Public route table routes"
  default = {
    "cidr_block"  = "0.0.0.0/0"
  }
}
variable "public_rtb_tags" {
  default = { 
    Name = "RT_DEMO_T1_PUB_A_B"
  }
}


// ACL Public Ingress
variable "acl_public_tier_ingress_protocol10" { default    = "tcp"}
variable "acl_public_tier_ingress_rule_no10" { default     = "10"}
variable "acl_public_tier_ingress_action10" { default      = "allow"}
variable "acl_public_tier_ingress_cidr_block10" { default  = "0.0.0.0/0"}
variable "acl_public_tier_ingress_from_port10" { default   = "80"}
variable "acl_public_tier_ingress_to_port10" { default     = "80"}

variable "acl_public_tier_ingress_protocol20" { default    = "tcp"}
variable "acl_public_tier_ingress_rule_no20" { default     = "20"}
variable "acl_public_tier_ingress_action20" { default      = "allow"}
variable "acl_public_tier_ingress_cidr_block20" { default  = "0.0.0.0/0"}
variable "acl_public_tier_ingress_from_port20" { default   = "1024"}
variable "acl_public_tier_ingress_to_port20" { default     = "65535"}

// ACL Public Egress
variable "acl_public_tier_egress_protocol10" { default     = "-1"}
variable "acl_public_tier_egress_rule_no10" { default      = "10"}
variable "acl_public_tier_egress_action10" { default       = "allow"}
variable "acl_public_tier_egress_cidr_block10" { default   = "0.0.0.0/0"}
variable "acl_public_tier_egress_from_port10" { default    = "0"}
variable "acl_public_tier_egress_to_port10" { default      = "0"}

variable "public_tier_acl" { 
  default = { 
    Name = "ACL_DEM0_T1_PUB" 
  }
}

variable "aws_key_pair_name" { default = "kp_demo" }
variable "aws_key_pair" { default = "<public key>" }

variable "aws_s3_bucket" { default = "<s3 bucket>" }
variable "aws_s3_bucket_acl" { default = "private" }
variable "aws_s3_bucket_tag" { default = "<s3 bucket tag>" }
variable "aws_s3_bucket_region" { default = "<bucket region>" }

variable "aws_s3_bucket_object_key" { default = "test_page.html" }
variable "aws_s3_bucket_object_source" { default = "test_page.html" }
variable "aws_s3_bucket_object_content_type" { default = "text/html" }

//////////////////////// EC2 General /////////////////////////////////
variable "number_of_instances" { default = 1}
variable "name_prefix_category" { 
  default {
    "server" = "docapp"
  } 
}
variable "project" { default = "sbx"}
variable "name_suffix_aza" { default = "a01"}
variable "operating_system" { default = "r"}
variable "instance_type" { default = "<instace type>"}
// Recommended AMI ami-e0c19f83
variable "ami_id" { default = "<ami>"}

// EC2 Storage 
variable "root_volume_type" { default = "gp2"}
variable "root_volume_size" { default = "50"}
variable "root_volume_delete_on_termination" { default = "true"}

// SG Server Ingress
variable "sg-demo-server_ingress_from_port10" { default   = "80"}
variable "sg-demo-server_ingress_to_port10" { default     = "80"}
variable "sg-demo-server_ingress_protocol10" { default    = "tcp"}
variable "sg-demo-server_ingress_cider_block10" { default = "0.0.0.0/0"}

variable "sg-demo-server_ingress_from_port20" { default   = "8080"}
variable "sg-demo-server_ingress_to_port20" { default     = "8080"}
variable "sg-demo-server_ingress_protocol20" { default    = "tcp"}
variable "sg-demo-server_ingress_cider_block20" { default = "0.0.0.0/0"}

// SG Server Egress
variable "sg-demo-server_egress_from_port10" { default   = "0"}
variable "sg-demo-server_egress_to_port10" { default     = "0"}
variable "sg-demo-server_egress_protocol10" { default    = "-1"}
variable "sg-demo-server_egress_cider_block10" { default = "0.0.0.0/0"}



