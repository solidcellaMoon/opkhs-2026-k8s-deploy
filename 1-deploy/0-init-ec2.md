
# EC2

- EC2 인스턴스는 모두 `t3.small (2 vCPU, 2 GiB)` 로 생성한다.

| NAME | Description | CPU | RAM | NIC1 | NIC2 | HOSTNAME |
| --- | --- | --- | --- | --- | --- | --- |
| jumpbox | Administration host | 2 | 1536 MB | 10.0.2.15 | **192.168.10.10** | **jumpbox** |
| server | Kubernetes server | 2 | 2GB | 10.0.2.15 | **192.168.10.100** | server.kubernetes.local **server** |
| node-0 | Kubernetes worker  | 2 | 2GB | 10.0.2.15 | **192.168.10.101** | node-0.kubernetes.local **node-0** |
| node-1 | Kubernetes worker  | 2 | 2GB | 10.0.2.15 | **192.168.10.102** | node-1.kubernetes.local **node-1** |

```bash
Apply complete! Resources: 0 added, 4 changed, 0 destroyed.

Outputs:

instance_ids = {
  "jumpbox" = "i-{jumphost_id}"
  "node-0" = "i-{node-0_id}"
  "node-1" = "i-{node-1_id}"
  "server" = "i-{server_id}"
}
instance_private_ips = {
  "jumpbox" = "172.31.8.16"
  "node-0" = "172.31.0.153"
  "node-1" = "172.31.9.15"
  "server" = "172.31.11.199"
}
instance_public_ips = {
  "jumpbox" = "생략"
  "node-0" = "생략"
  "node-1" = "생략"
  "server" = "생략"
}
```


## jumphost

```bash
❯ aws ssm start-session --target i-{jumphost_id}
$ sudo su -
root@ip-172-31-8-16:~#

root@ip-172-31-8-16:~# whoami
root

root@ip-172-31-8-16:~# pwd
/root

root@ip-172-31-8-16:~# cat /etc/os-release
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

root@ip-172-31-8-16:~# aa-status
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

root@ip-172-31-8-16:~# systemctl is-active apparmor
active # 응!? ㅠㅠ

root@ip-172-31-8-16:~# systemctl stop apparmor
root@ip-172-31-8-16:~# systemctl is-active apparmor
inactive
root@ip-172-31-8-16:~# systemctl disable apparmor
Synchronizing state of apparmor.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install disable apparmor
Removed '/etc/systemd/system/sysinit.target.wants/apparmor.service'.

```

