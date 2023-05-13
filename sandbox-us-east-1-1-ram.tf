#
# RAM shares for other accounts
#
resource "aws_ram_resource_share" "subnets-shared-us-east-1" {
  name                      = "subnets-shared-sandbox-us-east-1-1"
  allow_external_principals = false
}
resource "aws_ram_resource_association" "sandbox-us-east-1-1-shared-public-use-az1" {
  resource_arn       = aws_subnet.sandbox-us-east-1-1-shared-public-use1-az1.arn
  resource_share_arn = aws_ram_resource_share.subnets-shared-us-east-1.arn
}
resource "aws_ram_resource_association" "sandbox-us-east-1-1-shared-public-use-az2" {
  resource_arn       = aws_subnet.sandbox-us-east-1-1-shared-public-use1-az2.arn
  resource_share_arn = aws_ram_resource_share.subnets-shared-us-east-1.arn
}
resource "aws_ram_resource_association" "sandbox-us-east-1-1-shared-private-use-az1" {
  resource_arn       = aws_subnet.sandbox-us-east-1-1-shared-private-use1-az1.arn
  resource_share_arn = aws_ram_resource_share.subnets-shared-us-east-1.arn
}
resource "aws_ram_resource_association" "sandbox-us-east-1-1-shared-private-use-az2" {
  resource_arn       = aws_subnet.sandbox-us-east-1-1-shared-private-use1-az2.arn
  resource_share_arn = aws_ram_resource_share.subnets-shared-us-east-1.arn
}
resource "aws_ram_principal_association" "subnets-shared-us-east-1-sandbox" {
  principal          = "673052121367"
  resource_share_arn = aws_ram_resource_share.subnets-shared-us-east-1.arn
}

data "aws_default_tags" "sandbox" {
  provider = aws.sandbox
}

# tag resources in the other accounts
resource "aws_ec2_tag" "vpc-sandbox-us-east-1-1" {
  provider    = aws.sandbox
  resource_id = aws_vpc.sandbox-us-east-1-1.id

  for_each = merge(data.aws_default_tags.sandbox.tags, tomap({ "Name" = "sandbox-us-east-1-1" }))
  key      = each.key
  value    = each.value

  depends_on = [aws_ram_resource_share.subnets-shared-us-east-1]
}
resource "aws_ec2_tag" "subnet-sandbox-us-east-1-1-shared-public-use1-az1" {
  provider    = aws.sandbox
  resource_id = aws_subnet.sandbox-us-east-1-1-shared-public-use1-az1.id

  for_each = merge(data.aws_default_tags.sandbox.tags, tomap({ "Name" = "sandbox-us-east-1-1-shared-public-use1-az1" }))
  key      = each.key
  value    = each.value

  depends_on = [aws_ram_resource_share.subnets-shared-us-east-1]
}
resource "aws_ec2_tag" "subnet-sandbox-us-east-1-1-shared-public-use1-az2" {
  provider    = aws.sandbox
  resource_id = aws_subnet.sandbox-us-east-1-1-shared-public-use1-az2.id

  for_each = merge(data.aws_default_tags.sandbox.tags, tomap({ "Name" = "sandbox-us-east-1-1-shared-public-use1-az2" }))
  key      = each.key
  value    = each.value

  depends_on = [aws_ram_resource_share.subnets-shared-us-east-1]
}
resource "aws_ec2_tag" "subnet-sandbox-us-east-1-1-shared-private-use1-az1" {
  provider    = aws.sandbox
  resource_id = aws_subnet.sandbox-us-east-1-1-shared-private-use1-az1.id

  for_each = merge(data.aws_default_tags.sandbox.tags, tomap({ "Name" = "sandbox-us-east-1-1-shared-private-use1-az1" }))
  key      = each.key
  value    = each.value

  depends_on = [aws_ram_resource_share.subnets-shared-us-east-1]
}
resource "aws_ec2_tag" "subnet-sandbox-us-east-1-1-shared-private-use1-az2" {
  provider    = aws.sandbox
  resource_id = aws_subnet.sandbox-us-east-1-1-shared-private-use1-az2.id

  for_each = merge(data.aws_default_tags.sandbox.tags, tomap({ "Name" = "sandbox-us-east-1-1-shared-private-use1-az2" }))
  key      = each.key
  value    = each.value

  depends_on = [aws_ram_resource_share.subnets-shared-us-east-1]
}
