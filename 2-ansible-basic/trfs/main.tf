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

locals {
  instances = {
    server = {
      description     = "Ansible control node"
      hostname        = "server"
      ami_id          = var.ubuntu_ami_id
      root_volume_gb  = 30
      instance_type   = "t3.medium"
    }
    tnode1 = {
      description     = "Ansible managed node"
      hostname        = "tnode1"
      ami_id          = var.ubuntu_ami_id
      root_volume_gb  = 30
      instance_type   = var.instance_type
    }
    tnode2 = {
      description     = "Ansible managed node"
      hostname        = "tnode2"
      ami_id          = var.ubuntu_ami_id
      root_volume_gb  = 30
      instance_type   = var.instance_type
    }
    tnode3 = {
      description     = "Ansible managed node"
      hostname        = "tnode3"
      ami_id          = var.rocky_ami_id
      root_volume_gb  = 60
      instance_type   = var.instance_type
    }
  }

  bootstrap_user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail

    if [ -f /etc/os-release ]; then
      . /etc/os-release
    else
      ID=""
    fi

    case "$ID" in
      ubuntu|debian)
        apt-get update
        apt-get install -y --no-install-recommends ca-certificates curl jq vim git tree openssh-server sudo yq sshpass
        ssh_service="ssh"
        sudo_group="sudo"
        ssm_pkg_type="deb"
        ;;
      rocky|rhel|centos)
        dnf -y makecache
        dnf install -y ca-certificates curl jq vim git tree openssh-server sudo sshpass
        dnf install -y yq || true
        ssh_service="sshd"
        sudo_group="wheel"
        ssm_pkg_type="rpm"
        ;;
      *)
        echo "Unsupported OS: $ID" >&2
        exit 1
        ;;
    esac

    # Swap off & disable AppArmor where applicable
    swapoff -a
    sed -i '/swap/s/^/#/' /etc/fstab
    if systemctl is-active --quiet apparmor; then
      systemctl stop apparmor
      systemctl disable --now apparmor || true
    fi

    # create labadmin user & change root password
    useradd -m -s /bin/bash labadmin
    usermod -aG "$sudo_group" labadmin
    echo "labadmin:qwe123" | chpasswd
    echo "root:qwe123" | chpasswd
    passwd -u root || true
    
    # sshd 설정: 패스워드 로그인 허용 (Include 우선순위 확보)
    mkdir -p /etc/ssh/sshd_config.d
    cat <<'EOF' >/etc/ssh/sshd_config.d/00-enable-password.conf
    PasswordAuthentication yes
    PermitRootLogin yes
    UsePAM yes
    EOF

    # sshd 설정: 패스워드 로그인 허용 (메인 설정 파일에서도 강제)
    if grep -q '^PasswordAuthentication' /etc/ssh/sshd_config; then
      sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    else
      echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
    fi

    if grep -q '^PermitRootLogin' /etc/ssh/sshd_config; then
      sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    else
      echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
    fi

    if grep -q '^UsePAM' /etc/ssh/sshd_config; then
      sed -i 's/^UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config
    else
      echo 'UsePAM yes' >> /etc/ssh/sshd_config
    fi
    systemctl restart "$ssh_service"

  EOT
}

resource "aws_instance" "nodes" {
  for_each = local.instances

  ami           = each.value.ami_id
  instance_type = each.value.instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip
  key_name                    = var.key_name != null && var.key_name != "" ? var.key_name : null

  root_block_device {
    volume_size = each.value.root_volume_gb
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