```bash
# Sync GitHub Repository
root@ip-172-31-8-16:~# pwd
/root

root@ip-172-31-8-16:~# git clone --depth 1 https://github.com/kelseyhightower/kubernetes-the-hard-way.git
Cloning into 'kubernetes-the-hard-way'...
remote: Enumerating objects: 41, done.
remote: Counting objects: 100% (41/41), done.
remote: Compressing objects: 100% (40/40), done.
remote: Total 41 (delta 3), reused 14 (delta 1), pack-reused 0 (from 0)
Receiving objects: 100% (41/41), 29.27 KiB | 7.32 MiB/s, done.
Resolving deltas: 100% (3/3), done.


root@ip-172-31-8-16:~# cd kubernetes-the-hard-way && tree
.
├── CONTRIBUTING.md
├── COPYRIGHT.md
├── LICENSE
├── README.md
├── ca.conf
├── configs
│   ├── 10-bridge.conf
│   ├── 99-loopback.conf
│   ├── containerd-config.toml
│   ├── encryption-config.yaml
│   ├── kube-apiserver-to-kubelet.yaml
│   ├── kube-proxy-config.yaml
│   ├── kube-scheduler.yaml
│   └── kubelet-config.yaml
├── docs
│   ├── 01-prerequisites.md
│   ├── 02-jumpbox.md
│   ├── 03-compute-resources.md
│   ├── 04-certificate-authority.md
│   ├── 05-kubernetes-configuration-files.md
│   ├── 06-data-encryption-keys.md
│   ├── 07-bootstrapping-etcd.md
│   ├── 08-bootstrapping-kubernetes-controllers.md
│   ├── 09-bootstrapping-kubernetes-workers.md
│   ├── 10-configuring-kubectl.md
│   ├── 11-pod-network-routes.md
│   ├── 12-smoke-test.md
│   └── 13-cleanup.md
├── downloads-amd64.txt
├── downloads-arm64.txt
└── units
    ├── containerd.service
    ├── etcd.service
    ├── kube-apiserver.service
    ├── kube-controller-manager.service
    ├── kube-proxy.service
    ├── kube-scheduler.service
    └── kubelet.service

4 directories, 35 files

root@ip-172-31-8-16:~/kubernetes-the-hard-way# pwd
/root/kubernetes-the-hard-way

# ---

# Download Binaries : k8s 구성을 위한 컴포넌트 다운로드

# CPU 아키텍처 확인
root@ip-172-31-8-16:~/kubernetes-the-hard-way# dpkg --print-architecture
amd64

# CPU 아키텍처 별 다운로드 목록 정보 다름
root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -l downloads-*
-rw-r--r-- 1 root root 839 Jan  4 14:46 downloads-amd64.txt
-rw-r--r-- 1 root root 839 Jan  4 14:46 downloads-arm64.txt

# https://kubernetes.io/releases/download/
root@ip-172-31-8-16:~/kubernetes-the-hard-way# cat downloads-$(dpkg --print-architecture).txt
https://dl.k8s.io/v1.32.3/bin/linux/amd64/kubectl
https://dl.k8s.io/v1.32.3/bin/linux/amd64/kube-apiserver
https://dl.k8s.io/v1.32.3/bin/linux/amd64/kube-controller-manager
https://dl.k8s.io/v1.32.3/bin/linux/amd64/kube-scheduler
https://dl.k8s.io/v1.32.3/bin/linux/amd64/kube-proxy
https://dl.k8s.io/v1.32.3/bin/linux/amd64/kubelet
https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.32.0/crictl-v1.32.0-linux-amd64.tar.gz
https://github.com/opencontainers/runc/releases/download/v1.3.0-rc.1/runc.amd64
https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz
https://github.com/containerd/containerd/releases/download/v2.1.0-beta.0/containerd-2.1.0-beta.0-linux-amd64.tar.gz
https://github.com/etcd-io/etcd/releases/download/v3.6.0-rc.3/etcd-v3.6.0-rc.3-linux-amd64.tar.gz

# wget 으로 다운로드 실행 : 500MB Size 정도
root@ip-172-31-8-16:~/kubernetes-the-hard-way# wget -q --show-progress \
  --https-only \
  --timestamping \
  -P downloads \
  -i downloads-$(dpkg --print-architecture).txt

kubectl                                    100%[========================================================================================>]  54.67M   112MB/s    in 0.5s    
kube-apiserver                             100%[========================================================================================>]  88.94M  5.37MB/s    in 13s     
kube-controller-manager                    100%[========================================================================================>]  82.00M  5.66MB/s    in 13s     
kube-scheduler                             100%[========================================================================================>]  62.79M  6.11MB/s    in 11s     
kube-proxy                                 100%[========================================================================================>]  63.75M  6.01MB/s    in 11s     
kubelet                                    100%[========================================================================================>]  73.82M  5.69MB/s    in 15s     
crictl-v1.32.0-linux-amd64.tar.gz          100%[========================================================================================>]  18.21M  78.5MB/s    in 0.2s    
runc.amd64                                 100%[========================================================================================>]  11.30M  53.0MB/s    in 0.2s    
cni-plugins-linux-amd64-v1.6.2.tgz         100%[========================================================================================>]  50.35M  32.5MB/s    in 1.6s    
containerd-2.1.0-beta.0-linux-amd64.tar.gz 100%[========================================================================================>]  37.01M  59.1MB/s    in 0.6s    
etcd-v3.6.0-rc.3-linux-amd64.tar.gz        100%[========================================================================================>]  22.48M  17.5MB/s    in 1.3s    

# 확인
root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -oh downloads
total 566M
-rw-r--r-- 1 root 51M Jan  6  2025 cni-plugins-linux-amd64-v1.6.2.tgz
-rw-r--r-- 1 root 38M Mar 18  2025 containerd-2.1.0-beta.0-linux-amd64.tar.gz
-rw-r--r-- 1 root 19M Dec  9  2024 crictl-v1.32.0-linux-amd64.tar.gz
-rw-r--r-- 1 root 23M Mar 27  2025 etcd-v3.6.0-rc.3-linux-amd64.tar.gz
-rw-r--r-- 1 root 89M Mar 12  2025 kube-apiserver
-rw-r--r-- 1 root 83M Mar 12  2025 kube-controller-manager
-rw-r--r-- 1 root 64M Mar 12  2025 kube-proxy
-rw-r--r-- 1 root 63M Mar 12  2025 kube-scheduler
-rw-r--r-- 1 root 55M Mar 12  2025 kubectl
-rw-r--r-- 1 root 74M Mar 12  2025 kubelet
-rw-r--r-- 1 root 12M Mar  4  2025 runc.amd64

# Extract the component binaries from the release archives and organize them under the downloads directory.
root@ip-172-31-8-16:~/kubernetes-the-hard-way# ARCH=$(dpkg --print-architecture)
root@ip-172-31-8-16:~/kubernetes-the-hard-way# echo $ARCH
amd64

root@ip-172-31-8-16:~/kubernetes-the-hard-way# mkdir -p downloads/{client,cni-plugins,controller,worker}
root@ip-172-31-8-16:~/kubernetes-the-hard-way# tree -d downloads
downloads
├── client
├── cni-plugins
├── controller
└── worker

5 directories

# 압축 풀기
root@ip-172-31-8-16:~/kubernetes-the-hard-way# tar -xvf downloads/crictl-v1.32.0-linux-${ARCH}.tar.gz \
  -C downloads/worker/ && tree -ug downloads
crictl
[root     root    ]  downloads
├── [root     root    ]  client
├── [root     root    ]  cni-plugins
├── [root     root    ]  cni-plugins-linux-amd64-v1.6.2.tgz
├── [root     root    ]  containerd-2.1.0-beta.0-linux-amd64.tar.gz
├── [root     root    ]  controller
├── [root     root    ]  crictl-v1.32.0-linux-amd64.tar.gz
├── [root     root    ]  etcd-v3.6.0-rc.3-linux-amd64.tar.gz
├── [root     root    ]  kube-apiserver
├── [root     root    ]  kube-controller-manager
├── [root     root    ]  kube-proxy
├── [root     root    ]  kube-scheduler
├── [root     root    ]  kubectl
├── [root     root    ]  kubelet
├── [root     root    ]  runc.amd64
└── [root     root    ]  worker
    └── [ssm-user 127     ]  crictl

5 directories, 12 files


root@ip-172-31-8-16:~/kubernetes-the-hard-way# tar -xvf downloads/containerd-2.1.0-beta.0-linux-${ARCH}.tar.gz \
  --strip-components 1 \
  -C downloads/worker/ && tree -ug downloads
bin/containerd-shim-runc-v2
bin/containerd
bin/containerd-stress
bin/ctr
[root     root    ]  downloads
├── [root     root    ]  client
├── [root     root    ]  cni-plugins
├── [root     root    ]  cni-plugins-linux-amd64-v1.6.2.tgz
├── [root     root    ]  containerd-2.1.0-beta.0-linux-amd64.tar.gz
├── [root     root    ]  controller
├── [root     root    ]  crictl-v1.32.0-linux-amd64.tar.gz
├── [root     root    ]  etcd-v3.6.0-rc.3-linux-amd64.tar.gz
├── [root     root    ]  kube-apiserver
├── [root     root    ]  kube-controller-manager
├── [root     root    ]  kube-proxy
├── [root     root    ]  kube-scheduler
├── [root     root    ]  kubectl
├── [root     root    ]  kubelet
├── [root     root    ]  runc.amd64
└── [root     root    ]  worker
    ├── [root     root    ]  containerd
    ├── [root     root    ]  containerd-shim-runc-v2
    ├── [root     root    ]  containerd-stress
    ├── [ssm-user 127     ]  crictl
    └── [root     root    ]  ctr

5 directories, 16 files


root@ip-172-31-8-16:~/kubernetes-the-hard-way# tar -xvf downloads/cni-plugins-linux-${ARCH}-v1.6.2.tgz \
  -C downloads/cni-plugins/ && tree -ug downloads
./
./ipvlan
./tap
./loopback
./host-device
./README.md
./portmap
./ptp
./vlan
./bridge
./firewall
./LICENSE
./macvlan
./dummy
./bandwidth
./vrf
./tuning
./static
./dhcp
./host-local
./sbr
[root     root    ]  downloads
├── [root     root    ]  client
├── [root     root    ]  cni-plugins
│   ├── [root     root    ]  LICENSE
│   ├── [root     root    ]  README.md
│   ├── [root     root    ]  bandwidth
│   ├── [root     root    ]  bridge
│   ├── [root     root    ]  dhcp
│   ├── [root     root    ]  dummy
│   ├── [root     root    ]  firewall
│   ├── [root     root    ]  host-device
│   ├── [root     root    ]  host-local
│   ├── [root     root    ]  ipvlan
│   ├── [root     root    ]  loopback
│   ├── [root     root    ]  macvlan
│   ├── [root     root    ]  portmap
│   ├── [root     root    ]  ptp
│   ├── [root     root    ]  sbr
│   ├── [root     root    ]  static
│   ├── [root     root    ]  tap
│   ├── [root     root    ]  tuning
│   ├── [root     root    ]  vlan
│   └── [root     root    ]  vrf
├── [root     root    ]  cni-plugins-linux-amd64-v1.6.2.tgz
├── [root     root    ]  containerd-2.1.0-beta.0-linux-amd64.tar.gz
├── [root     root    ]  controller
├── [root     root    ]  crictl-v1.32.0-linux-amd64.tar.gz
├── [root     root    ]  etcd-v3.6.0-rc.3-linux-amd64.tar.gz
├── [root     root    ]  kube-apiserver
├── [root     root    ]  kube-controller-manager
├── [root     root    ]  kube-proxy
├── [root     root    ]  kube-scheduler
├── [root     root    ]  kubectl
├── [root     root    ]  kubelet
├── [root     root    ]  runc.amd64
└── [root     root    ]  worker
    ├── [root     root    ]  containerd
    ├── [root     root    ]  containerd-shim-runc-v2
    ├── [root     root    ]  containerd-stress
    ├── [ssm-user 127     ]  crictl
    └── [root     root    ]  ctr

5 directories, 36 files


## --strip-components 1 : etcd-v3.6.0-rc.3-linux-amd64/etcd 경로의 앞부분(디렉터리)을 제거
root@ip-172-31-8-16:~/kubernetes-the-hard-way# tar -xvf downloads/etcd-v3.6.0-rc.3-linux-${ARCH}.tar.gz \
  -C downloads/ \
  --strip-components 1 \
  etcd-v3.6.0-rc.3-linux-${ARCH}/etcdctl \
  etcd-v3.6.0-rc.3-linux-${ARCH}/etcd && tree -ug downloads
etcd-v3.6.0-rc.3-linux-amd64/etcdctl
etcd-v3.6.0-rc.3-linux-amd64/etcd
[root     root    ]  downloads
├── [root     root    ]  client
├── [root     root    ]  cni-plugins
│   ├── [root     root    ]  LICENSE
│   ├── [root     root    ]  README.md
│   ├── [root     root    ]  bandwidth
│   ├── [root     root    ]  bridge
│   ├── [root     root    ]  dhcp
│   ├── [root     root    ]  dummy
│   ├── [root     root    ]  firewall
│   ├── [root     root    ]  host-device
│   ├── [root     root    ]  host-local
│   ├── [root     root    ]  ipvlan
│   ├── [root     root    ]  loopback
│   ├── [root     root    ]  macvlan
│   ├── [root     root    ]  portmap
│   ├── [root     root    ]  ptp
│   ├── [root     root    ]  sbr
│   ├── [root     root    ]  static
│   ├── [root     root    ]  tap
│   ├── [root     root    ]  tuning
│   ├── [root     root    ]  vlan
│   └── [root     root    ]  vrf
├── [root     root    ]  cni-plugins-linux-amd64-v1.6.2.tgz
├── [root     root    ]  containerd-2.1.0-beta.0-linux-amd64.tar.gz
├── [root     root    ]  controller
├── [root     root    ]  crictl-v1.32.0-linux-amd64.tar.gz
├── [admin    admin   ]  etcd
├── [root     root    ]  etcd-v3.6.0-rc.3-linux-amd64.tar.gz
├── [admin    admin   ]  etcdctl
├── [root     root    ]  kube-apiserver
├── [root     root    ]  kube-controller-manager
├── [root     root    ]  kube-proxy
├── [root     root    ]  kube-scheduler
├── [root     root    ]  kubectl
├── [root     root    ]  kubelet
├── [root     root    ]  runc.amd64
└── [root     root    ]  worker
    ├── [root     root    ]  containerd
    ├── [root     root    ]  containerd-shim-runc-v2
    ├── [root     root    ]  containerd-stress
    ├── [ssm-user 127     ]  crictl
    └── [root     root    ]  ctr

5 directories, 38 files

# 확인
root@ip-172-31-8-16:~/kubernetes-the-hard-way# tree downloads/worker/
downloads/worker/
├── containerd
├── containerd-shim-runc-v2
├── containerd-stress
├── crictl
└── ctr

1 directory, 5 files

root@ip-172-31-8-16:~/kubernetes-the-hard-way# tree downloads/cni-plugins
downloads/cni-plugins
├── LICENSE
├── README.md
├── bandwidth
├── bridge
├── dhcp
├── dummy
├── firewall
├── host-device
├── host-local
├── ipvlan
├── loopback
├── macvlan
├── portmap
├── ptp
├── sbr
├── static
├── tap
├── tuning
├── vlan
└── vrf

1 directory, 20 files

root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -l downloads/{etcd,etcdctl}
-rwxr-xr-x 1 admin admin 25219224 Mar 27  2025 downloads/etcd
-rwxr-xr-x 1 admin admin 16421016 Mar 27  2025 downloads/etcdctl

# 파일 이동 
root@ip-172-31-8-16:~/kubernetes-the-hard-way# mv downloads/{etcdctl,kubectl} downloads/client/
root@ip-172-31-8-16:~/kubernetes-the-hard-way# mv downloads/{etcd,kube-apiserver,kube-controller-manager,kube-scheduler} downloads/controller/
root@ip-172-31-8-16:~/kubernetes-the-hard-way# mv downloads/{kubelet,kube-proxy} downloads/worker/
root@ip-172-31-8-16:~/kubernetes-the-hard-way# mv downloads/runc.${ARCH} downloads/worker/runc

# 확인
root@ip-172-31-8-16:~/kubernetes-the-hard-way# tree downloads/client/
downloads/client/
├── etcdctl
└── kubectl

1 directory, 2 files

root@ip-172-31-8-16:~/kubernetes-the-hard-way# tree downloads/controller/
downloads/controller/
├── etcd
├── kube-apiserver
├── kube-controller-manager
└── kube-scheduler

1 directory, 4 files

root@ip-172-31-8-16:~/kubernetes-the-hard-way# tree downloads/worker/
downloads/worker/
├── containerd
├── containerd-shim-runc-v2
├── containerd-stress
├── crictl
├── ctr
├── kube-proxy
├── kubelet
└── runc

1 directory, 8 files


# 불필요한 압축 파일 제거
root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -l downloads/*gz
-rw-r--r-- 1 root root 52794236 Jan  6  2025 downloads/cni-plugins-linux-amd64-v1.6.2.tgz
-rw-r--r-- 1 root root 38807044 Mar 18  2025 downloads/containerd-2.1.0-beta.0-linux-amd64.tar.gz
-rw-r--r-- 1 root root 19100418 Dec  9  2024 downloads/crictl-v1.32.0-linux-amd64.tar.gz
-rw-r--r-- 1 root root 23577153 Mar 27  2025 downloads/etcd-v3.6.0-rc.3-linux-amd64.tar.gz

root@ip-172-31-8-16:~/kubernetes-the-hard-way# rm -rf downloads/*gz


# Make the binaries executable.
root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -l downloads/{client,cni-plugins,controller,worker}/*
-rwxr-xr-x 1 admin    admin 16421016 Mar 27  2025 downloads/client/etcdctl
-rw-r--r-- 1 root     root  57323672 Mar 12  2025 downloads/client/kubectl
-rw-r--r-- 1 root     root     11357 Jan  6  2025 downloads/cni-plugins/LICENSE
-rw-r--r-- 1 root     root      2343 Jan  6  2025 downloads/cni-plugins/README.md
-rwxr-xr-x 1 root     root   4655178 Jan  6  2025 downloads/cni-plugins/bandwidth
-rwxr-xr-x 1 root     root   5287212 Jan  6  2025 downloads/cni-plugins/bridge
-rwxr-xr-x 1 root     root  12762814 Jan  6  2025 downloads/cni-plugins/dhcp
-rwxr-xr-x 1 root     root   4847854 Jan  6  2025 downloads/cni-plugins/dummy
-rwxr-xr-x 1 root     root   5315134 Jan  6  2025 downloads/cni-plugins/firewall
-rwxr-xr-x 1 root     root   4792010 Jan  6  2025 downloads/cni-plugins/host-device
-rwxr-xr-x 1 root     root   4060355 Jan  6  2025 downloads/cni-plugins/host-local
-rwxr-xr-x 1 root     root   4870719 Jan  6  2025 downloads/cni-plugins/ipvlan
-rwxr-xr-x 1 root     root   4114939 Jan  6  2025 downloads/cni-plugins/loopback
-rwxr-xr-x 1 root     root   4903324 Jan  6  2025 downloads/cni-plugins/macvlan
-rwxr-xr-x 1 root     root   4713429 Jan  6  2025 downloads/cni-plugins/portmap
-rwxr-xr-x 1 root     root   5076613 Jan  6  2025 downloads/cni-plugins/ptp
-rwxr-xr-x 1 root     root   4333422 Jan  6  2025 downloads/cni-plugins/sbr
-rwxr-xr-x 1 root     root   3651755 Jan  6  2025 downloads/cni-plugins/static
-rwxr-xr-x 1 root     root   4928874 Jan  6  2025 downloads/cni-plugins/tap
-rwxr-xr-x 1 root     root   4208424 Jan  6  2025 downloads/cni-plugins/tuning
-rwxr-xr-x 1 root     root   4868252 Jan  6  2025 downloads/cni-plugins/vlan
-rwxr-xr-x 1 root     root   4488658 Jan  6  2025 downloads/cni-plugins/vrf
-rwxr-xr-x 1 admin    admin 25219224 Mar 27  2025 downloads/controller/etcd
-rw-r--r-- 1 root     root  93261976 Mar 12  2025 downloads/controller/kube-apiserver
-rw-r--r-- 1 root     root  85987480 Mar 12  2025 downloads/controller/kube-controller-manager
-rw-r--r-- 1 root     root  65843352 Mar 12  2025 downloads/controller/kube-scheduler
-rwxr-xr-x 1 root     root  58584656 Mar 18  2025 downloads/worker/containerd
-rwxr-xr-x 1 root     root   8253624 Mar 18  2025 downloads/worker/containerd-shim-runc-v2
-rwxr-xr-x 1 root     root  22929761 Mar 18  2025 downloads/worker/containerd-stress
-rwxr-xr-x 1 ssm-user   127 40076447 Dec  9  2024 downloads/worker/crictl
-rwxr-xr-x 1 root     root  23830881 Mar 18  2025 downloads/worker/ctr
-rw-r--r-- 1 root     root  66842776 Mar 12  2025 downloads/worker/kube-proxy
-rw-r--r-- 1 root     root  77406468 Mar 12  2025 downloads/worker/kubelet
-rw-r--r-- 1 root     root  11854432 Mar  4  2025 downloads/worker/runc

root@ip-172-31-8-16:~/kubernetes-the-hard-way# chmod +x downloads/{client,cni-plugins,controller,worker}/*

root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -l downloads/{client,cni-plugins,controller,worker}/*
-rwxr-xr-x 1 admin    admin 16421016 Mar 27  2025 downloads/client/etcdctl
-rwxr-xr-x 1 root     root  57323672 Mar 12  2025 downloads/client/kubectl
-rwxr-xr-x 1 root     root     11357 Jan  6  2025 downloads/cni-plugins/LICENSE
-rwxr-xr-x 1 root     root      2343 Jan  6  2025 downloads/cni-plugins/README.md
-rwxr-xr-x 1 root     root   4655178 Jan  6  2025 downloads/cni-plugins/bandwidth
-rwxr-xr-x 1 root     root   5287212 Jan  6  2025 downloads/cni-plugins/bridge
-rwxr-xr-x 1 root     root  12762814 Jan  6  2025 downloads/cni-plugins/dhcp
-rwxr-xr-x 1 root     root   4847854 Jan  6  2025 downloads/cni-plugins/dummy
-rwxr-xr-x 1 root     root   5315134 Jan  6  2025 downloads/cni-plugins/firewall
-rwxr-xr-x 1 root     root   4792010 Jan  6  2025 downloads/cni-plugins/host-device
-rwxr-xr-x 1 root     root   4060355 Jan  6  2025 downloads/cni-plugins/host-local
-rwxr-xr-x 1 root     root   4870719 Jan  6  2025 downloads/cni-plugins/ipvlan
-rwxr-xr-x 1 root     root   4114939 Jan  6  2025 downloads/cni-plugins/loopback
-rwxr-xr-x 1 root     root   4903324 Jan  6  2025 downloads/cni-plugins/macvlan
-rwxr-xr-x 1 root     root   4713429 Jan  6  2025 downloads/cni-plugins/portmap
-rwxr-xr-x 1 root     root   5076613 Jan  6  2025 downloads/cni-plugins/ptp
-rwxr-xr-x 1 root     root   4333422 Jan  6  2025 downloads/cni-plugins/sbr
-rwxr-xr-x 1 root     root   3651755 Jan  6  2025 downloads/cni-plugins/static
-rwxr-xr-x 1 root     root   4928874 Jan  6  2025 downloads/cni-plugins/tap
-rwxr-xr-x 1 root     root   4208424 Jan  6  2025 downloads/cni-plugins/tuning
-rwxr-xr-x 1 root     root   4868252 Jan  6  2025 downloads/cni-plugins/vlan
-rwxr-xr-x 1 root     root   4488658 Jan  6  2025 downloads/cni-plugins/vrf
-rwxr-xr-x 1 admin    admin 25219224 Mar 27  2025 downloads/controller/etcd
-rwxr-xr-x 1 root     root  93261976 Mar 12  2025 downloads/controller/kube-apiserver
-rwxr-xr-x 1 root     root  85987480 Mar 12  2025 downloads/controller/kube-controller-manager
-rwxr-xr-x 1 root     root  65843352 Mar 12  2025 downloads/controller/kube-scheduler
-rwxr-xr-x 1 root     root  58584656 Mar 18  2025 downloads/worker/containerd
-rwxr-xr-x 1 root     root   8253624 Mar 18  2025 downloads/worker/containerd-shim-runc-v2
-rwxr-xr-x 1 root     root  22929761 Mar 18  2025 downloads/worker/containerd-stress
-rwxr-xr-x 1 ssm-user   127 40076447 Dec  9  2024 downloads/worker/crictl
-rwxr-xr-x 1 root     root  23830881 Mar 18  2025 downloads/worker/ctr
-rwxr-xr-x 1 root     root  66842776 Mar 12  2025 downloads/worker/kube-proxy
-rwxr-xr-x 1 root     root  77406468 Mar 12  2025 downloads/worker/kubelet
-rwxr-xr-x 1 root     root  11854432 Mar  4  2025 downloads/worker/runc


# 일부 파일 소유자 변경
root@ip-172-31-8-16:~/kubernetes-the-hard-way# tree -ug downloads
[root     root    ]  downloads
├── [root     root    ]  client
│   ├── [admin    admin   ]  etcdctl # 👀
│   └── [root     root    ]  kubectl
├── [root     root    ]  cni-plugins
│   ├── [root     root    ]  LICENSE
│   ├── [root     root    ]  README.md
│   ├── [root     root    ]  bandwidth
│   ├── [root     root    ]  bridge
│   ├── [root     root    ]  dhcp
│   ├── [root     root    ]  dummy
│   ├── [root     root    ]  firewall
│   ├── [root     root    ]  host-device
│   ├── [root     root    ]  host-local
│   ├── [root     root    ]  ipvlan
│   ├── [root     root    ]  loopback
│   ├── [root     root    ]  macvlan
│   ├── [root     root    ]  portmap
│   ├── [root     root    ]  ptp
│   ├── [root     root    ]  sbr
│   ├── [root     root    ]  static
│   ├── [root     root    ]  tap
│   ├── [root     root    ]  tuning
│   ├── [root     root    ]  vlan
│   └── [root     root    ]  vrf
├── [root     root    ]  controller
│   ├── [admin    admin   ]  etcd # 👀
│   ├── [root     root    ]  kube-apiserver
│   ├── [root     root    ]  kube-controller-manager
│   └── [root     root    ]  kube-scheduler
└── [root     root    ]  worker
    ├── [root     root    ]  containerd
    ├── [root     root    ]  containerd-shim-runc-v2
    ├── [root     root    ]  containerd-stress
    ├── [ssm-user 127     ]  crictl # 👀
    ├── [root     root    ]  ctr
    ├── [root     root    ]  kube-proxy
    ├── [root     root    ]  kubelet
    └── [root     root    ]  runc

5 directories, 34 files

root@ip-172-31-8-16:~/kubernetes-the-hard-way# chown root:root downloads/client/etcdctl
root@ip-172-31-8-16:~/kubernetes-the-hard-way# chown root:root downloads/controller/etcd
root@ip-172-31-8-16:~/kubernetes-the-hard-way# chown root:root downloads/worker/crictl

root@ip-172-31-8-16:~/kubernetes-the-hard-way# tree -ug downloads
[root     root    ]  downloads
├── [root     root    ]  client
│   ├── [root     root    ]  etcdctl # 👍
│   └── [root     root    ]  kubectl
├── [root     root    ]  cni-plugins
│   ├── [root     root    ]  LICENSE
│   ├── [root     root    ]  README.md
│   ├── [root     root    ]  bandwidth
│   ├── [root     root    ]  bridge
│   ├── [root     root    ]  dhcp
│   ├── [root     root    ]  dummy
│   ├── [root     root    ]  firewall
│   ├── [root     root    ]  host-device
│   ├── [root     root    ]  host-local
│   ├── [root     root    ]  ipvlan
│   ├── [root     root    ]  loopback
│   ├── [root     root    ]  macvlan
│   ├── [root     root    ]  portmap
│   ├── [root     root    ]  ptp
│   ├── [root     root    ]  sbr
│   ├── [root     root    ]  static
│   ├── [root     root    ]  tap
│   ├── [root     root    ]  tuning
│   ├── [root     root    ]  vlan
│   └── [root     root    ]  vrf
├── [root     root    ]  controller
│   ├── [root     root    ]  etcd # 👍
│   ├── [root     root    ]  kube-apiserver
│   ├── [root     root    ]  kube-controller-manager
│   └── [root     root    ]  kube-scheduler
└── [root     root    ]  worker
    ├── [root     root    ]  containerd
    ├── [root     root    ]  containerd-shim-runc-v2
    ├── [root     root    ]  containerd-stress
    ├── [root     root    ]  crictl # 👍
    ├── [root     root    ]  ctr
    ├── [root     root    ]  kube-proxy
    ├── [root     root    ]  kubelet
    └── [root     root    ]  runc

5 directories, 34 files


# kubernetes client 도구인 kubectl를 설치
root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -l downloads/client/kubectl
-rwxr-xr-x 1 root root 57323672 Mar 12  2025 downloads/client/kubectl

root@ip-172-31-8-16:~/kubernetes-the-hard-way# cp downloads/client/kubectl /usr/local/bin/

# can be verified by running the kubectl command:
root@ip-172-31-8-16:~/kubernetes-the-hard-way# kubectl version --client
Client Version: v1.32.3
Kustomize Version: v5.5.0
```

