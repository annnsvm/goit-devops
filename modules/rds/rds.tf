resource "aws_db_instance" "this" {
  count                        = var.use_aurora ? 0 : 1
  identifier                   = var.name
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  username                     = var.username
  password                     = var.password
  db_name                      = replace(var.name, "-", "_")
  allocated_storage            = var.allocated_storage
  storage_type                 = "gp3"
  port                         = var.db_port
  multi_az                     = var.multi_az
  publicly_accessible          = false
  db_subnet_group_name         = aws_db_subnet_group.this.name
  vpc_security_group_ids       = [aws_security_group.this.id]
  parameter_group_name         = aws_db_parameter_group.this[0].name
  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  maintenance_window           = var.preferred_maintenance_window
  deletion_protection          = var.deletion_protection
  skip_final_snapshot          = var.skip_final_snapshot
  apply_immediately            = var.apply_immediately
  auto_minor_version_upgrade   = true
  tags = merge(var.tags, { Name = var.name })
}
