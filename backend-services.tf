resource "aws_db_subnet_group" "vprofile-rds-subnetgrp" {
  name = "main"
  subnet_ids = [ module.vpc.private_subnets[0],module.vpc.private_subnets[1],module.vpc.private_subnets[2] ]
  tags = {
    Name= "Subnet group for RDS"
  }
}

resource "aws_elasticache_subnet_group" "vprofile-elasticache-subnetgrp" {
  name = "vprofile-elasticache-subnetgrp"
  subnet_ids = [ module.vpc.private_subnets[0],module.vpc.private_subnets[1],module.vpc.private_subnets[2] ]
  tags = {
    Name = "Elasticcache subnet group"
  }
}

resource "aws_db_instance" "vprofile-rds" {
  # RDS instance configuration
  allocated_storage    = 20    # Size of the database (in GB)
  storage_type         = "gp2" # General Purpose SSD
  instance_class       = "db.t2.micro" # Instance type (size of the RDS instance)
  engine               = "mysql" # Database engine (could be mysql, postgres, etc.)
  engine_version       = "5.6.34"  # Engine version, adjust according to your needs
  db_name              = var.dbname # Name of the database to create upon instance setup
  username             = var.dbuser # Master username for the database
  password             = var.dbpass # Master password
  parameter_group_name = "default.mysql5.6" # Parameter group for the engine
  
 
  
  # Multi-AZ setup (for high availability)
  multi_az             = false

  # Public accessibility (set to false for security)
  publicly_accessible  = false
  


  # Subnet group (used to specify the subnets to place the instance in)
  db_subnet_group_name  = aws_db_subnet_group.vprofile-rds-subnetgrp.name # Replace with your subnet group name
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.vprofile-backend-sg.id]
}

resource "aws_elasticache_cluster" "vprofile-elasticCache-cluster" {
  cluster_id = "vprofile-elasticCache-cluster"
  engine = "memcached"
  node_type = "cache.t2.micro"
  num_cache_nodes = 1
  parameter_group_name = "default.memcached1.5"
  port = 11211
  security_group_ids = [ aws_security_group.vprofile-backend-sg.id ]
  subnet_group_name = aws_elasticache_subnet_group.vprofile-elasticache-subnetgrp.name


}

resource "aws_mq_broker" "vprofile-rmq" {
    broker_name = "vprofile-rmq"
    engine_version = "5.15.0"
    engine_type = "ActiveMQ"
    host_instance_type = "mq.t2.micro"
    security_groups = [ aws_security_group.vprofile-backend-sg.id ]
    subnet_ids = [ module.vpc.private_subnets[0] ]
    user {
      username = var.rmquser
      password = var.rmqpass
          }
}

