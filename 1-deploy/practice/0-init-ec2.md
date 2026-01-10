# 실습용 EC2 환경 초기화

실습용 EC2 인스턴스는 모두 `t3.small (2 vCPU, 2 GiB)` 로 생성한다.

| NAME | Description | CPU | RAM | Private IP | HOSTNAME |
| --- | --- | --- | --- | --- | --- | --- |
| jumpbox | Administration host | 2 | 2GiB | **172.31.11.186** | **jumpbox** |
| server | Kubernetes server | 2 | 2GiB | **172.31.5.196** | server.kubernetes.local **server** |
| node-0 | Kubernetes worker  | 2 | 2GiB | **172.31.8.112** | node-0.kubernetes.local **node-0** |
| node-1 | Kubernetes worker  | 2 | 2GiB | **172.31.15.209** | node-1.kubernetes.local **node-1** |


## 1. terraform으로 EC2 배포

```bash
# terraform 구성이 있는 위치로 이동
❯ cd 1-deploy/trfs

# terraform.tfvars 예시 파일
❯ cat terraform.tfvars.example 
region              = "ap-northeast-2"
ami_id              = "ami-0c8b778b47e354873" # Debian 13 (HVM), SSD Volume Type, x86
vpc_id              = "vpc-0example123456789"
subnet_id           = "subnet-0example123456789"
security_group_ids  = ["sg-0example123456789"]
resource_prefix     = "k8s-hardway"
key_name            = "my-ec2-keypair" # Optional; set to null or remove to disable
associate_public_ip = true
default_tags = {
  Environment = "lab"
  Project     = "kubernetes-the-hard-way"
}

# 위의 예시 파일을 참고하여 본인 환경에 맞는 terraform.tfvars 파일을 구성한다.
❯ cat terraform.tfvars
region              = "ap-northeast-2"
ami_id              = "ami-0c8b778b47e354873" # Debian 13 (HVM), SSD Volume Type, x86
vpc_id              = "vpc-0example123456789" # 본인 환경에 맞도록 수정
subnet_id           = "subnet-0example123456789" # 본인 환경에 맞도록 수정
security_group_ids  = ["sg-0example123456789"] # 본인 환경에 맞도록 수정
resource_prefix     = "k8s-hardway"
key_name            = "my-ec2-keypair" # Optional; set to null or remove to disable # 본인 환경에 맞도록 수정
associate_public_ip = true # 본인 환경에 맞도록 수정
default_tags = {
  Environment = "lab"
  Project     = "kubernetes-the-hard-way"
}

# terraform plan으로 확인
❯ terraform plan

# 이상이 없다면 반영
❯ terraform apply
...
Apply complete! Resources: 0 added, 4 changed, 0 destroyed.

Outputs:

instance_ids = {
  "jumpbox" = "i-{jumphost_id}"
  "node-0" = "i-{node-0_id}"
  "node-1" = "i-{node-1_id}"
  "server" = "i-{server_id}"
}
instance_private_ips = {
  "jumpbox" = "172.31.11.186"
  "node-0" = "172.31.8.112"
  "node-1" = "172.31.15.209"
  "server" = "172.31.5.196"
}
instance_public_ips = {
  "jumpbox" = "생략"
  "node-0" = "생략"
  "node-1" = "생략"
  "server" = "생략"
}
```

## 2. 서버 내 추가적으로 필요한 구성 진행
- 모든 EC2의 `/etc/hosts` 파일 수정
- 모든 EC2의 hostname을 `hostnamectl`로 사전 변경

모든 EC2의 `/etc/hosts` 파일을 수정한다.
```bash
# jumphost 용도의 EC2 접속 후, /etc/hosts에 아래처럼 추가
oot@ip-172-31-11-186:~# cat /etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

root@ip-172-31-11-186:~# cat << EOF >> /etc/hosts
172.31.11.186  jumpbox
172.31.5.196 server.kubernetes.local server
172.31.8.112 node-0.kubernetes.local node-0
172.31.15.209 node-1.kubernetes.local node-1
EOF

root@ip-172-31-11-186:~# cat /etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

172.31.11.186  jumpbox
172.31.5.196 server.kubernetes.local server 
172.31.8.112 node-0.kubernetes.local node-0
172.31.15.209 node-1.kubernetes.local node-1

root@ip-172-31-11-186:~#
for host in server node-0 node-1; do
  ssh root@"$host" 'bash -s' <<'EOF'
set -e

echo "== /etc/hosts (before) =="
cat /etc/hosts

# 이미 들어갔으면 다시 추가하지 않는다.
if ! grep -q 'kubernetes.local' /etc/hosts; then
  cat <<'EOT' >> /etc/hosts
172.31.11.186  jumpbox
172.31.5.196   server.kubernetes.local server
172.31.8.112   node-0.kubernetes.local node-0
172.31.15.209  node-1.kubernetes.local node-1
EOT
fi

echo "== /etc/hosts (after) =="
cat /etc/hosts
EOF
done
```

모든 EC2의 hostname을 `hostnamectl`로 사전 변경한다.
```bash
# jumphost 용도의 EC2 접속 후, hostname 변경
root@ip-172-31-11-186:~# hostnamectl set-hostname jumphost
root@ip-172-31-11-186:~# exit

# server 용도의 EC2 접속 후, hostname 변경
root@ip-172-31-5-196:~# hostnamectl set-hostname server
root@ip-172-31-5-196:~# exit

# node-0 용도의 EC2 접속 후, hostname 변경
root@ip-172-31-8-112:~# hostnamectl set-hostname node-0
root@ip-172-31-8-112:~# exit

# node-1 용도의 EC2 접속 후, hostname 변경
root@ip-172-31-15-209:~# hostnamectl set-hostname node-1
root@ip-172-31-15-209:~# exit
```

## 