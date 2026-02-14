# 실습용 EC2 환경 초기화

실습용 EC2 인스턴스 구성은 아래와 같다.
- region: ap-northeast-2
- Rocky Linux 10: ami-062748fa168ed7aca
- k8s-ctr1: `t3.medium (2 vCPU, 4 GiB)`, root device 120GB
- k8s-node1~2: `t3.medium (2 vCPU, 4 GiB)`

terraform 커맨드 내용은 생략하고, 구성된 output은 아래와 같은 형식이다.

```json
instance_private_ips = {
  "k8s_ctr1" = "172.31.15.62"
  "k8s_node1" = "172.31.10.148"
  "k8s_node2" = "172.31.5.220"
}
```

## 기본 세팅 (대상: 모든 서버)
- k8s-ctr1에서 세팅한다.

```bash
# /etc/host에 전체 서버 추가
cat << EOF >> /etc/hosts
172.31.8.124 k8s-ctr1
172.31.10.148 k8s-node1
172.31.5.220 k8s-node2
EOF

# 커널 모듈 반영을 위해 reboot 진행
for i in 1 2; do
    ssh -o StrictHostKeyChecking=no root@k8s-node$i "reboot 2>&1"
done
```

## k8s-ctr1 기본 세팅
k9s 미리 설치.
```bash
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
wget -P /tmp https://github.com/derailed/k9s/releases/latest/download/k9s_linux_${CLI_ARCH}.tar.gz  >/dev/null 2>&1
tar -xzf /tmp/k9s_linux_${CLI_ARCH}.tar.gz -C /tmp
chown root:root /tmp/k9s
mv /tmp/k9s /usr/local/bin/
chmod +x /usr/local/bin/k9s
```