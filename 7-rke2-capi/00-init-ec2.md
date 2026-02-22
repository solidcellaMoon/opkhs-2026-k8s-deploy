# 실습용 EC2 환경 초기화

실습용 EC2 인스턴스 구성은 아래와 같다.
- region: ap-northeast-2
- Rocky Linux 9: ami-06b18c6a9a323f75f
- k8s-node1~2: `t3.medium (2 vCPU, 4 GiB)`

terraform 커맨드 내용은 생략하고, 구성된 output은 아래와 같은 형식이다.

```json
instance_private_ips = {
  "k8s_node1" = "172.31.1.135"
  "k8s_node2" = "172.31.2.251"
}
```

## 기본 세팅
```bash
# /etc/host에 전체 서버 추가
cat << EOF >> /etc/hosts
172.31.1.135 k8s-node1
172.31.2.251 k8s-node2
EOF

# disable firewalld and selinux
systemctl disable --now firewalld >/dev/null 2>&1
setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# install k9s
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
wget -P /tmp https://github.com/derailed/k9s/releases/latest/download/k9s_linux_${CLI_ARCH}.tar.gz  >/dev/null 2>&1
tar -xzf /tmp/k9s_linux_${CLI_ARCH}.tar.gz -C /tmp
chown root:root /tmp/k9s
mv /tmp/k9s /usr/local/bin/
chmod +x /usr/local/bin/k9s

# helm 3 설치 : https://helm.sh/docs/intro/install
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | DESIRED_VERSION=v3.18.6 bash
helm version
```