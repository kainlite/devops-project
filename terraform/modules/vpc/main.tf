resource "aws_vpc" "this" {
  cidr_block = var.cidr

  assign_generated_ipv6_cidr_block = false

  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_dns_support                   = var.enable_dns_support
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  tags = merge(
    { "Name" = var.name },
    var.tags,
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  
  availability_zone = element(var.availability_zones, count.index)
  cidr_block = element(concat(var.public_subnets, [""]), count.index)
  vpc_id     = aws_vpc.this.id

  tags = merge(var.tags, var.public_subnet_tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = var.tags
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public[*].id)

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = element(aws_route_table.public[*].id, count.index)
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.public[*].id

  tags = var.tags
}

resource "aws_network_acl_rule" "public_inbound" {
  count = length(var.public_inbound_acl_rules)

  network_acl_id = aws_network_acl.public.id

  egress          = false
  rule_number     = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound" {
  count = length(var.public_outbound_acl_rules)

  network_acl_id = aws_network_acl.public.id

  egress          = true
  rule_number     = var.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.public_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.public_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.public_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  availability_zone = element(var.availability_zones, count.index)
  cidr_block        = element(concat(var.private_subnets, [""]), count.index)
  vpc_id            = aws_vpc.this.id

  tags = merge(var.tags, var.private_subnet_tags)
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = var.tags
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private[*].id)

  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = aws_subnet.private[*].id

  tags = var.tags
}

resource "aws_network_acl_rule" "private_inbound" {
  count = length(var.private_inbound_acl_rules)

  network_acl_id = aws_network_acl.private.id

  egress          = false
  rule_number     = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_inbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = length(var.private_outbound_acl_rules)

  network_acl_id = aws_network_acl.private.id

  egress          = true
  rule_number     = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  icmp_code       = lookup(var.private_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type       = lookup(var.private_outbound_acl_rules[count.index], "icmp_type", null)
  protocol        = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", null)
}
