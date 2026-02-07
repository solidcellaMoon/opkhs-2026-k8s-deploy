# 실습용 EC2 환경 초기화

실습용 EC2 인스턴스 구성은 아래와 같다.
- region: ap-northeast-2
- Rocky Linux 10: ami-062748fa168ed7aca
- admin-lb: `t3.small (2 vCPU, 2 GiB)`
- k8s-node1~5: `t3.medium (2 vCPU, 4 GiB)`

terraform 커맨드 내용은 생략하고, 구성된 output은 아래와 같은 형식이다.

```json
instance_private_ips = {
  "admin_lb" = "172.31.4.90"
  "k8s_node1" = "172.31.1.127"
  "k8s_node2" = "172.31.2.170"
  "k8s_node3" = "172.31.2.118"
  "k8s_node4" = "172.31.7.101"
  "k8s_node5" = "172.31.1.69"
}
```

## admin-lb 초기화

### 기본 세팅
```bash
# /etc/host에 전체 서버 추가
cat << EOF >> /etc/hosts
172.31.4.90 admin-lb
172.31.1.127 k8s-node1
172.31.2.170 k8s-node2
172.31.2.118 k8s-node3
172.31.7.101 k8s-node4
172.31.1.69 k8s-node5
EOF

# disable firewalld and selinux
systemctl disable --now firewalld >/dev/null 2>&1
setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# install kubectl
cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubectl
EOF

dnf install -y -q kubectl --disableexcludes=kubernetes >/dev/null 2>&1

# install HAProxy
dnf install -y haproxy >/dev/null 2>&1

cat << EOF > /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

    # utilize system-wide crypto-policies
    ssl-default-bind-ciphers PROFILE=SYSTEM
    ssl-default-server-ciphers PROFILE=SYSTEM

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  tcplog
    option                  dontlognull
    option http-server-close
    #option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

# ---------------------------------------------------------------------
# Kubernetes API Server Load Balancer Configuration
# ---------------------------------------------------------------------
frontend k8s-api
    bind *:6443
    mode tcp
    option tcplog
    default_backend k8s-api-backend

backend k8s-api-backend
    mode tcp
    option tcp-check
    option log-health-checks
    timeout client 3h
    timeout server 3h
    balance roundrobin
    server k8s-node1 172.31.1.127:6443 check check-ssl verify none inter 10000
    server k8s-node2 172.31.2.170:6443 check check-ssl verify none inter 10000
    server k8s-node3 172.31.2.118:6443 check check-ssl verify none inter 10000

# ---------------------------------------------------------------------
# HAProxy Stats Dashboard - http://172.31.4.90:9000/haproxy_stats
# ---------------------------------------------------------------------
listen stats
    bind *:9000
    mode http
    stats enable
    stats uri /haproxy_stats
    stats realm HAProxy\ Statistic
    stats admin if TRUE

# ---------------------------------------------------------------------
# Configure the Prometheus exporter - curl http://172.31.4.90:8405/metrics
# ---------------------------------------------------------------------
frontend prometheus
    bind *:8405
    mode http
    http-request use-service prometheus-exporter if { path /metrics }
    no log
EOF

systemctl enable --now haproxy >/dev/null 2>&1

# install nfs utils
dnf install -y nfs-utils >/dev/null 2>&1
systemctl enable --now nfs-server >/dev/null 2>&1
mkdir -p /srv/nfs/share
chown nobody:nobody /srv/nfs/share
chmod 755 /srv/nfs/share
echo '/srv/nfs/share *(rw,async,no_root_squash,no_subtree_check)' > /etc/exports
exportfs -rav

# install packages
dnf install -y python3-pip git sshpass >/dev/null 2>&1

# setting SSH key
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa >/dev/null 2>&1

sshpass -p 'qwe123' ssh-copy-id -o StrictHostKeyChecking=no root@172.31.4.90  >/dev/null 2>&1
sshpass -p 'qwe123' ssh-copy-id -o StrictHostKeyChecking=no root@172.31.1.127  >/dev/null 2>&1
sshpass -p 'qwe123' ssh-copy-id -o StrictHostKeyChecking=no root@172.31.2.170  >/dev/null 2>&1
sshpass -p 'qwe123' ssh-copy-id -o StrictHostKeyChecking=no root@172.31.2.118  >/dev/null 2>&1
sshpass -p 'qwe123' ssh-copy-id -o StrictHostKeyChecking=no root@172.31.7.101  >/dev/null 2>&1
sshpass -p 'qwe123' ssh-copy-id -o StrictHostKeyChecking=no root@172.31.1.69  >/dev/null 2>&1

ssh -o StrictHostKeyChecking=no root@admin-lb hostname >/dev/null 2>&1
for (( i=1; i<=5; i++  )); do sshpass -p 'qwe123' ssh -o StrictHostKeyChecking=no root@k8s-node$i hostname >/dev/null 2>&1 ; done
```

