# 실습용 EC2 환경 초기화

실습용 EC2 인스턴스 구성은 아래와 같다.
- region: ap-northeast-2
- Rocky Linux 10: ami-062748fa168ed7aca
- k8s-ctr: `t3.xlarge (4 vCPU, 16 GiB)`

terraform 커맨드 내용은 생략하고, 구성된 output은 아래와 같은 형식이다.

```json
instance_private_ips = {
  "k8s_ctr" = "172.31.9.85"
}
```

## 서버 내 추가적으로 필요한 구성 진행
```bash
# kernel_module 설치 확인을 위해, 한번 reboot해두기
[root@k8s-ctr ~]# reboot

# user 확인
[root@k8s-ctr ~]# whoami && pwd
root
/root

# Linux Kernel Requirements : 5.8+ 이상 권장
[root@k8s-ctr ~]# uname -a
Linux k8s-ctr 6.12.0-124.28.1.el10_1.x86_64 #1 SMP PREEMPT_DYNAMIC Fri Jan 23 13:37:15 UTC 2026 x86_64 GNU/Linux

# Python : 3.10 ~ 3.12 : (참고) bento/rockylinux-9 경우 3.9
[root@k8s-ctr ~]# which python  && python -V
/usr/bin/python
Python 3.12.11
[root@k8s-ctr ~]# which python3 && python3 -V
/usr/bin/python3
Python 3.12.11

# pip , git 설치
dnf install -y python3-pip git

[root@k8s-ctr ~]# which pip  && pip -V
/usr/bin/pip
pip 23.3.2 from /usr/lib/python3.12/site-packages/pip (python 3.12)

[root@k8s-ctr ~]# which pip3 && pip3 -V
/usr/bin/pip3
pip 23.3.2 from /usr/lib/python3.12/site-packages/pip (python 3.12)

# /etc/hosts 확인
[root@k8s-ctr ~]# cat /etc/hosts
# Loopback entries; do not change.
# For historical reasons, localhost precedes localhost.localdomain:
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# See hosts(5) for proper format and other examples:
# 192.168.1.10 foo.example.org foo
# 192.168.1.13 bar.example.org bar
172.31.9.85 k8s-ctr
```