apt 인스톨 안해놨던게 있어서 수동으로 했던거 기록.
- git, tree
```bash
root@ip-172-31-8-16:~/kubernetes-the-hard-way# history | grep apt
   14  apt install git
   18  apt install tree -y
   29  history | grep apt
```

03 - Provisioning Compute Resources

```bash
# /etc/hosts에 아래처럼 추가

root@ip-172-31-8-16:~# cat /etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

root@ip-172-31-8-16:~# cat << EOF >> /etc/hosts
172.31.8.16  jumpbox
172.31.11.199 server.kubernetes.local server 
172.31.0.153 node-0.kubernetes.local node-0
172.31.9.15 node-1.kubernetes.local node-1
EOF

root@ip-172-31-8-16:~# cat /etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

172.31.8.16  jumpbox
172.31.11.199 server.kubernetes.local server 
172.31.0.153 node-0.kubernetes.local node-0
172.31.9.15 node-1.kubernetes.local node-1

```


04 - Provisioning a CA and Generating TLS Certificates

```bash
root@ip-172-31-8-16:~/kubernetes-the-hard-way# cat ca.conf
[req]
distinguished_name = req_distinguished_name
prompt             = no
x509_extensions    = ca_x509_extensions

[ca_x509_extensions]
basicConstraints = CA:TRUE
keyUsage         = cRLSign, keyCertSign

[req_distinguished_name]
C   = US
ST  = Washington
L   = Seattle
CN  = CA

[admin]
distinguished_name = admin_distinguished_name
prompt             = no
req_extensions     = default_req_extensions

[admin_distinguished_name]
CN = admin
O  = system:masters

# Service Accounts
#
# The Kubernetes Controller Manager leverages a key pair to generate
# and sign service account tokens as described in the
# [managing service accounts](https://kubernetes.io/docs/admin/service-accounts-admin/)
# documentation.

[service-accounts]
distinguished_name = service-accounts_distinguished_name
prompt             = no
req_extensions     = default_req_extensions

[service-accounts_distinguished_name]
CN = service-accounts

# Worker Nodes
#
# Kubernetes uses a [special-purpose authorization mode](https://kubernetes.io/docs/admin/authorization/node/)
# called Node Authorizer, that specifically authorizes API requests made
# by [Kubelets](https://kubernetes.io/docs/concepts/overview/components/#kubelet).
# In order to be authorized by the Node Authorizer, Kubelets must use a credential
# that identifies them as being in the `system:nodes` group, with a username
# of `system:node:<nodeName>`.

[node-0]
distinguished_name = node-0_distinguished_name
prompt             = no
req_extensions     = node-0_req_extensions

[node-0_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Node-0 Certificate"
subjectAltName       = DNS:node-0, IP:127.0.0.1
subjectKeyIdentifier = hash

[node-0_distinguished_name]
CN = system:node:node-0
O  = system:nodes
C  = US
ST = Washington
L  = Seattle

[node-1]
distinguished_name = node-1_distinguished_name
prompt             = no
req_extensions     = node-1_req_extensions

[node-1_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Node-1 Certificate"
subjectAltName       = DNS:node-1, IP:127.0.0.1
subjectKeyIdentifier = hash

[node-1_distinguished_name]
CN = system:node:node-1
O  = system:nodes
C  = US
ST = Washington
L  = Seattle


# Kube Proxy Section
[kube-proxy]
distinguished_name = kube-proxy_distinguished_name
prompt             = no
req_extensions     = kube-proxy_req_extensions

[kube-proxy_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Kube Proxy Certificate"
subjectAltName       = DNS:kube-proxy, IP:127.0.0.1
subjectKeyIdentifier = hash

[kube-proxy_distinguished_name]
CN = system:kube-proxy
O  = system:node-proxier
C  = US
ST = Washington
L  = Seattle


# Controller Manager
[kube-controller-manager]
distinguished_name = kube-controller-manager_distinguished_name
prompt             = no
req_extensions     = kube-controller-manager_req_extensions

[kube-controller-manager_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Kube Controller Manager Certificate"
subjectAltName       = DNS:kube-controller-manager, IP:127.0.0.1
subjectKeyIdentifier = hash

[kube-controller-manager_distinguished_name]
CN = system:kube-controller-manager
O  = system:kube-controller-manager
C  = US
ST = Washington
L  = Seattle


# Scheduler
[kube-scheduler]
distinguished_name = kube-scheduler_distinguished_name
prompt             = no
req_extensions     = kube-scheduler_req_extensions

[kube-scheduler_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Kube Scheduler Certificate"
subjectAltName       = DNS:kube-scheduler, IP:127.0.0.1
subjectKeyIdentifier = hash

[kube-scheduler_distinguished_name]
CN = system:kube-scheduler
O  = system:system:kube-scheduler
C  = US
ST = Washington
L  = Seattle


# API Server
#
# The Kubernetes API server is automatically assigned the `kubernetes`
# internal dns name, which will be linked to the first IP address (`10.32.0.1`)
# from the address range (`10.32.0.0/24`) reserved for internal cluster
# services.

[kube-api-server]
distinguished_name = kube-api-server_distinguished_name
prompt             = no
req_extensions     = kube-api-server_req_extensions

[kube-api-server_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client, server
nsComment            = "Kube API Server Certificate"
subjectAltName       = @kube-api-server_alt_names
subjectKeyIdentifier = hash

[kube-api-server_alt_names]
IP.0  = 127.0.0.1
IP.1  = 10.32.0.1
DNS.0 = kubernetes
DNS.1 = kubernetes.default
DNS.2 = kubernetes.default.svc
DNS.3 = kubernetes.default.svc.cluster
DNS.4 = kubernetes.svc.cluster.local
DNS.5 = server.kubernetes.local
DNS.6 = api-server.kubernetes.local

[kube-api-server_distinguished_name]
CN = kubernetes
C  = US
ST = Washington
L  = Seattle


[default_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Admin Client Certificate"
subjectKeyIdentifier = hash
```

