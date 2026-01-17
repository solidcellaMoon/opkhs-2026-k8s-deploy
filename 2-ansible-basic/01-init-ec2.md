# 실습용 EC2 환경 초기화

실습용 EC2 인스턴스는 모두 `t3.small (2 vCPU, 2 GiB)` 로 생성한다.
- region: ap-northeast-2
- Ubuntu 24.04: ami-0a71e3eb8b23101ed
- Rocky Linux 9: ami-06b18c6a9a323f75f

| Node   | OS            | Kernel | vCPU | Memory | Disk | 관리자 계정        | (기본) 일반 계정       |
| ------ | ------------- | ------ | ---- | ------ | ---- | ------------- | ---------------- |
| server | Ubuntu 24.04  | 6.14.0  | 2    | 2GiB  | 30GB | root / qwe123 | labadmin / qwe123 |
| tnode1 | Ubuntu 24.04  | 6.14.0  | 2    | 2GiB  | 30GB | root / qwe123 | labadmin / qwe123 |
| tnode2 | Ubuntu 24.04  | 6.14.0  | 2    | 2GiB  | 30GB | root / qwe123 | labadmin / qwe123 |
| tnode3 | Rocky Linux 9 | 5.14.0 | 2    | 2GiB  | 60GB | root / qwe123 | labadmin / qwe123 |

terraform 커맨드 내용은 생략하고, 구성된 output은 아래와 같은 형식이다.

```json
instance_ids = {
  "server" = "i-(생략)"
  "tnode1" = "i-(생략)"
  "tnode2" = "i-(생략)"
  "tnode3" = "i-(생략)"
}
instance_private_ips = {
  "server" = "172.31.14.64"
  "tnode1" = "172.31.3.86"
  "tnode2" = "172.31.3.42"
  "tnode3" = "172.31.5.232"
}
instance_public_ips = {
  "server" = "생략"
  "tnode1" = "생략"
  "tnode2" = "생략"
  "tnode3" = "생략"
}
```

## 서버 내 추가적으로 필요한 구성 진행
- 모든 EC2의 `/etc/hosts` 파일 수정
- 모든 EC2의 hostname을 `hostnamectl`로 사전 변경

모든 EC2의 `/etc/hosts` 파일을 수정한다.
```bash
# server 용도의 EC2 접속 후, /etc/hosts에 아래처럼 추가
root@ip-172-31-14-64:~# cat /etc/hosts
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts

root@ip-172-31-14-64:~# cat << EOF >> /etc/hosts
172.31.14.64 server
172.31.3.86 tnode1
172.31.3.42 tnode2
172.31.5.232 tnode3
EOF

root@ip-172-31-14-64:~# cat /etc/hosts
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
172.31.14.64 server
172.31.3.86 tnode1
172.31.3.42 tnode2
172.31.5.232 tnode3

root@ip-172-31-14-64:~#
for host in tnode1 tnode2 tnode3; do
  ssh root@"$host" 'bash -s' <<'EOF'
set -e

echo "== /etc/hosts (before) =="
cat /etc/hosts

# 이미 들어갔으면 다시 추가하지 않는다.
if ! grep -q 'tnode' /etc/hosts; then
  cat <<'EOT' >> /etc/hosts
172.31.14.64 server
172.31.3.86 tnode1
172.31.3.42 tnode2
172.31.5.232 tnode3
EOT
fi

echo "== /etc/hosts (after) =="
cat /etc/hosts
EOF
done
```

모든 EC2의 hostname을 `hostnamectl`로 사전 변경한다.
```bash
# server 용도의 EC2 접속 후, hostname 변경
root@ip-172-31-14-64:~# hostnamectl set-hostname server
root@ip-172-31-14-64:~# exit

# tnode1 용도의 EC2 접속 후, hostname 변경
root@ip-172-31-3-86:~# hostnamectl set-hostname tnode1
root@ip-172-31-3-86:~# exit

# tnode2 용도의 EC2 접속 후, hostname 변경
root@ip-172-31-3-42:~# hostnamectl set-hostname tnode2
root@ip-172-31-3-42:~# exit

# tnode3 용도의 EC2 접속 후, hostname 변경
root@ip-172-31-5-232:~# hostnamectl set-hostname tnode3
root@ip-172-31-5-232:~# exit
```