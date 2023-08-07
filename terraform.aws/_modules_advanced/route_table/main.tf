
resource "aws_route_table" "sac_testing_route_table" {
  vpc_id = aws_vpc.route_vpc.id
  route = []
}

resource "aws_vpc" "route_vpc" {
  cidr_block = "10.0.0.0/16"
}