Certificate Authority

```bash
# Generate the CA configuration file, certificate, and private key

# Root CA 개인키 생성 : ca.key
root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl genrsa -out ca.key 4096
root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -l ca.key 
-rw------- 1 root root 3272 Jan  4 15:11 ca.key

root@ip-172-31-8-16:~/kubernetes-the-hard-way# cat ca.key
-----BEGIN PRIVATE KEY-----
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
yN6bnwn8QA745Fmegi2DXSTzNlt7cA==
-----END PRIVATE KEY-----

# 개인키 구조 확인
root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl rsa -in ca.key -text -noout
Private-Key: (4096 bit, 2 primes)
modulus:
    00:b8:89:e5:ab:00:6b:3e:c6:a0:b4:4b:5c:99:22:
    df:a0:75:e2:d8:e1:05:8c:70:a8:7d:e7:84:27:6d:
    70:a0:dc:2a:83:14:97:25:7d:f3:d2:bd:45:02:24:
    d4:9b:f9:70:a3:10:36:b0:50:d5:b5:ca:7f:af:cc:
    d1:c3:c5:50:ca:78:0c:1f:16:78:68:23:1b:17:da:
    dd:79:6c:4f:5f:16:ed:26:2a:61:61:53:34:89:f4:
    6b:b2:32:54:5b:45:74:21:2a:a9:ab:95:5c:ba:e7:
    64:cf:ef:f7:e7:7e:23:62:78:03:b5:a4:53:b2:6d:
    71:db:49:57:2e:24:64:7f:85:ee:bc:93:6a:4c:da:
    8b:1e:67:13:01:ac:eb:44:04:5c:99:a3:96:c1:50:
    36:54:20:fc:3a:73:82:47:0e:d0:51:d3:38:ba:89:
    75:e5:e9:b1:d5:65:49:e6:d5:fe:00:71:98:ae:10:
    27:90:30:8a:e2:dd:2a:05:63:f6:2f:b1:bb:78:2d:
    b9:99:5c:52:a7:4e:6e:f3:25:c3:98:3a:29:62:ac:
    e9:3a:98:aa:61:aa:1d:f7:34:54:bf:1c:32:09:52:
    8c:bc:72:48:7a:38:e5:ca:cc:bf:66:61:83:e6:74:
    4c:5a:b5:5a:b1:b1:c4:b3:e1:51:27:b0:f9:33:fd:
    a4:8b:da:98:a9:4e:f1:11:3d:01:ce:bb:16:79:f4:
    fa:e6:b9:4e:73:1f:35:33:ee:c7:12:94:bb:ab:45:
    0c:ad:b9:04:96:ed:41:64:ab:b2:90:62:29:b8:be:
    13:3c:d9:17:7b:0a:51:aa:32:fb:09:32:ea:b4:af:
    de:ae:e4:f7:b3:47:5f:86:c5:26:eb:7f:24:da:bc:
    cd:20:77:d9:24:15:fb:ac:af:6e:6f:5c:3b:08:53:
    4d:bd:bf:17:c1:32:bb:30:4a:18:69:7a:c2:db:c1:
    0b:02:2f:77:fd:c0:67:78:e4:f0:c6:55:c3:42:12:
    97:09:34:45:47:cf:85:e7:eb:6f:ed:ee:53:36:35:
    04:15:44:db:bc:62:bf:f1:93:9d:d5:f0:d2:68:89:
    77:f8:28:8e:13:f8:fe:71:cd:74:1e:f6:ec:51:ec:
    cb:71:23:e8:f0:6e:e0:50:f9:1c:c8:ff:20:97:f8:
    9a:ca:fc:56:02:c9:68:1c:43:be:6e:07:02:c1:ab:
    cf:71:5c:33:41:7a:7c:29:15:50:e3:0f:8c:fe:80:
    00:98:32:89:29:10:cc:65:ea:45:3a:68:45:e9:ce:
    a9:d7:39:ad:dc:2c:e1:7d:2a:e1:a6:79:5e:1c:73:
    77:20:3c:4b:d5:a6:d3:16:ef:b8:57:67:44:ab:58:
    40:e2:29
publicExponent: 65537 (0x10001)
privateExponent:
    24:cd:3d:5b:e9:a8:b9:9b:77:93:95:1e:e9:9c:42:
    90:37:ca:4e:59:ab:d7:5a:e5:43:3c:9f:46:94:a4:
    fc:33:84:17:e1:8c:96:09:c5:0d:0f:39:5a:a8:d9:
    2c:a4:e5:71:63:8b:a0:84:72:66:3f:74:d0:ec:ae:
    1d:96:75:5a:f7:6f:65:68:c0:08:f6:8d:51:e7:d0:
    38:c5:a0:9b:94:51:25:86:18:a7:05:e6:a9:a7:70:
    ad:d8:2b:2a:0b:93:12:05:35:d2:95:e6:29:10:f9:
    f2:1d:07:69:a7:66:6b:9e:07:11:5b:ac:e4:5d:be:
    b1:ce:71:c0:2e:3a:4b:93:3c:6d:e7:91:30:b3:f9:
    c0:0d:aa:c4:f0:04:f8:2a:cd:83:c7:53:ca:88:12:
    59:9b:3d:69:f3:bc:b4:aa:8f:e1:6d:97:f7:dd:6f:
    81:73:26:47:aa:1c:3f:98:87:ff:f3:27:91:78:ff:
    c6:d9:e3:6c:c4:51:fb:c2:b8:67:41:10:e3:b1:ec:
    bc:58:a4:d4:20:48:70:9d:a4:a0:f0:62:6d:ff:11:
    41:22:0e:82:8d:20:4e:3b:25:b6:7a:2b:41:60:30:
    d8:69:0b:2a:b2:bb:a3:02:cb:9d:e1:8f:22:2f:a9:
    c5:82:3a:cc:ca:a8:b1:7d:db:07:29:1c:3d:a1:d5:
    05:46:c2:23:53:dc:24:ed:7b:bf:10:23:51:61:b3:
    70:21:d1:e8:7c:06:5a:21:16:0b:be:77:98:61:d2:
    73:b5:f8:ae:d7:26:64:cd:62:dc:2b:ef:85:88:d0:
    e7:02:87:60:be:dd:84:32:40:e5:70:2e:0b:f0:8e:
    81:31:c5:78:f6:ba:41:13:3a:a7:0c:7a:ac:1e:69:
    10:d7:30:6e:9d:23:d5:a3:1b:82:7a:ff:24:e8:3f:
    36:c4:ce:b0:f4:42:c7:b2:f2:dd:1a:13:48:0f:e7:
    fb:b9:34:99:6f:8c:b7:e7:b1:11:c6:74:b0:49:95:
    76:76:74:cc:d1:24:68:78:b7:bb:cb:c1:40:a3:d1:
    0a:98:6e:71:c9:ce:e1:e6:ce:3d:90:ce:e0:fa:36:
    c3:56:49:b1:18:b8:6c:29:d0:18:89:43:32:c5:fa:
    4c:d3:7d:cd:ca:d6:88:f3:e7:48:e4:dc:fc:84:44:
    77:67:72:98:99:e3:04:af:37:7d:b3:fe:5b:f0:95:
    37:cf:3b:e9:74:1c:96:d4:df:d7:a4:f4:e0:c5:7f:
    ae:09:64:03:5e:ce:a4:24:c8:52:4b:ce:4d:ee:1f:
    0e:c1:f6:fc:45:36:8b:c3:5f:03:00:4b:52:46:0e:
    45:d4:5a:7b:29:dc:32:5b:4c:eb:b0:b0:c2:73:b1:
    93:0d
prime1:
    00:f4:34:23:27:49:bb:80:58:b7:7f:ef:d4:8e:5c:
    c8:ca:05:08:40:b1:d3:c0:3a:6e:41:5d:a5:24:82:
    20:0c:aa:6b:dd:35:ff:a5:dc:d9:0b:74:5b:bd:e4:
    c7:b9:ba:07:91:4e:01:9c:ef:46:e9:bc:f8:4b:cd:
    de:00:f8:4e:f8:e6:76:fa:1d:1b:2c:6d:5f:f6:62:
    8e:c1:55:7d:2f:79:b1:c0:9b:0c:d3:26:c1:de:48:
    42:a8:ce:42:2a:08:5f:42:88:88:51:b4:57:e3:e2:
    02:ad:9d:84:7d:fb:1e:f7:27:e0:7f:d2:09:da:70:
    16:66:5f:81:e3:9c:1b:42:8c:67:85:71:61:67:cb:
    77:c0:2b:1e:d6:fb:5a:6a:bf:b3:eb:ec:6d:2a:0f:
    62:ef:91:1c:8f:22:ef:11:8e:2d:55:89:2f:e2:3f:
    ca:ac:30:3f:8d:48:a0:6f:c0:68:c7:9c:50:4c:ba:
    0e:fd:f3:fe:de:47:85:80:90:21:e7:e5:cb:7b:46:
    ae:0a:83:68:36:99:f4:81:a0:a1:f8:f0:7e:b0:08:
    af:df:b8:96:42:d5:96:70:51:e4:82:f8:b7:88:f2:
    ee:8f:6a:0b:2b:a3:20:25:62:23:0b:9f:51:59:a3:
    07:b5:df:7f:8c:35:51:11:60:13:b2:c6:5e:5b:20:
    82:65
prime2:
    00:c1:73:ee:be:ea:9d:c2:f4:53:07:37:c1:51:31:
    58:f5:eb:d1:a2:84:0e:e9:29:c3:99:ed:b0:76:cb:
    f9:5c:40:9c:4f:36:ad:ab:d2:d0:ed:b2:96:5e:b4:
    a9:a8:22:8d:44:ea:be:0d:a6:07:6a:dd:33:62:d6:
    72:30:d9:85:2e:04:7b:82:28:de:66:1a:8e:00:d1:
    1c:f6:97:e8:b3:c7:21:e0:da:2e:10:eb:42:f0:3e:
    01:1a:34:8f:ea:08:f7:7e:8d:99:fd:ce:36:64:8e:
    4e:35:b9:ed:3f:44:45:96:db:71:50:d6:8a:bd:66:
    29:0e:bc:62:88:41:07:64:f8:92:3c:57:02:49:65:
    49:21:da:1f:0e:7c:19:56:65:39:39:60:e5:59:96:
    1f:46:f6:8b:4b:36:80:1e:8f:10:16:1f:58:87:85:
    31:fa:0e:9f:d1:66:f5:f0:af:03:6c:a7:7e:c7:aa:
    e5:41:7e:5a:26:c9:a1:4c:f6:b3:5b:33:59:e6:41:
    a4:d6:61:8c:ce:57:03:cc:f1:83:7a:6d:65:b8:3f:
    cd:3b:a5:a0:d6:60:67:f5:9d:76:b1:27:4c:df:8a:
    fc:a4:c4:14:25:5c:73:25:98:9d:ed:d9:61:b5:9a:
    ce:31:ac:4b:0c:d3:22:50:ba:8b:23:2f:c4:95:96:
    82:75
exponent1:
    00:c5:9f:5b:c3:73:9b:d5:65:f6:3a:06:b0:10:f5:
    6d:58:6f:72:1a:48:ce:80:05:c9:2c:04:c8:9c:1e:
    e2:28:dd:d1:a4:97:0a:68:03:ad:71:e3:9c:4a:b4:
    56:1d:2b:3a:ec:90:20:26:0c:4d:6a:e2:8e:5d:6a:
    20:7a:d0:77:b8:5d:69:73:47:12:b2:85:60:df:57:
    2b:07:b2:53:38:94:57:10:f3:69:11:87:8f:e4:7e:
    bd:d3:35:f7:bd:64:41:12:ea:c2:c6:bc:17:54:47:
    96:bb:41:79:f3:29:c2:09:69:af:f8:40:d5:d0:7c:
    5c:e4:43:ee:2d:70:2b:6f:53:88:83:29:1a:16:91:
    46:3b:b1:a9:a7:78:89:d7:51:84:1d:2c:9b:bb:29:
    f0:7a:c7:08:41:9d:97:b2:b1:48:66:ac:3a:9f:f1:
    d7:e6:38:b5:75:74:8c:c1:63:08:68:61:4b:6a:8c:
    37:8d:b4:63:51:26:b8:17:2e:8d:01:c9:a9:3d:fe:
    18:e2:51:2d:88:e2:56:48:80:e2:13:3f:2c:86:f0:
    c0:c3:5f:f1:d9:ec:57:6e:56:17:83:16:1c:11:2b:
    e7:7b:0f:ea:32:4a:34:bd:8c:09:a8:62:29:c7:4c:
    73:f4:ef:05:9d:45:98:71:63:3b:0d:b6:12:ad:d4:
    45:31
exponent2:
    61:bb:45:11:34:8c:31:12:a7:e3:8c:9a:60:7f:72:
    b7:02:c4:ec:ba:94:a1:dc:d4:91:ae:50:29:24:11:
    3d:36:f3:00:dd:d9:cd:65:7a:e1:ab:08:66:9e:14:
    db:f9:60:af:41:7c:74:7e:bd:5e:92:93:c4:4a:1c:
    74:6b:5f:ea:08:9f:b0:f9:1e:aa:2c:9e:32:f1:72:
    15:6e:57:44:83:c4:ac:c8:ec:de:e5:4b:f2:fd:10:
    27:82:08:76:ae:c3:02:2f:5d:6d:a8:c1:37:f9:e0:
    af:29:d8:1e:cf:49:ec:d5:be:20:9d:d2:87:ae:d5:
    ed:38:e4:fa:7b:07:d6:4d:f1:eb:03:f6:06:c8:61:
    b2:f5:74:1d:28:3a:d0:b7:e0:ba:09:26:b5:24:af:
    76:75:55:97:d0:d7:d7:18:65:83:17:a0:ed:0e:30:
    5a:69:0a:fa:8a:6e:93:82:87:53:5c:27:23:8e:45:
    b5:d9:b4:87:c5:f3:74:63:69:e7:18:41:41:9f:46:
    3c:7c:19:db:a0:80:2e:08:91:68:c7:5d:cd:40:86:
    59:ac:ea:5d:83:64:e1:e4:04:33:a9:6c:1f:bf:22:
    b5:c6:cd:7a:b6:83:01:aa:61:96:e8:ec:81:07:cd:
    45:b1:0a:55:57:51:0d:c1:c0:4b:2d:75:be:30:c4:
    85
coefficient:
    4a:ef:59:c5:5d:58:87:10:76:fe:75:d9:c2:6b:ec:
    f9:a5:7e:6e:6e:bf:7b:1b:b0:67:7c:0f:30:b2:ec:
    26:b8:37:7a:f7:b3:35:69:0c:8b:3e:76:fe:70:fb:
    1b:59:22:b5:d6:a9:f4:47:79:a4:07:62:3f:47:44:
    1c:6e:1a:59:56:6b:50:5f:d2:64:a0:73:cf:45:01:
    df:a2:a3:21:7b:c5:0d:f0:8a:70:8d:51:42:a1:b8:
    f4:20:bc:64:91:55:f6:93:4c:7a:e2:23:19:b1:6d:
    23:ce:0d:28:90:2c:e9:3b:a1:b7:33:c5:40:45:16:
    bb:7f:1d:64:df:97:78:5f:02:6a:7b:a9:ce:43:9a:
    d1:9d:2f:3c:b8:71:42:d9:25:bb:94:fc:b8:e9:d6:
    94:7c:67:8d:92:40:2b:03:da:13:df:be:10:7b:37:
    15:42:7f:93:fb:72:fd:79:70:38:e9:ce:1b:85:19:
    8f:5b:30:12:d7:41:ee:32:55:ce:e6:af:cb:08:78:
    f1:ab:9c:a3:e0:df:29:11:a7:c0:cf:74:f9:d7:98:
    81:71:0b:be:38:42:11:f8:0e:84:d5:1e:5b:0b:bd:
    a5:f6:a9:ec:af:27:fb:00:ea:c8:de:9b:9f:09:fc:
    40:0e:f8:e4:59:9e:82:2d:83:5d:24:f3:36:5b:7b:
    70


# Root CA 인증서 생성 : ca.crt
## -x509 : CSR을 만들지 않고 바로 인증서(X.509) 생성, 즉, Self-Signed Certificate
## -noenc : 개인키를 암호화하지 않음, 즉, CA 키(ca.key)에 패스프레이즈 없음
## -config ca.conf : 인증서 세부 정보는 설정 파일에서 읽음 , [req] 섹션 사용됨 - DN 정보 → [req_distinguished_name] , CA 확장 → [ca_x509_extensions]

root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl req -x509 -new -sha512 -noenc \
  -key ca.key -days 3653 \
  -config ca.conf \
  -out ca.crt

root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -l ca.crt
-rw-r--r-- 1 root root 1899 Jan  4 15:12 ca.crt

# ca.conf 관련 내용
root@ip-172-31-8-16:~/kubernetes-the-hard-way# cat ca.conf | grep -C 9 "ca_x509_extensions"
[req]
distinguished_name = req_distinguished_name
prompt             = no
x509_extensions    = ca_x509_extensions

[ca_x509_extensions]
basicConstraints = CA:TRUE # 이 인증서는 CA 역할 가능
keyUsage         = cRLSign, keyCertSign # cRLSign: 인증서 폐기 목록(CRL) 서명 가능, keyCertSign: 다른 인증서를 서명할 수 있음

[req_distinguished_name]
C   = US
ST  = Washington
L   = Seattle
CN  = CA

root@ip-172-31-8-16:~/kubernetes-the-hard-way# cat ca.crt
-----BEGIN CERTIFICATE-----
MIIFTDCCAzSgAwIBAgIUD8uCbYnw2oOrT4kfr7pz8V1E46gwDQYJKoZIhvcNAQEN
BQAwQTELMAkGA1UEBhMCVVMxEzARBgNVBAgMCldhc2hpbmd0b24xEDAOBgNVBAcM
B1NlYXR0bGUxCzAJBgNVBAMMAkNBMB4XDTI2MDEwNDE1MTI1OVoXDTM2MDEwNTE1
MTI1OVowQTELMAkGA1UEBhMCVVMxEzARBgNVBAgMCldhc2hpbmd0b24xEDAOBgNV
BAcMB1NlYXR0bGUxCzAJBgNVBAMMAkNBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
MIICCgKCAgEAuInlqwBrPsagtEtcmSLfoHXi2OEFjHCofeeEJ21woNwqgxSXJX3z
0r1FAiTUm/lwoxA2sFDVtcp/r8zRw8VQyngMHxZ4aCMbF9rdeWxPXxbtJiphYVM0
ifRrsjJUW0V0ISqpq5Vcuudkz+/3534jYngDtaRTsm1x20lXLiRkf4XuvJNqTNqL
HmcTAazrRARcmaOWwVA2VCD8OnOCRw7QUdM4uol15emx1WVJ5tX+AHGYrhAnkDCK
4t0qBWP2L7G7eC25mVxSp05u8yXDmDopYqzpOpiqYaod9zRUvxwyCVKMvHJIejjl
ysy/ZmGD5nRMWrVasbHEs+FRJ7D5M/2ki9qYqU7xET0BzrsWefT65rlOcx81M+7H
EpS7q0UMrbkElu1BZKuykGIpuL4TPNkXewpRqjL7CTLqtK/eruT3s0dfhsUm638k
2rzNIHfZJBX7rK9ub1w7CFNNvb8XwTK7MEoYaXrC28ELAi93/cBneOTwxlXDQhKX
CTRFR8+F5+tv7e5TNjUEFUTbvGK/8ZOd1fDSaIl3+CiOE/j+cc10HvbsUezLcSPo
8G7gUPkcyP8gl/iayvxWAsloHEO+bgcCwavPcVwzQXp8KRVQ4w+M/oAAmDKJKRDM
ZepFOmhF6c6p1zmt3CzhfSrhpnleHHN3IDxL1abTFu+4V2dEq1hA4ikCAwEAAaM8
MDowDAYDVR0TBAUwAwEB/zALBgNVHQ8EBAMCAQYwHQYDVR0OBBYEFOxxt+OWYcd9
A+4KfLz1iINxpF6qMA0GCSqGSIb3DQEBDQUAA4ICAQCQGuirCe/kAl+HrEDzWxiS
l+0Cc3QV4nwcFDTfTKiEpg1zdaDTVa3olcr86DqnRbDNN2edpGWk93QJYg0DEVjO
8R39ADo+OySc+++LUSTJBFFGQUrzWUIzp8XONNEw8Q02UvEgMOeH3sRPGkt4bqgC
v7Lsc5ehOpiFZYmePFRu4YomyFz9nkAixDjrRXYhAknnKIA9IAqmQ+auuASAahyt
xiDNDIZEJ1Z/CmHLsZWQG9Q6Neufg746J+DbjrTBNpVjtFRYYmZPMs0Ih5H0mMlw
rGIy59PBi7rOO3YXBQXRh0BuM7Wlt1Xy31B2iNQAZ2Ig5jRbom4omzM3Nb8KQjQt
X1dRdhuusmHnyHg5NyWVreDQSoG8UPqlXNfPAMg1+E4o3ACpRSkLqsSzaiC9C7N0
xk3z919mZwShOSZJI878JP3FlWlbc4ByNQym66JH6N5bIeHsru1IPx3PcVVmEWde
Tju3tuX2MWuNyyTudeukg7HyOViaS3g5NyadHnb8o206SLMmH69CR24hd9IJBxM/
4/vj4wTFrejjNv4ruJOcnNT9Kut+T2/eXh8gB9Z+7qFVRHKE7IWCajT8c0noxZYG
llxlQ8+21ZZHEiq9vQymJ6WrR4zj53+0hSldMjYoyo+RWXRqH/gHE+Q2eHEoTyzY
LIQqs99Ju2PEq5F9qwpn9Q==
-----END CERTIFICATE-----

# 인증서 전체 내용 확인
root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl x509 -in ca.crt -text -noout
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            0f:cb:82:6d:89:f0:da:83:ab:4f:89:1f:af:ba:73:f1:5d:44:e3:a8
        Signature Algorithm: sha512WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan  4 15:12:59 2026 GMT
            Not After : Jan  5 15:12:59 2036 GMT
        Subject: C=US, ST=Washington, L=Seattle, CN=CA
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:b8:89:e5:ab:00:6b:3e:c6:a0:b4:4b:5c:99:22:
                    df:a0:75:e2:d8:e1:05:8c:70:a8:7d:e7:84:27:6d:
                    70:a0:dc:2a:83:14:97:25:7d:f3:d2:bd:45:02:24:
                    d4:9b:f9:70:a3:10:36:b0:50:d5:b5:ca:7f:af:cc:
                    d1:c3:c5:50:ca:78:0c:1f:16:78:68:23:1b:17:da:
                    dd:79:6c:4f:5f:16:ed:26:2a:61:61:53:34:89:f4:
                    6b:b2:32:54:5b:45:74:21:2a:a9:ab:95:5c:ba:e7:
                    64:cf:ef:f7:e7:7e:23:62:78:03:b5:a4:53:b2:6d:
                    71:db:49:57:2e:24:64:7f:85:ee:bc:93:6a:4c:da:
                    8b:1e:67:13:01:ac:eb:44:04:5c:99:a3:96:c1:50:
                    36:54:20:fc:3a:73:82:47:0e:d0:51:d3:38:ba:89:
                    75:e5:e9:b1:d5:65:49:e6:d5:fe:00:71:98:ae:10:
                    27:90:30:8a:e2:dd:2a:05:63:f6:2f:b1:bb:78:2d:
                    b9:99:5c:52:a7:4e:6e:f3:25:c3:98:3a:29:62:ac:
                    e9:3a:98:aa:61:aa:1d:f7:34:54:bf:1c:32:09:52:
                    8c:bc:72:48:7a:38:e5:ca:cc:bf:66:61:83:e6:74:
                    4c:5a:b5:5a:b1:b1:c4:b3:e1:51:27:b0:f9:33:fd:
                    a4:8b:da:98:a9:4e:f1:11:3d:01:ce:bb:16:79:f4:
                    fa:e6:b9:4e:73:1f:35:33:ee:c7:12:94:bb:ab:45:
                    0c:ad:b9:04:96:ed:41:64:ab:b2:90:62:29:b8:be:
                    13:3c:d9:17:7b:0a:51:aa:32:fb:09:32:ea:b4:af:
                    de:ae:e4:f7:b3:47:5f:86:c5:26:eb:7f:24:da:bc:
                    cd:20:77:d9:24:15:fb:ac:af:6e:6f:5c:3b:08:53:
                    4d:bd:bf:17:c1:32:bb:30:4a:18:69:7a:c2:db:c1:
                    0b:02:2f:77:fd:c0:67:78:e4:f0:c6:55:c3:42:12:
                    97:09:34:45:47:cf:85:e7:eb:6f:ed:ee:53:36:35:
                    04:15:44:db:bc:62:bf:f1:93:9d:d5:f0:d2:68:89:
                    77:f8:28:8e:13:f8:fe:71:cd:74:1e:f6:ec:51:ec:
                    cb:71:23:e8:f0:6e:e0:50:f9:1c:c8:ff:20:97:f8:
                    9a:ca:fc:56:02:c9:68:1c:43:be:6e:07:02:c1:ab:
                    cf:71:5c:33:41:7a:7c:29:15:50:e3:0f:8c:fe:80:
                    00:98:32:89:29:10:cc:65:ea:45:3a:68:45:e9:ce:
                    a9:d7:39:ad:dc:2c:e1:7d:2a:e1:a6:79:5e:1c:73:
                    77:20:3c:4b:d5:a6:d3:16:ef:b8:57:67:44:ab:58:
                    40:e2:29
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:TRUE
            X509v3 Key Usage: 
                Certificate Sign, CRL Sign
            X509v3 Subject Key Identifier: 
                EC:71:B7:E3:96:61:C7:7D:03:EE:0A:7C:BC:F5:88:83:71:A4:5E:AA
    Signature Algorithm: sha512WithRSAEncryption
    Signature Value:
        90:1a:e8:ab:09:ef:e4:02:5f:87:ac:40:f3:5b:18:92:97:ed:
        02:73:74:15:e2:7c:1c:14:34:df:4c:a8:84:a6:0d:73:75:a0:
        d3:55:ad:e8:95:ca:fc:e8:3a:a7:45:b0:cd:37:67:9d:a4:65:
        a4:f7:74:09:62:0d:03:11:58:ce:f1:1d:fd:00:3a:3e:3b:24:
        9c:fb:ef:8b:51:24:c9:04:51:46:41:4a:f3:59:42:33:a7:c5:
        ce:34:d1:30:f1:0d:36:52:f1:20:30:e7:87:de:c4:4f:1a:4b:
        78:6e:a8:02:bf:b2:ec:73:97:a1:3a:98:85:65:89:9e:3c:54:
        6e:e1:8a:26:c8:5c:fd:9e:40:22:c4:38:eb:45:76:21:02:49:
        e7:28:80:3d:20:0a:a6:43:e6:ae:b8:04:80:6a:1c:ad:c6:20:
        cd:0c:86:44:27:56:7f:0a:61:cb:b1:95:90:1b:d4:3a:35:eb:
        9f:83:be:3a:27:e0:db:8e:b4:c1:36:95:63:b4:54:58:62:66:
        4f:32:cd:08:87:91:f4:98:c9:70:ac:62:32:e7:d3:c1:8b:ba:
        ce:3b:76:17:05:05:d1:87:40:6e:33:b5:a5:b7:55:f2:df:50:
        76:88:d4:00:67:62:20:e6:34:5b:a2:6e:28:9b:33:37:35:bf:
        0a:42:34:2d:5f:57:51:76:1b:ae:b2:61:e7:c8:78:39:37:25:
        95:ad:e0:d0:4a:81:bc:50:fa:a5:5c:d7:cf:00:c8:35:f8:4e:
        28:dc:00:a9:45:29:0b:aa:c4:b3:6a:20:bd:0b:b3:74:c6:4d:
        f3:f7:5f:66:67:04:a1:39:26:49:23:ce:fc:24:fd:c5:95:69:
        5b:73:80:72:35:0c:a6:eb:a2:47:e8:de:5b:21:e1:ec:ae:ed:
        48:3f:1d:cf:71:55:66:11:67:5e:4e:3b:b7:b6:e5:f6:31:6b:
        8d:cb:24:ee:75:eb:a4:83:b1:f2:39:58:9a:4b:78:39:37:26:
        9d:1e:76:fc:a3:6d:3a:48:b3:26:1f:af:42:47:6e:21:77:d2:
        09:07:13:3f:e3:fb:e3:e3:04:c5:ad:e8:e3:36:fe:2b:b8:93:
        9c:9c:d4:fd:2a:eb:7e:4f:6f:de:5e:1f:20:07:d6:7e:ee:a1:
        55:44:72:84:ec:85:82:6a:34:fc:73:49:e8:c5:96:06:96:5c:
        65:43:cf:b6:d5:96:47:12:2a:bd:bd:0c:a6:27:a5:ab:47:8c:
        e3:e7:7f:b4:85:29:5d:32:36:28:ca:8f:91:59:74:6a:1f:f8:
        07:13:e4:36:78:71:28:4f:2c:d8:2c:84:2a:b3:df:49:bb:63:
        c4:ab:91:7d:ab:0a:67:f5

```