### kubespray 초기 설정
```bash
[root@admin-lb ~]# git clone -b v2.29.1 https://github.com/kubernetes-sigs/kubespray.git /root/kubespray >/dev/null 2>&1

[root@admin-lb ~]# cp -rfp /root/kubespray/inventory/sample /root/kubespray/inventory/mycluster

cat << EOF > /root/kubespray/inventory/mycluster/inventory.ini
[kube_control_plane]
k8s-node1 ansible_host=172.31.1.127 ip=172.31.1.127 etcd_member_name=etcd1
k8s-node2 ansible_host=172.31.2.170 ip=172.31.2.170 etcd_member_name=etcd2
k8s-node3 ansible_host=172.31.2.118 ip=172.31.2.118 etcd_member_name=etcd3

[etcd:children]
kube_control_plane

[kube_node]
k8s-node4 ansible_host=172.31.7.101 ip=172.31.7.101
#k8s-node5 ansible_host=172.31.1.69 ip=172.31.1.69
EOF

# install python dependencies
[root@admin-lb ~]# pip3 install -r /root/kubespray/requirements.txt >/dev/null 2>&1
[root@admin-lb ~]# pip3 list
Package                   Version
------------------------- -----------
ansible                   10.7.0
ansible-core              2.17.14
attrs                     23.2.0
awscli                    2.27.0
awscrt                    0.27.2
cffi                      2.0.0
charset-normalizer        3.4.2
cloud-init                24.4
cockpit                   344
colorama                  0.4.6
configobj                 5.0.8
cryptography              46.0.2
dasbus                    1.7
dbus-python               1.3.2
distro                    1.9.0
dnf                       4.20.0
docutils                  0.20.1
file-magic                0.4.0
idna                      3.7
Jinja2                    3.1.6
jmespath                  1.0.1
jsonpatch                 1.33
jsonpointer               2.3
jsonschema                4.19.1
jsonschema-specifications 2023.11.2
libcomps                  0.1.21
libdnf                    0.73.1
MarkupSafe                2.1.3
netaddr                   1.3.0
oauthlib                  3.2.2
packaging                 24.2
pexpect                   4.9.0
pip                       23.3.2
ply                       3.11
prompt_toolkit            3.0.41
ptyprocess                0.7.0
pycparser                 2.20
PyGObject                 3.46.0
pyserial                  3.5
python-dateutil           2.9.0.post0
PyYAML                    6.0.1
pyynl                     0.0.1
referencing               0.31.1
requests                  2.32.4
resolvelib                1.0.1
rpds-py                   0.17.1
rpm                       4.19.1.1
ruamel.yaml               0.18.5
ruamel.yaml.clib          0.2.7
selinux                   3.9
sepolicy                  3.9
setools                   4.5.1
setroubleshoot            3.3.33
setuptools                69.0.3
six                       1.16.0
sos                       4.10.0
systemd-python            235
urllib3                   1.26.19
wcwidth                   0.2.6


# install k9s
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
wget -P /tmp https://github.com/derailed/k9s/releases/latest/download/k9s_linux_${CLI_ARCH}.tar.gz  >/dev/null 2>&1
tar -xzf /tmp/k9s_linux_${CLI_ARCH}.tar.gz -C /tmp
chown root:root /tmp/k9s
mv /tmp/k9s /usr/local/bin/
chmod +x /usr/local/bin/k9s

# install helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | DESIRED_VERSION=v3.18.6 bash >/dev/null 2>&1
```

## k8s-node1~5 초기화
- swap off, kernel 설정은 terraform으로 서버 초기화 시, bootstrap_user_data로 미리 세팅해주었기에 생략함.
- 

```bash
# 확인
[root@admin-lb ~]# for i in 1 2 3 4 5; do
    ssh -o StrictHostKeyChecking=no root@k8s-node$i "hostname"
done
k8s-node1
k8s-node2
k8s-node3
k8s-node4
k8s-node5

# 커널 모듈 반영을 위해 reboot 진행
for i in 1 2 3 4 5; do
    ssh -o StrictHostKeyChecking=no root@k8s-node$i "reboot 2>&1"
done

# /etc/hosts에 전체 서버 추가 (admin-lb에서 각 노드에 SSH로 적용)
for i in 1 2 3 4 5; do
    ssh -o StrictHostKeyChecking=no root@k8s-node$i "cat << EOF >> /etc/hosts
172.31.4.90 admin-lb
172.31.1.127 k8s-node1
172.31.2.170 k8s-node2
172.31.2.118 k8s-node3
172.31.7.101 k8s-node4
172.31.1.69 k8s-node5
EOF"
done

# disable firewalld and selinux
for i in 1 2 3 4 5; do
  ssh -o StrictHostKeyChecking=no root@k8s-node$i "systemctl disable --now firewalld >/dev/null 2>&1; setenforce 0; sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config"
done

# install nfs-utils
for i in 1 2 3 4 5; do
    ssh -o StrictHostKeyChecking=no root@k8s-node$i "dnf install -y git nfs-utils >/dev/null 2>&1"
done
```