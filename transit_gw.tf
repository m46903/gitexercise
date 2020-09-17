# Transit Gateway

resource "aws_ec2_transit_gateway" "test-tgw" {
  description                     = "Transit Gateway testing scenario with 3 VPCs, 2 subnets each"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "cnc transit gateway"
  }
}

# VPC attachment

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-2" {
  subnet_ids = ["${aws_subnet.vpc-2-sub-a.id}",
  "${aws_subnet.vpc-2-sub-b.id}", 
  "${aws_subnet.vpc-2-sub-c.id}"]
  transit_gateway_id                              = aws_ec2_transit_gateway.test-tgw.id
  vpc_id                                          = aws_vpc.vpc-2.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "tgw-attach-victim-vpc"
  }
  #depends_on = ["aws_ec2_transit_gateway.test-tgw"]
  depends_on = [aws_ec2_transit_gateway.test-tgw]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-1" {
  subnet_ids = ["${aws_subnet.vpc-1-sub-a.id}",
    "${aws_subnet.vpc-1-sub-aa.id}",
  "${aws_subnet.vpc-1-sub-b.id}", 
  "${aws_subnet.vpc-1-sub-bb.id}",
  "${aws_subnet.vpc-1-sub-bbb.id}" ]
  transit_gateway_id                              = aws_ec2_transit_gateway.test-tgw.id
  vpc_id                                          = aws_vpc.vpc-1.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "tgw-attach-attack-vpc"
  }
  depends_on = [aws_ec2_transit_gateway.test-tgw]
}

# Route Tables

resource "aws_ec2_transit_gateway_route_table" "tgw-vpc-2-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.test-tgw.id
  tags = {
    Name = "tgw-victim-rt"
  }

  depends_on = [aws_ec2_transit_gateway.test-tgw]
}

resource "aws_ec2_transit_gateway_route_table" "tgw-vpc-1-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.test-tgw.id
  tags = {
    Name = "tgw-attack-rt"
  }

  depends_on = [aws_ec2_transit_gateway.test-tgw]
}

resource "aws_ec2_transit_gateway_route_table" "tgw-rt-table-public-ig" {
  transit_gateway_id = aws_ec2_transit_gateway.test-tgw.id
  tags = {
    Name = "tgw-public-rt"
  }

  depends_on = [aws_ec2_transit_gateway.test-tgw]
}


# Route Tables Associations

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-2-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-vpc-2-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-1-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-vpc-1-rt.id
}

# Route Tables Propagations

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-vpc-1-to-vpc-2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-vpc-1-rt.id
}


resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-vpc-2-to-vpc-1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-vpc-2-rt.id
}


