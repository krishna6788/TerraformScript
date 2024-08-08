locals {
  vpc-id     = aws_vpc.ALL.id
  anywhere   = "0.0.0.0/0"
  postgres-port = "5432"
  tcp        = "tcp"
  ssh-port   = 22
  http-port  = 80
}
