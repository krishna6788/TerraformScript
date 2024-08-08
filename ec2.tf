resource "aws_security_group" "inst" {
  vpc_id = local.vpc-id
  ingress {
    from_port   = local.ssh-port
    to_port     = local.ssh-port
    protocol    = local.tcp
    cidr_blocks = [local.anywhere]
  }
  ingress {
    from_port   = local.http-port
    to_port     = local.http-port
    protocol    = local.tcp
    cidr_blocks = [local.anywhere]
  }
  # Postgres-Port
  ingress {
    from_port = local.postgres-port
    to_port   = local.postgres-port
    protocol  = local.tcp
    cidr_blocks = [local.anywhere]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.anywhere]
  }

  tags = {
    Name = "inst"
  }
  depends_on = [
    aws_vpc.ALL
  ]
}



data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Amazon's owner ID

  filter {
    name   = "name"
    #values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }
}

data "aws_subnet" "web" {
  vpc_id = local.vpc-id
  filter {
    name   = "tag:Name"
    values = [var.ALL-VPC-INFO.web-ec2-subnet]
  }

  depends_on = [ 
    aws_subnet.SUBNETS
   ]
#   filter {
#     name   = "vpc-id"
#     values = [local.vpc-id]
#   }
}

resource "aws_instance" "hey" {
  count                       = var.instance_count  
  ami                         = data.aws_ami.latest_ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnet.web.id
  associate_public_ip_address = "true"
  key_name                    = "worker"
  vpc_security_group_ids      = [aws_security_group.inst.id]
  user_data = templatefile("installpostgres.sh.tpl",
              {postgres_version  = var.postgres_version,
               enable_pgbackrest = var.enable_pgbackrest} )
  #user_data =<<-EOF
            #!/bin/bash
	    #export POSTGRES_VERSION=15
            #export ENABLE_PGBACKREST=true
            #export ENABLE_MONITORING=false
            #sudo apt-get update
            #sudo apt install postgresql-client-common -y
            #sudo pg_createcluster ${var.postgres_version} main --start
            #sudo apt-get install -y postgresql-15 postgresql-contrib postgresql-client
            #sudo apt-get install -y postgresql-${var.postgres_version} postgresql-contrib-${var.postgres_version}
            #sudo systemctl enable postgresql
            #sudo systemctl start postgresql

	    #!/bin/bash
           # Update package list and install PostgreSQL
            #sudo apt-get update
            # sudo apt-get install -y wget gnupg2

           # Add PostgreSQL APT repository
            # echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

           # Import the repository signing key and update package list again
            # wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
            # sudo apt-get update

           # Install the specified version of PostgreSQL
           # sudo apt-get install -y postgresql-${var.postgres_version} postgresql-contrib-${var.postgres_version}
           # Start PostgreSQL service
           # sudo systemctl start postgresql

           # Enable PostgreSQL to start on boot
           # sudo systemctl enable postgresql

           # Output the status of PostgreSQL service
           # sudo systemctl status postgresql


            # if [ "${var.enable_pgbackrest}" = "true" ]; then
            
            # sudo apt-get install -y pgbackrest
            # Add pgBackRest configuration here
            # fi

            # if [ "${var.enable_monitoring}" = "true" ]; then
            # sudo apt-get install -y prometheus-node-exporter
            # Add monitoring setup here
            # fi
            # EOF

  tags = {
    Name = "postgres-db-${count.index}"
  }
  depends_on = [
    aws_security_group.inst,

  ]

}


