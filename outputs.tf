// Output VPC details

output "vpc_id" {
  value = "${aws_vpc.vpc_demo.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.vpc_demo.cidr_block}"
}

output "public_subnet" {
  value = "${aws_subnet.public_sub.id}"
}

output "public_route_table_id" {
  value = "${aws_route_table.public_rtb.id}"
}


// Output the ID of the EC2 instance created


output "ec2_server_101_private_adddress" { value = "${aws_instance.server_1.private_ip}" }

output "ec2_server_101_public_adddress" { value = "${aws_instance.server_1.public_ip}" }

