resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = var.name },
    var.tags,
  )
}

resource "aws_egress_only_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    { "Name" = var.name },
    var.tags,
  )
}
