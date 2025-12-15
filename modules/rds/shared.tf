locals {
  default_parameters = [
    { name="max_connections", value="200",  apply_method="pending-reboot" },
    { name="log_statement",   value="none", apply_method="immediate"     },
    { name="work_mem",        value="4MB",  apply_method="pending-reboot"}
  ]
  effective_parameters = length(var.parameters) > 0 ? var.parameters : local.default_parameters
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnets"
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, { Name = "${var.name}-subnets" })
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security group for ${var.name} database"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-sg" })
}

resource "aws_security_group_rule" "ingress_cidr" {
  for_each          = toset(var.allowed_cidr_blocks)
  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = [each.key]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress_sg" {
  for_each                 = toset(var.allowed_security_group_ids)
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = each.key
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_db_parameter_group" "this" {
  count  = var.use_aurora ? 0 : 1
  name   = "${var.name}-params"
  family = var.parameter_group_family
  dynamic "parameter" {
    for_each = local.effective_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }
  tags = merge(var.tags, { Name = "${var.name}-params" })
}

resource "aws_rds_cluster_parameter_group" "this" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.name}-cluster-params"
  family = var.cluster_parameter_group_family
  dynamic "parameter" {
    for_each = local.effective_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }
  tags = merge(var.tags, { Name = "${var.name}-cluster-params" })
}
