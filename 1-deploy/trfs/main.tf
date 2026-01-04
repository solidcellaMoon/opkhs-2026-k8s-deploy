terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_caller_identity" "current" {}

locals {
  instances = {
    jumpbox = {
      description = "Administration host"
      hostname    = "jumpbox"
    }
    server = {
      description = "Kubernetes control plane"
      hostname    = "server"
    }
    "node-0" = {
      description = "Kubernetes worker"
      hostname    = "node-0"
    }
    "node-1" = {
      description = "Kubernetes worker"
      hostname    = "node-1"
    }
  }

  bootstrap_user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail

    # initial settings
    # 1) Swap off
    swapoff -a
    sed -i '/swap/s/^/#/' /etc/fstab
    
    # 2) Disable AppArmor
    systemctl stop apparmor
    systemctl disable apparmor >/dev/null 2>&1

    # install amazon-ssm-agent
    apt-get update
    apt-get install -y --no-install-recommends ca-certificates curl jq vim git tree
    curl -fsSL "https://s3.${var.region}.amazonaws.com/amazon-ssm-${var.region}/latest/debian_amd64/amazon-ssm-agent.deb" -o /tmp/amazon-ssm-agent.deb
    dpkg -i /tmp/amazon-ssm-agent.deb
    systemctl enable --now amazon-ssm-agent
    rm -f /tmp/amazon-ssm-agent.deb
  EOT
}

resource "aws_iam_role" "ssm_role" {
  name_prefix = "${var.resource_prefix}-ssm-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.default_tags
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ssm_session_client" {
  name   = "${var.resource_prefix}-ssm-session-client"
  role   = aws_iam_role.ssm_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SsmStartSession"
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:TerminateSession",
          "ssm:DescribeSessions",
          "ssm:DescribeInstanceInformation"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Sid    = "SsmMessageChannels"
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name_prefix = "${var.resource_prefix}-ssm-"
  role        = aws_iam_role.ssm_role.name
}

resource "aws_instance" "nodes" {
  for_each = local.instances

  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = var.associate_public_ip
  key_name                    = var.key_name != null && var.key_name != "" ? var.key_name : null

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
    tags        = var.default_tags
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring = true
  user_data = local.bootstrap_user_data

  tags = merge(
    var.default_tags,
    {
      Name        = "${var.resource_prefix}-${each.value.hostname}"
      Description = each.value.description
      Hostname    = each.value.hostname
      VpcId       = data.aws_vpc.selected.id
    }
  )
}