Create Client and Server Certificates : admin

```bash
# Create Client and Server Certificates : admin
root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl genrsa -out admin.key 4096

root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -l admin.key
-rw------- 1 root root 3272 Jan  4 15:19 admin.key

# ca.conf 에 admin 섹션
root@ip-172-31-8-16:~/kubernetes-the-hard-way# cat ca.conf | grep -A 3 "\[admin"
[admin]
distinguished_name = admin_distinguished_name
prompt             = no
req_extensions     = default_req_extensions
--
[admin_distinguished_name]
CN = admin
O  = system:masters

root@ip-172-31-8-16:~/kubernetes-the-hard-way# cat ca.conf | grep -A 7 "\[default_req_extensions\]" # 공통 CSR 확장
[default_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Admin Client Certificate"
subjectKeyIdentifier = hash

# csr 파일 생성 : admin.key 개인키를 사용해 'CN=admin, O=system:masters'인 Kubernetes 관리자용 클라이언트 인증서 요청(admin.csr) 생성
root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl req -new -key admin.key -sha256 \
  -config ca.conf -section admin \
  -out admin.csr

root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -l admin.csr
-rw-r--r-- 1 root root 1830 Jan  4 15:22 admin.csr

# CSR 전체 내용 확인
openssl req -in admin.csr -text -noout


# ca에 csr 요청을 통한 crt 파일 생성
## -req : CSR를 입력으로 받아 인증서를 생성, self-signed 아님, CA가 서명하는 방식
## -days 3653 : 인증서 유효기간 3653일 (약 10년)
## -copy_extensions copyall : CSR에 포함된 모든 X.509 extensions를 인증서로 복사
## -CAcreateserial : CA 시리얼 번호 파일 자동 생성, 다음 인증서 발급 시 재사용, 기본 생성 파일(ca.srl)
root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl x509 -req -days 3653 -in admin.csr \
  -copy_extensions copyall \
  -sha256 -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out admin.crt
Certificate request self-signature ok
subject=CN=admin, O=system:masters

root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -l admin.crt
-rw-r--r-- 1 root root 2021 Jan  4 15:23 admin.crt


root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl x509 -in admin.crt -text -noout | grep -C 10 "Issuer"
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            25:4a:58:4b:0b:48:40:16:83:f5:bc:48:d8:68:25:96:22:d7:eb:2d
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan  4 15:23:42 2026 GMT
            Not After : Jan  5 15:23:42 2036 GMT
        Subject: CN=admin, O=system:masters # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:db:8d:65:99:b3:50:98:48:f1:d9:a8:34:53:f6:
                    58:57:56:fe:eb:bc:5f:91:77:5f:c1:72:4d:b8:2b:

root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl x509 -in admin.crt -text -noout | grep -C 10 "X509v3 extensions"
                    d4:e1:d9:4a:d0:d8:2d:ac:39:f5:2d:7f:dc:a8:6f:
                    cf:56:04:4d:2b:65:37:b1:94:d1:28:2f:cd:7d:7f:
                    e3:93:5d:77:5a:93:07:44:62:bb:61:78:14:75:e7:
                    a6:ba:ff:15:7b:22:33:f9:db:3c:d9:99:c3:a5:82:
                    44:4e:4f:df:82:0b:2f:49:d8:62:83:25:81:32:89:
                    9d:4a:08:9a:f9:d2:1a:eb:56:9d:d2:23:e8:8c:73:
                    96:12:38:53:c2:f0:1c:8c:71:68:47:fe:98:81:d0:
                    21:1c:59:f0:ba:c2:c0:89:c6:bb:b4:b4:08:40:1c:
                    04:c8:0b
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE # 👀
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication # 👀
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Admin Client Certificate
```

