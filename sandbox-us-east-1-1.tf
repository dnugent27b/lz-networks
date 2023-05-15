#
# VPC
#
#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
resource "aws_vpc" "sandbox-us-east-2-1" {
  cidr_block       = "172.16.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "sandbox-us-east-2-1"
  }
}

#
# Send VPC flow logs shared log archive account
#
resource "aws_flow_log" "sandbox-us-east-2-1" {
  count = var.enable_flow_logs ? 1 : 0

  log_destination      = "arn:aws:s3:::${var.s3_logs_bucket_name}"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.sandbox-us-east-2-1.id

  tags = {
    Name = "sandbox-us-east-2-1"
  }
}

#
# Lock down default security group
#
resource "aws_default_security_group" "sandbox-us-east-2-1-default" {
  vpc_id = aws_vpc.sandbox-us-east-2-1.id
  tags = {
    Name = "sandbox-us-east-2-1-default"
  }
}

#
# IGW
#
resource "aws_internet_gateway" "sandbox-us-east-2-1" {
  vpc_id = aws_vpc.sandbox-us-east-2-1.id
  tags = {
    Name = "sandbox-us-east-2-1"
  }
}
resource "aws_route_table" "sandbox-us-east-2-1-igw" {
  vpc_id = aws_vpc.sandbox-us-east-2-1.id
  tags = {
    Name = "sandbox-us-east-2-1-igw"
  }
}
resource "aws_route_table_association" "sandbox-us-east-2-1-igw" {
  gateway_id     = aws_internet_gateway.sandbox-us-east-2-1.id
  route_table_id = aws_route_table.sandbox-us-east-2-1-igw.id
}

#
# Workload Public and Private route tables
#
resource "aws_route_table" "sandbox-us-east-2-1-public" {
  vpc_id = aws_vpc.sandbox-us-east-2-1.id
  tags = {
    Name = "sandbox-us-east-2-1-public"
  }
}

resource "aws_route_table" "sandbox-us-east-2-1-private" {
  vpc_id = aws_vpc.sandbox-us-east-2-1.id
  tags = {
    Name = "sandbox-us-east-2-1-private"
  }
}

#
# NAT GW - just one AZ in sandbox
#
resource "aws_subnet" "sandbox-us-east-2-1-ngw-use1-az1" {
  vpc_id               = aws_vpc.sandbox-us-east-2-1.id
  cidr_block           = "172.16.2.0/28"
  availability_zone_id = "use1-az1"
  tags = {
    Name = "sandbox-us-east-2-1-ngw-use1-az1"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-2-1-ngw-use1-az1" {
  network_acl_id = aws_network_acl.sandbox-us-east-2-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-2-1-ngw-use1-az1.id
}
resource "aws_route_table" "sandbox-us-east-2-1-ngw" {
  vpc_id = aws_vpc.sandbox-us-east-2-1.id
  tags = {
    Name = "sandbox-us-east-2-1-ngw"
  }
}
resource "aws_route" "sandbox-us-east-2-1-ngw-to-internet" {
  route_table_id         = aws_route_table.sandbox-us-east-2-1-ngw.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sandbox-us-east-2-1.id
}

resource "aws_route_table_association" "sandbox-us-east-2-1-ngw-use-az1" {
  subnet_id      = aws_subnet.sandbox-us-east-2-1-ngw-use1-az1.id
  route_table_id = aws_route_table.sandbox-us-east-2-1-ngw.id
}
resource "aws_eip" "nat_gateway" {
  count = var.enable_ngw ? 1 : 0
  vpc   = true

  tags = {
    Name = "sandbox-us-east-2-1-ngw"
  }

}
resource "aws_nat_gateway" "nat_gateway" {
  count = var.enable_ngw ? 1 : 0

  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id     = aws_subnet.sandbox-us-east-2-1-ngw-use1-az1.id

  tags = {
    Name = "sandbox-us-east-2-1"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.sandbox-us-east-2-1]
}

#
# S3 gateway endpoint in fireall egress subnet route table
#
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.sandbox-us-east-2-1.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.us-east-2.s3"
  route_table_ids   = [aws_route_table.sandbox-us-east-2-1-private.id]

  tags = {
    Name = "sandbox-us-east-2-1-s3"
  }
}

#
# firewall ingress subnets and route table - 1 AZ in sandbox
#
resource "aws_subnet" "sandbox-us-east-2-1-firewall-ingress-use1-az1" {
  vpc_id               = aws_vpc.sandbox-us-east-2-1.id
  cidr_block           = "172.16.0.0/28"
  availability_zone_id = "use1-az1"
  tags = {
    Name = "sandbox-us-east-2-1-firewall-ingress-use1-az1"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-2-1-firewall-ingress-use1-az1" {
  network_acl_id = aws_network_acl.sandbox-us-east-2-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-2-1-firewall-ingress-use1-az1.id
}
resource "aws_route_table" "sandbox-us-east-2-1-firewall-ingress" {
  vpc_id = aws_vpc.sandbox-us-east-2-1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sandbox-us-east-2-1.id
  }
  tags = {
    Name = "sandbox-us-east-2-1-firewall-ingress"
  }
}
resource "aws_route_table_association" "sandbox-us-east-2-1-firewall-ingress-use-az1" {
  subnet_id      = aws_subnet.sandbox-us-east-2-1-firewall-ingress-use1-az1.id
  route_table_id = aws_route_table.sandbox-us-east-2-1-firewall-ingress.id
}

