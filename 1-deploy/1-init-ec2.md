# 실습용 EC2 환경 초기화

실습용 EC2 인스턴스는 모두 `t3.small (2 vCPU, 2 GiB)` 로 생성한다.

| NAME | Description | CPU | RAM | Private IP | HOSTNAME |
| --- | --- | --- | --- | --- | --- | --- |
| jumpbox | Administration host | 2 | 2GiB | **172.31.11.186** | **jumpbox** |
| server | Kubernetes server | 2 | 2GiB | **172.31.5.196** | server.kubernetes.local **server** |
| node-0 | Kubernetes worker  | 2 | 2GiB | **172.31.8.112** | node-0.kubernetes.local **node-0** |
| node-1 | Kubernetes worker  | 2 | 2GiB | **172.31.15.209** | node-1.kubernetes.local **node-1** |


## 1. terraform으로 EC2 배포

아래 커맨드로 EC2 4대를 배포한 뒤, aws 콘솔 상에서 아래 내용을 반드시 진행한다.
- ec2 우클릭 -> "네트워킹" -> "네트워크 소스 / 대상 확인 변경" -> "소스 / 대상 확인" **중지** 처리
  - 추후 k8s 구성 뒤, 노드 서버간 pod 대역 통신을 확인하기 위해서임 (terraform 코드는 추후 수정할 예정)


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
# jumpbox 용도의 EC2 접속 후, /etc/hosts에 아래처럼 추가
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
# jumpbox 용도의 EC2 접속 후, hostname 변경
root@ip-172-31-11-186:~# hostnamectl set-hostname jumpbox
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

## 3. EC2 시스템 설정 최종 확인

```bash
$ sudo su -
root@jumpbox:~#

root@jumpbox:~# whoami
root

root@jumpbox:~# pwd
/root

root@jumpbox:~# cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 13 (trixie)"
NAME="Debian GNU/Linux"
VERSION_ID="13"
VERSION="13 (trixie)"
VERSION_CODENAME=trixie
DEBIAN_VERSION_FULL=13.1
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"

root@jumpbox:~# aa-status
apparmor module is loaded.
106 profiles are loaded.
7 profiles are in enforce mode.
   /usr/bin/man
   lsb_release
   man_filter
   man_groff
   nvidia_modprobe
   nvidia_modprobe//kmod
   tcpdump
23 profiles are in complain mode.
   Xorg
   plasmashell
   plasmashell//QtWebEngineProcess
   sbuild
   sbuild-abort
   sbuild-adduser
   sbuild-apt
   sbuild-checkpackages
   sbuild-clean
   sbuild-createchroot
   sbuild-destroychroot
   sbuild-distupgrade
   sbuild-hold
   sbuild-shell
   sbuild-unhold
   sbuild-update
   sbuild-upgrade
   transmission-cli
   transmission-daemon
   transmission-gtk
   transmission-qt
   unix-chkpwd
   unprivileged_userns
0 profiles are in prompt mode.
0 profiles are in kill mode.
76 profiles are in unconfined mode.
   1password
   Discord
   MongoDB Compass
   QtWebEngineProcess
   balena-etcher
   brave
   buildah
   busybox
   cam
   ch-checkns
   ch-run
   chrome
   chromium
   crun
   devhelp
   element-desktop
   epiphany
   evolution
   firefox
   flatpak
   foliate
   geary
   github-desktop
   goldendict
   ipa_verify
   kchmviewer
   keybase
   lc-compliance
   libcamerify
   linux-sandbox
   loupe
   lxc-attach
   lxc-create
   lxc-destroy
   lxc-execute
   lxc-stop
   lxc-unshare
   lxc-usernsexec
   mmdebstrap
   msedge
   nautilus
   notepadqq
   obsidian
   opam
   opera
   pageedit
   polypane
   privacybrowser
   qcam
   qmapshack
   qutebrowser
   rootlesskit
   rpm
   rssguard
   runc
   scide
   signal-desktop
   slack
   slirp4netns
   steam
   stress-ng
   surfshark
   systemd-coredump
   toybox
   trinity
   tup
   tuxedo-control-center
   userbindmount
   uwsgi-core
   vdens
   virtiofsd
   vivaldi-bin
   vpnns
   vscode
   wike
   wpcom
0 processes have profiles defined.
0 processes are in enforce mode.
0 processes are in complain mode.
0 processes are in prompt mode.
0 processes are in kill mode.
0 processes are unconfined but have a profile defined.
0 processes are in mixed mode.

root@jumpbox:~# systemctl is-active apparmor
inactive
```