Create Client and Server Certificates
```bash
# ca.conf 수정
root@ip-172-31-8-16:~/kubernetes-the-hard-way# cat ca.conf | grep system:kube-scheduler
CN = system:kube-scheduler
O  = system:system:kube-scheduler

root@ip-172-31-8-16:~/kubernetes-the-hard-way# sed -i 's/system:system:kube-scheduler/system:kube-scheduler/' ca.conf
root@ip-172-31-8-16:~/kubernetes-the-hard-way# cat ca.conf | grep system:kube-scheduler
CN = system:kube-scheduler
O  = system:kube-scheduler

# 변수 지정
root@ip-172-31-8-16:~/kubernetes-the-hard-way# certs=(
  "node-0" "node-1"
  "kube-proxy" "kube-scheduler"
  "kube-controller-manager"
  "kube-api-server"
  "service-accounts"
)

# 확인
root@ip-172-31-8-16:~/kubernetes-the-hard-way# echo ${certs[*]}
node-0 node-1 kube-proxy kube-scheduler kube-controller-manager kube-api-server service-accounts

# 개인키 생성, csr 생성, 인증서 생성
root@ip-172-31-8-16:~/kubernetes-the-hard-way# for i in ${certs[*]}; do
  openssl genrsa -out "${i}.key" 4096

  openssl req -new -key "${i}.key" -sha256 \
    -config "ca.conf" -section ${i} \
    -out "${i}.csr"

  openssl x509 -req -days 3653 -in "${i}.csr" \
    -copy_extensions copyall \
    -sha256 -CA "ca.crt" \
    -CAkey "ca.key" \
    -CAcreateserial \
    -out "${i}.crt"
done
Certificate request self-signature ok
subject=CN=system:node:node-0, O=system:nodes, C=US, ST=Washington, L=Seattle
Certificate request self-signature ok
subject=CN=system:node:node-1, O=system:nodes, C=US, ST=Washington, L=Seattle
Certificate request self-signature ok
subject=CN=system:kube-proxy, O=system:node-proxier, C=US, ST=Washington, L=Seattle
Certificate request self-signature ok
subject=CN=system:kube-scheduler, O=system:kube-scheduler, C=US, ST=Washington, L=Seattle
Certificate request self-signature ok
subject=CN=system:kube-controller-manager, O=system:kube-controller-manager, C=US, ST=Washington, L=Seattle
Certificate request self-signature ok
subject=CN=kubernetes, C=US, ST=Washington, L=Seattle
Certificate request self-signature ok
subject=CN=service-accounts

root@ip-172-31-8-16:~/kubernetes-the-hard-way# ls -1 *.crt *.key *.csr
admin.crt
admin.csr
admin.key
ca.crt
ca.key
kube-api-server.crt
kube-api-server.csr
kube-api-server.key
kube-controller-manager.crt
kube-controller-manager.csr
kube-controller-manager.key
kube-proxy.crt
kube-proxy.csr
kube-proxy.key
kube-scheduler.crt
kube-scheduler.csr
kube-scheduler.key
node-0.crt
node-0.csr
node-0.key
node-1.crt
node-1.csr
node-1.key
service-accounts.crt
service-accounts.csr
service-accounts.key

# 인증서 정보 확인
root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl x509 -in node-0.crt -text -noout | grep -C 10 node-0
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            25:4a:58:4b:0b:48:40:16:83:f5:bc:48:d8:68:25:96:22:d7:eb:2e
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan  4 15:28:17 2026 GMT
            Not After : Jan  5 15:28:17 2036 GMT
        Subject: CN=system:node:node-0, O=system:nodes, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:ba:a4:b1:c5:e5:a8:e8:85:69:0d:ab:37:45:ca:
                    94:bb:c0:ee:e6:e4:f1:df:79:8e:79:7e:a9:4d:5f:
                    05:d9:e9:ba:61:06:59:d9:94:62:42:80:3f:13:16:
                    e4:c2:4c:da:8d:59:0d:5c:94:28:f3:0c:c7:94:47:
                    57:b9:3c:b4:83:e7:c3:f5:53:9c:ce:e7:95:2b:47:
                    4b:99:73:82:85:33:e3:3b:2a:aa:dc:bf:19:d8:51:
--
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication # 👀
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Node-0 Certificate
            X509v3 Subject Alternative Name: 
                DNS:node-0, IP Address:127.0.0.1 # 👀
            X509v3 Subject Key Identifier: 
                1D:47:33:70:BF:56:7C:D8:DB:EF:A3:61:94:86:CB:BD:AB:2C:D9:19
            X509v3 Authority Key Identifier: 
                EC:71:B7:E3:96:61:C7:7D:03:EE:0A:7C:BC:F5:88:83:71:A4:5E:AA
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        11:70:e7:4f:b6:c4:75:fd:f4:e0:26:53:3e:12:98:59:81:bd:
        ac:8a:60:46:d5:03:3b:a8:a0:eb:d8:0b:aa:53:0f:51:58:2a:
        e8:91:05:63:d6:3e:ee:18:74:04:00:36:fb:10:a6:94:b3:8d:
        e3:fe:eb:8c:34:ef:e8:79:b6:6b:d1:46:47:ec:b3:db:c7:e9:


root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl x509 -in node-1.crt -text -noout | grep -C 10 node-1
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            25:4a:58:4b:0b:48:40:16:83:f5:bc:48:d8:68:25:96:22:d7:eb:2f
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan  4 15:28:18 2026 GMT
            Not After : Jan  5 15:28:18 2036 GMT
        Subject: CN=system:node:node-1, O=system:nodes, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:c3:11:c2:e6:9a:14:9a:04:d7:5a:e2:e7:fb:88:
                    db:03:42:33:24:14:7e:fd:ec:c7:f9:ab:a2:65:f7:
                    48:2e:23:85:0a:e9:a2:fa:78:9c:ec:6f:fe:3d:62:
                    73:4f:a0:f9:bf:2e:09:7f:e2:bc:d6:e7:6e:7b:fc:
                    7f:56:b3:ae:86:9c:38:88:c7:6b:c1:4a:66:ef:7f:
                    f1:76:0e:a8:fc:d8:d2:85:9d:dd:8e:e8:03:41:60:
--
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication # 👀
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Node-1 Certificate
            X509v3 Subject Alternative Name: 
                DNS:node-1, IP Address:127.0.0.1 # 👀
            X509v3 Subject Key Identifier: 
                5C:20:8E:82:AB:09:A9:85:D4:B4:3D:21:6A:65:38:F3:DF:1D:9F:23
            X509v3 Authority Key Identifier: 
                EC:71:B7:E3:96:61:C7:7D:03:EE:0A:7C:BC:F5:88:83:71:A4:5E:AA
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        b2:c4:86:1a:62:65:dd:34:55:61:78:43:5e:8a:bc:a5:04:bc:
        a3:10:90:e7:c6:66:4d:0f:ed:37:09:45:01:4f:f4:a5:6c:f6:
        ec:14:4b:ce:4e:62:90:74:4a:94:68:7b:06:46:a1:3a:3d:54:
        29:35:86:b4:0e:cf:39:90:29:98:cb:91:ab:0b:d6:28:82:c0:


root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl x509 -in kube-proxy.crt -text -noout | grep -C 10 kube-proxy
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            25:4a:58:4b:0b:48:40:16:83:f5:bc:48:d8:68:25:96:22:d7:eb:30
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan  4 15:28:18 2026 GMT
            Not After : Jan  5 15:28:18 2036 GMT
        Subject: CN=system:kube-proxy, O=system:node-proxier, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:c6:87:90:2c:08:c1:90:67:f5:38:ac:cc:98:fe:
                    43:ee:d4:23:18:4a:9c:cb:97:69:a4:a4:8a:92:a7:
                    5b:51:84:2e:94:41:cd:84:e0:cf:4c:9d:03:69:7e:
                    a6:44:d8:ed:85:17:35:81:09:7b:c6:85:a9:2e:e8:
                    50:df:13:2d:b7:50:e3:57:70:f3:f7:1e:3f:c1:05:
                    a6:17:cc:5d:65:e9:09:06:00:de:55:c6:37:11:cd:
--
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Kube Proxy Certificate
            X509v3 Subject Alternative Name: 
                DNS:kube-proxy, IP Address:127.0.0.1 # 👀
            X509v3 Subject Key Identifier: 
                0B:5D:A9:DA:36:84:9E:C4:E6:E2:28:DE:93:5A:0A:D2:B3:F0:D3:16
            X509v3 Authority Key Identifier: 
                EC:71:B7:E3:96:61:C7:7D:03:EE:0A:7C:BC:F5:88:83:71:A4:5E:AA
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        2a:26:26:ea:09:8c:ac:d5:0d:c2:16:46:d5:43:cc:b9:5e:e6:
        c0:e2:83:4e:ff:74:f7:60:65:7d:93:65:e1:5c:8e:b8:c2:e4:
        b5:9a:90:73:bb:7c:7c:45:89:9c:a5:70:6b:99:e7:20:f1:10:
        f8:48:9f:67:d9:cd:bf:b2:6d:03:cd:09:99:93:b5:19:15:21:


root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl x509 -in kube-scheduler.crt -text -noout | grep -C 10 kube-scheduler
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            25:4a:58:4b:0b:48:40:16:83:f5:bc:48:d8:68:25:96:22:d7:eb:31
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan  4 15:28:19 2026 GMT
            Not After : Jan  5 15:28:19 2036 GMT
        Subject: CN=system:kube-scheduler, O=system:kube-scheduler, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:a5:71:23:ff:cf:4b:2a:21:d4:a1:c7:d6:17:d3:
                    24:6d:f4:ff:0e:b9:b5:65:9f:c2:11:ef:b5:c5:43:
                    8c:89:e0:2d:1b:e2:fb:82:f0:12:d0:a7:17:12:fd:
                    51:f9:97:75:d4:cd:66:fc:24:dd:9e:bf:c3:76:13:
                    e8:a6:90:22:8f:af:cc:48:8b:e9:98:99:4b:d5:16:
                    74:8d:d2:bf:61:6d:03:a5:18:7a:01:55:27:52:57:
--
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Kube Scheduler Certificate
            X509v3 Subject Alternative Name: 
                DNS:kube-scheduler, IP Address:127.0.0.1 # 👀
            X509v3 Subject Key Identifier: 
                D7:83:C1:BB:2B:2E:BF:B7:EB:E7:72:E8:86:73:E5:1A:37:00:C2:E5
            X509v3 Authority Key Identifier: 
                EC:71:B7:E3:96:61:C7:7D:03:EE:0A:7C:BC:F5:88:83:71:A4:5E:AA
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        74:be:59:5b:54:17:22:f3:41:9c:1f:0a:17:7f:a7:f6:1d:82:
        69:04:f7:19:b4:32:76:fb:f5:5c:a4:af:08:5c:08:21:44:4a:
        7e:6f:75:8f:b1:d6:92:fb:20:f1:15:34:73:5c:67:8e:d5:22:
        f2:8e:af:a3:d9:f5:ae:b4:80:b8:75:79:a0:eb:66:e4:cf:a2:


root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl x509 -in kube-controller-manager.crt -text -noout | grep -C 10 kube-controller-manager
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            25:4a:58:4b:0b:48:40:16:83:f5:bc:48:d8:68:25:96:22:d7:eb:32
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan  4 15:28:19 2026 GMT
            Not After : Jan  5 15:28:19 2036 GMT
        Subject: CN=system:kube-controller-manager, O=system:kube-controller-manager, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:bc:1a:15:6e:73:68:d2:52:c3:da:83:26:3b:0d:
                    97:be:6b:52:79:95:4b:e5:b9:62:e1:17:96:ac:3a:
                    58:5d:ad:00:3d:75:24:43:e4:f8:c2:d8:b5:ee:aa:
                    bc:d0:b9:c3:79:d0:e0:ad:09:a6:83:99:b1:b8:e2:
                    ba:a0:ce:73:d8:76:6f:73:07:bb:e0:bd:d9:ca:f4:
                    90:b3:94:a3:35:3b:e2:16:7a:c0:a9:03:cb:4a:91:
--
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Kube Controller Manager Certificate
            X509v3 Subject Alternative Name: 
                DNS:kube-controller-manager, IP Address:127.0.0.1 # 👀
            X509v3 Subject Key Identifier: 
                04:C3:0F:00:7A:4D:21:31:99:2B:26:24:37:F2:E4:2C:F7:E7:42:0A
            X509v3 Authority Key Identifier: 
                EC:71:B7:E3:96:61:C7:7D:03:EE:0A:7C:BC:F5:88:83:71:A4:5E:AA
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        ae:ed:45:bf:ca:06:f9:71:a5:f9:c7:57:03:4f:ff:ff:c1:50:
        39:62:e6:79:73:8c:3f:93:a0:ed:a1:ae:d3:7b:a0:21:b4:c1:
        25:6c:c5:80:9a:91:5c:74:31:08:71:6e:2d:13:21:cc:17:95:
        65:14:bf:32:08:c2:a8:c4:32:e3:ff:4e:76:c6:79:d5:84:08:


# api-server : SAN 정보에 10.32.0.1 은 kubernetes (Service) ClusterIP. 다른 인증서와 다르게 SSL Server 역할 추가 확인
root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl x509 -in kube-api-server.crt -text -noout | grep -C 10 kubernetes
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            25:4a:58:4b:0b:48:40:16:83:f5:bc:48:d8:68:25:96:22:d7:eb:33
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan  4 15:28:20 2026 GMT
            Not After : Jan  5 15:28:20 2036 GMT
        Subject: CN=kubernetes, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:a2:97:8d:bb:4c:8d:e2:7c:66:4c:5c:7a:42:31:
                    8b:e5:3a:3c:8c:26:38:91:30:38:ff:07:c8:c8:c5:
                    3a:e1:50:ba:06:e1:14:f8:e0:29:64:99:23:ad:71:
                    05:cc:32:a2:c5:eb:29:0a:36:de:34:0a:8b:dc:36:
                    c6:c1:60:5e:94:6b:9d:af:8d:6e:3c:6a:cc:4f:af:
                    2d:a3:f0:15:1b:ef:f2:f4:13:8a:e8:78:1d:a4:a6:
--
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client, SSL Server # 👀
            Netscape Comment: 
                Kube API Server Certificate
            X509v3 Subject Alternative Name: # 👀
                IP Address:127.0.0.1, IP Address:10.32.0.1, DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster, DNS:kubernetes.svc.cluster.local, DNS:server.kubernetes.local, DNS:api-server.kubernetes.local
            X509v3 Subject Key Identifier: 
                BF:1F:B6:91:E5:20:1D:73:B8:8E:1E:D7:43:1F:3F:96:EB:F7:FF:6A
            X509v3 Authority Key Identifier: 
                EC:71:B7:E3:96:61:C7:7D:03:EE:0A:7C:BC:F5:88:83:71:A4:5E:AA
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        8b:4b:0c:a2:d7:99:91:7d:3f:30:a7:d0:ab:35:d4:58:23:c6:
        31:ab:2a:e6:cd:73:fa:6a:e3:d9:9c:c9:f6:82:79:3d:fd:37:
        94:e0:78:18:39:41:f3:68:f5:d3:ad:4a:b4:6c:e4:6a:f1:54:
        0e:f4:e1:15:80:a0:63:4e:2a:73:55:95:f1:15:96:fe:c1:b0:


root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl x509 -in service-accounts.crt -text -noout | grep -C 10 service-accounts
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            25:4a:58:4b:0b:48:40:16:83:f5:bc:48:d8:68:25:96:22:d7:eb:34
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan  4 15:28:20 2026 GMT
            Not After : Jan  5 15:28:20 2036 GMT
        Subject: CN=service-accounts 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:a4:2e:31:bd:83:0b:a9:fe:76:bd:89:d9:18:ce:
                    7b:9c:8e:64:bc:94:3b:e3:e7:e6:0d:74:81:3e:88:
                    26:d5:11:80:7b:8b:d1:e9:ae:c1:9f:1c:52:5d:de:
                    90:c4:90:3c:39:5c:cc:8a:af:af:31:6c:15:8a:c2:
                    17:cc:50:a2:9b:62:c9:a3:f1:e8:48:27:61:f8:7b:
                    46:2f:f7:3a:20:30:29:92:1f:c7:91:7d:49:ac:7c:

root@ip-172-31-8-16:~/kubernetes-the-hard-way# openssl x509 -in service-accounts.crt -text -noout | grep -C 10 CA:FALSE
                    68:1a:fe:b7:e8:5e:3c:06:17:b4:d4:5d:04:c6:01:
                    cd:e8:6b:c2:0e:51:11:66:fe:d0:45:a1:02:e7:8d:
                    86:5c:ce:70:b7:23:4a:99:e6:93:8e:20:76:7e:52:
                    c2:74:5a:5b:88:3b:e1:6c:77:ed:95:2d:43:42:4e:
                    b7:ad:32:9b:59:3a:a5:0b:20:75:5c:fd:e3:11:16:
                    7f:2c:df:7c:6e:3d:55:24:25:8a:69:ba:e3:c8:e8:
                    09:d3:2b
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Admin Client Certificate
            X509v3 Subject Key Identifier: 
                87:7F:3C:B6:F9:E3:BF:9B:EA:B6:F7:F9:D8:4E:1F:8F:88:AC:F8:CB

```

Distribute the Client and Server Certificates
```bash

instance_ids = {
  "jumpbox" = "i-0e1dc45b5a51752da"
  "node-0" = "i-019b7ca8364b151a7"
  "node-1" = "i-0577beb3adc641a91"
  "server" = "i-0495b08bd46029f03"
}

aws ssm start-session --target i-019b7ca8364b151a7

# Copy the appropriate certificates and private keys to the node-0 and node-1 machines


aws ssm start-session \
  --target i-019b7ca8364b151a7 \
  --document-name AWS-StartPortForwardingSession \
  --parameters "portNumber=22,localPortNumber=2222"


Host ssm-node-0
  HostName i-0TARGET
  User admin
  IdentityFile /path/to/key
  ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"


scp -P 2222 -i /path/to/key file.txt admin@localhost:/home/admin/
scp -P 2222 README.md root@localhost:/root


for host in i-019b7ca8364b151a7 i-0577beb3adc641a91; do
  ssh root@${host} mkdir /var/lib/kubelet/

  scp ca.crt root@${host}:/var/lib/kubelet/

  scp ${host}.crt \
    root@${host}:/var/lib/kubelet/kubelet.crt

  scp ${host}.key \
    root@${host}:/var/lib/kubelet/kubelet.key
done


```


