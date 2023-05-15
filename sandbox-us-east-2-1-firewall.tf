resource "aws_networkfirewall_firewall_policy" "sandbox-us-east-2-1-ingress" {
  name = "sandbox-us-east-2-1-ingress"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateless_rule_group_reference {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.drop-icmp.arn
    }
  }
}

resource "aws_networkfirewall_firewall_policy" "sandbox-us-east-2-1-egress" {
  name = "sandbox-us-east-2-1-egress"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block-domains.arn
    }
  }
}

resource "aws_networkfirewall_rule_group" "drop-icmp" {
  capacity = 1
  name     = "drop-icmp"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [1]
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_rule_group" "drop-tcp-dan" {
  capacity = 1
  name     = "drop-tcp-dan"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [6]
              source {
                address_definition = "23.28.74.47/32"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_rule_group" "block-domains" {
  capacity = 100
  name     = "block-domains"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [aws_vpc.sandbox-us-east-2-1.cidr_block]
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = [".facebook.com", ".twitter.com"]
      }
    }
  }
}

#
# Create firewall endpoints
#
resource "aws_networkfirewall_firewall" "sandbox-us-east-2-1-ingress" {
  count = var.enable_firewalls ? 1 : 0

  name                = "sandbox-us-east-2-1-ingress"
  description         = "Ingress firewall for Sandbox VPC"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.sandbox-us-east-2-1-ingress.arn
  vpc_id              = aws_vpc.sandbox-us-east-2-1.id
  subnet_mapping {
    subnet_id = aws_subnet.sandbox-us-east-2-1-firewall-ingress-use1-az1.id
  }
}

resource "aws_networkfirewall_firewall" "sandbox-us-east-2-1-egress" {
  count = var.enable_firewalls ? 1 : 0

  name                = "sandbox-us-east-2-1-egress"
  description         = "Egress firewall for Sandbox VPC"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.sandbox-us-east-2-1-egress.arn
  vpc_id              = aws_vpc.sandbox-us-east-2-1.id
  subnet_mapping {
    subnet_id = aws_subnet.sandbox-us-east-2-1-firewall-egress-use1-az1.id
  }
}

#
# Update routes if FWs added.  Destination CIDRs must exist as subnet cidrs - can not specify larger blocks that are not defined as subnets.  :-(
#

# Add IGW route for traffic coming to public subnets to use ingress FW
resource "aws_route" "sandbox-us-east-2-1-igw-to-public-use-az1" {
  count = var.enable_firewalls ? 1 : 0

  route_table_id         = aws_route_table.sandbox-us-east-2-1-igw.id
  destination_cidr_block = "172.16.16.0/20"

  # https://github.com/hashicorp/terraform-provider-aws/issues/16759
  vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.sandbox-us-east-2-1-ingress[count.index].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.sandbox-us-east-2-1-firewall-ingress-use1-az1.id], 0)
}
resource "aws_route" "sandbox-us-east-2-1-igw-to-public-use-az2" {
  count = var.enable_firewalls ? 1 : 0

  route_table_id         = aws_route_table.sandbox-us-east-2-1-igw.id
  destination_cidr_block = "172.16.32.0/20"

  # https://github.com/hashicorp/terraform-provider-aws/issues/16759
  vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.sandbox-us-east-2-1-ingress[count.index].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.sandbox-us-east-2-1-firewall-ingress-use1-az1.id], 0)
}
# Add egress traffic from public subnets to ingress firewall
resource "aws_route" "sandbox-us-east-2-1-public-return-to-ingress-firewall" {
  count = var.enable_firewalls ? 1 : 0

  route_table_id         = aws_route_table.sandbox-us-east-2-1-public.id
  destination_cidr_block = "0.0.0.0/0"

  # https://github.com/hashicorp/terraform-provider-aws/issues/16759
  vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.sandbox-us-east-2-1-ingress[count.index].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.sandbox-us-east-2-1-firewall-ingress-use1-az1.id], 0)
}
# Add egress traffic from private subnets to egress firewall
resource "aws_route" "sandbox-us-east-2-1-private-to-egress-firewall" {
  count = var.enable_firewalls ? 1 : 0

  route_table_id         = aws_route_table.sandbox-us-east-2-1-private.id
  destination_cidr_block = "0.0.0.0/0"

  # https://github.com/hashicorp/terraform-provider-aws/issues/16759
  vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.sandbox-us-east-2-1-egress[count.index].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.sandbox-us-east-2-1-firewall-egress-use1-az1.id], 0)
}
# Add private return traffic route to the NGW subnet
resource "aws_route" "sandbox-us-east-2-1-ngw-return-to-private-use-az1" {
  count = var.enable_firewalls ? 1 : 0

  route_table_id         = aws_route_table.sandbox-us-east-2-1-ngw.id
  destination_cidr_block = "172.16.80.0/20"

  # https://github.com/hashicorp/terraform-provider-aws/issues/16759
  vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.sandbox-us-east-2-1-egress[count.index].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.sandbox-us-east-2-1-firewall-egress-use1-az1.id], 0)
}
# Add private return traffic route to the NGW subnet
resource "aws_route" "sandbox-us-east-2-1-ngw-return-to-private-use-az2" {
  count = var.enable_firewalls ? 1 : 0

  route_table_id         = aws_route_table.sandbox-us-east-2-1-ngw.id
  destination_cidr_block = "172.16.96.0/20"

  # https://github.com/hashicorp/terraform-provider-aws/issues/16759
  vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.sandbox-us-east-2-1-egress[count.index].firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.sandbox-us-east-2-1-firewall-egress-use1-az1.id], 0)
}

#
# Send logs to log archive account
#
resource "aws_networkfirewall_logging_configuration" "sandbox-us-east-2-1-ingress" {
  count = var.enable_flow_logs ? 1 : 0

  firewall_arn = aws_networkfirewall_firewall.sandbox-us-east-2-1-ingress[count.index].arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        bucketName = var.s3_logs_bucket_name
      }
      log_destination_type = "S3"
      log_type             = "FLOW"
    }
  }
}
resource "aws_networkfirewall_logging_configuration" "sandbox-us-east-2-1-egress" {
  count = var.enable_flow_logs ? 1 : 0

  firewall_arn = aws_networkfirewall_firewall.sandbox-us-east-2-1-egress[count.index].arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        bucketName = var.s3_logs_bucket_name
      }
      log_destination_type = "S3"
      log_type             = "FLOW"
    }
  }
}