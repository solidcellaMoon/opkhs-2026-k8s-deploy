# 실습용 EC2 환경 초기화

실습용 EC2 인스턴스 구성은 아래와 같다.
- region: ap-northeast-2
- Rocky Linux 9: ami-06b18c6a9a323f75f
- k8s-ctr: `t3.xlarge (4 vCPU, 16 GiB)`
- k8s-w1, k8s-w2: `t3.medium (2 vCPU, 4 GiB)`

terraform 커맨드 내용은 생략하고, 구성된 output은 아래와 같은 형식이다.

```json
instance_private_ips = {
  "k8s_ctr" = "172.31.7.91"
  "k8s_w1" = "172.31.8.194"
  "k8s_w2" = "172.31.5.17"
}
```

## 서버 내 추가적으로 필요한 구성 진행
- 모든 EC2의 `/etc/hosts` 파일 수정
- 모든 EC2의 hostname을 `hostnamectl`로 사전 변경

모든 EC2의 `/etc/hosts` 파일을 수정한다.
```bash
# k8s-ctr 용도의 EC2 접속 후, /etc/hosts에 아래처럼 추가
cat << EOF >> /etc/hosts
172.31.7.91 k8s-ctr
172.31.8.194 k8s-w1
172.31.5.17 k8s-w2
EOF

# 다른 노드에도 세팅
for host in k8s-w1 k8s-w2; do
  ssh root@"$host" 'bash -s' <<'EOF'
set -e

echo "== /etc/hosts (before) =="
cat /etc/hosts

# 이미 들어갔으면 다시 추가하지 않는다.
if ! grep -q 'tnode' /etc/hosts; then
  cat <<'EOT' >> /etc/hosts
172.31.7.91 k8s-ctr
172.31.8.194 k8s-w1
172.31.5.17 k8s-w2
EOT
fi

echo "== /etc/hosts (after) =="
cat /etc/hosts
EOF
done
```

모든 EC2의 hostname을 `hostnamectl`로 사전 변경한다.
```bash
# k8s-ctr 용도의 EC2 접속 후, hostname 변경
hostnamectl set-hostname k8s-ctr
exit

# k8s-w1 용도의 EC2 접속 후, hostname 변경
hostnamectl set-hostname k8s-w1
exit

# k8s-w2 용도의 EC2 접속 후, hostname 변경
hostnamectl set-hostname k8s-w2
exit
```