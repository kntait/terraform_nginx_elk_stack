#Terraform NGINX ELK - Docker Stack

This project uses Terraform to build and configure NGINX, Elasticsearch, Logstash and Kibana docker containers on a EC2 instance in AWS. 

NGINX by default uses S3 as backend and acts as a proxy for Kibana as well as authentication.
NGINX access logs are pipped to Logstash and then Elasticsearch, Kiban will then query Elasticsearch.

#Prerequisites:

Terraform 0.6.15

#Installation:

Before runnnig terraform update the following in the variables.tf file.

* variable "aws_region" { default = "<region>"} 1
* variable "aws_access_key" { default = "<access_key>" } 2
* variable "aws_secret_key" { default = "<secret_key" } 3

* // VPC 1
* variable "aws_vpc" { 2
*   default = { 3
*     "cidr_block"  = "<vpc-cidr>" 4
*   } 5
* } 6

* // Public and Private Subnets 1
* variable "aws_subnet_public" { 2
*   description = "VPC subnet aza" 3
*   default = { 4
*     "cidr_block"  = "<subnet cidr>" 5
*     "map_public_ip_on_launch" = "true" 6
*     "availability_zone" = "<az>" 7
*   } 8
* } 9

* variable "aws_key_pair" { default = "<Public SSH KEY>" } 1
* variable "aws_s3_bucket" { default = "<S3 Bucket>" } 2
* variable "aws_s3_bucket_region" { default = "<s3 region>" } 3
* variable "instance_type" { default = "<instance size>"} 4
* variable "ami_id" { default = "<ami>"} 5

When you have updated the above run:

**terraform apply**

**NOTE** - Provisioning time may differ - Please allow 5-10 minutes before attempting to access.

#Example Usage

To view the default static HTML page go to instance **<public ip>/test_page.html**

To access Kibana browse to instance **<public ip>:8080**, in the prompt type in the following default credentials:

**user: admin**
**password: admin**

Once logged in select Create to create a defaut index.

Change Kibana Nginx password:

Use htpasswd to generate a new password and then open stack_userdata_aws_main.sh.tpl and update file /opt/app/nginx/htpasswd


