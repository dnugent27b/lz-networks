#
# VPC
#
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
resource "aws_vpc" "sandbox-us-east-1-1" {
  cidr_block       = "172.16.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "sandbox-us-east-1-1"
  }
}

#
# Send VPC flow logs shared log archive account
#
resource "aws_flow_log" "sandbox-us-east-1-1" {
  count = var.enable_flow_logs ? 1 : 0

  log_destination      = var.s3_vpc_flow_logs_bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.sandbox-us-east-1-1.id

  tags = {
    Name = "sandbox-us-east-1-1"
  }
}

#
# Lock down default security group
#
resource "aws_default_security_group" "sandbox-us-east-1-1-default" {
  vpc_id = aws_vpc.sandbox-us-east-1-1.id
  tags = {
    Name = "sandbox-us-east-1-1-default"
  }
}

#
# IGW
#
resource "aws_internet_gateway" "sandbox-us-east-1-1" {
  vpc_id = aws_vpc.sandbox-us-east-1-1.id
  tags = {
    Name = "sandbox-us-east-1-1"
  }
}
resource "aws_route_table" "sandbox-us-east-1-1-igw" {
  vpc_id = aws_vpc.sandbox-us-east-1-1.id
  tags = {
    Name = "sandbox-us-east-1-1-igw"
  }
}
resource "aws_route_table_association" "sandbox-us-east-1-1-igw" {
  gateway_id     = aws_internet_gateway.sandbox-us-east-1-1.id
  route_table_id = aws_route_table.sandbox-us-east-1-1-igw.id
}

#
# Workload Public and Private route tables
#
resource "aws_route_table" "sandbox-us-east-1-1-public" {
  vpc_id = aws_vpc.sandbox-us-east-1-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sandbox-us-east-1-1.id
  }
  tags = {
    Name = "sandbox-us-east-1-1-public"
  }
}
resource "aws_route_table" "sandbox-us-east-1-1-private" {
  vpc_id = aws_vpc.sandbox-us-east-1-1.id
  tags = {
    Name = "sandbox-us-east-1-1-private"
  }
}

#
# NAT GW - just one AZ in sandbox
#
resource "aws_subnet" "sandbox-us-east-1-1-ngw-use1-az1" {
  vpc_id               = aws_vpc.sandbox-us-east-1-1.id
  cidr_block           = "172.16.2.0/28"
  availability_zone_id = "use1-az1"
  tags = {
    Name = "sandbox-us-east-1-1-ngw-use1-az1"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-1-1-ngw-use1-az1" {
  network_acl_id = aws_network_acl.sandbox-us-east-1-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-1-1-ngw-use1-az1.id
}
resource "aws_route_table" "sandbox-us-east-1-1-ngw" {
  vpc_id = aws_vpc.sandbox-us-east-1-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sandbox-us-east-1-1.id
  }
  tags = {
    Name = "sandbox-us-east-1-1-ngw"
  }
}
resource "aws_route_table_association" "sandbox-us-east-1-1-ngw-use-az1" {
  subnet_id      = aws_subnet.sandbox-us-east-1-1-ngw-use1-az1.id
  route_table_id = aws_route_table.sandbox-us-east-1-1-ngw.id
}
resource "aws_eip" "nat_gateway" {
  count = var.enable_ngw ? 1 : 0
  vpc   = true

  tags = {
    Name = "sandbox-us-east-1-1-ngw"
  }

}
resource "aws_nat_gateway" "nat_gateway" {
  count = var.enable_ngw ? 1 : 0

  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id     = aws_subnet.sandbox-us-east-1-1-ngw-use1-az1.id

  tags = {
    Name = "sandbox-us-east-1-1"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.sandbox-us-east-1-1]
}
resource "aws_route" "nat_gateway" {
  count = var.enable_ngw ? 1 : 0

  route_table_id         = aws_route_table.sandbox-us-east-1-1-private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}

#
# S3 gateway endpoint in NAT egress VPC
#
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.sandbox-us-east-1-1.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.us-east-1.s3"
  route_table_ids   = [aws_route_table.sandbox-us-east-1-1-ngw.id]

  tags = {
    Name = "sandbox-us-east-1-1-s3"
  }
}

#
# firewall ingress subnets and route table - 1 AZ in sandbox
#
resource "aws_subnet" "sandbox-us-east-1-1-firewall-ingress-use1-az1" {
  vpc_id               = aws_vpc.sandbox-us-east-1-1.id
  cidr_block           = "172.16.0.0/28"
  availability_zone_id = "use1-az1"
  tags = {
    Name = "sandbox-us-east-1-1-firewall-ingress-use1-az1"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-1-1-firewall-ingress-use1-az1" {
  network_acl_id = aws_network_acl.sandbox-us-east-1-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-1-1-firewall-ingress-use1-az1.id
}
resource "aws_route_table" "sandbox-us-east-1-1-firewall-ingress" {
  vpc_id = aws_vpc.sandbox-us-east-1-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sandbox-us-east-1-1.id
  }
  tags = {
    Name = "sandbox-us-east-1-1-firewall-ingress"
  }
}
resource "aws_route_table_association" "sandbox-us-east-1-1-firewall-ingress-use-az1" {
  subnet_id      = aws_subnet.sandbox-us-east-1-1-firewall-ingress-use1-az1.id
  route_table_id = aws_route_table.sandbox-us-east-1-1-firewall-ingress.id
}

