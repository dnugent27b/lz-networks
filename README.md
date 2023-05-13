# Networks

Create the sandbox network

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |
| <a name="provider_aws.sandbox"></a> [aws.sandbox](#provider\_aws.sandbox) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.sandbox-us-east-1-1-default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_ec2_tag.subnet-sandbox-us-east-1-1-shared-private-use1-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_ec2_tag.subnet-sandbox-us-east-1-1-shared-private-use1-az2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_ec2_tag.subnet-sandbox-us-east-1-1-shared-public-use1-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_ec2_tag.subnet-sandbox-us-east-1-1-shared-public-use1-az2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_ec2_tag.vpc-sandbox-us-east-1-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_eip.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.sandbox-us-east-1-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_internet_gateway.sandbox-us-east-1-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.sandbox-us-east-1-1-default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_association.sandbox-us-east-1-1-firewall-egress-use1-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association) | resource |
| [aws_network_acl_association.sandbox-us-east-1-1-firewall-ingress-use1-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association) | resource |
| [aws_network_acl_association.sandbox-us-east-1-1-ngw-use1-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association) | resource |
| [aws_network_acl_association.sandbox-us-east-1-1-shared-private-use1-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association) | resource |
| [aws_network_acl_association.sandbox-us-east-1-1-shared-private-use1-az2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association) | resource |
| [aws_network_acl_association.sandbox-us-east-1-1-shared-public-use1-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association) | resource |
| [aws_network_acl_association.sandbox-us-east-1-1-shared-public-use1-az2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association) | resource |
| [aws_ram_principal_association.subnets-shared-us-east-1-sandbox](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.sandbox-us-east-1-1-shared-private-use-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_association.sandbox-us-east-1-1-shared-private-use-az2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_association.sandbox-us-east-1-1-shared-public-use-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_association.sandbox-us-east-1-1-shared-public-use-az2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.subnets-shared-us-east-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_route.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.sandbox-us-east-1-1-firewall-egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.sandbox-us-east-1-1-firewall-ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.sandbox-us-east-1-1-igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.sandbox-us-east-1-1-ngw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.sandbox-us-east-1-1-private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.sandbox-us-east-1-1-public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.sandbox-us-east-1-1-firewall-egress-use-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.sandbox-us-east-1-1-firewall-ingress-use-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.sandbox-us-east-1-1-igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.sandbox-us-east-1-1-ngw-use-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.sandbox-us-east-1-1-shared-private-use-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.sandbox-us-east-1-1-shared-private-use-az2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.sandbox-us-east-1-1-shared-public-use-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.sandbox-us-east-1-1-shared-public-use-az2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.sandbox-us-east-1-1-firewall-egress-use1-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.sandbox-us-east-1-1-firewall-ingress-use1-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.sandbox-us-east-1-1-ngw-use1-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.sandbox-us-east-1-1-shared-private-use1-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.sandbox-us-east-1-1-shared-private-use1-az2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.sandbox-us-east-1-1-shared-public-use1-az1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.sandbox-us-east-1-1-shared-public-use1-az2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.sandbox-us-east-1-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_default_tags.sandbox](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_flow_logs"></a> [enable\_flow\_logs](#input\_enable\_flow\_logs) | true if VPC flow logs should be created | `bool` | `true` | no |
| <a name="input_enable_ngw"></a> [enable\_ngw](#input\_enable\_ngw) | true if create NAT gateway | `bool` | `false` | no |
| <a name="input_s3_vpc_flow_logs_bucket_arn"></a> [s3\_vpc\_flow\_logs\_bucket\_arn](#input\_s3\_vpc\_flow\_logs\_bucket\_arn) | S3 bucket arn to store VPC flow logs | `string` | `"arn:aws:s3:::abrigo1-logs-us-east-1"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
