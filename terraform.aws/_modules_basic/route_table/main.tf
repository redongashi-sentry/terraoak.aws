
resource "aws_route_table" "sac_testing_route_table" {
  vpc_id = aws_vpc.route_vpc.id
  route  = []
}
