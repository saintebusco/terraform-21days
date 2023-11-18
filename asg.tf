resource "aws_db_subnet_group" "this" {
name        = var.env_prefix
subnet_ids = var.subnet_ids

 tags = {
  Name = var.env_prefix

 }
}

resource "aws_security_group" "this" {
    name = "${var.env_prefix}-rds"
    vpc_id = var.vpc_id

    ingress {
        from_port  = "3306"
        to_port    = "3306"
        protocol   = "tcp"
        security_groups = [var.source_security_group]
    }

    tags = {
        Name = "${var.env_prefix}-rds"
    }
  
}

resource "aws_db_instance"  "this" {
   identifier             = var.env_prefix
   allocated_storage      =  10
   engine                 = "mysql"
   instance_class         = "db.t3.micro"
   name                   = "mydb"
   username               = "admin"
   password               = "supersecretpassword"
   multi_az                = true 
   db_subnet_group_name    = aws_db_subnet_group.this
   vpc_security_group_ids  = [aws_security_group.this.name] 
   backup_retention_period = 35
   backup_window           = "21:00-23:00"
   skip_final_snapshot     = true
}