#
# NACLs
#
resource "aws_network_acl" "sandbox-us-east-2-1-default" {
  #checkov:skip=CKV2_AWS_1:Ensure that all NACL are attached to subnets
  #checkov:skip=CKV_AWS_229:Ensure no NACL allow ingress from 0.0.0.0:0 to port 21
  #checkov:skip=CKV_AWS_230:Ensure no NACL allow ingress from 0.0.0.0:0 to port 20
  #checkov:skip=CKV_AWS_231:Ensure no NACL allow ingress from 0.0.0.0:0 to port 3389
  #checkov:skip=CKV_AWS_232:Ensure no NACL allow ingress from 0.0.0.0:0 to port 22
  vpc_id = aws_vpc.sandbox-us-east-2-1.id

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
    Name = "sandbox-us-east-2-1-default"
  }
}

#
# firewall egress subnets and route table - 1 AZ for sandbox
#
resource "aws_subnet" "sandbox-us-east-2-1-firewall-egress-use1-az1" {
  vpc_id               = aws_vpc.sandbox-us-east-2-1.id
  cidr_block           = "172.16.64.0/28"
  availability_zone_id = "use1-az1"
  tags = {
    Name = "sandbox-us-east-2-1-firewall-egress-use1-az1"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-2-1-firewall-egress-use1-az1" {
  network_acl_id = aws_network_acl.sandbox-us-east-2-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-2-1-firewall-egress-use1-az1.id
}
resource "aws_route_table" "sandbox-us-east-2-1-firewall-egress" {
  vpc_id = aws_vpc.sandbox-us-east-2-1.id
  tags = {
    Name = "sandbox-us-east-2-1-firewall-egress"
  }
}
resource "aws_route" "sandbox-us-east-2-1-firewall-egress-to-internet" {
  count = var.enable_ngw ? 1 : 0

  route_table_id         = aws_route_table.sandbox-us-east-2-1-firewall-egress.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}

resource "aws_route_table_association" "sandbox-us-east-2-1-firewall-egress-use-az1" {
  subnet_id      = aws_subnet.sandbox-us-east-2-1-firewall-egress-use1-az1.id
  route_table_id = aws_route_table.sandbox-us-east-2-1-firewall-egress.id
}

#
# Resources for Workloads
#
resource "aws_subnet" "sandbox-us-east-2-1-shared-public-use1-az1" {
  vpc_id               = aws_vpc.sandbox-us-east-2-1.id
  cidr_block           = "172.16.16.0/20"
  availability_zone_id = "use1-az1"
  tags = {
    Name = "sandbox-us-east-2-1-shared-public-use1-az1"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-2-1-shared-public-use1-az1" {
  network_acl_id = aws_network_acl.sandbox-us-east-2-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-2-1-shared-public-use1-az1.id
}
resource "aws_subnet" "sandbox-us-east-2-1-shared-private-use1-az1" {
  vpc_id               = aws_vpc.sandbox-us-east-2-1.id
  cidr_block           = "172.16.80.0/20"
  availability_zone_id = "use1-az1"
  tags = {
    Name = "sandbox-us-east-2-1-shared-private-use1-az1"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-2-1-shared-private-use1-az1" {
  network_acl_id = aws_network_acl.sandbox-us-east-2-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-2-1-shared-private-use1-az1.id
}
resource "aws_subnet" "sandbox-us-east-2-1-shared-public-use1-az2" {
  vpc_id               = aws_vpc.sandbox-us-east-2-1.id
  cidr_block           = "172.16.32.0/20"
  availability_zone_id = "use1-az2"
  tags = {
    Name = "sandbox-us-east-2-1-shared-public-use1-az2"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-2-1-shared-public-use1-az2" {
  network_acl_id = aws_network_acl.sandbox-us-east-2-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-2-1-shared-public-use1-az2.id
}
resource "aws_subnet" "sandbox-us-east-2-1-shared-private-use1-az2" {
  vpc_id               = aws_vpc.sandbox-us-east-2-1.id
  cidr_block           = "172.16.96.0/20"
  availability_zone_id = "use1-az2"
  tags = {
    Name = "sandbox-us-east-2-1-shared-private-use1-az2"
  }
}
resource "aws_network_acl_association" "sandbox-us-east-2-1-shared-private-use1-az2" {
  network_acl_id = aws_network_acl.sandbox-us-east-2-1-default.id
  subnet_id      = aws_subnet.sandbox-us-east-2-1-shared-private-use1-az2.id
}

resource "aws_route_table_association" "sandbox-us-east-2-1-shared-public-use-az1" {
  subnet_id      = aws_subnet.sandbox-us-east-2-1-shared-public-use1-az1.id
  route_table_id = aws_route_table.sandbox-us-east-2-1-public.id
}
resource "aws_route_table_association" "sandbox-us-east-2-1-shared-private-use-az1" {
  subnet_id      = aws_subnet.sandbox-us-east-2-1-shared-private-use1-az1.id
  route_table_id = aws_route_table.sandbox-us-east-2-1-private.id
}
resource "aws_route_table_association" "sandbox-us-east-2-1-shared-public-use-az2" {
  subnet_id      = aws_subnet.sandbox-us-east-2-1-shared-public-use1-az2.id
  route_table_id = aws_route_table.sandbox-us-east-2-1-public.id
}
resource "aws_route_table_association" "sandbox-us-east-2-1-shared-private-use-az2" {
  subnet_id      = aws_subnet.sandbox-us-east-2-1-shared-private-use1-az2.id
  route_table_id = aws_route_table.sandbox-us-east-2-1-private.id
}

#
# RAM shares for other accounts
#
resource "aws_ram_resource_share" "subnets-shared-us-east-2" {
  name                      = "subnets-shared-sandbox-us-east-2-1"
  allow_external_principals = false
}
resource "aws_ram_resource_association" "sandbox-us-east-2-1-shared-public-use-az1" {
  resource_arn       = aws_subnet.sandbox-us-east-2-1-shared-public-use1-az1.arn
  resource_share_arn = aws_ram_resource_share.subnets-shared-us-east-2.arn
}
resource "aws_ram_resource_association" "sandbox-us-east-2-1-shared-public-use-az2" {
  resource_arn       = aws_subnet.sandbox-us-east-2-1-shared-public-use1-az2.arn
  resource_share_arn = aws_ram_resource_share.subnets-shared-us-east-2.arn
}
resource "aws_ram_resource_association" "sandbox-us-east-2-1-shared-private-use-az1" {
  resource_arn       = aws_subnet.sandbox-us-east-2-1-shared-private-use1-az1.arn
  resource_share_arn = aws_ram_resource_share.subnets-shared-us-east-2.arn
}
resource "aws_ram_resource_association" "sandbox-us-east-2-1-shared-private-use-az2" {
  resource_arn       = aws_subnet.sandbox-us-east-2-1-shared-private-use1-az2.arn
  resource_share_arn = aws_ram_resource_share.subnets-shared-us-east-2.arn
}
resource "aws_ram_principal_association" "subnets-shared-us-east-2-sandbox" {
  principal          = "673052121367"
  resource_share_arn = aws_ram_resource_share.subnets-shared-us-east-2.arn
}

data "aws_default_tags" "sandbox" {
  provider = aws.sandbox
}

# tag resources in the other accounts
resource "aws_ec2_tag" "vpc-sandbox-us-east-2-1" {
  provider    = aws.sandbox
  resource_id = aws_vpc.sandbox-us-east-2-1.id

  for_each = merge(data.aws_default_tags.sandbox.tags, tomap({ "Name" = "sandbox-us-east-2-1" }))
  key      = each.key
  value    = each.value

  depends_on = [aws_ram_resource_share.subnets-shared-us-east-2]
}
resource "aws_ec2_tag" "subnet-sandbox-us-east-2-1-shared-public-use1-az1" {
  provider    = aws.sandbox
  resource_id = aws_subnet.sandbox-us-east-2-1-shared-public-use1-az1.id

  for_each = merge(data.aws_default_tags.sandbox.tags, tomap({ "Name" = "sandbox-us-east-2-1-shared-public-use1-az1" }))
  key      = each.key
  value    = each.value

  depends_on = [aws_ram_resource_share.subnets-shared-us-east-2]
}
resource "aws_ec2_tag" "subnet-sandbox-us-east-2-1-shared-public-use1-az2" {
  provider    = aws.sandbox
  resource_id = aws_subnet.sandbox-us-east-2-1-shared-public-use1-az2.id

  for_each = merge(data.aws_default_tags.sandbox.tags, tomap({ "Name" = "sandbox-us-east-2-1-shared-public-use1-az2" }))
  key      = each.key
  value    = each.value

  depends_on = [aws_ram_resource_share.subnets-shared-us-east-2]
}
resource "aws_ec2_tag" "subnet-sandbox-us-east-2-1-shared-private-use1-az1" {
  provider    = aws.sandbox
  resource_id = aws_subnet.sandbox-us-east-2-1-shared-private-use1-az1.id

  for_each = merge(data.aws_default_tags.sandbox.tags, tomap({ "Name" = "sandbox-us-east-2-1-shared-private-use1-az1" }))
  key      = each.key
  value    = each.value

  depends_on = [aws_ram_resource_share.subnets-shared-us-east-2]
}
resource "aws_ec2_tag" "subnet-sandbox-us-east-2-1-shared-private-use1-az2" {
  provider    = aws.sandbox
  resource_id = aws_subnet.sandbox-us-east-2-1-shared-private-use1-az2.id

  for_each = merge(data.aws_default_tags.sandbox.tags, tomap({ "Name" = "sandbox-us-east-2-1-shared-private-use1-az2" }))
  key      = each.key
  value    = each.value

  depends_on = [aws_ram_resource_share.subnets-shared-us-east-2]
}
