resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    {
      "Name" = var.name,
    },
    var.tags,
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public[0].id

  tags = merge(
    {
      "Name" = var.name,
    },
    var.tags,
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.nat_gateway_destination_cidr_block
  nat_gateway_id         = aws_nat_gateway.this.id

  timeouts {
    create = "5m"
  }
}
