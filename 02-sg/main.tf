module "db" {
  source = "git::https://github.com/puneethtiruveedula/expense-sg-module.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  common_tags = var.common_tags
  sg_description = "SG for the DB MySQL Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "db"
}

module "backend" {
  source = "git::https://github.com/puneethtiruveedula/expense-sg-module.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  common_tags = var.common_tags
  sg_description = "SG for the Backend Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "backend"
}

module "frontend" {
  source = "git::https://github.com/puneethtiruveedula/expense-sg-module.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  common_tags = var.common_tags
  sg_description = "SG for the Frontend Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "frontend"
}

module "bastion" {
  source = "git::https://github.com/puneethtiruveedula/expense-sg-module.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  common_tags = var.common_tags
  sg_description = "SG for the Bastion Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "bastion"
}

module "ansible" {
  source = "git::https://github.com/puneethtiruveedula/expense-sg-module.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  common_tags = var.common_tags
  sg_description = "SG for the Ansible Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "ansible"
}

# DB is accepting connections from backend
resource "aws_security_group_rule" "db_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.backend.sg_id
  security_group_id = module.db.sg_id
}

resource "aws_security_group_rule" "db_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.db.sg_id
}

resource "aws_security_group_rule" "backend_frontend" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.frontend.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "backend_ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.ansible.sg_id
  security_group_id = module.backend.sg_id
}

resource "aws_security_group_rule" "frontend_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.ansible.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "bastion_publiv" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

resource "aws_security_group_rule" "ansible_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ansible.sg_id
}