#
# NACLs
#
resource "aws_network_acl" "sandbox-us-east-1-1-default" {
  #checkov:skip=CKV2_AWS_1:Ensure that all NACL are attached to subnets
  #checkov:skip=CKV_AWS_229:Ensure no NACL allow ingress from 0.0.0.0:0 to port 21
  #checkov:skip=CKV_AWS_230:Ensure no NACL allow ingress from 0.0.0.0:0 to port 20
  #checkov:skip=CKV_AWS_231:Ensure no NACL allow ingress from 0.0.0.0:0 to port 3389
  #checkov:skip=CKV_AWS_232:Ensure no NACL allow ingress from 0.0.0.0:0 to port 22
  vpc_id = aws_vpc.sandbox-us-east-1-1.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "sandbox-us-east-1-1-default"
  }
}

#
# firewall egress subnets and route table - 1 AZ for sandbox
#
resource "aws_subnet" "sandbox-us-east-1-1-firewall-egress-use1-az1" {
  vpc_id               = aws_vpc.sandbox-us-east-1-1.id
  cidr_block           = "172.16.64.0/28"
  availability_zone_id = "use1-az1"
  tags = {
    Name = "sandbox-us-east-1-1-firewall-egress-use1-az1"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-1-1-firewall-egress-use1-az1" {
  network_acl_id = aws_network_acl.sandbox-us-east-1-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-1-1-firewall-egress-use1-az1.id
}
resource "aws_route_table" "sandbox-us-east-1-1-firewall-egress" {
  vpc_id = aws_vpc.sandbox-us-east-1-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sandbox-us-east-1-1.id
  }
  tags = {
    Name = "sandbox-us-east-1-1-firewall-egress"
  }
}
resource "aws_route_table_association" "sandbox-us-east-1-1-firewall-egress-use-az1" {
  subnet_id      = aws_subnet.sandbox-us-east-1-1-firewall-egress-use1-az1.id
  route_table_id = aws_route_table.sandbox-us-east-1-1-firewall-egress.id
}

#
# Resources for Workloads
#
resource "aws_subnet" "sandbox-us-east-1-1-shared-public-use1-az1" {
  vpc_id               = aws_vpc.sandbox-us-east-1-1.id
  cidr_block           = "172.16.16.0/20"
  availability_zone_id = "use1-az1"
  tags = {
    Name = "sandbox-us-east-1-1-shared-public-use1-az1"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-1-1-shared-public-use1-az1" {
  network_acl_id = aws_network_acl.sandbox-us-east-1-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-1-1-shared-public-use1-az1.id
}
resource "aws_subnet" "sandbox-us-east-1-1-shared-private-use1-az1" {
  vpc_id               = aws_vpc.sandbox-us-east-1-1.id
  cidr_block           = "172.16.80.0/20"
  availability_zone_id = "use1-az1"
  tags = {
    Name = "sandbox-us-east-1-1-shared-private-use1-az1"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-1-1-shared-private-use1-az1" {
  network_acl_id = aws_network_acl.sandbox-us-east-1-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-1-1-shared-private-use1-az1.id
}
resource "aws_subnet" "sandbox-us-east-1-1-shared-public-use1-az2" {
  vpc_id               = aws_vpc.sandbox-us-east-1-1.id
  cidr_block           = "172.16.32.0/20"
  availability_zone_id = "use1-az2"
  tags = {
    Name = "sandbox-us-east-1-1-shared-public-use1-az2"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-1-1-shared-public-use1-az2" {
  network_acl_id = aws_network_acl.sandbox-us-east-1-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-1-1-shared-public-use1-az2.id
}
resource "aws_subnet" "sandbox-us-east-1-1-shared-private-use1-az2" {
  vpc_id               = aws_vpc.sandbox-us-east-1-1.id
  cidr_block           = "172.16.96.0/20"
  availability_zone_id = "use1-az2"
  tags = {
    Name = "sandbox-us-east-1-1-shared-private-use1-az2"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-1-1-shared-private-use1-az2" {
  network_acl_id = aws_network_acl.sandbox-us-east-1-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-1-1-shared-private-use1-az2.id
}

resource "aws_route_table_association" "sandbox-us-east-1-1-shared-public-use-az1" {
  subnet_id      = aws_subnet.sandbox-us-east-1-1-shared-public-use1-az1.id
  route_table_id = aws_route_table.sandbox-us-east-1-1-public.id
}
resource "aws_route_table_association" "sandbox-us-east-1-1-shared-private-use-az1" {
  subnet_id      = aws_subnet.sandbox-us-east-1-1-shared-private-use1-az1.id
  route_table_id = aws_route_table.sandbox-us-east-1-1-private.id
}
resource "aws_route_table_association" "sandbox-us-east-1-1-shared-public-use-az2" {
  subnet_id      = aws_subnet.sandbox-us-east-1-1-shared-public-use1-az2.id
  route_table_id = aws_route_table.sandbox-us-east-1-1-public.id
}
resource "aws_route_table_association" "sandbox-us-east-1-1-shared-private-use-az2" {
  subnet_id      = aws_subnet.sandbox-us-east-1-1-shared-private-use1-az2.id
  route_table_id = aws_route_table.sandbox-us-east-1-1-private.id
}