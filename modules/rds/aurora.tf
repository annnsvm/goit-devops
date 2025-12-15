resource "aws_rds_cluster" "this" {
  count                           = var.use_aurora ? 1 : 0
  cluster_identifier              = "${var.name}-cluster"
  engine                          = var.engine
  engine_version                  = var.engine_version
  master_username                 = var.username
  master_password                 = var.password
  database_name                   = replace(var.name, "-", "_")
  port                            = var.db_port
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this[0].name
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  deletion_protection             = var.deletion_protection
  skip_final_snapshot             = var.skip_final_snapshot
  apply_immediately               = var.apply_immediately
  tags = merge(var.tags, { Name = "${var.name}-cluster" })
}

resource "aws_rds_cluster_instance" "writer" {
  count                        = var.use_aurora ? 1 : 0
  identifier                   = "${var.name}-writer-1"
  cluster_identifier           = aws_rds_cluster.this[0].id
  instance_class               = var.instance_class
  engine                       = var.engine
  engine_version               = var.engine_version
  publicly_accessible          = false
  apply_immediately            = var.apply_immediately
  preferred_maintenance_window = var.preferred_maintenance_window
  tags                         = merge(var.tags, { Name = "${var.name}-writer-1" })
}
