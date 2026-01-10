
## EC2

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


## jumphost

```bash
❯ aws ssm start-session --target i-{jumphost_id}
$ sudo su -
root@ip-172-31-11-186:~#

root@ip-172-31-11-186:~# whoami
root

root@ip-172-31-11-186:~# pwd
/root

root@ip-172-31-11-186:~# cat /etc/os-release
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

root@ip-172-31-11-186:~# aa-status
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

root@ip-172-31-11-186:~# systemctl is-active apparmor
inactive
```

```bash
# Sync GitHub Repository
root@ip-172-31-11-186:~# pwd
/root

root@ip-172-31-11-186:~# git clone --depth 1 https://github.com/kelseyhightower/kubernetes-the-hard-way.git
Cloning into 'kubernetes-the-hard-way'...
remote: Enumerating objects: 41, done.
remote: Counting objects: 100% (41/41), done.
remote: Compressing objects: 100% (40/40), done.
remote: Total 41 (delta 3), reused 14 (delta 1), pack-reused 0 (from 0)
Receiving objects: 100% (41/41), 29.27 KiB | 7.32 MiB/s, done.
Resolving deltas: 100% (3/3), done.


root@ip-172-31-11-186:~# cd kubernetes-the-hard-way && tree
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

root@ip-172-31-11-186:~/kubernetes-the-hard-way# pwd
/root/kubernetes-the-hard-way

# ---

# Download Binaries : k8s 구성을 위한 컴포넌트 다운로드

# CPU 아키텍처 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# dpkg --print-architecture
amd64

# CPU 아키텍처 별 다운로드 목록 정보 다름
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l downloads-*
-rw-r--r-- 1 root root 839 Jan  4 14:46 downloads-amd64.txt
-rw-r--r-- 1 root root 839 Jan  4 14:46 downloads-arm64.txt

# https://kubernetes.io/releases/download/
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat downloads-$(dpkg --print-architecture).txt
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
root@ip-172-31-11-186:~/kubernetes-the-hard-way# wget -q --show-progress \
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
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -oh downloads
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
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ARCH=$(dpkg --print-architecture)
root@ip-172-31-11-186:~/kubernetes-the-hard-way# echo $ARCH
amd64

root@ip-172-31-11-186:~/kubernetes-the-hard-way# mkdir -p downloads/{client,cni-plugins,controller,worker}
root@ip-172-31-11-186:~/kubernetes-the-hard-way# tree -d downloads
downloads
├── client
├── cni-plugins
├── controller
└── worker

5 directories

# 압축 풀기
root@ip-172-31-11-186:~/kubernetes-the-hard-way# tar -xvf downloads/crictl-v1.32.0-linux-${ARCH}.tar.gz \
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


root@ip-172-31-11-186:~/kubernetes-the-hard-way# tar -xvf downloads/containerd-2.1.0-beta.0-linux-${ARCH}.tar.gz \
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


root@ip-172-31-11-186:~/kubernetes-the-hard-way# tar -xvf downloads/cni-plugins-linux-${ARCH}-v1.6.2.tgz \
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
root@ip-172-31-11-186:~/kubernetes-the-hard-way# tar -xvf downloads/etcd-v3.6.0-rc.3-linux-${ARCH}.tar.gz \
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
root@ip-172-31-11-186:~/kubernetes-the-hard-way# tree downloads/worker/
downloads/worker/
├── containerd
├── containerd-shim-runc-v2
├── containerd-stress
├── crictl
└── ctr

1 directory, 5 files

root@ip-172-31-11-186:~/kubernetes-the-hard-way# tree downloads/cni-plugins
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

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l downloads/{etcd,etcdctl}
-rwxr-xr-x 1 admin admin 25219224 Mar 27  2025 downloads/etcd
-rwxr-xr-x 1 admin admin 16421016 Mar 27  2025 downloads/etcdctl

# 파일 이동 
root@ip-172-31-11-186:~/kubernetes-the-hard-way# mv downloads/{etcdctl,kubectl} downloads/client/
root@ip-172-31-11-186:~/kubernetes-the-hard-way# mv downloads/{etcd,kube-apiserver,kube-controller-manager,kube-scheduler} downloads/controller/
root@ip-172-31-11-186:~/kubernetes-the-hard-way# mv downloads/{kubelet,kube-proxy} downloads/worker/
root@ip-172-31-11-186:~/kubernetes-the-hard-way# mv downloads/runc.${ARCH} downloads/worker/runc

# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# tree downloads/client/
downloads/client/
├── etcdctl
└── kubectl

1 directory, 2 files

root@ip-172-31-11-186:~/kubernetes-the-hard-way# tree downloads/controller/
downloads/controller/
├── etcd
├── kube-apiserver
├── kube-controller-manager
└── kube-scheduler

1 directory, 4 files

root@ip-172-31-11-186:~/kubernetes-the-hard-way# tree downloads/worker/
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
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l downloads/*gz
-rw-r--r-- 1 root root 52794236 Jan  6  2025 downloads/cni-plugins-linux-amd64-v1.6.2.tgz
-rw-r--r-- 1 root root 38807044 Mar 18  2025 downloads/containerd-2.1.0-beta.0-linux-amd64.tar.gz
-rw-r--r-- 1 root root 19100418 Dec  9  2024 downloads/crictl-v1.32.0-linux-amd64.tar.gz
-rw-r--r-- 1 root root 23577153 Mar 27  2025 downloads/etcd-v3.6.0-rc.3-linux-amd64.tar.gz

root@ip-172-31-11-186:~/kubernetes-the-hard-way# rm -rf downloads/*gz


# Make the binaries executable.
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l downloads/{client,cni-plugins,controller,worker}/*
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
-rwxr-xr-x 1 labadmin   127 40076447 Dec  9  2024 downloads/worker/crictl
-rwxr-xr-x 1 root     root  23830881 Mar 18  2025 downloads/worker/ctr
-rw-r--r-- 1 root     root  66842776 Mar 12  2025 downloads/worker/kube-proxy
-rw-r--r-- 1 root     root  77406468 Mar 12  2025 downloads/worker/kubelet
-rw-r--r-- 1 root     root  11854432 Mar  4  2025 downloads/worker/runc

root@ip-172-31-11-186:~/kubernetes-the-hard-way# chmod +x downloads/{client,cni-plugins,controller,worker}/*

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l downloads/{client,cni-plugins,controller,worker}/*
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
-rwxr-xr-x 1 labadmin   127 40076447 Dec  9  2024 downloads/worker/crictl
-rwxr-xr-x 1 root     root  23830881 Mar 18  2025 downloads/worker/ctr
-rwxr-xr-x 1 root     root  66842776 Mar 12  2025 downloads/worker/kube-proxy
-rwxr-xr-x 1 root     root  77406468 Mar 12  2025 downloads/worker/kubelet
-rwxr-xr-x 1 root     root  11854432 Mar  4  2025 downloads/worker/runc


# 일부 파일 소유자 변경
root@ip-172-31-11-186:~/kubernetes-the-hard-way# tree -ug downloads
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
    ├── [labadmin 127     ]  crictl # 👀
    ├── [root     root    ]  ctr
    ├── [root     root    ]  kube-proxy
    ├── [root     root    ]  kubelet
    └── [root     root    ]  runc

5 directories, 34 files

root@ip-172-31-11-186:~/kubernetes-the-hard-way# chown root:root downloads/client/etcdctl
root@ip-172-31-11-186:~/kubernetes-the-hard-way# chown root:root downloads/controller/etcd
root@ip-172-31-11-186:~/kubernetes-the-hard-way# chown root:root downloads/worker/crictl

root@ip-172-31-11-186:~/kubernetes-the-hard-way# tree -ug downloads
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
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l downloads/client/kubectl
-rwxr-xr-x 1 root root 57323672 Mar 12  2025 downloads/client/kubectl

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cp downloads/client/kubectl /usr/local/bin/

# can be verified by running the kubectl command:
root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl version --client
Client Version: v1.32.3
Kustomize Version: v5.5.0
```

---
03 - Provisioning Compute Resources

```bash
# /etc/hosts에 아래처럼 추가

root@ip-172-31-11-186:~# cat /etc/hosts
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

root@server's password: 
== /etc/hosts (before) ==
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

== /etc/hosts (after) ==
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

172.31.11.186  jumpbox
172.31.5.196   server.kubernetes.local server
172.31.8.112   node-0.kubernetes.local node-0
172.31.15.209  node-1.kubernetes.local node-1

root@node-0's password: 
== /etc/hosts (before) ==
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

== /etc/hosts (after) ==
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

172.31.11.186  jumpbox
172.31.5.196   server.kubernetes.local server
172.31.8.112   node-0.kubernetes.local node-0
172.31.15.209  node-1.kubernetes.local node-1

root@node-1's password: 
== /etc/hosts (before) ==
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

== /etc/hosts (after) ==
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

172.31.11.186  jumpbox
172.31.5.196   server.kubernetes.local server
172.31.8.112   node-0.kubernetes.local node-0
172.31.15.209  node-1.kubernetes.local node-1
```

```bash
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat <<EOF > machines.txt
172.31.5.196 server.kubernetes.local server
172.31.8.112 node-0.kubernetes.local node-0 10.200.0.0/24
172.31.15.209 node-1.kubernetes.local node-1 10.200.1.0/24
EOF


root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat machines.txt
172.31.5.196 server.kubernetes.local server
172.31.8.112 node-0.kubernetes.local node-0 10.200.0.0/24
172.31.15.209 node-1.kubernetes.local node-1 10.200.1.0/24

root@ip-172-31-11-186:~/kubernetes-the-hard-way# while read IP FQDN HOST SUBNET; do
  echo "${IP} ${FQDN} ${HOST} ${SUBNET}"
done < machines.txt
172.31.5.196 server.kubernetes.local server 
172.31.8.112 node-0.kubernetes.local node-0 10.200.0.0/24
172.31.15.209 node-1.kubernetes.local node-1 10.200.1.0/24
```


04 - Provisioning a CA and Generating TLS Certificates

```bash
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat ca.conf
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

---

Certificate Authority

```bash
# Generate the CA configuration file, certificate, and private key

# Root CA 개인키 생성 : ca.key
root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl genrsa -out ca.key 4096
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l ca.key 
-rw------- 1 root root 3272 Jan 10 12:07 ca.key

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat ca.key
-----BEGIN PRIVATE KEY-----
MIIJQgIBADANBgkqhkiG9w0BAQEFAASCCSwwggkoAgEAAoICAQC8RFUbLu5sSI4m
9yBXLZGdTrwua4UhHzpfVW1Hc81qINe5lhj6n3xHO5HxvjozArWnAjDpWsj17vZ3
XaXhCsx2tO6zUx/l5kTSrnvM5gO0b9T0sbEO6/duTmbxyBnEjwsYnhCbqfpZF1TR
dSUcCruzlauOddHOF99Cmend8Y2kjeRDeZNgavBaVjpQPjP1jHaqRYa1p0XBRRZa
XED2IUVlBoq7xU6fEd8WKsnQmWCLQiLrZrGvCI1g37KcZwN3nbNc3pYKywiN3pak
WhGzWZ1yg+6p4bykkyYNl671HsHXgKEAjOg6kSNwLHd3vnuee6AcpiQs9lHUC4fQ
MlvH+c+/A5V7E9MlSe27LV/O6TbNkjIsPQaQp5awTzqREO0SmuXgkyuIK/XkG45D
jj5SuxmcWkKmQc6Z0PtDjDhl6yLDA+lee/F/hKFyHOmqmlJxautBifPjy6IkPj0Q
ZLa0PsCDChVEIiGzEO2Ndvw9EXpQiQBAF4nGE5qkNMYpvfcEDwE49SuXWXaayJxo
+ypyTe9dgllsNgf61ktnqpiCHV/E8/4iFezXN6fKvBtaR7rLg+XQZFZf4ao0z8JZ
FfBpTSZVIOil9GigQnDzqZGZU735wXw9hEqaFc5ZZovqrBhIJ/+e/rpG7hy+JTlO
haXpW6Ab1i+YreWuldoqHxSAcUbPTwIDAQABAoICAAsl3gbpX9jYRa1CU49AoC9j
wCTc3QSPEtJzqTA38ovm50nn/Lv/wZ4o2trTsXffyzMudV2msIuk22yfW6PYaIRc
Rl4mp+w3FxAv9h4LPguV1lL+9UW1l0XYLU8CfZ7JUZY4QIeB0ynUsIMOoA8/Bh+m
LIMXsEAMjdMlxgFhvPS81NgMqjtlWazKZP2SEVroNwacw1NHqmEStDYkNvyGun3h
m0lvGi61IjPv01ofcDtkGSk96tDl0r6lFbBz28gIyzF5RK0y7zi8sMgz788M7r50
gtIFuePiNWNMqLbUXBS6Bc6V3r0eZwN3aUOVQJYBKq6c7+YcV9AUjArkpdFQ64os
AmG1xo/v98PZAhzUhDJCTkt5h4ohS4t4G31F9Ou7ZJKQ1LfvPhdK+IkexZDcPG1C
sqGuT4RanpX/FHQtIclTQ3SF626+HTneQVMEgHgFgTm53YlSfO1CEqPAdEeiFB4G
Xt5C3AJxyHZueVwai1N4YQKtJ40m7wdYCUPktNRlX39Cj4MtY1Hz/PJpZUJvZpdQ
ZtIQi7uPlEvMGA6TL2ezAK5QjAhtSc2Vfc+Bd9I2AGfeuIb9Ttid2GWHXn4Y78iM
+PhTdGNpUsf7yCQyfT2cGvC5ULQshffT2le91PIKHEa/9s1RKFc90oRE3LI+OPEF
TUoKplQX7zsWLUWdZu5BAoIBAQDf2bNkDjS1sV0D4hc+YT+p0YljwgNu47D/AKdo
4oYRba0V3IWMdj/37+j7Ca89vfLTgyMwcUfmwShXhwiDg/FlU03+nsUViWU92Oim
aT7pQx350x48lar8FbOngf1LFUmDvN1AWKWPYEwVyuQjGbjoYjZDftgZcqr2ati0
4gs6LF8OuyIiIzgxJ9fak8qsLf4bJCoiRnvHVmvKKZVSFFhH36MWSqQcAIbuHQ22
wil1QGbdqJ4rYaq6J/+83zHCC3ZaXrtzwn2Q4d3dYvoj33+kbEBnm6cQOz56v9y9
TbAcMJzOLRg4TNdYwBXiTTeHqd2wt0J3CkR0WXianAbUcFaRAoIBAQDXTlXnQKB1
eGkxlfXbDhqP/NzphFfdPrYRXIVVZHZDWO9cor06K4TBmfMuzQyRXxTvpPfE5P6Q
+eaV2yZTqBFzhga5OZ3gsWe4ua8NrB7ORfw30s6d5ag/6uczJ5puE/mislczFYid
uexwYRH0tDHhUoBXCksuFUOsWenzh1T0EDmBi5DoQ2BZsaB/S9uz+5jn4X3uFFhb
zBSy7Mq3dihNc68TAVlqDV6tnvm2yxefvDOfMVDq5IlsTlnkIGF+I5ygLUyXS3t2
LMtkeNv3yhB50jteeCQ9rpzYkTGWhlj0eqUG46XlJ+BpOsP1p6bFz4Dj1VneWPf9
IgcjmxmbTnffAoIBAQDFkgy+K7ekAbYZ/kwLl6OsC6+aZ5vGHJqUhww7C2vPKCET
YX5RufC9sXbNUv/jm6oduumtEN6oMSWdEyaVhTfi+YKmT5Wda5X6315/ufZ3xPBJ
FmfiiyrNsY3OM3HO+ivXZTNWXqdJg3HD7j4rKMHGASDps6Oh2k5AjY9VHwlPv+fq
RYpb3P/0irj+R2EjVLipVeMGO3V2O7WJSehr+F7umNkFjL2JpYFx2hzHiFk1DrF7
xB5OJbac9T7HgasWHC3Kl0AVbLyMyn2ar4gdb17mTVEO4RezwMZlar+2KUJdrx5G
7xAoaNHMmET4ZrSzPV7YYPb9wAcpNeq3cyyoBbqxAoIBAFca+CIQwVoFFvnao5a2
BAUQ1gcbZbi6sEoh1keP11Cz4FLn/ApWpOT2da4PgvAlOYEiiqL7ygm5MJKcEMtz
iWvlYz74kmjfHQldBfdQFT56jem/vZuf2AvT6ymE8jNqnWo3IJQoOBcnqwJkIzGO
3Uc9a3LLVVMVg0VtMvs1WydKkRlZ74woBgkDld0qQX51YY0eayYw0PaCgDVLG1BR
20hKbyAPQa9oLU+sq3ZKgAo9x9y1xPji8L4CjNeASjEQE0OyT/Q9s3tB8B97zfJX
q4a9iQtVK8RQql/rjdZKEB8Ip088NleZZG7uOW1fIFeS9aA3Jp6P+/RLGfxLuXZd
rp0CggEAcm7pkM77vw5wAtm8dawmv3CeFqIxoBDJ8/9dGqZ7mjguUUlEQ5Imn8lR
6SGnxv4Y2DsV4AkjoxpJUXnxzqWfyEeJVIEyPsin57qoF6Q2sA63P9HDwJys16CM
6sfo3crrUMJ+NQ8etXfWYTENXt4XCCqQdUo0nxnB0pVZqB/Bxwi3N0ZNK9mra0r3
PG0/cLRDsPKj5S38VJ8FJwd+Lf0biklqLa7ESz/jQYdr39oVffRjwEojLhrZqhB5
SvVoHmFVN598SJF3xqt1untTAvhhZeEzsuXrv4cWR92l281GWW3MtO3V1TEjJzFL
P+L9jpMS9hk/6kIshoFd0bXw7z9CdA==
-----END PRIVATE KEY-----

# 개인키 구조 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl rsa -in ca.key -text -noout
Private-Key: (4096 bit, 2 primes)
modulus:
    00:bc:44:55:1b:2e:ee:6c:48:8e:26:f7:20:57:2d:
    91:9d:4e:bc:2e:6b:85:21:1f:3a:5f:55:6d:47:73:
    cd:6a:20:d7:b9:96:18:fa:9f:7c:47:3b:91:f1:be:
    3a:33:02:b5:a7:02:30:e9:5a:c8:f5:ee:f6:77:5d:
    a5:e1:0a:cc:76:b4:ee:b3:53:1f:e5:e6:44:d2:ae:
    7b:cc:e6:03:b4:6f:d4:f4:b1:b1:0e:eb:f7:6e:4e:
    66:f1:c8:19:c4:8f:0b:18:9e:10:9b:a9:fa:59:17:
    54:d1:75:25:1c:0a:bb:b3:95:ab:8e:75:d1:ce:17:
    df:42:99:e9:dd:f1:8d:a4:8d:e4:43:79:93:60:6a:
    f0:5a:56:3a:50:3e:33:f5:8c:76:aa:45:86:b5:a7:
    45:c1:45:16:5a:5c:40:f6:21:45:65:06:8a:bb:c5:
    4e:9f:11:df:16:2a:c9:d0:99:60:8b:42:22:eb:66:
    b1:af:08:8d:60:df:b2:9c:67:03:77:9d:b3:5c:de:
    96:0a:cb:08:8d:de:96:a4:5a:11:b3:59:9d:72:83:
    ee:a9:e1:bc:a4:93:26:0d:97:ae:f5:1e:c1:d7:80:
    a1:00:8c:e8:3a:91:23:70:2c:77:77:be:7b:9e:7b:
    a0:1c:a6:24:2c:f6:51:d4:0b:87:d0:32:5b:c7:f9:
    cf:bf:03:95:7b:13:d3:25:49:ed:bb:2d:5f:ce:e9:
    36:cd:92:32:2c:3d:06:90:a7:96:b0:4f:3a:91:10:
    ed:12:9a:e5:e0:93:2b:88:2b:f5:e4:1b:8e:43:8e:
    3e:52:bb:19:9c:5a:42:a6:41:ce:99:d0:fb:43:8c:
    38:65:eb:22:c3:03:e9:5e:7b:f1:7f:84:a1:72:1c:
    e9:aa:9a:52:71:6a:eb:41:89:f3:e3:cb:a2:24:3e:
    3d:10:64:b6:b4:3e:c0:83:0a:15:44:22:21:b3:10:
    ed:8d:76:fc:3d:11:7a:50:89:00:40:17:89:c6:13:
    9a:a4:34:c6:29:bd:f7:04:0f:01:38:f5:2b:97:59:
    76:9a:c8:9c:68:fb:2a:72:4d:ef:5d:82:59:6c:36:
    07:fa:d6:4b:67:aa:98:82:1d:5f:c4:f3:fe:22:15:
    ec:d7:37:a7:ca:bc:1b:5a:47:ba:cb:83:e5:d0:64:
    56:5f:e1:aa:34:cf:c2:59:15:f0:69:4d:26:55:20:
    e8:a5:f4:68:a0:42:70:f3:a9:91:99:53:bd:f9:c1:
    7c:3d:84:4a:9a:15:ce:59:66:8b:ea:ac:18:48:27:
    ff:9e:fe:ba:46:ee:1c:be:25:39:4e:85:a5:e9:5b:
    a0:1b:d6:2f:98:ad:e5:ae:95:da:2a:1f:14:80:71:
    46:cf:4f
publicExponent: 65537 (0x10001)
privateExponent:
    0b:25:de:06:e9:5f:d8:d8:45:ad:42:53:8f:40:a0:
    2f:63:c0:24:dc:dd:04:8f:12:d2:73:a9:30:37:f2:
    8b:e6:e7:49:e7:fc:bb:ff:c1:9e:28:da:da:d3:b1:
    77:df:cb:33:2e:75:5d:a6:b0:8b:a4:db:6c:9f:5b:
    a3:d8:68:84:5c:46:5e:26:a7:ec:37:17:10:2f:f6:
    1e:0b:3e:0b:95:d6:52:fe:f5:45:b5:97:45:d8:2d:
    4f:02:7d:9e:c9:51:96:38:40:87:81:d3:29:d4:b0:
    83:0e:a0:0f:3f:06:1f:a6:2c:83:17:b0:40:0c:8d:
    d3:25:c6:01:61:bc:f4:bc:d4:d8:0c:aa:3b:65:59:
    ac:ca:64:fd:92:11:5a:e8:37:06:9c:c3:53:47:aa:
    61:12:b4:36:24:36:fc:86:ba:7d:e1:9b:49:6f:1a:
    2e:b5:22:33:ef:d3:5a:1f:70:3b:64:19:29:3d:ea:
    d0:e5:d2:be:a5:15:b0:73:db:c8:08:cb:31:79:44:
    ad:32:ef:38:bc:b0:c8:33:ef:cf:0c:ee:be:74:82:
    d2:05:b9:e3:e2:35:63:4c:a8:b6:d4:5c:14:ba:05:
    ce:95:de:bd:1e:67:03:77:69:43:95:40:96:01:2a:
    ae:9c:ef:e6:1c:57:d0:14:8c:0a:e4:a5:d1:50:eb:
    8a:2c:02:61:b5:c6:8f:ef:f7:c3:d9:02:1c:d4:84:
    32:42:4e:4b:79:87:8a:21:4b:8b:78:1b:7d:45:f4:
    eb:bb:64:92:90:d4:b7:ef:3e:17:4a:f8:89:1e:c5:
    90:dc:3c:6d:42:b2:a1:ae:4f:84:5a:9e:95:ff:14:
    74:2d:21:c9:53:43:74:85:eb:6e:be:1d:39:de:41:
    53:04:80:78:05:81:39:b9:dd:89:52:7c:ed:42:12:
    a3:c0:74:47:a2:14:1e:06:5e:de:42:dc:02:71:c8:
    76:6e:79:5c:1a:8b:53:78:61:02:ad:27:8d:26:ef:
    07:58:09:43:e4:b4:d4:65:5f:7f:42:8f:83:2d:63:
    51:f3:fc:f2:69:65:42:6f:66:97:50:66:d2:10:8b:
    bb:8f:94:4b:cc:18:0e:93:2f:67:b3:00:ae:50:8c:
    08:6d:49:cd:95:7d:cf:81:77:d2:36:00:67:de:b8:
    86:fd:4e:d8:9d:d8:65:87:5e:7e:18:ef:c8:8c:f8:
    f8:53:74:63:69:52:c7:fb:c8:24:32:7d:3d:9c:1a:
    f0:b9:50:b4:2c:85:f7:d3:da:57:bd:d4:f2:0a:1c:
    46:bf:f6:cd:51:28:57:3d:d2:84:44:dc:b2:3e:38:
    f1:05:4d:4a:0a:a6:54:17:ef:3b:16:2d:45:9d:66:
    ee:41
prime1:
    00:df:d9:b3:64:0e:34:b5:b1:5d:03:e2:17:3e:61:
    3f:a9:d1:89:63:c2:03:6e:e3:b0:ff:00:a7:68:e2:
    86:11:6d:ad:15:dc:85:8c:76:3f:f7:ef:e8:fb:09:
    af:3d:bd:f2:d3:83:23:30:71:47:e6:c1:28:57:87:
    08:83:83:f1:65:53:4d:fe:9e:c5:15:89:65:3d:d8:
    e8:a6:69:3e:e9:43:1d:f9:d3:1e:3c:95:aa:fc:15:
    b3:a7:81:fd:4b:15:49:83:bc:dd:40:58:a5:8f:60:
    4c:15:ca:e4:23:19:b8:e8:62:36:43:7e:d8:19:72:
    aa:f6:6a:d8:b4:e2:0b:3a:2c:5f:0e:bb:22:22:23:
    38:31:27:d7:da:93:ca:ac:2d:fe:1b:24:2a:22:46:
    7b:c7:56:6b:ca:29:95:52:14:58:47:df:a3:16:4a:
    a4:1c:00:86:ee:1d:0d:b6:c2:29:75:40:66:dd:a8:
    9e:2b:61:aa:ba:27:ff:bc:df:31:c2:0b:76:5a:5e:
    bb:73:c2:7d:90:e1:dd:dd:62:fa:23:df:7f:a4:6c:
    40:67:9b:a7:10:3b:3e:7a:bf:dc:bd:4d:b0:1c:30:
    9c:ce:2d:18:38:4c:d7:58:c0:15:e2:4d:37:87:a9:
    dd:b0:b7:42:77:0a:44:74:59:78:9a:9c:06:d4:70:
    56:91
prime2:
    00:d7:4e:55:e7:40:a0:75:78:69:31:95:f5:db:0e:
    1a:8f:fc:dc:e9:84:57:dd:3e:b6:11:5c:85:55:64:
    76:43:58:ef:5c:a2:bd:3a:2b:84:c1:99:f3:2e:cd:
    0c:91:5f:14:ef:a4:f7:c4:e4:fe:90:f9:e6:95:db:
    26:53:a8:11:73:86:06:b9:39:9d:e0:b1:67:b8:b9:
    af:0d:ac:1e:ce:45:fc:37:d2:ce:9d:e5:a8:3f:ea:
    e7:33:27:9a:6e:13:f9:a2:b2:57:33:15:88:9d:b9:
    ec:70:61:11:f4:b4:31:e1:52:80:57:0a:4b:2e:15:
    43:ac:59:e9:f3:87:54:f4:10:39:81:8b:90:e8:43:
    60:59:b1:a0:7f:4b:db:b3:fb:98:e7:e1:7d:ee:14:
    58:5b:cc:14:b2:ec:ca:b7:76:28:4d:73:af:13:01:
    59:6a:0d:5e:ad:9e:f9:b6:cb:17:9f:bc:33:9f:31:
    50:ea:e4:89:6c:4e:59:e4:20:61:7e:23:9c:a0:2d:
    4c:97:4b:7b:76:2c:cb:64:78:db:f7:ca:10:79:d2:
    3b:5e:78:24:3d:ae:9c:d8:91:31:96:86:58:f4:7a:
    a5:06:e3:a5:e5:27:e0:69:3a:c3:f5:a7:a6:c5:cf:
    80:e3:d5:59:de:58:f7:fd:22:07:23:9b:19:9b:4e:
    77:df
exponent1:
    00:c5:92:0c:be:2b:b7:a4:01:b6:19:fe:4c:0b:97:
    a3:ac:0b:af:9a:67:9b:c6:1c:9a:94:87:0c:3b:0b:
    6b:cf:28:21:13:61:7e:51:b9:f0:bd:b1:76:cd:52:
    ff:e3:9b:aa:1d:ba:e9:ad:10:de:a8:31:25:9d:13:
    26:95:85:37:e2:f9:82:a6:4f:95:9d:6b:95:fa:df:
    5e:7f:b9:f6:77:c4:f0:49:16:67:e2:8b:2a:cd:b1:
    8d:ce:33:71:ce:fa:2b:d7:65:33:56:5e:a7:49:83:
    71:c3:ee:3e:2b:28:c1:c6:01:20:e9:b3:a3:a1:da:
    4e:40:8d:8f:55:1f:09:4f:bf:e7:ea:45:8a:5b:dc:
    ff:f4:8a:b8:fe:47:61:23:54:b8:a9:55:e3:06:3b:
    75:76:3b:b5:89:49:e8:6b:f8:5e:ee:98:d9:05:8c:
    bd:89:a5:81:71:da:1c:c7:88:59:35:0e:b1:7b:c4:
    1e:4e:25:b6:9c:f5:3e:c7:81:ab:16:1c:2d:ca:97:
    40:15:6c:bc:8c:ca:7d:9a:af:88:1d:6f:5e:e6:4d:
    51:0e:e1:17:b3:c0:c6:65:6a:bf:b6:29:42:5d:af:
    1e:46:ef:10:28:68:d1:cc:98:44:f8:66:b4:b3:3d:
    5e:d8:60:f6:fd:c0:07:29:35:ea:b7:73:2c:a8:05:
    ba:b1
exponent2:
    57:1a:f8:22:10:c1:5a:05:16:f9:da:a3:96:b6:04:
    05:10:d6:07:1b:65:b8:ba:b0:4a:21:d6:47:8f:d7:
    50:b3:e0:52:e7:fc:0a:56:a4:e4:f6:75:ae:0f:82:
    f0:25:39:81:22:8a:a2:fb:ca:09:b9:30:92:9c:10:
    cb:73:89:6b:e5:63:3e:f8:92:68:df:1d:09:5d:05:
    f7:50:15:3e:7a:8d:e9:bf:bd:9b:9f:d8:0b:d3:eb:
    29:84:f2:33:6a:9d:6a:37:20:94:28:38:17:27:ab:
    02:64:23:31:8e:dd:47:3d:6b:72:cb:55:53:15:83:
    45:6d:32:fb:35:5b:27:4a:91:19:59:ef:8c:28:06:
    09:03:95:dd:2a:41:7e:75:61:8d:1e:6b:26:30:d0:
    f6:82:80:35:4b:1b:50:51:db:48:4a:6f:20:0f:41:
    af:68:2d:4f:ac:ab:76:4a:80:0a:3d:c7:dc:b5:c4:
    f8:e2:f0:be:02:8c:d7:80:4a:31:10:13:43:b2:4f:
    f4:3d:b3:7b:41:f0:1f:7b:cd:f2:57:ab:86:bd:89:
    0b:55:2b:c4:50:aa:5f:eb:8d:d6:4a:10:1f:08:a7:
    4f:3c:36:57:99:64:6e:ee:39:6d:5f:20:57:92:f5:
    a0:37:26:9e:8f:fb:f4:4b:19:fc:4b:b9:76:5d:ae:
    9d
coefficient:
    72:6e:e9:90:ce:fb:bf:0e:70:02:d9:bc:75:ac:26:
    bf:70:9e:16:a2:31:a0:10:c9:f3:ff:5d:1a:a6:7b:
    9a:38:2e:51:49:44:43:92:26:9f:c9:51:e9:21:a7:
    c6:fe:18:d8:3b:15:e0:09:23:a3:1a:49:51:79:f1:
    ce:a5:9f:c8:47:89:54:81:32:3e:c8:a7:e7:ba:a8:
    17:a4:36:b0:0e:b7:3f:d1:c3:c0:9c:ac:d7:a0:8c:
    ea:c7:e8:dd:ca:eb:50:c2:7e:35:0f:1e:b5:77:d6:
    61:31:0d:5e:de:17:08:2a:90:75:4a:34:9f:19:c1:
    d2:95:59:a8:1f:c1:c7:08:b7:37:46:4d:2b:d9:ab:
    6b:4a:f7:3c:6d:3f:70:b4:43:b0:f2:a3:e5:2d:fc:
    54:9f:05:27:07:7e:2d:fd:1b:8a:49:6a:2d:ae:c4:
    4b:3f:e3:41:87:6b:df:da:15:7d:f4:63:c0:4a:23:
    2e:1a:d9:aa:10:79:4a:f5:68:1e:61:55:37:9f:7c:
    48:91:77:c6:ab:75:ba:7b:53:02:f8:61:65:e1:33:
    b2:e5:eb:bf:87:16:47:dd:a5:db:cd:46:59:6d:cc:
    b4:ed:d5:d5:31:23:27:31:4b:3f:e2:fd:8e:93:12:
    f6:19:3f:ea:42:2c:86:81:5d:d1:b5:f0:ef:3f:42:
    74


# Root CA 인증서 생성 : ca.crt
## -x509 : CSR을 만들지 않고 바로 인증서(X.509) 생성, 즉, Self-Signed Certificate
## -noenc : 개인키를 암호화하지 않음, 즉, CA 키(ca.key)에 패스프레이즈 없음
## -config ca.conf : 인증서 세부 정보는 설정 파일에서 읽음 , [req] 섹션 사용됨 - DN 정보 → [req_distinguished_name] , CA 확장 → [ca_x509_extensions]

root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl req -x509 -new -sha512 -noenc \
  -key ca.key -days 3653 \
  -config ca.conf \
  -out ca.crt

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l ca.crt
-rw-r--r-- 1 root root 1899 Jan 10 12:08 ca.crt

# ca.conf 관련 내용
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat ca.conf | grep -C 9 "ca_x509_extensions"
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

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat ca.crt
-----BEGIN CERTIFICATE-----
MIIFTDCCAzSgAwIBAgIUHFcNvixknFyAFmy3NwUfDLkfhxswDQYJKoZIhvcNAQEN
BQAwQTELMAkGA1UEBhMCVVMxEzARBgNVBAgMCldhc2hpbmd0b24xEDAOBgNVBAcM
B1NlYXR0bGUxCzAJBgNVBAMMAkNBMB4XDTI2MDExMDEyMDgwNVoXDTM2MDExMTEy
MDgwNVowQTELMAkGA1UEBhMCVVMxEzARBgNVBAgMCldhc2hpbmd0b24xEDAOBgNV
BAcMB1NlYXR0bGUxCzAJBgNVBAMMAkNBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
MIICCgKCAgEAvERVGy7ubEiOJvcgVy2RnU68LmuFIR86X1VtR3PNaiDXuZYY+p98
RzuR8b46MwK1pwIw6VrI9e72d12l4QrMdrTus1Mf5eZE0q57zOYDtG/U9LGxDuv3
bk5m8cgZxI8LGJ4Qm6n6WRdU0XUlHAq7s5WrjnXRzhffQpnp3fGNpI3kQ3mTYGrw
WlY6UD4z9Yx2qkWGtadFwUUWWlxA9iFFZQaKu8VOnxHfFirJ0Jlgi0Ii62axrwiN
YN+ynGcDd52zXN6WCssIjd6WpFoRs1mdcoPuqeG8pJMmDZeu9R7B14ChAIzoOpEj
cCx3d757nnugHKYkLPZR1AuH0DJbx/nPvwOVexPTJUntuy1fzuk2zZIyLD0GkKeW
sE86kRDtEprl4JMriCv15BuOQ44+UrsZnFpCpkHOmdD7Q4w4ZesiwwPpXnvxf4Sh
chzpqppScWrrQYnz48uiJD49EGS2tD7AgwoVRCIhsxDtjXb8PRF6UIkAQBeJxhOa
pDTGKb33BA8BOPUrl1l2msicaPsqck3vXYJZbDYH+tZLZ6qYgh1fxPP+IhXs1zen
yrwbWke6y4Pl0GRWX+GqNM/CWRXwaU0mVSDopfRooEJw86mRmVO9+cF8PYRKmhXO
WWaL6qwYSCf/nv66Ru4cviU5ToWl6VugG9YvmK3lrpXaKh8UgHFGz08CAwEAAaM8
MDowDAYDVR0TBAUwAwEB/zALBgNVHQ8EBAMCAQYwHQYDVR0OBBYEFGdoiUBnqWqc
o/NEVr9aJ1eY/9UAMA0GCSqGSIb3DQEBDQUAA4ICAQAuRi3XMZdrrSpu4PE1Sk7V
peSi4uPDTJN6W7rBXYCDUVVR3C61VmJX1WhfwHyFLWX+BJErdc0uGMcDD/j07TaC
Hr02cjiJcHOnH+veUGevW6dZylvMzuE+ielOMYD7zoqK96l0Y1ySOTD7sXPTZoOp
4KGZl1y7vfI2iu2GqWeP8AAptBnIcEK9o9GFPrha7npM/Q8Ih4vB4qLF/DTCCFa1
4Lj9bWugtMFBmewObstZxzKsSUzAJvMLWkLaSKuzBZWeYpVyn/4J+Jdfy0Irmm9v
iPL7J7Hvvc2NdQi+MiqM4fBhnMJCRA10EzmbOX1RSzoCUNy2pXhbgdl1L+hDFmrA
ovcMgXn71IRU7GExTm6Q4mGfDdzn6YDC46GtAF5YVQhTX5WAcWPH2KS5PJyRobdM
lfZxLw+HkQ6vt3iYhYqCF3ESI27hQj1PAzyOajiYyDlcDEQEP+Xk7lKCittQcLCK
eyBqbW3DbemLgGUkgVqdL+is7tUGzF8e4kRx6dKfL67/W+G9oArf11x0L3S0XHrn
YQDMzkWCXrft4MRzWjyidCaBwVTcHwYz74gVT1B3ZXEbbBjfAKtTTUmpExjqns9q
mQ39/WNrlNY7MxXbNbEWI+Nz++KbgzqE6HgmK7Hl1smI0MONZba6DCSsDx0oVO22
2X/SUI2Nm5+TwedDUQrKEQ==
-----END CERTIFICATE-----

# 인증서 전체 내용 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl x509 -in ca.crt -text -noout
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            1c:57:0d:be:2c:64:9c:5c:80:16:6c:b7:37:05:1f:0c:b9:1f:87:1b
        Signature Algorithm: sha512WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:08:05 2026 GMT
            Not After : Jan 11 12:08:05 2036 GMT
        Subject: C=US, ST=Washington, L=Seattle, CN=CA
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:bc:44:55:1b:2e:ee:6c:48:8e:26:f7:20:57:2d:
                    91:9d:4e:bc:2e:6b:85:21:1f:3a:5f:55:6d:47:73:
                    cd:6a:20:d7:b9:96:18:fa:9f:7c:47:3b:91:f1:be:
                    3a:33:02:b5:a7:02:30:e9:5a:c8:f5:ee:f6:77:5d:
                    a5:e1:0a:cc:76:b4:ee:b3:53:1f:e5:e6:44:d2:ae:
                    7b:cc:e6:03:b4:6f:d4:f4:b1:b1:0e:eb:f7:6e:4e:
                    66:f1:c8:19:c4:8f:0b:18:9e:10:9b:a9:fa:59:17:
                    54:d1:75:25:1c:0a:bb:b3:95:ab:8e:75:d1:ce:17:
                    df:42:99:e9:dd:f1:8d:a4:8d:e4:43:79:93:60:6a:
                    f0:5a:56:3a:50:3e:33:f5:8c:76:aa:45:86:b5:a7:
                    45:c1:45:16:5a:5c:40:f6:21:45:65:06:8a:bb:c5:
                    4e:9f:11:df:16:2a:c9:d0:99:60:8b:42:22:eb:66:
                    b1:af:08:8d:60:df:b2:9c:67:03:77:9d:b3:5c:de:
                    96:0a:cb:08:8d:de:96:a4:5a:11:b3:59:9d:72:83:
                    ee:a9:e1:bc:a4:93:26:0d:97:ae:f5:1e:c1:d7:80:
                    a1:00:8c:e8:3a:91:23:70:2c:77:77:be:7b:9e:7b:
                    a0:1c:a6:24:2c:f6:51:d4:0b:87:d0:32:5b:c7:f9:
                    cf:bf:03:95:7b:13:d3:25:49:ed:bb:2d:5f:ce:e9:
                    36:cd:92:32:2c:3d:06:90:a7:96:b0:4f:3a:91:10:
                    ed:12:9a:e5:e0:93:2b:88:2b:f5:e4:1b:8e:43:8e:
                    3e:52:bb:19:9c:5a:42:a6:41:ce:99:d0:fb:43:8c:
                    38:65:eb:22:c3:03:e9:5e:7b:f1:7f:84:a1:72:1c:
                    e9:aa:9a:52:71:6a:eb:41:89:f3:e3:cb:a2:24:3e:
                    3d:10:64:b6:b4:3e:c0:83:0a:15:44:22:21:b3:10:
                    ed:8d:76:fc:3d:11:7a:50:89:00:40:17:89:c6:13:
                    9a:a4:34:c6:29:bd:f7:04:0f:01:38:f5:2b:97:59:
                    76:9a:c8:9c:68:fb:2a:72:4d:ef:5d:82:59:6c:36:
                    07:fa:d6:4b:67:aa:98:82:1d:5f:c4:f3:fe:22:15:
                    ec:d7:37:a7:ca:bc:1b:5a:47:ba:cb:83:e5:d0:64:
                    56:5f:e1:aa:34:cf:c2:59:15:f0:69:4d:26:55:20:
                    e8:a5:f4:68:a0:42:70:f3:a9:91:99:53:bd:f9:c1:
                    7c:3d:84:4a:9a:15:ce:59:66:8b:ea:ac:18:48:27:
                    ff:9e:fe:ba:46:ee:1c:be:25:39:4e:85:a5:e9:5b:
                    a0:1b:d6:2f:98:ad:e5:ae:95:da:2a:1f:14:80:71:
                    46:cf:4f
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:TRUE
            X509v3 Key Usage: 
                Certificate Sign, CRL Sign
            X509v3 Subject Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha512WithRSAEncryption
    Signature Value:
        2e:46:2d:d7:31:97:6b:ad:2a:6e:e0:f1:35:4a:4e:d5:a5:e4:
        a2:e2:e3:c3:4c:93:7a:5b:ba:c1:5d:80:83:51:55:51:dc:2e:
        b5:56:62:57:d5:68:5f:c0:7c:85:2d:65:fe:04:91:2b:75:cd:
        2e:18:c7:03:0f:f8:f4:ed:36:82:1e:bd:36:72:38:89:70:73:
        a7:1f:eb:de:50:67:af:5b:a7:59:ca:5b:cc:ce:e1:3e:89:e9:
        4e:31:80:fb:ce:8a:8a:f7:a9:74:63:5c:92:39:30:fb:b1:73:
        d3:66:83:a9:e0:a1:99:97:5c:bb:bd:f2:36:8a:ed:86:a9:67:
        8f:f0:00:29:b4:19:c8:70:42:bd:a3:d1:85:3e:b8:5a:ee:7a:
        4c:fd:0f:08:87:8b:c1:e2:a2:c5:fc:34:c2:08:56:b5:e0:b8:
        fd:6d:6b:a0:b4:c1:41:99:ec:0e:6e:cb:59:c7:32:ac:49:4c:
        c0:26:f3:0b:5a:42:da:48:ab:b3:05:95:9e:62:95:72:9f:fe:
        09:f8:97:5f:cb:42:2b:9a:6f:6f:88:f2:fb:27:b1:ef:bd:cd:
        8d:75:08:be:32:2a:8c:e1:f0:61:9c:c2:42:44:0d:74:13:39:
        9b:39:7d:51:4b:3a:02:50:dc:b6:a5:78:5b:81:d9:75:2f:e8:
        43:16:6a:c0:a2:f7:0c:81:79:fb:d4:84:54:ec:61:31:4e:6e:
        90:e2:61:9f:0d:dc:e7:e9:80:c2:e3:a1:ad:00:5e:58:55:08:
        53:5f:95:80:71:63:c7:d8:a4:b9:3c:9c:91:a1:b7:4c:95:f6:
        71:2f:0f:87:91:0e:af:b7:78:98:85:8a:82:17:71:12:23:6e:
        e1:42:3d:4f:03:3c:8e:6a:38:98:c8:39:5c:0c:44:04:3f:e5:
        e4:ee:52:82:8a:db:50:70:b0:8a:7b:20:6a:6d:6d:c3:6d:e9:
        8b:80:65:24:81:5a:9d:2f:e8:ac:ee:d5:06:cc:5f:1e:e2:44:
        71:e9:d2:9f:2f:ae:ff:5b:e1:bd:a0:0a:df:d7:5c:74:2f:74:
        b4:5c:7a:e7:61:00:cc:ce:45:82:5e:b7:ed:e0:c4:73:5a:3c:
        a2:74:26:81:c1:54:dc:1f:06:33:ef:88:15:4f:50:77:65:71:
        1b:6c:18:df:00:ab:53:4d:49:a9:13:18:ea:9e:cf:6a:99:0d:
        fd:fd:63:6b:94:d6:3b:33:15:db:35:b1:16:23:e3:73:fb:e2:
        9b:83:3a:84:e8:78:26:2b:b1:e5:d6:c9:88:d0:c3:8d:65:b6:
        ba:0c:24:ac:0f:1d:28:54:ed:b6:d9:7f:d2:50:8d:8d:9b:9f:
        93:c1:e7:43:51:0a:ca:11

```


Create Client and Server Certificates : admin

```bash
# Create Client and Server Certificates : admin
root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl genrsa -out admin.key 4096

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l admin.key
-rw------- 1 root root 3272 Jan 10 12:09 admin.key

# ca.conf 에 admin 섹션
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat ca.conf | grep -A 3 "\[admin"
[admin]
distinguished_name = admin_distinguished_name
prompt             = no
req_extensions     = default_req_extensions
--
[admin_distinguished_name]
CN = admin
O  = system:masters

# 공통 CSR 확장
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat ca.conf | grep -A 7 "\[default_req_extensions\]"
[default_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Admin Client Certificate"
subjectKeyIdentifier = hash

# csr 파일 생성 : admin.key 개인키를 사용해 'CN=admin, O=system:masters'인 Kubernetes 관리자용 클라이언트 인증서 요청(admin.csr) 생성
root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl req -new -key admin.key -sha256 \
  -config ca.conf -section admin \
  -out admin.csr

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l admin.csr
-rw-r--r-- 1 root root 1830 Jan 10 12:10 admin.csr

# CSR 전체 내용 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl req -in admin.csr -text -noout
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: CN=admin, O=system:masters
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:b3:7d:fb:20:b1:a8:9e:28:44:d7:fe:75:44:b6:
                    d8:bc:2a:f3:88:cd:ab:4d:09:e6:73:62:cf:57:f8:
                    1b:e7:07:1b:5a:04:7c:fd:42:24:55:a5:02:f1:73:
                    17:44:31:5e:e3:0d:68:87:3a:65:57:0a:c7:79:3f:
                    56:04:69:c5:7e:3e:0b:a3:da:93:e1:3f:c3:c6:28:
                    ff:17:98:6d:56:b8:1a:a7:55:16:18:99:71:2e:f3:
                    75:0f:38:15:2f:92:95:ac:08:53:82:b3:41:d3:ed:
                    c4:51:bc:ca:6d:b5:f4:07:54:fc:8b:e2:c9:26:f0:
                    c8:6f:99:b7:70:ac:c3:61:60:df:1b:4a:5b:87:b4:
                    8d:c4:b8:ae:32:d1:4d:4c:87:8c:e9:0e:fd:75:b0:
                    3e:29:c7:a1:75:8e:c8:10:0f:d1:ea:a3:5f:b1:f7:
                    a9:36:5e:5a:2f:09:d2:ca:5a:9b:9b:41:b5:a9:b8:
                    a9:a8:3f:4a:9d:dd:43:99:2d:bb:a3:05:87:a0:0e:
                    d8:c6:67:4b:f9:3a:0c:eb:ef:e2:8b:1e:6f:b1:18:
                    51:f6:92:b3:5d:79:79:52:92:13:88:a3:a2:90:0e:
                    65:50:96:ab:85:e9:e2:fe:cc:fe:4c:5b:99:f2:ec:
                    b6:8d:19:3a:75:7d:c1:8a:c1:20:20:c6:eb:14:b7:
                    f7:b7:46:58:29:b9:44:c9:37:b3:42:18:fc:3c:1d:
                    e7:d1:82:e4:d0:0b:fb:c8:0f:6c:9c:51:49:39:a0:
                    77:dc:77:15:be:3b:c1:68:3a:4d:29:bd:97:4d:51:
                    c2:22:6a:d6:ae:aa:6a:ab:13:15:10:89:8e:75:f5:
                    43:7a:59:81:52:aa:47:81:58:0b:bd:8b:f0:d0:09:
                    72:30:c9:c5:c0:e9:8f:4a:e1:0b:6b:1d:ef:b6:0b:
                    ce:a2:65:74:74:ff:a4:9b:01:5a:2d:65:01:17:54:
                    45:b9:a5:82:76:f8:42:62:cb:06:32:c7:47:a8:5f:
                    52:1c:e9:15:9b:70:14:d7:47:f0:8e:f2:57:89:ba:
                    95:d8:b1:05:e8:68:49:8c:07:75:4f:64:c0:83:12:
                    0d:a3:f9:f2:b2:ff:e5:8e:8b:d7:4f:27:d1:a7:2a:
                    2e:fa:cf:dc:df:6c:1b:cd:6a:fc:62:db:46:1a:e6:
                    c0:78:3b:9b:02:d5:64:12:7c:a6:17:2d:69:7a:e5:
                    38:ff:bb:c4:b6:38:78:3e:52:63:c9:e8:af:0d:81:
                    f2:eb:9c:e9:de:14:ed:f7:cb:e7:7d:96:f3:bd:b0:
                    1c:26:70:e3:a1:f5:e3:2d:3b:db:c1:73:d8:4e:e4:
                    0b:98:be:c5:eb:8e:a6:58:f3:aa:45:de:7f:90:77:
                    52:f4:fd
                Exponent: 65537 (0x10001)
        Attributes:
            Requested Extensions:
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
                    2C:00:5F:51:EC:63:EA:F3:8D:A3:7F:E7:67:98:99:72:94:79:B7:11
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        5f:56:7d:6c:77:ef:5b:6b:fe:e6:64:7e:a2:0a:fb:e0:c6:7d:
        40:d3:5b:99:57:fd:b5:6e:55:0f:5b:f7:36:b9:54:bd:6f:09:
        b7:c5:e0:ab:35:32:58:a0:3a:55:ef:12:87:fc:15:10:f3:6a:
        cc:f4:91:b8:00:14:5a:e3:5b:74:85:57:a5:fa:0b:31:b9:99:
        6b:2f:ac:8b:c2:4c:d0:2a:44:f3:c2:a0:89:d4:e6:50:39:72:
        52:7a:41:b8:65:69:03:2b:0c:f7:ca:1d:6b:be:16:b4:5b:24:
        dd:41:fa:1d:a6:71:54:26:4f:0b:1e:47:a0:e6:ec:74:e4:a4:
        0c:59:80:7e:19:27:b3:6e:d0:ab:0e:d3:74:91:be:06:18:0c:
        ab:ed:2c:2a:ba:16:43:c7:26:70:3a:7d:0c:17:f2:3d:cc:c1:
        9d:94:e2:3d:fc:2e:3a:7d:6d:6f:95:aa:a5:ab:94:fe:5a:32:
        28:44:ac:9e:0d:f4:38:2a:9d:35:e0:02:b9:3b:74:51:fb:b4:
        91:70:ad:58:61:6f:a6:b2:86:c2:b1:20:1c:d9:28:da:dc:8b:
        ef:1e:3a:39:9a:f6:2c:e8:a6:59:75:d1:4e:79:d6:61:71:94:
        f9:00:74:f2:41:91:b3:eb:dd:f6:2e:34:1d:e7:ca:50:db:f4:
        35:32:03:92:e7:0f:47:26:d8:b6:a7:6d:d8:9c:6d:09:ff:7c:
        af:01:d7:e9:cd:58:87:67:ac:09:cc:8d:4d:09:b7:8e:79:1a:
        fa:41:fc:44:d0:83:f5:dc:3a:d8:30:80:c3:47:07:a4:fc:db:
        78:28:f0:a6:d9:38:ac:66:aa:dd:c3:55:4c:1f:a2:90:fe:3e:
        44:1a:b3:1b:a9:b4:99:f3:80:e5:fa:4e:8f:97:d4:a6:d7:e5:
        89:2f:f4:7b:94:23:ab:a4:3d:ed:b7:a8:12:31:39:9e:2b:f4:
        00:8a:d1:1b:97:3e:f6:d6:64:ac:00:fd:b5:77:24:d3:d3:1e:
        fa:2e:2a:65:99:b9:cf:de:00:c6:c6:69:36:44:2f:1b:d2:b2:
        56:52:31:f3:c7:00:2a:c5:2b:20:a4:ca:b8:2f:b0:8c:84:97:
        11:62:dc:72:2d:ff:fd:1e:4f:ce:2a:29:15:37:ec:d9:0f:0e:
        0d:61:02:06:32:86:44:5d:52:5c:b1:72:3f:fd:3b:ac:95:0a:
        8d:cf:89:63:88:54:1a:50:5b:56:18:6b:be:c7:e6:5b:28:3d:
        92:52:b3:be:b1:ea:f7:bd:d2:7d:bc:ed:12:1e:3f:f7:e1:52:
        5b:5a:9b:37:3e:7e:00:59:1d:66:6f:38:e7:14:37:92:81:86:
        c5:01:59:75:e0:52:55:c7


# ca에 csr 요청을 통한 crt 파일 생성
## -req : CSR를 입력으로 받아 인증서를 생성, self-signed 아님, CA가 서명하는 방식
## -days 3653 : 인증서 유효기간 3653일 (약 10년)
## -copy_extensions copyall : CSR에 포함된 모든 X.509 extensions를 인증서로 복사
## -CAcreateserial : CA 시리얼 번호 파일 자동 생성, 다음 인증서 발급 시 재사용, 기본 생성 파일(ca.srl)
root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl x509 -req -days 3653 -in admin.csr \
  -copy_extensions copyall \
  -sha256 -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out admin.crt
Certificate request self-signature ok
subject=CN=admin, O=system:masters

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l admin.crt
-rw-r--r-- 1 root root 2021 Jan 10 12:11 admin.crt


root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl x509 -in admin.crt -text -noout | grep -C 10 "Issuer"
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:8d
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:11:07 2026 GMT
            Not After : Jan 11 12:11:07 2036 GMT
        Subject: CN=admin, O=system:masters # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:b3:7d:fb:20:b1:a8:9e:28:44:d7:fe:75:44:b6:
                    d8:bc:2a:f3:88:cd:ab:4d:09:e6:73:62:cf:57:f8:


root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl x509 -in admin.crt -text -noout | grep -C 10 "X509v3 extensions"
                    95:d8:b1:05:e8:68:49:8c:07:75:4f:64:c0:83:12:
                    0d:a3:f9:f2:b2:ff:e5:8e:8b:d7:4f:27:d1:a7:2a:
                    2e:fa:cf:dc:df:6c:1b:cd:6a:fc:62:db:46:1a:e6:
                    c0:78:3b:9b:02:d5:64:12:7c:a6:17:2d:69:7a:e5:
                    38:ff:bb:c4:b6:38:78:3e:52:63:c9:e8:af:0d:81:
                    f2:eb:9c:e9:de:14:ed:f7:cb:e7:7d:96:f3:bd:b0:
                    1c:26:70:e3:a1:f5:e3:2d:3b:db:c1:73:d8:4e:e4:
                    0b:98:be:c5:eb:8e:a6:58:f3:aa:45:de:7f:90:77:
                    52:f4:fd
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
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat ca.conf | grep system:kube-scheduler
CN = system:kube-scheduler
O  = system:system:kube-scheduler

root@ip-172-31-11-186:~/kubernetes-the-hard-way# sed -i 's/system:system:kube-scheduler/system:kube-scheduler/' ca.conf

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat ca.conf | grep system:kube-scheduler
CN = system:kube-scheduler
O  = system:kube-scheduler

# 변수 지정
root@ip-172-31-11-186:~/kubernetes-the-hard-way# certs=(
  "node-0" "node-1"
  "kube-proxy" "kube-scheduler"
  "kube-controller-manager"
  "kube-api-server"
  "service-accounts"
)

# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# echo ${certs[*]}
node-0 node-1 kube-proxy kube-scheduler kube-controller-manager kube-api-server service-accounts

# 개인키 생성, csr 생성, 인증서 생성
root@ip-172-31-11-186:~/kubernetes-the-hard-way# for i in ${certs[*]}; do
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

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -1 *.crt *.key *.csr
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
root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl x509 -in node-0.crt -text -noout | grep -C 10 node-0
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:8e
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:12 2026 GMT
            Not After : Jan 11 12:13:12 2036 GMT
        Subject: CN=system:node:node-0, O=system:nodes, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:8c:40:e8:76:2b:16:c5:6d:88:fb:63:bf:08:a7:
                    06:87:78:b8:a4:54:88:7d:03:a3:3a:01:c8:07:c3:
                    14:bb:76:c2:27:bb:2e:0d:76:29:4b:de:fa:5e:d4:
                    99:ca:83:f0:02:e1:1f:51:34:7b:6e:87:c4:f0:60:
                    46:f3:2a:fa:96:f9:a7:f6:f6:86:35:4f:63:e9:99:
                    53:38:8d:63:4b:83:d6:04:49:6b:6f:19:97:2e:09:
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
                EC:85:76:8D:8B:31:08:45:7F:E1:BF:8C:56:0C:13:43:5D:97:72:59
            X509v3 Authority Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        a2:a0:97:96:b4:f5:5e:af:e2:2c:87:05:21:3c:15:65:09:9a:
        d8:70:ff:cd:a8:32:df:9c:87:21:e0:ed:e3:66:0a:7c:9a:0e:
        0e:38:93:ba:8b:6f:b6:21:5b:5b:15:f5:4e:a4:ae:48:74:af:
        27:ee:1f:1c:6e:7d:3d:08:6f:d1:be:10:23:3b:94:2b:d2:f6:


root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl x509 -in node-1.crt -text -noout | grep -C 10 node-1
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:8f
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:12 2026 GMT
            Not After : Jan 11 12:13:12 2036 GMT
        Subject: CN=system:node:node-1, O=system:nodes, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:c6:dc:d5:82:79:ee:aa:66:b1:02:f9:fd:92:f9:
                    5e:1f:06:0c:f5:32:38:4f:f5:8a:80:32:73:2e:55:
                    11:2f:c4:cf:85:c8:a7:d3:45:4d:8f:58:ac:56:ca:
                    75:3b:9c:1a:07:5d:f4:f8:3d:d8:c1:43:e8:0f:ef:
                    1e:60:d5:12:7a:f9:1e:49:98:eb:5c:09:dc:a3:39:
                    89:df:55:9a:37:5e:cd:cb:c5:74:2a:ea:6e:ad:a0:
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
                65:84:F6:F5:CA:06:10:B8:CC:E8:A8:D9:69:0A:3D:3B:2A:85:70:9D
            X509v3 Authority Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        b8:18:95:cb:b3:4d:df:0c:c9:f4:a4:97:ef:75:04:86:22:38:
        ea:eb:45:21:e5:81:6c:ae:f1:4b:4d:79:09:8c:97:5f:54:ad:
        d7:95:eb:25:a6:0a:b1:2e:50:50:31:6d:89:5d:49:cb:b0:12:
        94:69:cf:9a:06:29:72:7f:a4:96:37:71:d0:a0:cc:ee:58:a5:


root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl x509 -in kube-proxy.crt -text -noout | grep -C 10 kube-proxy
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:90
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:13 2026 GMT
            Not After : Jan 11 12:13:13 2036 GMT
        Subject: CN=system:kube-proxy, O=system:node-proxier, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:ab:8b:e6:c7:24:7c:f6:12:a4:3d:7a:bc:13:59:
                    9b:92:1f:4f:16:58:b2:f4:26:0d:0b:fb:19:31:6b:
                    6a:90:7d:f4:11:94:4f:fd:55:18:31:e9:8a:b6:11:
                    a3:cd:ff:1a:c0:52:d9:de:18:b3:9c:0b:36:fe:45:
                    14:57:14:80:27:71:3d:06:b8:d9:71:7d:c7:85:15:
                    fd:b4:b9:3b:4a:35:d4:d5:ae:64:36:97:9f:68:ef:
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
                40:A5:30:79:02:40:53:7E:E4:1B:5F:20:87:0B:7E:BD:17:51:F4:19
            X509v3 Authority Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        35:51:ba:c3:c0:74:52:b4:ee:5f:57:b4:18:38:b5:8b:fa:e3:
        46:fb:5e:2f:a9:01:dd:1b:84:c3:69:7d:58:ba:0e:cb:93:9e:
        c4:98:29:15:1f:f7:c6:f3:0d:cb:4a:91:4f:68:46:30:b0:d6:
        6c:25:7f:06:d7:40:4f:d2:c1:2d:42:ec:0d:4f:04:c3:30:a2:


root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl x509 -in kube-scheduler.crt -text -noout | grep -C 10 kube-scheduler
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:91
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:14 2026 GMT
            Not After : Jan 11 12:13:14 2036 GMT
        Subject: CN=system:kube-scheduler, O=system:kube-scheduler, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:b3:90:03:69:1d:bc:55:ab:e3:4c:54:cb:f3:26:
                    7d:89:d0:fc:5d:6b:da:32:78:8c:f0:dd:02:cd:5c:
                    47:ee:cc:72:00:20:aa:78:30:ef:fa:60:13:8a:f8:
                    5f:59:2d:4b:7e:37:db:b5:a8:c4:8f:62:85:b2:2f:
                    65:f8:08:ce:d9:cb:03:77:5f:b5:cc:2a:35:1f:7f:
                    70:53:18:56:f6:a0:51:61:56:7e:51:c5:b9:77:96:
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
                4C:7D:D9:3B:7A:50:D6:64:85:4F:BE:5D:92:13:2E:52:C8:46:39:AA
            X509v3 Authority Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        b7:38:60:ad:3f:fe:83:8e:88:ea:45:2f:d5:20:e9:8b:ce:60:
        ea:c7:8b:3b:1b:40:89:e7:88:f7:ef:65:fe:ca:78:ab:59:73:
        1b:8e:fc:c2:35:39:2c:b8:56:a2:95:48:a7:01:c4:9a:57:77:
        13:e1:d5:d0:2f:b8:51:96:05:95:99:a0:3b:c8:e9:2e:87:f7:


root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl x509 -in kube-controller-manager.crt -text -noout | grep -C 10 kube-controller-manager
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:92
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:15 2026 GMT
            Not After : Jan 11 12:13:15 2036 GMT
        Subject: CN=system:kube-controller-manager, O=system:kube-controller-manager, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:a7:10:2f:bd:61:38:78:d7:0a:d7:8f:c1:04:b2:
                    e6:9c:bf:26:a8:98:da:8b:2e:63:c9:79:64:a0:61:
                    bf:9c:ff:b6:2f:c4:e5:52:93:e0:c3:c1:a6:70:3c:
                    8c:42:be:7c:2f:a5:fe:cb:1c:3e:01:da:c4:65:ff:
                    96:48:fa:7f:91:63:e6:53:74:77:30:28:a3:b6:3e:
                    1c:44:cd:63:ea:2b:8a:97:12:54:b4:de:d7:69:b0:
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
                13:A6:2E:13:A7:65:DF:6F:B5:D0:55:77:88:65:1B:02:A7:DA:5F:4D
            X509v3 Authority Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        6b:1b:ae:6d:96:d1:bb:67:67:fa:ab:c8:9c:ad:68:80:17:31:
        29:b9:f0:0a:ae:73:5b:db:76:1a:1a:09:02:cb:35:b9:f4:bf:
        57:29:1e:a6:3c:5b:fc:1f:e9:6d:67:96:c5:b7:cd:94:00:7e:
        4f:77:55:cf:36:02:b7:6f:4e:b7:8c:46:e5:15:d6:7f:70:65:


# api-server : SAN 정보에 10.32.0.1 은 kubernetes (Service) ClusterIP. 다른 인증서와 다르게 SSL Server 역할 추가 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl x509 -in kube-api-server.crt -text -noout | grep -C 10 kubernetes
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:93
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:15 2026 GMT
            Not After : Jan 11 12:13:15 2036 GMT
        Subject: CN=kubernetes, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:e8:84:0c:6e:f2:0a:a4:c8:b5:21:e9:10:8a:84:
                    f0:ae:6a:11:fb:7b:cb:f8:1c:da:7f:87:98:1f:b4:
                    8f:07:f2:1b:1b:f0:1c:0e:01:f6:47:b1:2b:8e:64:
                    9f:e3:b5:cc:fe:bc:ef:0d:e6:e1:80:09:26:b6:ae:
                    eb:d6:85:e6:8e:f5:f3:32:46:22:aa:23:c6:83:6a:
                    c6:26:ef:7f:25:d1:12:be:ae:db:dd:1a:4a:b2:44:
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
                44:D0:C1:CF:43:54:C6:64:33:7E:24:F8:4B:D2:82:C5:DA:CC:3F:4B
            X509v3 Authority Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        21:43:a7:c2:19:ba:10:0f:10:48:0b:18:8b:fc:e7:a2:5c:a6:
        33:83:27:3f:80:17:a7:8e:71:1c:8e:f3:06:3c:47:83:1c:a7:
        51:79:02:12:68:22:c2:c4:0f:6f:35:c7:5d:d8:91:b4:89:b9:
        25:41:cb:d8:34:20:d2:12:59:7a:de:1f:e8:1a:6e:1d:cc:d6:


root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl x509 -in service-accounts.crt -text -noout | grep -C 10 service-accounts
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:94
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:16 2026 GMT
            Not After : Jan 11 12:13:16 2036 GMT
        Subject: CN=service-accounts # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:d1:a1:ba:d6:6f:5a:e3:b5:e7:15:ec:5a:31:54:
                    97:dd:12:63:84:54:dd:b2:dd:5c:87:51:39:bf:7a:
                    ac:b9:ff:c5:a7:a0:06:22:f2:9b:67:ca:61:98:f6:
                    d7:67:6d:f3:d9:b8:00:ce:1e:67:a5:eb:94:7b:af:
                    46:8d:1b:92:ed:ef:fe:20:c8:1f:39:d0:e5:f1:ac:
                    f1:7f:a9:81:ab:9a:28:bf:23:16:fc:9a:40:b5:04:
```

Distribute the Client and Server Certificates

```bash
# Copy the appropriate certificates and private keys to the node-0 and node-1 machines
for host in node-0 node-1; do
  ssh root@${host} mkdir /var/lib/kubelet/

  scp ca.crt root@${host}:/var/lib/kubelet/

  scp ${host}.crt \
    root@${host}:/var/lib/kubelet/kubelet.crt

  scp ${host}.key \
    root@${host}:/var/lib/kubelet/kubelet.key
done
```

```bash
root@ip-172-31-11-186:~/kubernetes-the-hard-way# for host in node-0 node-1; do
  ssh root@${host} mkdir /var/lib/kubelet/

  scp ca.crt root@${host}:/var/lib/kubelet/

  scp ${host}.crt \
    root@${host}:/var/lib/kubelet/kubelet.crt

  scp ${host}.key \
    root@${host}:/var/lib/kubelet/kubelet.key
done

root@node-0's password: 
root@node-0's password: 
ca.crt                                                    100% 1899     3.5MB/s   00:00    
root@node-0's password: 
node-0.crt                                                100% 2147     5.3MB/s   00:00    
root@node-0's password: 
node-0.key                                                100% 3272     7.4MB/s   00:00    
root@node-1's password: 
root@node-1's password: 
ca.crt                                                    100% 1899     4.5MB/s   00:00    
root@node-1's password: 
node-1.crt                                                100% 2147     3.9MB/s   00:00    
root@node-1's password: 
node-1.key                                                100% 3272     4.1MB/s   00:00

# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-0 ls -l /var/lib/kubelet
root@node-0's password: 
total 12
-rw-r--r-- 1 root root 1899 Jan 10 12:20 ca.crt
-rw-r--r-- 1 root root 2147 Jan 10 12:20 kubelet.crt
-rw------- 1 root root 3272 Jan 10 12:20 kubelet.key

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-1 ls -l /var/lib/kubelet
root@node-1's password: 
total 12
-rw-r--r-- 1 root root 1899 Jan 10 12:20 ca.crt
-rw-r--r-- 1 root root 2147 Jan 10 12:20 kubelet.crt
-rw------- 1 root root 3272 Jan 10 12:20 kubelet.key
```

```bash
# Copy the appropriate certificates and private keys to the server machine
scp \
  ca.key ca.crt \
  kube-api-server.key kube-api-server.crt \
  service-accounts.key service-accounts.crt \
  root@server:~/
```

```bash
root@ip-172-31-11-186:~/kubernetes-the-hard-way# scp \
  ca.key ca.crt \
  kube-api-server.key kube-api-server.crt \
  service-accounts.key service-accounts.crt \
  root@server:~/
root@server's password: 
ca.key                                                    100% 3272     4.2MB/s   00:00    
ca.crt                                                    100% 1899     2.4MB/s   00:00    
kube-api-server.key                                       100% 3272     6.1MB/s   00:00    
kube-api-server.crt                                       100% 2354     4.0MB/s   00:00    
service-accounts.key                                      100% 3272     5.4MB/s   00:00    
service-accounts.crt                                      100% 2004     3.7MB/s   00:00 

# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh server ls -l /root
root@server's password: 
total 24
-rw-r--r-- 1 root root 1899 Jan 10 12:24 ca.crt
-rw------- 1 root root 3272 Jan 10 12:24 ca.key
-rw-r--r-- 1 root root 2354 Jan 10 12:24 kube-api-server.crt
-rw------- 1 root root 3272 Jan 10 12:24 kube-api-server.key
-rw-r--r-- 1 root root 2004 Jan 10 12:24 service-accounts.crt
-rw------- 1 root root 3272 Jan 10 12:24 service-accounts.key
```
---

## 05 - Generating Kubernetes Configuration Files for Authentication

### The kubelet Kubernetes Configuration File

```bash
# Generate a kubeconfig file for the node-0 and node-1 worker nodes

# config set-cluster
root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://server.kubernetes.local:6443 \
  --kubeconfig=node-0.kubeconfig && ls -l node-0.kubeconfig && cat node-0.kubeconfig
Cluster "kubernetes-the-hard-way" set.
-rw------- 1 root root 2758 Jan 10 12:26 node-0.kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZURENDQXpTZ0F3SUJBZ0lVSEZjTnZpeGtuRnlBRm15M053VWZETGtmaHhzd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1EZ3dOVm9YRFRNMk1ERXhNVEV5Ck1EZ3dOVm93UVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01DbGRoYzJocGJtZDBiMjR4RURBT0JnTlYKQkFjTUIxTmxZWFIwYkdVeEN6QUpCZ05WQkFNTUFrTkJNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QQpNSUlDQ2dLQ0FnRUF2RVJWR3k3dWJFaU9KdmNnVnkyUm5VNjhMbXVGSVI4NlgxVnRSM1BOYWlEWHVaWVkrcDk4ClJ6dVI4YjQ2TXdLMXB3SXc2VnJJOWU3MmQxMmw0UXJNZHJUdXMxTWY1ZVpFMHE1N3pPWUR0Ry9VOUxHeER1djMKYms1bThjZ1p4SThMR0o0UW02bjZXUmRVMFhVbEhBcTdzNVdyam5YUnpoZmZRcG5wM2ZHTnBJM2tRM21UWUdydwpXbFk2VUQ0ejlZeDJxa1dHdGFkRndVVVdXbHhBOWlGRlpRYUt1OFZPbnhIZkZpckowSmxnaTBJaTYyYXhyd2lOCllOK3luR2NEZDUyelhONldDc3NJamQ2V3BGb1JzMW1kY29QdXFlRzhwSk1tRFpldTlSN0IxNENoQUl6b09wRWoKY0N4M2Q3NTdubnVnSEtZa0xQWlIxQXVIMERKYngvblB2d09WZXhQVEpVbnR1eTFmenVrMnpaSXlMRDBHa0tlVwpzRTg2a1JEdEVwcmw0Sk1yaUN2MTVCdU9RNDQrVXJzWm5GcENwa0hPbWREN1E0dzRaZXNpd3dQcFhudnhmNFNoCmNoenBxcHBTY1dyclFZbno0OHVpSkQ0OUVHUzJ0RDdBZ3dvVlJDSWhzeER0alhiOFBSRjZVSWtBUUJlSnhoT2EKcERUR0tiMzNCQThCT1BVcmwxbDJtc2ljYVBzcWNrM3ZYWUpaYkRZSCt0WkxaNnFZZ2gxZnhQUCtJaFhzMXplbgp5cndiV2tlNnk0UGwwR1JXWCtHcU5NL0NXUlh3YVUwbVZTRG9wZlJvb0VKdzg2bVJtVk85K2NGOFBZUkttaFhPCldXYUw2cXdZU0NmL252NjZSdTRjdmlVNVRvV2w2VnVnRzlZdm1LM2xycFhhS2g4VWdIRkd6MDhDQXdFQUFhTTgKTURvd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZHZG9pVUJucVdxYwpvL05FVnI5YUoxZVkvOVVBTUEwR0NTcUdTSWIzRFFFQkRRVUFBNElDQVFBdVJpM1hNWmRyclNwdTRQRTFTazdWCnBlU2k0dVBEVEpONlc3ckJYWUNEVVZWUjNDNjFWbUpYMVdoZndIeUZMV1grQkpFcmRjMHVHTWNERC9qMDdUYUMKSHIwMmNqaUpjSE9uSCt2ZVVHZXZXNmRaeWx2TXp1RStpZWxPTVlEN3pvcUs5NmwwWTF5U09URDdzWFBUWm9PcAo0S0dabDF5N3ZmSTJpdTJHcVdlUDhBQXB0Qm5JY0VLOW85R0ZQcmhhN25wTS9ROEloNHZCNHFMRi9EVENDRmExCjRMajliV3VndE1GQm1ld09ic3RaeHpLc1NVekFKdk1MV2tMYVNLdXpCWldlWXBWeW4vNEorSmRmeTBJcm1tOXYKaVBMN0o3SHZ2YzJOZFFpK01pcU00ZkJobk1KQ1JBMTBFem1iT1gxUlN6b0NVTnkycFhoYmdkbDFMK2hERm1yQQpvdmNNZ1huNzFJUlU3R0V4VG02UTRtR2ZEZHpuNllEQzQ2R3RBRjVZVlFoVFg1V0FjV1BIMktTNVBKeVJvYmRNCmxmWnhMdytIa1E2dnQzaVloWXFDRjNFU0kyN2hRajFQQXp5T2FqaVl5RGxjREVRRVArWGs3bEtDaXR0UWNMQ0sKZXlCcWJXM0RiZW1MZ0dVa2dWcWRMK2lzN3RVR3pGOGU0a1J4NmRLZkw2Ny9XK0c5b0FyZjExeDBMM1MwWEhybgpZUURNemtXQ1hyZnQ0TVJ6V2p5aWRDYUJ3VlRjSHdZejc0Z1ZUMUIzWlhFYmJCamZBS3RUVFVtcEV4anFuczlxCm1RMzkvV05ybE5ZN014WGJOYkVXSStOeisrS2JnenFFNkhnbUs3SGwxc21JME1PTlpiYTZEQ1NzRHgwb1ZPMjIKMlgvU1VJMk5tNStUd2VkRFVRcktFUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://server.kubernetes.local:6443
  name: kubernetes-the-hard-way
contexts: null
current-context: ""
kind: Config
preferences: {}
users: null

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://server.kubernetes.local:6443 \
  --kubeconfig=node-1.kubeconfig && ls -l node-1.kubeconfig && cat node-1.kubeconfig
Cluster "kubernetes-the-hard-way" set.
-rw------- 1 root root 2758 Jan 10 12:27 node-1.kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZURENDQXpTZ0F3SUJBZ0lVSEZjTnZpeGtuRnlBRm15M053VWZETGtmaHhzd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1EZ3dOVm9YRFRNMk1ERXhNVEV5Ck1EZ3dOVm93UVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01DbGRoYzJocGJtZDBiMjR4RURBT0JnTlYKQkFjTUIxTmxZWFIwYkdVeEN6QUpCZ05WQkFNTUFrTkJNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QQpNSUlDQ2dLQ0FnRUF2RVJWR3k3dWJFaU9KdmNnVnkyUm5VNjhMbXVGSVI4NlgxVnRSM1BOYWlEWHVaWVkrcDk4ClJ6dVI4YjQ2TXdLMXB3SXc2VnJJOWU3MmQxMmw0UXJNZHJUdXMxTWY1ZVpFMHE1N3pPWUR0Ry9VOUxHeER1djMKYms1bThjZ1p4SThMR0o0UW02bjZXUmRVMFhVbEhBcTdzNVdyam5YUnpoZmZRcG5wM2ZHTnBJM2tRM21UWUdydwpXbFk2VUQ0ejlZeDJxa1dHdGFkRndVVVdXbHhBOWlGRlpRYUt1OFZPbnhIZkZpckowSmxnaTBJaTYyYXhyd2lOCllOK3luR2NEZDUyelhONldDc3NJamQ2V3BGb1JzMW1kY29QdXFlRzhwSk1tRFpldTlSN0IxNENoQUl6b09wRWoKY0N4M2Q3NTdubnVnSEtZa0xQWlIxQXVIMERKYngvblB2d09WZXhQVEpVbnR1eTFmenVrMnpaSXlMRDBHa0tlVwpzRTg2a1JEdEVwcmw0Sk1yaUN2MTVCdU9RNDQrVXJzWm5GcENwa0hPbWREN1E0dzRaZXNpd3dQcFhudnhmNFNoCmNoenBxcHBTY1dyclFZbno0OHVpSkQ0OUVHUzJ0RDdBZ3dvVlJDSWhzeER0alhiOFBSRjZVSWtBUUJlSnhoT2EKcERUR0tiMzNCQThCT1BVcmwxbDJtc2ljYVBzcWNrM3ZYWUpaYkRZSCt0WkxaNnFZZ2gxZnhQUCtJaFhzMXplbgp5cndiV2tlNnk0UGwwR1JXWCtHcU5NL0NXUlh3YVUwbVZTRG9wZlJvb0VKdzg2bVJtVk85K2NGOFBZUkttaFhPCldXYUw2cXdZU0NmL252NjZSdTRjdmlVNVRvV2w2VnVnRzlZdm1LM2xycFhhS2g4VWdIRkd6MDhDQXdFQUFhTTgKTURvd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZHZG9pVUJucVdxYwpvL05FVnI5YUoxZVkvOVVBTUEwR0NTcUdTSWIzRFFFQkRRVUFBNElDQVFBdVJpM1hNWmRyclNwdTRQRTFTazdWCnBlU2k0dVBEVEpONlc3ckJYWUNEVVZWUjNDNjFWbUpYMVdoZndIeUZMV1grQkpFcmRjMHVHTWNERC9qMDdUYUMKSHIwMmNqaUpjSE9uSCt2ZVVHZXZXNmRaeWx2TXp1RStpZWxPTVlEN3pvcUs5NmwwWTF5U09URDdzWFBUWm9PcAo0S0dabDF5N3ZmSTJpdTJHcVdlUDhBQXB0Qm5JY0VLOW85R0ZQcmhhN25wTS9ROEloNHZCNHFMRi9EVENDRmExCjRMajliV3VndE1GQm1ld09ic3RaeHpLc1NVekFKdk1MV2tMYVNLdXpCWldlWXBWeW4vNEorSmRmeTBJcm1tOXYKaVBMN0o3SHZ2YzJOZFFpK01pcU00ZkJobk1KQ1JBMTBFem1iT1gxUlN6b0NVTnkycFhoYmdkbDFMK2hERm1yQQpvdmNNZ1huNzFJUlU3R0V4VG02UTRtR2ZEZHpuNllEQzQ2R3RBRjVZVlFoVFg1V0FjV1BIMktTNVBKeVJvYmRNCmxmWnhMdytIa1E2dnQzaVloWXFDRjNFU0kyN2hRajFQQXp5T2FqaVl5RGxjREVRRVArWGs3bEtDaXR0UWNMQ0sKZXlCcWJXM0RiZW1MZ0dVa2dWcWRMK2lzN3RVR3pGOGU0a1J4NmRLZkw2Ny9XK0c5b0FyZjExeDBMM1MwWEhybgpZUURNemtXQ1hyZnQ0TVJ6V2p5aWRDYUJ3VlRjSHdZejc0Z1ZUMUIzWlhFYmJCamZBS3RUVFVtcEV4anFuczlxCm1RMzkvV05ybE5ZN014WGJOYkVXSStOeisrS2JnenFFNkhnbUs3SGwxc21JME1PTlpiYTZEQ1NzRHgwb1ZPMjIKMlgvU1VJMk5tNStUd2VkRFVRcktFUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://server.kubernetes.local:6443
  name: kubernetes-the-hard-way
contexts: null
current-context: ""
kind: Config
preferences: {}
users: null

# config set-credentials
root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-credentials system:node:node-0 \
  --client-certificate=node-0.crt \
  --client-key=node-0.key \
  --embed-certs=true \
  --kubeconfig=node-0.kubeconfig && cat node-0.kubeconfig
User "system:node:node-0" set.
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZURENDQXpTZ0F3SUJBZ0lVSEZjTnZpeGtuRnlBRm15M053VWZETGtmaHhzd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1EZ3dOVm9YRFRNMk1ERXhNVEV5Ck1EZ3dOVm93UVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01DbGRoYzJocGJtZDBiMjR4RURBT0JnTlYKQkFjTUIxTmxZWFIwYkdVeEN6QUpCZ05WQkFNTUFrTkJNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QQpNSUlDQ2dLQ0FnRUF2RVJWR3k3dWJFaU9KdmNnVnkyUm5VNjhMbXVGSVI4NlgxVnRSM1BOYWlEWHVaWVkrcDk4ClJ6dVI4YjQ2TXdLMXB3SXc2VnJJOWU3MmQxMmw0UXJNZHJUdXMxTWY1ZVpFMHE1N3pPWUR0Ry9VOUxHeER1djMKYms1bThjZ1p4SThMR0o0UW02bjZXUmRVMFhVbEhBcTdzNVdyam5YUnpoZmZRcG5wM2ZHTnBJM2tRM21UWUdydwpXbFk2VUQ0ejlZeDJxa1dHdGFkRndVVVdXbHhBOWlGRlpRYUt1OFZPbnhIZkZpckowSmxnaTBJaTYyYXhyd2lOCllOK3luR2NEZDUyelhONldDc3NJamQ2V3BGb1JzMW1kY29QdXFlRzhwSk1tRFpldTlSN0IxNENoQUl6b09wRWoKY0N4M2Q3NTdubnVnSEtZa0xQWlIxQXVIMERKYngvblB2d09WZXhQVEpVbnR1eTFmenVrMnpaSXlMRDBHa0tlVwpzRTg2a1JEdEVwcmw0Sk1yaUN2MTVCdU9RNDQrVXJzWm5GcENwa0hPbWREN1E0dzRaZXNpd3dQcFhudnhmNFNoCmNoenBxcHBTY1dyclFZbno0OHVpSkQ0OUVHUzJ0RDdBZ3dvVlJDSWhzeER0alhiOFBSRjZVSWtBUUJlSnhoT2EKcERUR0tiMzNCQThCT1BVcmwxbDJtc2ljYVBzcWNrM3ZYWUpaYkRZSCt0WkxaNnFZZ2gxZnhQUCtJaFhzMXplbgp5cndiV2tlNnk0UGwwR1JXWCtHcU5NL0NXUlh3YVUwbVZTRG9wZlJvb0VKdzg2bVJtVk85K2NGOFBZUkttaFhPCldXYUw2cXdZU0NmL252NjZSdTRjdmlVNVRvV2w2VnVnRzlZdm1LM2xycFhhS2g4VWdIRkd6MDhDQXdFQUFhTTgKTURvd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZHZG9pVUJucVdxYwpvL05FVnI5YUoxZVkvOVVBTUEwR0NTcUdTSWIzRFFFQkRRVUFBNElDQVFBdVJpM1hNWmRyclNwdTRQRTFTazdWCnBlU2k0dVBEVEpONlc3ckJYWUNEVVZWUjNDNjFWbUpYMVdoZndIeUZMV1grQkpFcmRjMHVHTWNERC9qMDdUYUMKSHIwMmNqaUpjSE9uSCt2ZVVHZXZXNmRaeWx2TXp1RStpZWxPTVlEN3pvcUs5NmwwWTF5U09URDdzWFBUWm9PcAo0S0dabDF5N3ZmSTJpdTJHcVdlUDhBQXB0Qm5JY0VLOW85R0ZQcmhhN25wTS9ROEloNHZCNHFMRi9EVENDRmExCjRMajliV3VndE1GQm1ld09ic3RaeHpLc1NVekFKdk1MV2tMYVNLdXpCWldlWXBWeW4vNEorSmRmeTBJcm1tOXYKaVBMN0o3SHZ2YzJOZFFpK01pcU00ZkJobk1KQ1JBMTBFem1iT1gxUlN6b0NVTnkycFhoYmdkbDFMK2hERm1yQQpvdmNNZ1huNzFJUlU3R0V4VG02UTRtR2ZEZHpuNllEQzQ2R3RBRjVZVlFoVFg1V0FjV1BIMktTNVBKeVJvYmRNCmxmWnhMdytIa1E2dnQzaVloWXFDRjNFU0kyN2hRajFQQXp5T2FqaVl5RGxjREVRRVArWGs3bEtDaXR0UWNMQ0sKZXlCcWJXM0RiZW1MZ0dVa2dWcWRMK2lzN3RVR3pGOGU0a1J4NmRLZkw2Ny9XK0c5b0FyZjExeDBMM1MwWEhybgpZUURNemtXQ1hyZnQ0TVJ6V2p5aWRDYUJ3VlRjSHdZejc0Z1ZUMUIzWlhFYmJCamZBS3RUVFVtcEV4anFuczlxCm1RMzkvV05ybE5ZN014WGJOYkVXSStOeisrS2JnenFFNkhnbUs3SGwxc21JME1PTlpiYTZEQ1NzRHgwb1ZPMjIKMlgvU1VJMk5tNStUd2VkRFVRcktFUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://server.kubernetes.local:6443
  name: kubernetes-the-hard-way
contexts: null
current-context: ""
kind: Config
preferences: {}
users:
- name: system:node:node-0
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUdCRENDQSt5Z0F3SUJBZ0lVWmFnNXc5OXFDR3JDWnIwY1hPNUl4RnRlVFk0d0RRWUpLb1pJaHZjTkFRRUwKQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1UTXhNbG9YRFRNMk1ERXhNVEV5Ck1UTXhNbG93YURFYk1Ca0dBMVVFQXd3U2MzbHpkR1Z0T201dlpHVTZibTlrWlMwd01SVXdFd1lEVlFRS0RBeHoKZVhOMFpXMDZibTlrWlhNeEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlEQXBYWVhOb2FXNW5kRzl1TVJBdwpEZ1lEVlFRSERBZFRaV0YwZEd4bE1JSUNJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBZzhBTUlJQ0NnS0NBZ0VBCmpFRG9kaXNXeFcySSsyTy9DS2NHaDNpNHBGU0lmUU9qT2dISUI4TVV1M2JDSjdzdURYWXBTOTc2WHRTWnlvUHcKQXVFZlVUUjdib2ZFOEdCRzh5cjZsdm1uOXZhR05VOWo2WmxUT0kxalM0UFdCRWxyYnhtWExnbWZQRm1pMG5ScQpPd2l1NGtac1ZvQU1tSi85TkxJZ0tXN1ZtR1hOckR3dHREWXdWTFpJdy9rc2Y1eGRQUm1pd0pNQTgzZGg2d3NkCkpmNVIrWm1FWVhOZ2MrVlRhZXQ5Zng0M3Y5TnVNZnJjRjEzNFVqTk5DazR2QzQyeUR6M0Exb085emZuczFpYzUKZ1ZHU2VndkJPc0V4MTVYWmYwN29oSEkxOCtrbElZbGhXSkJtVmNCOTdieTcxdVc0djZiWWZjWk9Hb2hQK2NNeQpyZWV1d0ZWbjNYTEVtK05aQkhFYlQvbktJQS9wWnd5R2crVkV2ZUxJM092cjYxVWhMU3AzM1VKUElpa1FHdGxnClBBT21taXZmVXN4R1lpRWVDdGVnbkFodEtmV2RQT2Q5VkRGTjJLOEtTbmdqRDZFazZRaXVtenlGbUJ1OU9CTkMKbEpqQnJvV242amxmblZKZ3YxdXpVcnVXRUU5NENZL0MzS2ZPSXRqSk9EWmF4UFRXbTdnR2ZvOXcvdzJ4dGROZwpxbitjRDRlcUZwSjRrdXQzbm4weFhheTB1d093OGVCTkdIZyt4QzNhRm9MdnhkclZ1aGI4TDN0YjJzMnAwNi9kCkFPTUtEMERraE1pM3dVM3M2QjgzU0VJTXhMM0hTUHp0cVNpVWloL3A3ZVd0cEdEUzV1SHMxcW02L2pIR2ZGOFQKc1VWRDBpck83Z3dMUVc2Y3IrWnJsZHVBNXJEdVBFcUpRRW1IbmdENTV3MENBd0VBQWFPQnpEQ0J5VEFKQmdOVgpIUk1FQWpBQU1CMEdBMVVkSlFRV01CUUdDQ3NHQVFVRkJ3TUNCZ2dyQmdFRkJRY0RBVEFPQmdOVkhROEJBZjhFCkJBTUNCYUF3RVFZSllJWklBWWI0UWdFQkJBUURBZ2VBTUNFR0NXQ0dTQUdHK0VJQkRRUVVGaEpPYjJSbExUQWcKUTJWeWRHbG1hV05oZEdVd0Z3WURWUjBSQkJBd0RvSUdibTlrWlMwd2h3Ui9BQUFCTUIwR0ExVWREZ1FXQkJUcwpoWGFOaXpFSVJYL2h2NHhXREJORFhaZHlXVEFmQmdOVkhTTUVHREFXZ0JSbmFJbEFaNmxxbktQelJGYS9XaWRYCm1QL1ZBREFOQmdrcWhraUc5dzBCQVFzRkFBT0NBZ0VBb3FDWGxyVDFYcS9pTEljRklUd1ZaUW1hMkhEL3phZ3kKMzV5SEllRHQ0MllLZkpvT0RqaVR1b3R2dGlGYld4WDFUcVN1U0hTdkorNGZIRzU5UFFodjBiNFFJenVVSzlMMgo2WExyb29TUktQYnR0WnZiODlUUGxWWkExTjdqL0ErTTBSeUZrQk4wL0hVNjUya1RaR1A3dHFoenB2Mnd1S2hpCnVackc2UFJHVE5sZVdFNzBCSTVvc2habm9mbDFtOHBDblJ4amhqaGdmMEpkdElCamFuSFlOVGcwU29YR0RETnIKWDVCZERFYnNJODJuTkEzM1QyWHcyb0RuZzZvSDk0aGlZTUNuc2tpZG9jdU8wV1E4K3hwSXhmazArbGh5eklnQQowZ2dqKzJWeitxVk83b0QxMDJoeEhVQVpiZHA4TklDN3NLdERsam12YUM1R3NpYmxqTVk1b0NTMHRJSzRwbWRRCnBaL1lGcmpYNTFtL1dIaTVQT0pDZFpRaUhsdkxveDExRU1HcDJ3UHF0T1BVdGVLOHNrV1hqYzhCNE82cHNoblAKVWE2K2NSN3VheUREWWlWY3F5elVneDg5NW1VYkRwZ2hqUXZVaDYvNFFVVTlWcE1hTlppM1EvbzNWUFRicVFVZApLZXIydlQwcGcrU0JiY0w2aHlOWFVzZUNmUndiSjdSanVqdTlsdTA0dnVWQXBCd0JUWnZyZWhkamtLL0dsQVI0Ci9sNEhMN2crNzFOZzdwelh1Nko0NTNIempsZlFvL1NBcC9FUUNpNVBjc1Rtb282SXJ5TzAyN2M3NCtpVlJHaDEKNFMwVEp0UVRkYVNPUjNkOVJnWDRYZlpWUng0M3VraWwwZG13RUplY0lNY2kwTHZUbjg2Q3ZyeDRxWlpZVmY1MAplMlRPdEdWZmkwQT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    client-key-data: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRZ0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1N3d2dna29BZ0VBQW9JQ0FRQ01RT2gyS3hiRmJZajcKWTc4SXB3YUhlTGlrVkloOUE2TTZBY2dId3hTN2RzSW51eTROZGlsTDN2cGUxSm5LZy9BQzRSOVJOSHR1aDhUdwpZRWJ6S3ZxVythZjI5b1kxVDJQcG1WTTRqV05MZzlZRVNXdHZHWmN1Q1o4OFdhTFNkR283Q0s3aVJteFdnQXlZCm4vMDBzaUFwYnRXWVpjMnNQQzIwTmpCVXRrakQrU3gvbkYwOUdhTEFrd0R6ZDJIckN4MGwvbEg1bVlSaGMyQnoKNVZOcDYzMS9IamUvMDI0eCt0d1hYZmhTTTAwS1RpOExqYklQUGNEV2c3M04rZXpXSnptQlVaSjZDOEU2d1RIWApsZGwvVHVpRWNqWHo2U1VoaVdGWWtHWlZ3SDN0dkx2VzViaS9wdGg5eGs0YWlFLzV3ekt0NTY3QVZXZmRjc1NiCjQxa0VjUnRQK2NvZ0QrbG5ESWFENVVTOTRzamM2K3ZyVlNFdEtuZmRRazhpS1JBYTJXQThBNmFhSzk5U3pFWmkKSVI0SzE2Q2NDRzBwOVowODUzMVVNVTNZcndwS2VDTVBvU1RwQ0s2YlBJV1lHNzA0RTBLVW1NR3VoYWZxT1YrZApVbUMvVzdOU3U1WVFUM2dKajhMY3A4NGkyTWs0TmxyRTlOYWJ1QVorajNEL0RiRzEwMkNxZjV3UGg2b1drbmlTCjYzZWVmVEZkckxTN0E3RHg0RTBZZUQ3RUxkb1dndS9GMnRXNkZ2d3ZlMXZhemFuVHI5MEE0d29QUU9TRXlMZkIKVGV6b0h6ZElRZ3pFdmNkSS9PMnBLSlNLSCtudDVhMmtZTkxtNGV6V3FicitNY1o4WHhPeFJVUFNLczd1REF0QgpicHl2NW11VjI0RG1zTzQ4U29sQVNZZWVBUG5uRFFJREFRQUJBb0lDQUNGSk8xSm1OZ3lMaXpYTWJiZHVPb0syCjBDMXlBWVdYOGlwdlowdU9UVEtUaEE4OVlYZmc2ZnFmZEJERENLL1RRY2hSS09kVEd4TTNwakg5UzRGbEd4MXYKS1dHWGp2RUNnejRhdlRFLy93ZWFSWlgxWGNtN2kxRnFCN0JoUHA4UGNYSEt4UVNmUFpHRzZOWmxMQWtRV0VrMQpESHpUZG0xUXgvRUw1a3NJaXZyMXZVMlk3TmoySjFYb1haS3FxK0xHVzdmYlpKV21EVkM2ZXZMdWcyNHhMVExZCjExYlBwVWkzMW5tMk85dTRZS21ZTmhxYUdaNzc0ek1XQjVzbG5FT1VBaFlTcDc2TzRTQmlYd09oQlFJdGxrbnUKdUNiSDE1L2V0S3Q1ODh1WXVGcE9qMDc0YkxFUmRqSmRlTVpid1ExUCtneGpYcW8zYXNQWCs5amFhMU0rUzhLRQpuWDQwWE5SR3hldVNOdm4wZXZmTTk0RHYwK0hObjNUcXNOdnY1dFcxZkllc2FhS1gzcUtIWjNXUm1sWmQ1N1RICk1XM0d3ckdJV0o4VDRPV00vR29zTGtweGU0cnI2R2N0N1NoVW14OVo3Z0pZenRuLzhJZXdrUFB5a25wUkJDL2QKbVVKSWlQUlZPTGEvTlhGM2xpWUFLcVcrYmc5a05xL0VwdXJJMm9XVzh3R3RQc1Q2MzBnZ1JzenNqT0ZMU1hoYQpDMDdQNjBFMytVRUVTU21aQnZabmpreUVxN0hGOU9NSTFITlBnRk9QWk5EaFdlditraXc4ZlpvMmtRbmNxVDI1CktOZGk1RXI2N3lHeUVKS01lL2lZNnJaeGNnazZLSE04MEhZbmVrdWRFcUg5c0oyRUYwRE9EeE5LRkZKY3VWMzUKWERWdDJVY3dIMnpLQ3RpV0R2OEpBb0lCQVFDL3I0ZmVuQkJZZW93ZGtZU0habjd5c0NiNGFNQ0xtRXdROGlIUgo5eWhpV0loTVVjK0xpWDI5V2xzUzdFNk1TRnB3ODNFVm1ldHQ2Y1Rkb1AxVnNoMDdCQUlyRk9XaTc0bkxVSW56CkpYdkxMS1kyL2pZNnFiK2NRc3ZjRzhpdlZoSmNhSGNMRlV1bHpuVVdyUktNVkRRRHA2Y005ZGJYTHNwWjBTV3gKWDdIKzY5SXlUa01nOVZ5a3lwQjZMeis1alVRYjdSTjh4VlgzVEgwb2czc0NkLzh0U0ROUlZmWDFYemhuT2o1UQpoMEFIRExya0diKzdUd0QxMmxDZ0U4SnJ5UEVuYjc4cjJoS1ByanZBdGpxbXRLaGd1TlNicDRlVkFzcVhhK2FhCkFUdmVPaEVnUkxDd3ZKUjdxK1IzQlJpMnlMbkw3R1ZYVTZiNGxOcWNFeEh4ellaVkFvSUJBUUM3VDdjRzRlaDgKMlJ1ZEEwUUlDR0tLd21obFdSSWJxbXFHSXAxbWl6MjMvR1ZvdFovSGVhdGQ2dHIwM1ljREtwN1hsWTRQMnhabgpHQzhlbkpXSUdOR3dGSVZYSHFqSFlWY3kwRXdISmhEYkJyS291MUpidHZtTlE2Y3k1MW0xSCtHM0ZvWnBuY1V5CnY0cnZRRkVIQ3hKNG1VMWhjWlUyWlQxZ3RRRU5JWDJRenVIUncxeWI1YlpxNXNMY0NoSXp3b1dyR29EZmttTG4Ka3pNTCs3RW5scDhRV2JNRkFScytFb1FQS0NPY05peWxsZVNNR21EZXFXdlUrWE02TzBrWjNjbFJyeTN3cy8rNQp1QU15UTl4bUtSZzUwL1VnSW9UQkFtWnBNV216S01IK004cVVNVFZLUjBSMllhdC92VmNpaWdwTGNtZlVUWHYrCjBuOUJaanZkTmVYWkFvSUJBQjJ2NjlVWVNwZkpjd1hwVWFNK3hvNkRwYVYzWThxNjdaejZReTZubnNPTWZwK0QKVkNlQ1JjMGJ2MXN3NmdGaiswM2ZCamFZUGhRcHptbWMwMStBVkhLZGJsQ0p6ZjdzSm1Vc3RoRElUMkhxS2x2KwpCeHdTeWpCRFVCdG8yaTM5b0o1Yk40U3A2YXRtVEZBVXdmaWwyZUJ2Q0xwRElPRDJ5RFFjNWorUVdKcm9ud2RYCmc2SUpIaTRQaVV6RElKVjJRWVFwdFlqdmJ4Nzc0NjV3bm82RlV5b0tNcGg0UGIyZzM3VnRHZFdTL09HYW9SOU8KdFprbTVUa3VkS28ySlRoWVNMRVk1M3k5SzM3Qk4xUGpaVFlJYU1PQ0hMdDJ1TkxsT2NjMTJPTWxLY2FESzcvWgpvNXZidVF0bVZkM3hGaURJK2EyUmtTaHpOanJ0b3VYbE5qUkM1bmtDZ2dFQVZ5dFN6dVlsRHF6dTE5UWtQZVRCCkR6aEg0eHBmZmZhQjJtaVRmWnhCSGJWYzhDek43Y1BtaHk5N3RFYS94UzU1ZTNTREIwZjdGZ0ZBTkd2RWZ2Q2wKN042djZ3byttNExtVktSeExVWit3NTlMVjVETlZCZEQ3WVRWYzdBTXBHanczd2FoaU5jK1pVNlVkcUVrMURWSAo1RTNib0FSKzN6Q2dMcmd0aEJIWTRLSVduMHJlZDBLZzhRRHhIL3VqMnVpazBpcmtYS2RBVmVxLzc4eXk5ZXgzCm0rRlNtWHFaVmZyQjhGZktzckRYZUR2WWY0YnJHOVFXZGFlZEF6V0I0SUxCWkwwMGtQY0RoRWRwWFdRTlZwRzcKVDNZZmRsUDZHZVJuQ245UFpHd01VNk9BbkJTR2EwbmRSNFpPaklUdDN3b0VublhnY2dHWk9jNTJJRlpXZDZ6VQppUUtDQVFFQW14WWJGdE5YZ2UxeXlORGJqM0hZTEFzN1YreDhVWXdkOVpYcm51RXBHNEtjYlB1Y1FCUnRXL2VWCjNzNmIrRmFvd05vU0N0WkV6Uk8rVm80OXhjNnMzMkt4YkI5RDlPTHVQUy9qWXV6Vm5TWHZ4NVphQUs1M1gva1MKbEV6Y0g2UmJIS05TVGJXd1Rkc3U1dGI1WFhkUTZ0QkFyM2cvaG5WOWJ0cVBxcHAwRjE4dW5OeDBjTWc5bHF2cAplV1RMY3VXUXVTWm1xSm0zb3dMUEJKR3FhM2tYT3VRWVBOY0pqelFNeDdERTNtSGt2WFBQS2xCSkZFRlRtdUlNCmE0azdENmQvaTZkS291ZmcyRVBvNG5FVmx5ZmxFdWxNQU5qR09OTUtDeFF6RnZkcWp0OWUzREt0OXpWWGtVb3cKQVNTdUlScktkY1FrQ284bHNIcjkrdEZiSno0RHR3PT0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-credentials system:node:node-1 \
  --client-certificate=node-1.crt \
  --client-key=node-1.key \
  --embed-certs=true \
  --kubeconfig=node-1.kubeconfig && cat node-1.kubeconfig
User "system:node:node-1" set.
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZURENDQXpTZ0F3SUJBZ0lVSEZjTnZpeGtuRnlBRm15M053VWZETGtmaHhzd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1EZ3dOVm9YRFRNMk1ERXhNVEV5Ck1EZ3dOVm93UVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01DbGRoYzJocGJtZDBiMjR4RURBT0JnTlYKQkFjTUIxTmxZWFIwYkdVeEN6QUpCZ05WQkFNTUFrTkJNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QQpNSUlDQ2dLQ0FnRUF2RVJWR3k3dWJFaU9KdmNnVnkyUm5VNjhMbXVGSVI4NlgxVnRSM1BOYWlEWHVaWVkrcDk4ClJ6dVI4YjQ2TXdLMXB3SXc2VnJJOWU3MmQxMmw0UXJNZHJUdXMxTWY1ZVpFMHE1N3pPWUR0Ry9VOUxHeER1djMKYms1bThjZ1p4SThMR0o0UW02bjZXUmRVMFhVbEhBcTdzNVdyam5YUnpoZmZRcG5wM2ZHTnBJM2tRM21UWUdydwpXbFk2VUQ0ejlZeDJxa1dHdGFkRndVVVdXbHhBOWlGRlpRYUt1OFZPbnhIZkZpckowSmxnaTBJaTYyYXhyd2lOCllOK3luR2NEZDUyelhONldDc3NJamQ2V3BGb1JzMW1kY29QdXFlRzhwSk1tRFpldTlSN0IxNENoQUl6b09wRWoKY0N4M2Q3NTdubnVnSEtZa0xQWlIxQXVIMERKYngvblB2d09WZXhQVEpVbnR1eTFmenVrMnpaSXlMRDBHa0tlVwpzRTg2a1JEdEVwcmw0Sk1yaUN2MTVCdU9RNDQrVXJzWm5GcENwa0hPbWREN1E0dzRaZXNpd3dQcFhudnhmNFNoCmNoenBxcHBTY1dyclFZbno0OHVpSkQ0OUVHUzJ0RDdBZ3dvVlJDSWhzeER0alhiOFBSRjZVSWtBUUJlSnhoT2EKcERUR0tiMzNCQThCT1BVcmwxbDJtc2ljYVBzcWNrM3ZYWUpaYkRZSCt0WkxaNnFZZ2gxZnhQUCtJaFhzMXplbgp5cndiV2tlNnk0UGwwR1JXWCtHcU5NL0NXUlh3YVUwbVZTRG9wZlJvb0VKdzg2bVJtVk85K2NGOFBZUkttaFhPCldXYUw2cXdZU0NmL252NjZSdTRjdmlVNVRvV2w2VnVnRzlZdm1LM2xycFhhS2g4VWdIRkd6MDhDQXdFQUFhTTgKTURvd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZHZG9pVUJucVdxYwpvL05FVnI5YUoxZVkvOVVBTUEwR0NTcUdTSWIzRFFFQkRRVUFBNElDQVFBdVJpM1hNWmRyclNwdTRQRTFTazdWCnBlU2k0dVBEVEpONlc3ckJYWUNEVVZWUjNDNjFWbUpYMVdoZndIeUZMV1grQkpFcmRjMHVHTWNERC9qMDdUYUMKSHIwMmNqaUpjSE9uSCt2ZVVHZXZXNmRaeWx2TXp1RStpZWxPTVlEN3pvcUs5NmwwWTF5U09URDdzWFBUWm9PcAo0S0dabDF5N3ZmSTJpdTJHcVdlUDhBQXB0Qm5JY0VLOW85R0ZQcmhhN25wTS9ROEloNHZCNHFMRi9EVENDRmExCjRMajliV3VndE1GQm1ld09ic3RaeHpLc1NVekFKdk1MV2tMYVNLdXpCWldlWXBWeW4vNEorSmRmeTBJcm1tOXYKaVBMN0o3SHZ2YzJOZFFpK01pcU00ZkJobk1KQ1JBMTBFem1iT1gxUlN6b0NVTnkycFhoYmdkbDFMK2hERm1yQQpvdmNNZ1huNzFJUlU3R0V4VG02UTRtR2ZEZHpuNllEQzQ2R3RBRjVZVlFoVFg1V0FjV1BIMktTNVBKeVJvYmRNCmxmWnhMdytIa1E2dnQzaVloWXFDRjNFU0kyN2hRajFQQXp5T2FqaVl5RGxjREVRRVArWGs3bEtDaXR0UWNMQ0sKZXlCcWJXM0RiZW1MZ0dVa2dWcWRMK2lzN3RVR3pGOGU0a1J4NmRLZkw2Ny9XK0c5b0FyZjExeDBMM1MwWEhybgpZUURNemtXQ1hyZnQ0TVJ6V2p5aWRDYUJ3VlRjSHdZejc0Z1ZUMUIzWlhFYmJCamZBS3RUVFVtcEV4anFuczlxCm1RMzkvV05ybE5ZN014WGJOYkVXSStOeisrS2JnenFFNkhnbUs3SGwxc21JME1PTlpiYTZEQ1NzRHgwb1ZPMjIKMlgvU1VJMk5tNStUd2VkRFVRcktFUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://server.kubernetes.local:6443
  name: kubernetes-the-hard-way
contexts: null
current-context: ""
kind: Config
preferences: {}
users:
- name: system:node:node-1
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUdCRENDQSt5Z0F3SUJBZ0lVWmFnNXc5OXFDR3JDWnIwY1hPNUl4RnRlVFk4d0RRWUpLb1pJaHZjTkFRRUwKQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1UTXhNbG9YRFRNMk1ERXhNVEV5Ck1UTXhNbG93YURFYk1Ca0dBMVVFQXd3U2MzbHpkR1Z0T201dlpHVTZibTlrWlMweE1SVXdFd1lEVlFRS0RBeHoKZVhOMFpXMDZibTlrWlhNeEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlEQXBYWVhOb2FXNW5kRzl1TVJBdwpEZ1lEVlFRSERBZFRaV0YwZEd4bE1JSUNJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBZzhBTUlJQ0NnS0NBZ0VBCnh0elZnbm51cW1heEF2bjlrdmxlSHdZTTlUSTRUL1dLZ0RKekxsVVJMOFRQaGNpbjAwVk5qMWlzVnNwMU81d2EKQjEzMCtEM1l3VVBvRCs4ZVlOVVNldmtlU1pqclhBbmNvem1KMzFXYU4xN055OFYwS3VwdXJhRDJtQnVESUd4UApZNFd6Y3FyYU1Jc0poN1daMmZVWUEyVGY0SG9oajRFY29EYTBSK0xyWXJNZ1ArS0FMRm44ZHlKOTRGcFphN1pEClZ3WTFxeXVsaXJnTXBDT0RsQXYzcklPT2dVOWU5SGJObW9qZjNKT1ZBQlgwdVpBd1BlN2xTdEFYVlZEelZvTFMKdVp5YzhkVC92SUFIbC9CRWErVXAvam9hd0NSS0F5SnVpdmgzRGdjWkdoYTRBU3Q3MHpWa3ZmS3RSNXphVGNUZQpyaTRoSVRLV29UcFhVOFJUZzNlRmpvMS9tSnQzakQ5VTZxK3dnMVM0UnNMSGQwVmVnb2poN1ExS0JKK05saThwClR1K3JERE9oeWkvNER3SUVxTjhhVzNWajhqbnV0bVdWTFFDbzRySUlacjZsaFkzTUVvZVhoeWw3WWh1YkZJTGgKTTFrRzVONSt6WlZOdDJoWHA3alR0cVpXd1U1UHNqcldSMStBdW1KTzNIRTljcjNJSWJJQnNjT0YwQlZtdk5CUApOa29DaXZFTmg3N3NBbDMxeTl0b3EyS3NaYzJtc2NTTk1id0xCMXpEQk9WaGdrTHpocUVKby8wdE9DRk1FZjdqCjlRS3FVU01FVkJUK0gwL1lPTzlCUklocmhkU0JYVTIvTGpLd3VXVnRhckc1NXlUSGliR3dnN3h5YVBlWGw5QTgKQkFnNU91eVJDQmE3WmJPSGVjOE43QXFBdS8xYVNod3FOWm9vdE1aR21qVUNBd0VBQWFPQnpEQ0J5VEFKQmdOVgpIUk1FQWpBQU1CMEdBMVVkSlFRV01CUUdDQ3NHQVFVRkJ3TUNCZ2dyQmdFRkJRY0RBVEFPQmdOVkhROEJBZjhFCkJBTUNCYUF3RVFZSllJWklBWWI0UWdFQkJBUURBZ2VBTUNFR0NXQ0dTQUdHK0VJQkRRUVVGaEpPYjJSbExURWcKUTJWeWRHbG1hV05oZEdVd0Z3WURWUjBSQkJBd0RvSUdibTlrWlMweGh3Ui9BQUFCTUIwR0ExVWREZ1FXQkJSbApoUGIxeWdZUXVNem9xTmxwQ2owN0tvVnduVEFmQmdOVkhTTUVHREFXZ0JSbmFJbEFaNmxxbktQelJGYS9XaWRYCm1QL1ZBREFOQmdrcWhraUc5dzBCQVFzRkFBT0NBZ0VBdUJpVnk3Tk4zd3pKOUtTWDczVUVoaUk0NnV0RkllV0IKYks3eFMwMTVDWXlYWDFTdDE1WHJKYVlLc1M1UVVERnRpVjFKeTdBU2xHblBtZ1lwY24ra2xqZHgwS0RNN2xpbApCTk9ZME9kMWxaeHlBcTVCM1llWWdudnBJVENPVzBncmwyVXR0aWRJZWFJVThWTnhmNTFGZm1BZitkN2pBVzZXCjJSSHAxeXFYbklERDJxQkRuMnovR3V3UklZY2Rzb2kyb0c3QUFNOU5vWDNydmdta0IvTEpYdFFOamcwN3RpRGQKZjRaVlFVVHlmYnkzZ2ZhM0I2YklEMlZYV2hHUi9SaFlqcUdhSUtLOHEzSFdPc0IxS0V3N0IrMTE1Tkw0RlMwRAorTXoxeXNJTmJCWnFXSno2ZGdFOERzSnJpZVc5RHFCa0prTmlMLzNiWnQzNW05dmNxQXQrT1kzWkF6YTJmcGZ5CkQyV2pGeDdFUjN3c1RNSGZRYmtUWmZCVnRKak1QOGlEV3RxQ0lCQXJia2Z0TXZ6NXdSZmJkaHVSYWh6Wkd3Z3EKYXdMbHNyb1hnQUNnY0pwN1h4T1IzUStZTXJkWm01K3d5czBjUXpnQ3VRaFdvSG01WjZtVFVON000UFZHSDdrMwpTengrbjhvT21vaTFBVXFIaUJrZmNpVlQxM2FwT0hXRXFXQTNpUlhnZU5mMk9SMDc4UUFNQURIWjhaZ1pxM2QxClNMSk0yaDEvMVE0b0VrblBtdHowbVEzNWt4MmZpUng4U3Y2WnYzRCtiUnNORVpQMWFRbDNrYnZ5TGdCb1hJYzUKNEdmcFMzZWJpMVAvYXUvTWRGR3ZWLzlqaThJZm5OSmJTYkxaNW1jbkZ6cU5YaGlmbHNta3NPSlpLUU9ETExNdQo2OVNuamo1QzVaQT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    client-key-data: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRZ0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1N3d2dna29BZ0VBQW9JQ0FRREczTldDZWU2cVpyRUMKK2YyUytWNGZCZ3oxTWpoUDlZcUFNbk11VlJFdnhNK0Z5S2ZUUlUyUFdLeFd5blU3bkJvSFhmVDRQZGpCUStnUAo3eDVnMVJKNitSNUptT3RjQ2R5ak9ZbmZWWm8zWHMzTHhYUXE2bTZ0b1BhWUc0TWdiRTlqaGJOeXF0b3dpd21ICnRablo5UmdEWk4vZ2VpR1BnUnlnTnJSSDR1dGlzeUEvNG9Bc1dmeDNJbjNnV2xscnRrTlhCaldySzZXS3VBeWsKSTRPVUMvZXNnNDZCVDE3MGRzMmFpTi9jazVVQUZmUzVrREE5N3VWSzBCZFZVUE5XZ3RLNW5KengxUCs4Z0FlWAo4RVJyNVNuK09ockFKRW9ESW02SytIY09CeGthRnJnQkszdlROV1M5OHExSG5OcE54TjZ1TGlFaE1wYWhPbGRUCnhGT0RkNFdPalgrWW0zZU1QMVRxcjdDRFZMaEd3c2QzUlY2Q2lPSHREVW9FbjQyV0x5bE83NnNNTTZIS0wvZ1AKQWdTbzN4cGJkV1B5T2U2MlpaVXRBS2ppc2dobXZxV0ZqY3dTaDVlSEtYdGlHNXNVZ3VFeldRYmszbjdObFUyMwphRmVudU5PMnBsYkJUayt5T3RaSFg0QzZZazdjY1QxeXZjZ2hzZ0d4dzRYUUZXYTgwRTgyU2dLSzhRMkh2dXdDClhmWEwyMmlyWXF4bHphYXh4STB4dkFzSFhNTUU1V0dDUXZPR29RbWovUzA0SVV3Ui91UDFBcXBSSXdSVUZQNGYKVDlnNDcwRkVpR3VGMUlGZFRiOHVNckM1WlcxcXNibm5KTWVKc2JDRHZISm85NWVYMER3RUNEazY3SkVJRnJ0bApzNGQ1enczc0NvQzcvVnBLSENvMW1paTB4a2FhTlFJREFRQUJBb0lDQUFXTkViL2tDOWxIMm8valR2ZkJoZGxHCnBpbU1icnBoZDYyc0I2WGRQenZGSUhVTWt3M3J0TG1MY1I5UEY5L2RHa0RteXJrdk8vcFJIU1k1aEZiNENIY0gKZ3pHR1Z3MHBRN1p1dFBHSzB5NDRHZHU4Z3EvVmw5ZFM3U0oxY0l2TndKY3F6aEtMODVSenRyaVczdkxEL3VYTwpLQTJ3Ujk4bGJIKzlNL3VBSCtNcG9VblVDY1JNeGZNcS80TlRpTGZnQUdUUTQ4STdQZDhpMDdLMVFLMmVSeG81CkdSZmJYbFhKMC8xdlZFaG9MVzJYeU9nS3Z2RXlDY2FCY2J1eWkySDRvaHB0ZnZHbE5kMkJYODU5WEVoaXZ3cTkKZk9GR0x0bnFXU016anljM3NMU3d1ZzlqR1kwcVhXTy9NajZ0VG1oUUl5TW9YdU10V0loRTBUNEg5cndJSStHZQp3bVNpNlZpV25TaFYxMk9tN0o0T2xqTDhLN0t5L2JZbjEzcUZkLzFLaThyLzdtc3daQ3pQb3NQOGQvUnJyMDdhClVVcHNzeS9tVFZsTU54QUZOS0ptTFBVd01pU3NZZFVKRlpCVWZUZklNcnowK2VXbFBvN05SUVlXWUM0UXUyblEKYlhlM0JUcmJ4d3BMUklreTZ5ODkvaVQvYTZBRXQ3SjZ4d2NuYmdqZVRjVGlmWW1nVitsSVhuN2dqUTBYek91MgpDd2pMdVliYm41UWI5VElCZDhNTU9NRnlIcEVRd2xtRUwxU05nVGVGd3BCK0JIZjBwR2dTLzJ5ZlpQbHgrUTVnCnI5SFNCYU1IblpHbWFKS2VKdDVuUVRUT1k4a3ltSEFoQXFFMHBhN244N2JqaWNILzUxZ1FJUUxuSUNHNytOWHUKRnI2NFhuMlIvS2pUdDZScHlEK2hBb0lCQVFENFQxYnhIUFNyaWlwTS9pRTJkZ2x0UFREUGtadFJ1VzVZUUtRdQpTMm1nbGVETzJHc0ZJeDJRa2hNL3hJaFFPS2x5SG5mTlIrK3pVYjhxbVlORmh1Mm1Fa1l5c001Q0dJb2hIdlhNCng0NVJxdW5xYVZBSFhuc1dnOWVSOWVwekNJMGpOVTExVlJ6dzByemxqZWRkU0FSYSs4a0daNjZMWXpmbUF0QmMKZXpnWlNkYnFQdEZhZHhQUmx4Qk5FNDYyd1FmVzRkdE9Ub1hzTzdmR0d3SDdxOTFrZzFwQ0xVK2Rkb296dHU0RQpsY3I4YmtOVlk4bXRWRUN1ZGEwV0xVV1RHd1hXK3VzRzNsQnZTbStDeEN6ZGtYb2gwSXRHNnIwQXYwUGduQm0xCnNleWNPa2xkeUVpa0ZiZExqa3UxVXA3b1cybGpIamVHRnhSeTFIT0NPUE5IVTd0TkFvSUJBUUROQlhicEljT04KRGZ2eFZLc3RYTGZjcnR2T0FUck5GYkhuQzVDZHI5Vi9Wc29NbGRvd3ZTUkVWTFpSUmlISXRxR3hUZkJBbVFqUgpZT1pUbmVFVVhiUmZLa3pUQTRZVWdPT2FtRWswVkY0ckNiekFlSTBZbG8vc2NIWDlUWCt2VXFEWUxEVXI4T04wCjU1SlRZTGlldFJrK25iYnVaWW0rb1VaeEw0emgzZlYwMm8yMmQxVExhSlAyR0VwakxTN0hTWWVsMDdja2w2WWcKNllwN2JDWmVFb1V0NG9wenNEODVnUW5RdTNSenVwVm53dnphYzlnbzNpNitWK25QL1BLcTYyVDgzYlpXUTFPTwp2NUxqNUs1TFFTWHFyRTliVzlYMUpIb1F5NEVYa1dDajExbkVMdGxkcGVPVHNlV2NETk1wZ2Rxb0V2Sy9kK1BtClVMREZ5TGttK2RhSkFvSUJBUURCNWZLV1JXNHBwYkp5Zk4raWozbTgrOU5wd3VIdVowWnJVODdnOTdKNzI0MjQKOS9aYUJKbkprc2ZGTzhyV0dlajNYQ05oQVpPRUM0bWowa3hYdG8xTTZXZzNuU2p6SkFaNDVwdzZWSG9sKzdpOQplNDhxc2ZTY0dFZjFpbnFSYVZRTThrcVNIT3lFZ1l0UUZnZGRLQ2QraEs3dGVYa3JEMGRQTFZOWFpFRGlQbTY4CmJHRStxMDJtbExmOStBK3hWZnF4S1p6L0FRSkMvajc3UzR1NDR2UDIwVHRpQWMveHZlY2Rpdk5DVVZZNDJFRnMKSklnUCtZS291T3Q0TGRIdWxXTnlCRzRTNXZjWWNKK3pGVTJUbDA0dnFaR1l4eVRmdUh0Z29ZVFNCU1ltdUwwaApwb3hTMVVKVWxjRTR6bE9ZVGdsMWhOc0dzbThkWEJqMnoxSHBtTkRoQW9JQkFDZnhTSmxpMnBaQWd6VWhLYmhNCnVBVm1pNncyMFIzamZDVm5PMlY5UERyeXphcG1CM3czWFRseXg1Sk45NGNERGIxZFVkRkQvMVBMYlJRZFRoeUoKcFBwbFkxSTQvWVpCRmhhb1ZKcTlWUnROYWxpVkkrZ0diVVBESlRtVVA2d0lqUTJRajB0Z1F2QWpyWDVRK2FieAo0Vmt4b05JUk5pVE5oc3ZHVjh3cFVnalNDNG5nOWNRck82aFdVeWUvUmIzTnRYKzVINVVoZGx3ekk2ZW9DbEdKCmlpakdXZkx3QTJGUW9uam9ER2Yva2R3RlFQM09VKzZpV3JqNnA3Szl0UWxYa3ZVd3ZMVlJxSlhHL1BjcE5rdXoKQlpBU3dlTXFvU1NCVnNhdTN4ZVlXeHVRZVF5ZmsvbUt1Q3V1SE8ycUVmbWtNdFZMMjc4eHZGVENvNjNrelMycQp2d0VDZ2dFQWE3dXJGK3hKa2J0NkxseXR1VTNaQ2JZT0xZYjlKMEhUMFlvcTB3bmROVkd2N21lUnpiTkd5d2xsCnpnOVFhak0yQ0RSRFVvdEYreG1vbVVNemd3dDBxYjd4THphV3UyYzZuTEdlMmxKODQ0VldyOE9UTy93V0xNTEwKR2JpOFFUN0lyMnNuNjh2N1pkT20rU2JnbjBNOGYya2pyMlJZd1lOQlFkV2tOVzdjOXVid2xZdjBENzZkNTlpRwo2N1lIcGUyMkNkdHNjUE90Qy9XcU8vUXdQN0FncG8ydnROOHBoaVBDTG9mSG9VR1Fwd0xoVGxvRXJBcHI3QXphCmpHZkRHTExML09FdWgzTHd5TXkxbDhCS01LaU43K29kc2Roc1dJTGpqTGVmWWV2L2xyQklmTkYydTR6eDZvUHgKRjdnMGdacXdMOGtNb0htQkhxU1lvbm9QNGxWdUxnPT0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=

# set-context : default 추가
root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:node:node-0 \
  --kubeconfig=node-0.kubeconfig && cat node-0.kubeconfig
Context "default" created.
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZURENDQXpTZ0F3SUJBZ0lVSEZjTnZpeGtuRnlBRm15M053VWZETGtmaHhzd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1EZ3dOVm9YRFRNMk1ERXhNVEV5Ck1EZ3dOVm93UVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01DbGRoYzJocGJtZDBiMjR4RURBT0JnTlYKQkFjTUIxTmxZWFIwYkdVeEN6QUpCZ05WQkFNTUFrTkJNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QQpNSUlDQ2dLQ0FnRUF2RVJWR3k3dWJFaU9KdmNnVnkyUm5VNjhMbXVGSVI4NlgxVnRSM1BOYWlEWHVaWVkrcDk4ClJ6dVI4YjQ2TXdLMXB3SXc2VnJJOWU3MmQxMmw0UXJNZHJUdXMxTWY1ZVpFMHE1N3pPWUR0Ry9VOUxHeER1djMKYms1bThjZ1p4SThMR0o0UW02bjZXUmRVMFhVbEhBcTdzNVdyam5YUnpoZmZRcG5wM2ZHTnBJM2tRM21UWUdydwpXbFk2VUQ0ejlZeDJxa1dHdGFkRndVVVdXbHhBOWlGRlpRYUt1OFZPbnhIZkZpckowSmxnaTBJaTYyYXhyd2lOCllOK3luR2NEZDUyelhONldDc3NJamQ2V3BGb1JzMW1kY29QdXFlRzhwSk1tRFpldTlSN0IxNENoQUl6b09wRWoKY0N4M2Q3NTdubnVnSEtZa0xQWlIxQXVIMERKYngvblB2d09WZXhQVEpVbnR1eTFmenVrMnpaSXlMRDBHa0tlVwpzRTg2a1JEdEVwcmw0Sk1yaUN2MTVCdU9RNDQrVXJzWm5GcENwa0hPbWREN1E0dzRaZXNpd3dQcFhudnhmNFNoCmNoenBxcHBTY1dyclFZbno0OHVpSkQ0OUVHUzJ0RDdBZ3dvVlJDSWhzeER0alhiOFBSRjZVSWtBUUJlSnhoT2EKcERUR0tiMzNCQThCT1BVcmwxbDJtc2ljYVBzcWNrM3ZYWUpaYkRZSCt0WkxaNnFZZ2gxZnhQUCtJaFhzMXplbgp5cndiV2tlNnk0UGwwR1JXWCtHcU5NL0NXUlh3YVUwbVZTRG9wZlJvb0VKdzg2bVJtVk85K2NGOFBZUkttaFhPCldXYUw2cXdZU0NmL252NjZSdTRjdmlVNVRvV2w2VnVnRzlZdm1LM2xycFhhS2g4VWdIRkd6MDhDQXdFQUFhTTgKTURvd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZHZG9pVUJucVdxYwpvL05FVnI5YUoxZVkvOVVBTUEwR0NTcUdTSWIzRFFFQkRRVUFBNElDQVFBdVJpM1hNWmRyclNwdTRQRTFTazdWCnBlU2k0dVBEVEpONlc3ckJYWUNEVVZWUjNDNjFWbUpYMVdoZndIeUZMV1grQkpFcmRjMHVHTWNERC9qMDdUYUMKSHIwMmNqaUpjSE9uSCt2ZVVHZXZXNmRaeWx2TXp1RStpZWxPTVlEN3pvcUs5NmwwWTF5U09URDdzWFBUWm9PcAo0S0dabDF5N3ZmSTJpdTJHcVdlUDhBQXB0Qm5JY0VLOW85R0ZQcmhhN25wTS9ROEloNHZCNHFMRi9EVENDRmExCjRMajliV3VndE1GQm1ld09ic3RaeHpLc1NVekFKdk1MV2tMYVNLdXpCWldlWXBWeW4vNEorSmRmeTBJcm1tOXYKaVBMN0o3SHZ2YzJOZFFpK01pcU00ZkJobk1KQ1JBMTBFem1iT1gxUlN6b0NVTnkycFhoYmdkbDFMK2hERm1yQQpvdmNNZ1huNzFJUlU3R0V4VG02UTRtR2ZEZHpuNllEQzQ2R3RBRjVZVlFoVFg1V0FjV1BIMktTNVBKeVJvYmRNCmxmWnhMdytIa1E2dnQzaVloWXFDRjNFU0kyN2hRajFQQXp5T2FqaVl5RGxjREVRRVArWGs3bEtDaXR0UWNMQ0sKZXlCcWJXM0RiZW1MZ0dVa2dWcWRMK2lzN3RVR3pGOGU0a1J4NmRLZkw2Ny9XK0c5b0FyZjExeDBMM1MwWEhybgpZUURNemtXQ1hyZnQ0TVJ6V2p5aWRDYUJ3VlRjSHdZejc0Z1ZUMUIzWlhFYmJCamZBS3RUVFVtcEV4anFuczlxCm1RMzkvV05ybE5ZN014WGJOYkVXSStOeisrS2JnenFFNkhnbUs3SGwxc21JME1PTlpiYTZEQ1NzRHgwb1ZPMjIKMlgvU1VJMk5tNStUd2VkRFVRcktFUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://server.kubernetes.local:6443
  name: kubernetes-the-hard-way
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: system:node:node-0
  name: default
current-context: ""
kind: Config
preferences: {}
users:
- name: system:node:node-0
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUdCRENDQSt5Z0F3SUJBZ0lVWmFnNXc5OXFDR3JDWnIwY1hPNUl4RnRlVFk0d0RRWUpLb1pJaHZjTkFRRUwKQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1UTXhNbG9YRFRNMk1ERXhNVEV5Ck1UTXhNbG93YURFYk1Ca0dBMVVFQXd3U2MzbHpkR1Z0T201dlpHVTZibTlrWlMwd01SVXdFd1lEVlFRS0RBeHoKZVhOMFpXMDZibTlrWlhNeEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlEQXBYWVhOb2FXNW5kRzl1TVJBdwpEZ1lEVlFRSERBZFRaV0YwZEd4bE1JSUNJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBZzhBTUlJQ0NnS0NBZ0VBCmpFRG9kaXNXeFcySSsyTy9DS2NHaDNpNHBGU0lmUU9qT2dISUI4TVV1M2JDSjdzdURYWXBTOTc2WHRTWnlvUHcKQXVFZlVUUjdib2ZFOEdCRzh5cjZsdm1uOXZhR05VOWo2WmxUT0kxalM0UFdCRWxyYnhtWExnbWZQRm1pMG5ScQpPd2l1NGtac1ZvQU1tSi85TkxJZ0tXN1ZtR1hOckR3dHREWXdWTFpJdy9rc2Y1eGRQUm1pd0pNQTgzZGg2d3NkCkpmNVIrWm1FWVhOZ2MrVlRhZXQ5Zng0M3Y5TnVNZnJjRjEzNFVqTk5DazR2QzQyeUR6M0Exb085emZuczFpYzUKZ1ZHU2VndkJPc0V4MTVYWmYwN29oSEkxOCtrbElZbGhXSkJtVmNCOTdieTcxdVc0djZiWWZjWk9Hb2hQK2NNeQpyZWV1d0ZWbjNYTEVtK05aQkhFYlQvbktJQS9wWnd5R2crVkV2ZUxJM092cjYxVWhMU3AzM1VKUElpa1FHdGxnClBBT21taXZmVXN4R1lpRWVDdGVnbkFodEtmV2RQT2Q5VkRGTjJLOEtTbmdqRDZFazZRaXVtenlGbUJ1OU9CTkMKbEpqQnJvV242amxmblZKZ3YxdXpVcnVXRUU5NENZL0MzS2ZPSXRqSk9EWmF4UFRXbTdnR2ZvOXcvdzJ4dGROZwpxbitjRDRlcUZwSjRrdXQzbm4weFhheTB1d093OGVCTkdIZyt4QzNhRm9MdnhkclZ1aGI4TDN0YjJzMnAwNi9kCkFPTUtEMERraE1pM3dVM3M2QjgzU0VJTXhMM0hTUHp0cVNpVWloL3A3ZVd0cEdEUzV1SHMxcW02L2pIR2ZGOFQKc1VWRDBpck83Z3dMUVc2Y3IrWnJsZHVBNXJEdVBFcUpRRW1IbmdENTV3MENBd0VBQWFPQnpEQ0J5VEFKQmdOVgpIUk1FQWpBQU1CMEdBMVVkSlFRV01CUUdDQ3NHQVFVRkJ3TUNCZ2dyQmdFRkJRY0RBVEFPQmdOVkhROEJBZjhFCkJBTUNCYUF3RVFZSllJWklBWWI0UWdFQkJBUURBZ2VBTUNFR0NXQ0dTQUdHK0VJQkRRUVVGaEpPYjJSbExUQWcKUTJWeWRHbG1hV05oZEdVd0Z3WURWUjBSQkJBd0RvSUdibTlrWlMwd2h3Ui9BQUFCTUIwR0ExVWREZ1FXQkJUcwpoWGFOaXpFSVJYL2h2NHhXREJORFhaZHlXVEFmQmdOVkhTTUVHREFXZ0JSbmFJbEFaNmxxbktQelJGYS9XaWRYCm1QL1ZBREFOQmdrcWhraUc5dzBCQVFzRkFBT0NBZ0VBb3FDWGxyVDFYcS9pTEljRklUd1ZaUW1hMkhEL3phZ3kKMzV5SEllRHQ0MllLZkpvT0RqaVR1b3R2dGlGYld4WDFUcVN1U0hTdkorNGZIRzU5UFFodjBiNFFJenVVSzlMMgo2WExyb29TUktQYnR0WnZiODlUUGxWWkExTjdqL0ErTTBSeUZrQk4wL0hVNjUya1RaR1A3dHFoenB2Mnd1S2hpCnVackc2UFJHVE5sZVdFNzBCSTVvc2habm9mbDFtOHBDblJ4amhqaGdmMEpkdElCamFuSFlOVGcwU29YR0RETnIKWDVCZERFYnNJODJuTkEzM1QyWHcyb0RuZzZvSDk0aGlZTUNuc2tpZG9jdU8wV1E4K3hwSXhmazArbGh5eklnQQowZ2dqKzJWeitxVk83b0QxMDJoeEhVQVpiZHA4TklDN3NLdERsam12YUM1R3NpYmxqTVk1b0NTMHRJSzRwbWRRCnBaL1lGcmpYNTFtL1dIaTVQT0pDZFpRaUhsdkxveDExRU1HcDJ3UHF0T1BVdGVLOHNrV1hqYzhCNE82cHNoblAKVWE2K2NSN3VheUREWWlWY3F5elVneDg5NW1VYkRwZ2hqUXZVaDYvNFFVVTlWcE1hTlppM1EvbzNWUFRicVFVZApLZXIydlQwcGcrU0JiY0w2aHlOWFVzZUNmUndiSjdSanVqdTlsdTA0dnVWQXBCd0JUWnZyZWhkamtLL0dsQVI0Ci9sNEhMN2crNzFOZzdwelh1Nko0NTNIempsZlFvL1NBcC9FUUNpNVBjc1Rtb282SXJ5TzAyN2M3NCtpVlJHaDEKNFMwVEp0UVRkYVNPUjNkOVJnWDRYZlpWUng0M3VraWwwZG13RUplY0lNY2kwTHZUbjg2Q3ZyeDRxWlpZVmY1MAplMlRPdEdWZmkwQT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    client-key-data: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRZ0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1N3d2dna29BZ0VBQW9JQ0FRQ01RT2gyS3hiRmJZajcKWTc4SXB3YUhlTGlrVkloOUE2TTZBY2dId3hTN2RzSW51eTROZGlsTDN2cGUxSm5LZy9BQzRSOVJOSHR1aDhUdwpZRWJ6S3ZxVythZjI5b1kxVDJQcG1WTTRqV05MZzlZRVNXdHZHWmN1Q1o4OFdhTFNkR283Q0s3aVJteFdnQXlZCm4vMDBzaUFwYnRXWVpjMnNQQzIwTmpCVXRrakQrU3gvbkYwOUdhTEFrd0R6ZDJIckN4MGwvbEg1bVlSaGMyQnoKNVZOcDYzMS9IamUvMDI0eCt0d1hYZmhTTTAwS1RpOExqYklQUGNEV2c3M04rZXpXSnptQlVaSjZDOEU2d1RIWApsZGwvVHVpRWNqWHo2U1VoaVdGWWtHWlZ3SDN0dkx2VzViaS9wdGg5eGs0YWlFLzV3ekt0NTY3QVZXZmRjc1NiCjQxa0VjUnRQK2NvZ0QrbG5ESWFENVVTOTRzamM2K3ZyVlNFdEtuZmRRazhpS1JBYTJXQThBNmFhSzk5U3pFWmkKSVI0SzE2Q2NDRzBwOVowODUzMVVNVTNZcndwS2VDTVBvU1RwQ0s2YlBJV1lHNzA0RTBLVW1NR3VoYWZxT1YrZApVbUMvVzdOU3U1WVFUM2dKajhMY3A4NGkyTWs0TmxyRTlOYWJ1QVorajNEL0RiRzEwMkNxZjV3UGg2b1drbmlTCjYzZWVmVEZkckxTN0E3RHg0RTBZZUQ3RUxkb1dndS9GMnRXNkZ2d3ZlMXZhemFuVHI5MEE0d29QUU9TRXlMZkIKVGV6b0h6ZElRZ3pFdmNkSS9PMnBLSlNLSCtudDVhMmtZTkxtNGV6V3FicitNY1o4WHhPeFJVUFNLczd1REF0QgpicHl2NW11VjI0RG1zTzQ4U29sQVNZZWVBUG5uRFFJREFRQUJBb0lDQUNGSk8xSm1OZ3lMaXpYTWJiZHVPb0syCjBDMXlBWVdYOGlwdlowdU9UVEtUaEE4OVlYZmc2ZnFmZEJERENLL1RRY2hSS09kVEd4TTNwakg5UzRGbEd4MXYKS1dHWGp2RUNnejRhdlRFLy93ZWFSWlgxWGNtN2kxRnFCN0JoUHA4UGNYSEt4UVNmUFpHRzZOWmxMQWtRV0VrMQpESHpUZG0xUXgvRUw1a3NJaXZyMXZVMlk3TmoySjFYb1haS3FxK0xHVzdmYlpKV21EVkM2ZXZMdWcyNHhMVExZCjExYlBwVWkzMW5tMk85dTRZS21ZTmhxYUdaNzc0ek1XQjVzbG5FT1VBaFlTcDc2TzRTQmlYd09oQlFJdGxrbnUKdUNiSDE1L2V0S3Q1ODh1WXVGcE9qMDc0YkxFUmRqSmRlTVpid1ExUCtneGpYcW8zYXNQWCs5amFhMU0rUzhLRQpuWDQwWE5SR3hldVNOdm4wZXZmTTk0RHYwK0hObjNUcXNOdnY1dFcxZkllc2FhS1gzcUtIWjNXUm1sWmQ1N1RICk1XM0d3ckdJV0o4VDRPV00vR29zTGtweGU0cnI2R2N0N1NoVW14OVo3Z0pZenRuLzhJZXdrUFB5a25wUkJDL2QKbVVKSWlQUlZPTGEvTlhGM2xpWUFLcVcrYmc5a05xL0VwdXJJMm9XVzh3R3RQc1Q2MzBnZ1JzenNqT0ZMU1hoYQpDMDdQNjBFMytVRUVTU21aQnZabmpreUVxN0hGOU9NSTFITlBnRk9QWk5EaFdlditraXc4ZlpvMmtRbmNxVDI1CktOZGk1RXI2N3lHeUVKS01lL2lZNnJaeGNnazZLSE04MEhZbmVrdWRFcUg5c0oyRUYwRE9EeE5LRkZKY3VWMzUKWERWdDJVY3dIMnpLQ3RpV0R2OEpBb0lCQVFDL3I0ZmVuQkJZZW93ZGtZU0habjd5c0NiNGFNQ0xtRXdROGlIUgo5eWhpV0loTVVjK0xpWDI5V2xzUzdFNk1TRnB3ODNFVm1ldHQ2Y1Rkb1AxVnNoMDdCQUlyRk9XaTc0bkxVSW56CkpYdkxMS1kyL2pZNnFiK2NRc3ZjRzhpdlZoSmNhSGNMRlV1bHpuVVdyUktNVkRRRHA2Y005ZGJYTHNwWjBTV3gKWDdIKzY5SXlUa01nOVZ5a3lwQjZMeis1alVRYjdSTjh4VlgzVEgwb2czc0NkLzh0U0ROUlZmWDFYemhuT2o1UQpoMEFIRExya0diKzdUd0QxMmxDZ0U4SnJ5UEVuYjc4cjJoS1ByanZBdGpxbXRLaGd1TlNicDRlVkFzcVhhK2FhCkFUdmVPaEVnUkxDd3ZKUjdxK1IzQlJpMnlMbkw3R1ZYVTZiNGxOcWNFeEh4ellaVkFvSUJBUUM3VDdjRzRlaDgKMlJ1ZEEwUUlDR0tLd21obFdSSWJxbXFHSXAxbWl6MjMvR1ZvdFovSGVhdGQ2dHIwM1ljREtwN1hsWTRQMnhabgpHQzhlbkpXSUdOR3dGSVZYSHFqSFlWY3kwRXdISmhEYkJyS291MUpidHZtTlE2Y3k1MW0xSCtHM0ZvWnBuY1V5CnY0cnZRRkVIQ3hKNG1VMWhjWlUyWlQxZ3RRRU5JWDJRenVIUncxeWI1YlpxNXNMY0NoSXp3b1dyR29EZmttTG4Ka3pNTCs3RW5scDhRV2JNRkFScytFb1FQS0NPY05peWxsZVNNR21EZXFXdlUrWE02TzBrWjNjbFJyeTN3cy8rNQp1QU15UTl4bUtSZzUwL1VnSW9UQkFtWnBNV216S01IK004cVVNVFZLUjBSMllhdC92VmNpaWdwTGNtZlVUWHYrCjBuOUJaanZkTmVYWkFvSUJBQjJ2NjlVWVNwZkpjd1hwVWFNK3hvNkRwYVYzWThxNjdaejZReTZubnNPTWZwK0QKVkNlQ1JjMGJ2MXN3NmdGaiswM2ZCamFZUGhRcHptbWMwMStBVkhLZGJsQ0p6ZjdzSm1Vc3RoRElUMkhxS2x2KwpCeHdTeWpCRFVCdG8yaTM5b0o1Yk40U3A2YXRtVEZBVXdmaWwyZUJ2Q0xwRElPRDJ5RFFjNWorUVdKcm9ud2RYCmc2SUpIaTRQaVV6RElKVjJRWVFwdFlqdmJ4Nzc0NjV3bm82RlV5b0tNcGg0UGIyZzM3VnRHZFdTL09HYW9SOU8KdFprbTVUa3VkS28ySlRoWVNMRVk1M3k5SzM3Qk4xUGpaVFlJYU1PQ0hMdDJ1TkxsT2NjMTJPTWxLY2FESzcvWgpvNXZidVF0bVZkM3hGaURJK2EyUmtTaHpOanJ0b3VYbE5qUkM1bmtDZ2dFQVZ5dFN6dVlsRHF6dTE5UWtQZVRCCkR6aEg0eHBmZmZhQjJtaVRmWnhCSGJWYzhDek43Y1BtaHk5N3RFYS94UzU1ZTNTREIwZjdGZ0ZBTkd2RWZ2Q2wKN042djZ3byttNExtVktSeExVWit3NTlMVjVETlZCZEQ3WVRWYzdBTXBHanczd2FoaU5jK1pVNlVkcUVrMURWSAo1RTNib0FSKzN6Q2dMcmd0aEJIWTRLSVduMHJlZDBLZzhRRHhIL3VqMnVpazBpcmtYS2RBVmVxLzc4eXk5ZXgzCm0rRlNtWHFaVmZyQjhGZktzckRYZUR2WWY0YnJHOVFXZGFlZEF6V0I0SUxCWkwwMGtQY0RoRWRwWFdRTlZwRzcKVDNZZmRsUDZHZVJuQ245UFpHd01VNk9BbkJTR2EwbmRSNFpPaklUdDN3b0VublhnY2dHWk9jNTJJRlpXZDZ6VQppUUtDQVFFQW14WWJGdE5YZ2UxeXlORGJqM0hZTEFzN1YreDhVWXdkOVpYcm51RXBHNEtjYlB1Y1FCUnRXL2VWCjNzNmIrRmFvd05vU0N0WkV6Uk8rVm80OXhjNnMzMkt4YkI5RDlPTHVQUy9qWXV6Vm5TWHZ4NVphQUs1M1gva1MKbEV6Y0g2UmJIS05TVGJXd1Rkc3U1dGI1WFhkUTZ0QkFyM2cvaG5WOWJ0cVBxcHAwRjE4dW5OeDBjTWc5bHF2cAplV1RMY3VXUXVTWm1xSm0zb3dMUEJKR3FhM2tYT3VRWVBOY0pqelFNeDdERTNtSGt2WFBQS2xCSkZFRlRtdUlNCmE0azdENmQvaTZkS291ZmcyRVBvNG5FVmx5ZmxFdWxNQU5qR09OTUtDeFF6RnZkcWp0OWUzREt0OXpWWGtVb3cKQVNTdUlScktkY1FrQ284bHNIcjkrdEZiSno0RHR3PT0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:node:node-1 \
  --kubeconfig=node-1.kubeconfig && cat node-1.kubeconfig
Context "default" created.
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZURENDQXpTZ0F3SUJBZ0lVSEZjTnZpeGtuRnlBRm15M053VWZETGtmaHhzd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1EZ3dOVm9YRFRNMk1ERXhNVEV5Ck1EZ3dOVm93UVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01DbGRoYzJocGJtZDBiMjR4RURBT0JnTlYKQkFjTUIxTmxZWFIwYkdVeEN6QUpCZ05WQkFNTUFrTkJNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QQpNSUlDQ2dLQ0FnRUF2RVJWR3k3dWJFaU9KdmNnVnkyUm5VNjhMbXVGSVI4NlgxVnRSM1BOYWlEWHVaWVkrcDk4ClJ6dVI4YjQ2TXdLMXB3SXc2VnJJOWU3MmQxMmw0UXJNZHJUdXMxTWY1ZVpFMHE1N3pPWUR0Ry9VOUxHeER1djMKYms1bThjZ1p4SThMR0o0UW02bjZXUmRVMFhVbEhBcTdzNVdyam5YUnpoZmZRcG5wM2ZHTnBJM2tRM21UWUdydwpXbFk2VUQ0ejlZeDJxa1dHdGFkRndVVVdXbHhBOWlGRlpRYUt1OFZPbnhIZkZpckowSmxnaTBJaTYyYXhyd2lOCllOK3luR2NEZDUyelhONldDc3NJamQ2V3BGb1JzMW1kY29QdXFlRzhwSk1tRFpldTlSN0IxNENoQUl6b09wRWoKY0N4M2Q3NTdubnVnSEtZa0xQWlIxQXVIMERKYngvblB2d09WZXhQVEpVbnR1eTFmenVrMnpaSXlMRDBHa0tlVwpzRTg2a1JEdEVwcmw0Sk1yaUN2MTVCdU9RNDQrVXJzWm5GcENwa0hPbWREN1E0dzRaZXNpd3dQcFhudnhmNFNoCmNoenBxcHBTY1dyclFZbno0OHVpSkQ0OUVHUzJ0RDdBZ3dvVlJDSWhzeER0alhiOFBSRjZVSWtBUUJlSnhoT2EKcERUR0tiMzNCQThCT1BVcmwxbDJtc2ljYVBzcWNrM3ZYWUpaYkRZSCt0WkxaNnFZZ2gxZnhQUCtJaFhzMXplbgp5cndiV2tlNnk0UGwwR1JXWCtHcU5NL0NXUlh3YVUwbVZTRG9wZlJvb0VKdzg2bVJtVk85K2NGOFBZUkttaFhPCldXYUw2cXdZU0NmL252NjZSdTRjdmlVNVRvV2w2VnVnRzlZdm1LM2xycFhhS2g4VWdIRkd6MDhDQXdFQUFhTTgKTURvd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZHZG9pVUJucVdxYwpvL05FVnI5YUoxZVkvOVVBTUEwR0NTcUdTSWIzRFFFQkRRVUFBNElDQVFBdVJpM1hNWmRyclNwdTRQRTFTazdWCnBlU2k0dVBEVEpONlc3ckJYWUNEVVZWUjNDNjFWbUpYMVdoZndIeUZMV1grQkpFcmRjMHVHTWNERC9qMDdUYUMKSHIwMmNqaUpjSE9uSCt2ZVVHZXZXNmRaeWx2TXp1RStpZWxPTVlEN3pvcUs5NmwwWTF5U09URDdzWFBUWm9PcAo0S0dabDF5N3ZmSTJpdTJHcVdlUDhBQXB0Qm5JY0VLOW85R0ZQcmhhN25wTS9ROEloNHZCNHFMRi9EVENDRmExCjRMajliV3VndE1GQm1ld09ic3RaeHpLc1NVekFKdk1MV2tMYVNLdXpCWldlWXBWeW4vNEorSmRmeTBJcm1tOXYKaVBMN0o3SHZ2YzJOZFFpK01pcU00ZkJobk1KQ1JBMTBFem1iT1gxUlN6b0NVTnkycFhoYmdkbDFMK2hERm1yQQpvdmNNZ1huNzFJUlU3R0V4VG02UTRtR2ZEZHpuNllEQzQ2R3RBRjVZVlFoVFg1V0FjV1BIMktTNVBKeVJvYmRNCmxmWnhMdytIa1E2dnQzaVloWXFDRjNFU0kyN2hRajFQQXp5T2FqaVl5RGxjREVRRVArWGs3bEtDaXR0UWNMQ0sKZXlCcWJXM0RiZW1MZ0dVa2dWcWRMK2lzN3RVR3pGOGU0a1J4NmRLZkw2Ny9XK0c5b0FyZjExeDBMM1MwWEhybgpZUURNemtXQ1hyZnQ0TVJ6V2p5aWRDYUJ3VlRjSHdZejc0Z1ZUMUIzWlhFYmJCamZBS3RUVFVtcEV4anFuczlxCm1RMzkvV05ybE5ZN014WGJOYkVXSStOeisrS2JnenFFNkhnbUs3SGwxc21JME1PTlpiYTZEQ1NzRHgwb1ZPMjIKMlgvU1VJMk5tNStUd2VkRFVRcktFUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://server.kubernetes.local:6443
  name: kubernetes-the-hard-way
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: system:node:node-1
  name: default
current-context: ""
kind: Config
preferences: {}
users:
- name: system:node:node-1
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUdCRENDQSt5Z0F3SUJBZ0lVWmFnNXc5OXFDR3JDWnIwY1hPNUl4RnRlVFk4d0RRWUpLb1pJaHZjTkFRRUwKQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1UTXhNbG9YRFRNMk1ERXhNVEV5Ck1UTXhNbG93YURFYk1Ca0dBMVVFQXd3U2MzbHpkR1Z0T201dlpHVTZibTlrWlMweE1SVXdFd1lEVlFRS0RBeHoKZVhOMFpXMDZibTlrWlhNeEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlEQXBYWVhOb2FXNW5kRzl1TVJBdwpEZ1lEVlFRSERBZFRaV0YwZEd4bE1JSUNJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBZzhBTUlJQ0NnS0NBZ0VBCnh0elZnbm51cW1heEF2bjlrdmxlSHdZTTlUSTRUL1dLZ0RKekxsVVJMOFRQaGNpbjAwVk5qMWlzVnNwMU81d2EKQjEzMCtEM1l3VVBvRCs4ZVlOVVNldmtlU1pqclhBbmNvem1KMzFXYU4xN055OFYwS3VwdXJhRDJtQnVESUd4UApZNFd6Y3FyYU1Jc0poN1daMmZVWUEyVGY0SG9oajRFY29EYTBSK0xyWXJNZ1ArS0FMRm44ZHlKOTRGcFphN1pEClZ3WTFxeXVsaXJnTXBDT0RsQXYzcklPT2dVOWU5SGJObW9qZjNKT1ZBQlgwdVpBd1BlN2xTdEFYVlZEelZvTFMKdVp5YzhkVC92SUFIbC9CRWErVXAvam9hd0NSS0F5SnVpdmgzRGdjWkdoYTRBU3Q3MHpWa3ZmS3RSNXphVGNUZQpyaTRoSVRLV29UcFhVOFJUZzNlRmpvMS9tSnQzakQ5VTZxK3dnMVM0UnNMSGQwVmVnb2poN1ExS0JKK05saThwClR1K3JERE9oeWkvNER3SUVxTjhhVzNWajhqbnV0bVdWTFFDbzRySUlacjZsaFkzTUVvZVhoeWw3WWh1YkZJTGgKTTFrRzVONSt6WlZOdDJoWHA3alR0cVpXd1U1UHNqcldSMStBdW1KTzNIRTljcjNJSWJJQnNjT0YwQlZtdk5CUApOa29DaXZFTmg3N3NBbDMxeTl0b3EyS3NaYzJtc2NTTk1id0xCMXpEQk9WaGdrTHpocUVKby8wdE9DRk1FZjdqCjlRS3FVU01FVkJUK0gwL1lPTzlCUklocmhkU0JYVTIvTGpLd3VXVnRhckc1NXlUSGliR3dnN3h5YVBlWGw5QTgKQkFnNU91eVJDQmE3WmJPSGVjOE43QXFBdS8xYVNod3FOWm9vdE1aR21qVUNBd0VBQWFPQnpEQ0J5VEFKQmdOVgpIUk1FQWpBQU1CMEdBMVVkSlFRV01CUUdDQ3NHQVFVRkJ3TUNCZ2dyQmdFRkJRY0RBVEFPQmdOVkhROEJBZjhFCkJBTUNCYUF3RVFZSllJWklBWWI0UWdFQkJBUURBZ2VBTUNFR0NXQ0dTQUdHK0VJQkRRUVVGaEpPYjJSbExURWcKUTJWeWRHbG1hV05oZEdVd0Z3WURWUjBSQkJBd0RvSUdibTlrWlMweGh3Ui9BQUFCTUIwR0ExVWREZ1FXQkJSbApoUGIxeWdZUXVNem9xTmxwQ2owN0tvVnduVEFmQmdOVkhTTUVHREFXZ0JSbmFJbEFaNmxxbktQelJGYS9XaWRYCm1QL1ZBREFOQmdrcWhraUc5dzBCQVFzRkFBT0NBZ0VBdUJpVnk3Tk4zd3pKOUtTWDczVUVoaUk0NnV0RkllV0IKYks3eFMwMTVDWXlYWDFTdDE1WHJKYVlLc1M1UVVERnRpVjFKeTdBU2xHblBtZ1lwY24ra2xqZHgwS0RNN2xpbApCTk9ZME9kMWxaeHlBcTVCM1llWWdudnBJVENPVzBncmwyVXR0aWRJZWFJVThWTnhmNTFGZm1BZitkN2pBVzZXCjJSSHAxeXFYbklERDJxQkRuMnovR3V3UklZY2Rzb2kyb0c3QUFNOU5vWDNydmdta0IvTEpYdFFOamcwN3RpRGQKZjRaVlFVVHlmYnkzZ2ZhM0I2YklEMlZYV2hHUi9SaFlqcUdhSUtLOHEzSFdPc0IxS0V3N0IrMTE1Tkw0RlMwRAorTXoxeXNJTmJCWnFXSno2ZGdFOERzSnJpZVc5RHFCa0prTmlMLzNiWnQzNW05dmNxQXQrT1kzWkF6YTJmcGZ5CkQyV2pGeDdFUjN3c1RNSGZRYmtUWmZCVnRKak1QOGlEV3RxQ0lCQXJia2Z0TXZ6NXdSZmJkaHVSYWh6Wkd3Z3EKYXdMbHNyb1hnQUNnY0pwN1h4T1IzUStZTXJkWm01K3d5czBjUXpnQ3VRaFdvSG01WjZtVFVON000UFZHSDdrMwpTengrbjhvT21vaTFBVXFIaUJrZmNpVlQxM2FwT0hXRXFXQTNpUlhnZU5mMk9SMDc4UUFNQURIWjhaZ1pxM2QxClNMSk0yaDEvMVE0b0VrblBtdHowbVEzNWt4MmZpUng4U3Y2WnYzRCtiUnNORVpQMWFRbDNrYnZ5TGdCb1hJYzUKNEdmcFMzZWJpMVAvYXUvTWRGR3ZWLzlqaThJZm5OSmJTYkxaNW1jbkZ6cU5YaGlmbHNta3NPSlpLUU9ETExNdQo2OVNuamo1QzVaQT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    client-key-data: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRZ0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1N3d2dna29BZ0VBQW9JQ0FRREczTldDZWU2cVpyRUMKK2YyUytWNGZCZ3oxTWpoUDlZcUFNbk11VlJFdnhNK0Z5S2ZUUlUyUFdLeFd5blU3bkJvSFhmVDRQZGpCUStnUAo3eDVnMVJKNitSNUptT3RjQ2R5ak9ZbmZWWm8zWHMzTHhYUXE2bTZ0b1BhWUc0TWdiRTlqaGJOeXF0b3dpd21ICnRablo5UmdEWk4vZ2VpR1BnUnlnTnJSSDR1dGlzeUEvNG9Bc1dmeDNJbjNnV2xscnRrTlhCaldySzZXS3VBeWsKSTRPVUMvZXNnNDZCVDE3MGRzMmFpTi9jazVVQUZmUzVrREE5N3VWSzBCZFZVUE5XZ3RLNW5KengxUCs4Z0FlWAo4RVJyNVNuK09ockFKRW9ESW02SytIY09CeGthRnJnQkszdlROV1M5OHExSG5OcE54TjZ1TGlFaE1wYWhPbGRUCnhGT0RkNFdPalgrWW0zZU1QMVRxcjdDRFZMaEd3c2QzUlY2Q2lPSHREVW9FbjQyV0x5bE83NnNNTTZIS0wvZ1AKQWdTbzN4cGJkV1B5T2U2MlpaVXRBS2ppc2dobXZxV0ZqY3dTaDVlSEtYdGlHNXNVZ3VFeldRYmszbjdObFUyMwphRmVudU5PMnBsYkJUayt5T3RaSFg0QzZZazdjY1QxeXZjZ2hzZ0d4dzRYUUZXYTgwRTgyU2dLSzhRMkh2dXdDClhmWEwyMmlyWXF4bHphYXh4STB4dkFzSFhNTUU1V0dDUXZPR29RbWovUzA0SVV3Ui91UDFBcXBSSXdSVUZQNGYKVDlnNDcwRkVpR3VGMUlGZFRiOHVNckM1WlcxcXNibm5KTWVKc2JDRHZISm85NWVYMER3RUNEazY3SkVJRnJ0bApzNGQ1enczc0NvQzcvVnBLSENvMW1paTB4a2FhTlFJREFRQUJBb0lDQUFXTkViL2tDOWxIMm8valR2ZkJoZGxHCnBpbU1icnBoZDYyc0I2WGRQenZGSUhVTWt3M3J0TG1MY1I5UEY5L2RHa0RteXJrdk8vcFJIU1k1aEZiNENIY0gKZ3pHR1Z3MHBRN1p1dFBHSzB5NDRHZHU4Z3EvVmw5ZFM3U0oxY0l2TndKY3F6aEtMODVSenRyaVczdkxEL3VYTwpLQTJ3Ujk4bGJIKzlNL3VBSCtNcG9VblVDY1JNeGZNcS80TlRpTGZnQUdUUTQ4STdQZDhpMDdLMVFLMmVSeG81CkdSZmJYbFhKMC8xdlZFaG9MVzJYeU9nS3Z2RXlDY2FCY2J1eWkySDRvaHB0ZnZHbE5kMkJYODU5WEVoaXZ3cTkKZk9GR0x0bnFXU016anljM3NMU3d1ZzlqR1kwcVhXTy9NajZ0VG1oUUl5TW9YdU10V0loRTBUNEg5cndJSStHZQp3bVNpNlZpV25TaFYxMk9tN0o0T2xqTDhLN0t5L2JZbjEzcUZkLzFLaThyLzdtc3daQ3pQb3NQOGQvUnJyMDdhClVVcHNzeS9tVFZsTU54QUZOS0ptTFBVd01pU3NZZFVKRlpCVWZUZklNcnowK2VXbFBvN05SUVlXWUM0UXUyblEKYlhlM0JUcmJ4d3BMUklreTZ5ODkvaVQvYTZBRXQ3SjZ4d2NuYmdqZVRjVGlmWW1nVitsSVhuN2dqUTBYek91MgpDd2pMdVliYm41UWI5VElCZDhNTU9NRnlIcEVRd2xtRUwxU05nVGVGd3BCK0JIZjBwR2dTLzJ5ZlpQbHgrUTVnCnI5SFNCYU1IblpHbWFKS2VKdDVuUVRUT1k4a3ltSEFoQXFFMHBhN244N2JqaWNILzUxZ1FJUUxuSUNHNytOWHUKRnI2NFhuMlIvS2pUdDZScHlEK2hBb0lCQVFENFQxYnhIUFNyaWlwTS9pRTJkZ2x0UFREUGtadFJ1VzVZUUtRdQpTMm1nbGVETzJHc0ZJeDJRa2hNL3hJaFFPS2x5SG5mTlIrK3pVYjhxbVlORmh1Mm1Fa1l5c001Q0dJb2hIdlhNCng0NVJxdW5xYVZBSFhuc1dnOWVSOWVwekNJMGpOVTExVlJ6dzByemxqZWRkU0FSYSs4a0daNjZMWXpmbUF0QmMKZXpnWlNkYnFQdEZhZHhQUmx4Qk5FNDYyd1FmVzRkdE9Ub1hzTzdmR0d3SDdxOTFrZzFwQ0xVK2Rkb296dHU0RQpsY3I4YmtOVlk4bXRWRUN1ZGEwV0xVV1RHd1hXK3VzRzNsQnZTbStDeEN6ZGtYb2gwSXRHNnIwQXYwUGduQm0xCnNleWNPa2xkeUVpa0ZiZExqa3UxVXA3b1cybGpIamVHRnhSeTFIT0NPUE5IVTd0TkFvSUJBUUROQlhicEljT04KRGZ2eFZLc3RYTGZjcnR2T0FUck5GYkhuQzVDZHI5Vi9Wc29NbGRvd3ZTUkVWTFpSUmlISXRxR3hUZkJBbVFqUgpZT1pUbmVFVVhiUmZLa3pUQTRZVWdPT2FtRWswVkY0ckNiekFlSTBZbG8vc2NIWDlUWCt2VXFEWUxEVXI4T04wCjU1SlRZTGlldFJrK25iYnVaWW0rb1VaeEw0emgzZlYwMm8yMmQxVExhSlAyR0VwakxTN0hTWWVsMDdja2w2WWcKNllwN2JDWmVFb1V0NG9wenNEODVnUW5RdTNSenVwVm53dnphYzlnbzNpNitWK25QL1BLcTYyVDgzYlpXUTFPTwp2NUxqNUs1TFFTWHFyRTliVzlYMUpIb1F5NEVYa1dDajExbkVMdGxkcGVPVHNlV2NETk1wZ2Rxb0V2Sy9kK1BtClVMREZ5TGttK2RhSkFvSUJBUURCNWZLV1JXNHBwYkp5Zk4raWozbTgrOU5wd3VIdVowWnJVODdnOTdKNzI0MjQKOS9aYUJKbkprc2ZGTzhyV0dlajNYQ05oQVpPRUM0bWowa3hYdG8xTTZXZzNuU2p6SkFaNDVwdzZWSG9sKzdpOQplNDhxc2ZTY0dFZjFpbnFSYVZRTThrcVNIT3lFZ1l0UUZnZGRLQ2QraEs3dGVYa3JEMGRQTFZOWFpFRGlQbTY4CmJHRStxMDJtbExmOStBK3hWZnF4S1p6L0FRSkMvajc3UzR1NDR2UDIwVHRpQWMveHZlY2Rpdk5DVVZZNDJFRnMKSklnUCtZS291T3Q0TGRIdWxXTnlCRzRTNXZjWWNKK3pGVTJUbDA0dnFaR1l4eVRmdUh0Z29ZVFNCU1ltdUwwaApwb3hTMVVKVWxjRTR6bE9ZVGdsMWhOc0dzbThkWEJqMnoxSHBtTkRoQW9JQkFDZnhTSmxpMnBaQWd6VWhLYmhNCnVBVm1pNncyMFIzamZDVm5PMlY5UERyeXphcG1CM3czWFRseXg1Sk45NGNERGIxZFVkRkQvMVBMYlJRZFRoeUoKcFBwbFkxSTQvWVpCRmhhb1ZKcTlWUnROYWxpVkkrZ0diVVBESlRtVVA2d0lqUTJRajB0Z1F2QWpyWDVRK2FieAo0Vmt4b05JUk5pVE5oc3ZHVjh3cFVnalNDNG5nOWNRck82aFdVeWUvUmIzTnRYKzVINVVoZGx3ekk2ZW9DbEdKCmlpakdXZkx3QTJGUW9uam9ER2Yva2R3RlFQM09VKzZpV3JqNnA3Szl0UWxYa3ZVd3ZMVlJxSlhHL1BjcE5rdXoKQlpBU3dlTXFvU1NCVnNhdTN4ZVlXeHVRZVF5ZmsvbUt1Q3V1SE8ycUVmbWtNdFZMMjc4eHZGVENvNjNrelMycQp2d0VDZ2dFQWE3dXJGK3hKa2J0NkxseXR1VTNaQ2JZT0xZYjlKMEhUMFlvcTB3bmROVkd2N21lUnpiTkd5d2xsCnpnOVFhak0yQ0RSRFVvdEYreG1vbVVNemd3dDBxYjd4THphV3UyYzZuTEdlMmxKODQ0VldyOE9UTy93V0xNTEwKR2JpOFFUN0lyMnNuNjh2N1pkT20rU2JnbjBNOGYya2pyMlJZd1lOQlFkV2tOVzdjOXVid2xZdjBENzZkNTlpRwo2N1lIcGUyMkNkdHNjUE90Qy9XcU8vUXdQN0FncG8ydnROOHBoaVBDTG9mSG9VR1Fwd0xoVGxvRXJBcHI3QXphCmpHZkRHTExML09FdWgzTHd5TXkxbDhCS01LaU43K29kc2Roc1dJTGpqTGVmWWV2L2xyQklmTkYydTR6eDZvUHgKRjdnMGdacXdMOGtNb0htQkhxU1lvbm9QNGxWdUxnPT0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=

# use-context : current-context 에 default 추가
root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config use-context default \
  --kubeconfig=node-0.kubeconfig
Switched to context "default".

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config use-context default \
  --kubeconfig=node-1.kubeconfig
Switched to context "default".

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat node-1.kubeconfig
...
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: system:node:node-1
  name: default
current-context: default
kind: Config
...



root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l *.kubeconfig
-rw------- 1 root root 10161 Jan 10 12:30 node-0.kubeconfig
-rw------- 1 root root 10161 Jan 10 12:31 node-1.kubeconfig
```


### The kube-proxy Kubernetes Configuration File
```bash
# Generate a kubeconfig file for the kube-proxy service
root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://server.kubernetes.local:6443 \
  --kubeconfig=kube-proxy.kubeconfig
Cluster "kubernetes-the-hard-way" set.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-credentials system:kube-proxy \
  --client-certificate=kube-proxy.crt \
  --client-key=kube-proxy.key \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
User "system:kube-proxy" set.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
Context "default" created.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config use-context default \
  --kubeconfig=kube-proxy.kubeconfig
Switched to context "default".

# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat kube-proxy.kubeconfig 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZURENDQXpTZ0F3SUJBZ0lVSEZjTnZpeGtuRnlBRm15M053VWZETGtmaHhzd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1EZ3dOVm9YRFRNMk1ERXhNVEV5Ck1EZ3dOVm93UVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01DbGRoYzJocGJtZDBiMjR4RURBT0JnTlYKQkFjTUIxTmxZWFIwYkdVeEN6QUpCZ05WQkFNTUFrTkJNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QQpNSUlDQ2dLQ0FnRUF2RVJWR3k3dWJFaU9KdmNnVnkyUm5VNjhMbXVGSVI4NlgxVnRSM1BOYWlEWHVaWVkrcDk4ClJ6dVI4YjQ2TXdLMXB3SXc2VnJJOWU3MmQxMmw0UXJNZHJUdXMxTWY1ZVpFMHE1N3pPWUR0Ry9VOUxHeER1djMKYms1bThjZ1p4SThMR0o0UW02bjZXUmRVMFhVbEhBcTdzNVdyam5YUnpoZmZRcG5wM2ZHTnBJM2tRM21UWUdydwpXbFk2VUQ0ejlZeDJxa1dHdGFkRndVVVdXbHhBOWlGRlpRYUt1OFZPbnhIZkZpckowSmxnaTBJaTYyYXhyd2lOCllOK3luR2NEZDUyelhONldDc3NJamQ2V3BGb1JzMW1kY29QdXFlRzhwSk1tRFpldTlSN0IxNENoQUl6b09wRWoKY0N4M2Q3NTdubnVnSEtZa0xQWlIxQXVIMERKYngvblB2d09WZXhQVEpVbnR1eTFmenVrMnpaSXlMRDBHa0tlVwpzRTg2a1JEdEVwcmw0Sk1yaUN2MTVCdU9RNDQrVXJzWm5GcENwa0hPbWREN1E0dzRaZXNpd3dQcFhudnhmNFNoCmNoenBxcHBTY1dyclFZbno0OHVpSkQ0OUVHUzJ0RDdBZ3dvVlJDSWhzeER0alhiOFBSRjZVSWtBUUJlSnhoT2EKcERUR0tiMzNCQThCT1BVcmwxbDJtc2ljYVBzcWNrM3ZYWUpaYkRZSCt0WkxaNnFZZ2gxZnhQUCtJaFhzMXplbgp5cndiV2tlNnk0UGwwR1JXWCtHcU5NL0NXUlh3YVUwbVZTRG9wZlJvb0VKdzg2bVJtVk85K2NGOFBZUkttaFhPCldXYUw2cXdZU0NmL252NjZSdTRjdmlVNVRvV2w2VnVnRzlZdm1LM2xycFhhS2g4VWdIRkd6MDhDQXdFQUFhTTgKTURvd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZHZG9pVUJucVdxYwpvL05FVnI5YUoxZVkvOVVBTUEwR0NTcUdTSWIzRFFFQkRRVUFBNElDQVFBdVJpM1hNWmRyclNwdTRQRTFTazdWCnBlU2k0dVBEVEpONlc3ckJYWUNEVVZWUjNDNjFWbUpYMVdoZndIeUZMV1grQkpFcmRjMHVHTWNERC9qMDdUYUMKSHIwMmNqaUpjSE9uSCt2ZVVHZXZXNmRaeWx2TXp1RStpZWxPTVlEN3pvcUs5NmwwWTF5U09URDdzWFBUWm9PcAo0S0dabDF5N3ZmSTJpdTJHcVdlUDhBQXB0Qm5JY0VLOW85R0ZQcmhhN25wTS9ROEloNHZCNHFMRi9EVENDRmExCjRMajliV3VndE1GQm1ld09ic3RaeHpLc1NVekFKdk1MV2tMYVNLdXpCWldlWXBWeW4vNEorSmRmeTBJcm1tOXYKaVBMN0o3SHZ2YzJOZFFpK01pcU00ZkJobk1KQ1JBMTBFem1iT1gxUlN6b0NVTnkycFhoYmdkbDFMK2hERm1yQQpvdmNNZ1huNzFJUlU3R0V4VG02UTRtR2ZEZHpuNllEQzQ2R3RBRjVZVlFoVFg1V0FjV1BIMktTNVBKeVJvYmRNCmxmWnhMdytIa1E2dnQzaVloWXFDRjNFU0kyN2hRajFQQXp5T2FqaVl5RGxjREVRRVArWGs3bEtDaXR0UWNMQ0sKZXlCcWJXM0RiZW1MZ0dVa2dWcWRMK2lzN3RVR3pGOGU0a1J4NmRLZkw2Ny9XK0c5b0FyZjExeDBMM1MwWEhybgpZUURNemtXQ1hyZnQ0TVJ6V2p5aWRDYUJ3VlRjSHdZejc0Z1ZUMUIzWlhFYmJCamZBS3RUVFVtcEV4anFuczlxCm1RMzkvV05ybE5ZN014WGJOYkVXSStOeisrS2JnenFFNkhnbUs3SGwxc21JME1PTlpiYTZEQ1NzRHgwb1ZPMjIKMlgvU1VJMk5tNStUd2VkRFVRcktFUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://server.kubernetes.local:6443
  name: kubernetes-the-hard-way
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: system:kube-proxy
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: system:kube-proxy
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUdFakNDQS9xZ0F3SUJBZ0lVWmFnNXc5OXFDR3JDWnIwY1hPNUl4RnRlVFpBd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1UTXhNMW9YRFRNMk1ERXhNVEV5Ck1UTXhNMW93YmpFYU1CZ0dBMVVFQXd3UmMzbHpkR1Z0T210MVltVXRjSEp2ZUhreEhEQWFCZ05WQkFvTUUzTjUKYzNSbGJUcHViMlJsTFhCeWIzaHBaWEl4Q3pBSkJnTlZCQVlUQWxWVE1STXdFUVlEVlFRSURBcFhZWE5vYVc1bgpkRzl1TVJBd0RnWURWUVFIREFkVFpXRjBkR3hsTUlJQ0lqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FnOEFNSUlDCkNnS0NBZ0VBcTR2bXh5Ujg5aEtrUFhxOEUxbWJraDlQRmxpeTlDWU5DL3NaTVd0cWtIMzBFWlJQL1ZVWU1lbUsKdGhHanpmOGF3RkxaM2hpem5BczIva1VVVnhTQUozRTlCcmpaY1gzSGhSWDl0TGs3U2pYVTFhNWtOcGVmYU8vcgpIZi9IOFF1WUVhRXdmamgvUWUxNE11dW5WOW0ycEdIaVFoQjJjZjZCMEZQRHNmY1owa093dmE0UGtBbzlwQ1p0CmNzdUZnRXVNOUdGWG9OTWpoemVOOVMvRWFwNlRnTXl4Y1MvNEhoMEhFNHZHZ2pFMFcyTW04MzQ2K3pKWEpWYncKTWNGOEVYK1dLVzAwMlZEWEQxS2RSTEM2bk9Od3MrOG03c3p1YzhUUVpINGVKbGJhcTJyemRXTXlmWFRNLzkxVgp1cE9tUUlINEV6cTJoOVB6L0JuQjU1S205Mys2UlJ6YzdyOE5RQkMzejNJY3EwUzE4SFNJMGVKcFNhMlBLMkJaCnE4bGoxZXBZb2t1MzdueXVDbmdncG8zQ2I3YjVSQzUwcTlEQm9aVHNMNmZ1LzRrL01YVmZrZytKRHJPTlM2MjQKS3FsZEtacVJsMXo4L2RGMGRvSERDOXpaZjhJU2lqejBtNlZWSVRpbzgzb2RiV2ZHdVRlaEswK0NIUFIwTU92Qwoyd1NGYWdWR0dRcnJuczRmYUNGL1hKK3ZoQXN3bjdLN0JoUDRGR0pVRkFEZjJ6dnVmQ05uWmhORFJDM2NEVTRECjFPSTdnN0xTeGd4Q1pMckZkUExoR0xQSUxFeWdHT2x4aDlMWmlwZXM5elZPUEVEeithRGRhbGlZQjZLU01Ga0UKN05GQW9hSXl5ZTI2cFkzUjFzY1o3SE0zazBSaXI3NDQ5dzAxeEllakJZVS9DZWMvdDJrQ0F3RUFBYU9CMURDQgowVEFKQmdOVkhSTUVBakFBTUIwR0ExVWRKUVFXTUJRR0NDc0dBUVVGQndNQ0JnZ3JCZ0VGQlFjREFUQU9CZ05WCkhROEJBZjhFQkFNQ0JhQXdFUVlKWUlaSUFZYjRRZ0VCQkFRREFnZUFNQ1VHQ1dDR1NBR0crRUlCRFFRWUZoWkwKZFdKbElGQnliM2g1SUVObGNuUnBabWxqWVhSbE1Cc0dBMVVkRVFRVU1CS0NDbXQxWW1VdGNISnZlSG1IQkg4QQpBQUV3SFFZRFZSME9CQllFRkVDbE1Ia0NRRk4rNUJ0ZklJY0xmcjBYVWZRWk1COEdBMVVkSXdRWU1CYUFGR2RvCmlVQm5xV3Fjby9ORVZyOWFKMWVZLzlVQU1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQ0FRQTFVYnJEd0hSU3RPNWYKVjdRWU9MV0wrdU5HKzE0dnFRSGRHNFREYVgxWXVnN0xrNTdFbUNrVkgvZkc4dzNMU3BGUGFFWXdzTlpzSlg4RwoxMEJQMHNFdFF1d05Ud1RETUtLQ0J1YnRBQXQvSGQ0Zk8vdWk3NHZ2c1U5bkFVVDNpOUFMaFdFaG9hdVZqc2t6CmhMNGI4WUgwaVdEN0pEMENLR2dWOW8wUCt3dEg2a1ZFK1Q5WXhhckkzc2xJOXNESVJwUUROQjVEQkVpbWVsajUKM1RueEFoQSt0SzJTZWN2M3ArbnYvcnp2L3o2THZjeEkwclhHdjZrTHg3T2xlTDZWRzhaNG9ja3E5YklvVmdsUgp5VkUxeXdPd2VIZm1BWHJ6RnNpazRwaEh2aDRmVDFkNU96NkQzV1dITnhiV3JzUksvcldmdjI4OHROK2R2dm0vCmNTZGFNVXNvSmVZWGtsMFJuTnp3Sy9YMUljYUdBOVNFaHBuV3RNUXcwcm1tR1RiOVlidkh0VXljNnBYcWZKb1AKalNLV25PbFl0S3owaWI4c0JjVU1rc2p0TS9lcmk0cENFanovUUg4MGZNbWpHWnVUUEVUK1NhZGFSWmh4ZVVpWAppb2kzZG5TTE12aXlRaDJITUZ4WmZhZ3lRZ21xWGRnM3g4STU5ek50ZnFpN3lEajBxdUl6QW4yZzhSMktmVzN5ClFrc0FxU3BZczBKTTZDdXprb0wrOGsxekFnQk90Y010U2FpKzJiZDVRQXRjNU5kbFlPNlVNVE1UZmVVT1Z1UVcKWmlHem80WWloWUxoWiszODNmeHM1VW9lMDhyNkZlbHA0SnljVXVtVlN1d0VJb2dENFpzRlhrT0FCenMvWHRuUgpaQlJrY2IreVM5bnBwSS9RSVNCT3lxME9pNXJiTEE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    client-key-data: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRd0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1Mwd2dna3BBZ0VBQW9JQ0FRQ3JpK2JISkh6MkVxUTkKZXJ3VFdadVNIMDhXV0xMMEpnMEwreGt4YTJxUWZmUVJsRS85VlJneDZZcTJFYVBOL3hyQVV0bmVHTE9jQ3piKwpSUlJYRklBbmNUMEd1Tmx4ZmNlRkZmMjB1VHRLTmRUVnJtUTJsNTlvNytzZC84ZnhDNWdSb1RCK09IOUI3WGd5CjY2ZFgyYmFrWWVKQ0VIWngvb0hRVThPeDl4blNRN0M5cmcrUUNqMmtKbTF5eTRXQVM0ejBZVmVnMHlPSE40MzEKTDhScW5wT0F6TEZ4TC9nZUhRY1RpOGFDTVRSYll5YnpmanI3TWxjbFZ2QXh3WHdSZjVZcGJUVFpVTmNQVXAxRQpzTHFjNDNDejd5YnV6TzV6eE5Ca2ZoNG1WdHFyYXZOMVl6SjlkTXovM1ZXNms2WkFnZmdUT3JhSDAvUDhHY0huCmtxYjNmN3BGSE56dXZ3MUFFTGZQY2h5clJMWHdkSWpSNG1sSnJZOHJZRm1yeVdQVjZsaWlTN2Z1Zks0S2VDQ20KamNKdnR2bEVMblNyME1HaGxPd3ZwKzcvaVQ4eGRWK1NENGtPczQxTHJiZ3FxVjBwbXBHWFhQejkwWFIyZ2NNTAozTmwvd2hLS1BQU2JwVlVoT0tqemVoMXRaOGE1TjZFclQ0SWM5SFF3NjhMYkJJVnFCVVlaQ3V1ZXpoOW9JWDljCm42K0VDekNmc3JzR0UvZ1VZbFFVQU4vYk8rNThJMmRtRTBORUxkd05UZ1BVNGp1RHN0TEdERUprdXNWMDh1RVkKczhnc1RLQVk2WEdIMHRtS2w2ejNOVTQ4UVBQNW9OMXFXSmdIb3BJd1dRVHMwVUNob2pMSjdicWxqZEhXeHhucwpjemVUUkdLdnZqajNEVFhFaDZNRmhUOEo1eiszYVFJREFRQUJBb0lDQUFPOG9BaFNmNDViRlptY2NhQmZGSWdSCjdibm9GeUVPWVltVFJrcHFnREtQK0ova201U292a2FVM1Bxckk3T0hEUlFoQnJIdENqbGRLZm5veG9SQXNON0UKcnJadkxHUFFHZ0R1OVUwTWcrZ2VWT0FuaC9OUWZKNTQrRDlnUHBwWG1lbWV6TnpUQTlYWU50R3V2ZzRPcGdrUgpEWmF3YkZEaytzZThLMkh2MmdsWHQxWktiTVVwUnlXckM5Tk12SE5YWlN2WTFKYWlRc3QyMmZCaWp6RXJZTDJWCkhrMHk1UnEvbiswSmVUcTR5NnVUam8xQnMrQUNpZXFpdGNmeTRxRmp3QnJXSFBYTlVKdVVjTGxnVlBhNTd6VmMKTksrMG1ZSHhyek9oTTZ5SHVqZXlnUjhvVEFXcC9oVXpLWHpvK0JEeUVLS0ttVVoraytBRXg1NktqNnlLSG9xWApRQmRjdEI1SXdFYXdTODBOeDlFNHBZNmY3Rk5aVnJCR2ltSmxYRFdGMHp5UzdpT09YaDZNa3FXN3hCQlFRTWhXCktWamFVSm1mMDRrWExOSXlPUlRzd3NTc0NnREs3eGgvN3lLOS90SmJ3Wlo4VlZPREJlRkZ5RXBDNzBwUnljbXUKZGx3THdEK0ZmWnJBanAxc2hMcHhDODFLVG44QjIzS0xydjVWY0xOQ3JuRFJvalZNbkJWQXNwclZmUG1CSXRFMwptck5iNXdaSklTSHNLeC9NaWV2NmRLNEV0dzJJVWRZQzdjY1owQ0VVNVpkeXJZNDZWUkRIbE45N3o4MGxRVWdKCkI4NEx5d2RSU2RWK3FNUERhbmhIOWxGUy9URTRzNEo2dmxHZXhCanVScFlKdnl4RUp5TytpQnlZZ2RldmVmNkUKVk9YZDZIYnk3OUUwSmVkbXlUNEpBb0lCQVFEeEdvbEVUTmJWK2hUUkVlY3pQSkRTS0gvaHJKOGdmY0l0UVhNTgpoUTgvTldVUmlNc1crMngzZkZvOEFmZGRBMVFTSkpUdnhPVGNRM1o1c2dRek10eTdaSWlQTWdGc3BGL1FZcy9KCnRUcnRtTjkyYk5qNjNyRjNacTh1Vk1PK250anZTZlZZSmduazlVcFg0QXRqaWZCRktReVU3L0NkTmxPSWlXdHoKbHJBbS9Qa0ErdkhqczlFYktBWjdrTVNMNVM2Q29RbHdkK2x3aTJUeVprNXlzY0pTdHlLc0pmMkFvQXBwbUJCNgp5SWRVTFBBOW5Kc3FzalFIWm93bUxibTNEdlRaWGplOVhCdThTQ0VDZEdWWFczelBuSHR4NzJFeGc3eFVydkY2CjV4NTB6MG9sR3lwZFplemt6OFBsQXZSNUQzMnY0MWpLSklXczMvRS9lb0FPWUtkUEFvSUJBUUMySlROWGplRmMKMnZPTkEzNlEvc0MrV3JaeDA0am1FNkhKMG1ld3R5cTVXT1I0QjZ3RmZ2T1lJakxzeTBsMHFaV2lnSngvbXlBUAptZjk5cUdhWlBucU9SL1hZcVJxWURodE96VTdEaTNiYlVXZEtxSTg0bXBnZ2lCdlZub3dNZUhNMmtBVFIrUkQ5CmJPUi9CdDlXc3NBRmdXSnIyZUd0ODdKYzJmWXg2L0pKU1c0UkFDVWhRcFh6eWZpcGJTOU5kUTJmM3FOTXlKU0EKYWRBdFdIMGpUcEMzOTdFYzVlM0dHQlpvcDZmSk5jakJsYUptclJXdjUvSDVVQndhWkVPZ3JocGxMS2U4by9lbwpubDIvMHJ2N1Y3TDNoV3N3RnBLWGcvTEp1OWZhS29OQS9Fd0I3cXJkd01tRmY1di80NGhBQTI4dXBVWDJlU3VZCldPVTVoTWZYTFlmSEFvSUJBRGx5S0NpVTRrOURjYmhLdXJxVGdMSUNJazRqOGhvc3ZKcEowTjcweUNnNFVhZDIKMzJUUGJRMmZIR1RWMXhsYlZLbXArNjZSVERKTEJLeUVSTW5xSVh1b3ZYelkza3dEY2l6VmprcXlHcU5IM0Y1OApHc3JUU3BkM2FOL3lKRjJEdlk1dUliM3Ara3VLUWpkajAzTFpCOTJDcFZQTFE1cEJ1bTk2eHBaWTNnbThGcHdzCkxud2hlUDR1Y0RUNnprbkN4bTByYjNOVHJ0UTQ4a2xySk4vaENMcnFsYUZNdi9Ub3JQSngzK05SYWlVZE8vU0MKSHRweWNVRWVKdUJsM3EwR0xFS3FWeitQOWEvTHc4bXc4QUI3ZE9hR2swY1hVU0lhRUVKaEdIby9IUnVaMUVHNQpFa1FFcUFmd2xPMDQ0Z1VDTXVFNG13dzIzWDdPTU0zK0l3cko3ck1DZ2dFQkFJYm1nbUlFQ0xjV3ltN1QrYmMxCmxsYmxKRjZsUnF6d09WRWFiZ1ZwZzFFR3p4OCt2MTdLcVdzeFdQb2JqV25EOTdrRSsrTmVacDVuZGR3QkR3dk0KUkVTQWMwcGw0L1pkN0VldXN2a01uNWpMYjI3UjdGRUYza21weE1Pdnl4V3BWOXMvU3ZLZ1ByOFRHU0FqWE9ILwpQVXhXaVNoTGxHT2JLNnl0R1RQY0JmUFZXSmxxdkJVb0Zac2JLUG1DamhnVjYyTk9KeS9GRm9jTTEwdmVUOEFJCmZoSmlkbUJxd25HR2dZSTlPWDFDUWs5dG5YdmlFVC9ZejFQUXl4K1l4cVdJakxBR0pLMEgyM0tjNTk0Y0czR0oKZ0ZqbURYN3VHTi95cjZ4TlhRNk5rZXhkYjRXMjJBR291UmdRYk45V0N5RXQ2ZmhvRzZyeUR5R2tKUkUya0RPRAoyeDBDZ2dFQkFLRHlNdzNvYmdOcWxxVzlHSjMzKzJHMnFzREdXNURCWVByMkNBNzI0SVdoQVRSN2d6KzR0OEhnCjlPdnJ4NkhUbi9LR1kvdWNpblZlK0NZVTRvK09wdDZ0V2lMMmdnMmNwQ3ZleEVUVFNzK2FqVmVlTjNFTHFGdXIKQUY2eHJhLzBvN0NVS0x3eDdBWE1qSkZoNS9GelpEU28vQjN5YU1Pc3ZkaXdGUkIwSERTRzJPaUQvRS95Zko2VApnSnlpNnpFeTZjV09SMnE5WlE0SVhJUVJOS2Y3a1h1RSt6U1BzcnFnTVgwbk52QkQ5S3puSWhFRlE0eVFYYUZLCmQ2a21yS25jN2J6eGt3NURIc3MzMnZHQUlIY2N0bzVTK0RGazNEdGdXYThxaWFVTlJqeWZaZ2lnZlZFOGk3ejEKQ3B1YklHczJwekU1bWoza0UrSFNPNGtrZ1Iyd0tudz0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=
```

### The kube-controller-manager Kubernetes Configuration File

```bash
# Generate a kubeconfig file for the kube-controller-manager service

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://server.kubernetes.local:6443 \
  --kubeconfig=kube-controller-manager.kubeconfig
Cluster "kubernetes-the-hard-way" set.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=kube-controller-manager.crt \
  --client-key=kube-controller-manager.key \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig
User "system:kube-controller-manager" set.


root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig
Context "default" created.


root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config use-context default \
  --kubeconfig=kube-controller-manager.kubeconfig
Switched to context "default".

# 확인 

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat kube-controller-manager.kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZURENDQXpTZ0F3SUJBZ0lVSEZjTnZpeGtuRnlBRm15M053VWZETGtmaHhzd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1EZ3dOVm9YRFRNMk1ERXhNVEV5Ck1EZ3dOVm93UVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01DbGRoYzJocGJtZDBiMjR4RURBT0JnTlYKQkFjTUIxTmxZWFIwYkdVeEN6QUpCZ05WQkFNTUFrTkJNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QQpNSUlDQ2dLQ0FnRUF2RVJWR3k3dWJFaU9KdmNnVnkyUm5VNjhMbXVGSVI4NlgxVnRSM1BOYWlEWHVaWVkrcDk4ClJ6dVI4YjQ2TXdLMXB3SXc2VnJJOWU3MmQxMmw0UXJNZHJUdXMxTWY1ZVpFMHE1N3pPWUR0Ry9VOUxHeER1djMKYms1bThjZ1p4SThMR0o0UW02bjZXUmRVMFhVbEhBcTdzNVdyam5YUnpoZmZRcG5wM2ZHTnBJM2tRM21UWUdydwpXbFk2VUQ0ejlZeDJxa1dHdGFkRndVVVdXbHhBOWlGRlpRYUt1OFZPbnhIZkZpckowSmxnaTBJaTYyYXhyd2lOCllOK3luR2NEZDUyelhONldDc3NJamQ2V3BGb1JzMW1kY29QdXFlRzhwSk1tRFpldTlSN0IxNENoQUl6b09wRWoKY0N4M2Q3NTdubnVnSEtZa0xQWlIxQXVIMERKYngvblB2d09WZXhQVEpVbnR1eTFmenVrMnpaSXlMRDBHa0tlVwpzRTg2a1JEdEVwcmw0Sk1yaUN2MTVCdU9RNDQrVXJzWm5GcENwa0hPbWREN1E0dzRaZXNpd3dQcFhudnhmNFNoCmNoenBxcHBTY1dyclFZbno0OHVpSkQ0OUVHUzJ0RDdBZ3dvVlJDSWhzeER0alhiOFBSRjZVSWtBUUJlSnhoT2EKcERUR0tiMzNCQThCT1BVcmwxbDJtc2ljYVBzcWNrM3ZYWUpaYkRZSCt0WkxaNnFZZ2gxZnhQUCtJaFhzMXplbgp5cndiV2tlNnk0UGwwR1JXWCtHcU5NL0NXUlh3YVUwbVZTRG9wZlJvb0VKdzg2bVJtVk85K2NGOFBZUkttaFhPCldXYUw2cXdZU0NmL252NjZSdTRjdmlVNVRvV2w2VnVnRzlZdm1LM2xycFhhS2g4VWdIRkd6MDhDQXdFQUFhTTgKTURvd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZHZG9pVUJucVdxYwpvL05FVnI5YUoxZVkvOVVBTUEwR0NTcUdTSWIzRFFFQkRRVUFBNElDQVFBdVJpM1hNWmRyclNwdTRQRTFTazdWCnBlU2k0dVBEVEpONlc3ckJYWUNEVVZWUjNDNjFWbUpYMVdoZndIeUZMV1grQkpFcmRjMHVHTWNERC9qMDdUYUMKSHIwMmNqaUpjSE9uSCt2ZVVHZXZXNmRaeWx2TXp1RStpZWxPTVlEN3pvcUs5NmwwWTF5U09URDdzWFBUWm9PcAo0S0dabDF5N3ZmSTJpdTJHcVdlUDhBQXB0Qm5JY0VLOW85R0ZQcmhhN25wTS9ROEloNHZCNHFMRi9EVENDRmExCjRMajliV3VndE1GQm1ld09ic3RaeHpLc1NVekFKdk1MV2tMYVNLdXpCWldlWXBWeW4vNEorSmRmeTBJcm1tOXYKaVBMN0o3SHZ2YzJOZFFpK01pcU00ZkJobk1KQ1JBMTBFem1iT1gxUlN6b0NVTnkycFhoYmdkbDFMK2hERm1yQQpvdmNNZ1huNzFJUlU3R0V4VG02UTRtR2ZEZHpuNllEQzQ2R3RBRjVZVlFoVFg1V0FjV1BIMktTNVBKeVJvYmRNCmxmWnhMdytIa1E2dnQzaVloWXFDRjNFU0kyN2hRajFQQXp5T2FqaVl5RGxjREVRRVArWGs3bEtDaXR0UWNMQ0sKZXlCcWJXM0RiZW1MZ0dVa2dWcWRMK2lzN3RVR3pGOGU0a1J4NmRLZkw2Ny9XK0c5b0FyZjExeDBMM1MwWEhybgpZUURNemtXQ1hyZnQ0TVJ6V2p5aWRDYUJ3VlRjSHdZejc0Z1ZUMUIzWlhFYmJCamZBS3RUVFVtcEV4anFuczlxCm1RMzkvV05ybE5ZN014WGJOYkVXSStOeisrS2JnenFFNkhnbUs3SGwxc21JME1PTlpiYTZEQ1NzRHgwb1ZPMjIKMlgvU1VJMk5tNStUd2VkRFVRcktFUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://server.kubernetes.local:6443
  name: kubernetes-the-hard-way
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: system:kube-controller-manager
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: system:kube-controller-manager
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUdSVENDQkMyZ0F3SUJBZ0lVWmFnNXc5OXFDR3JDWnIwY1hPNUl4RnRlVFpJd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1UTXhOVm9YRFRNMk1ERXhNVEV5Ck1UTXhOVm93Z1lZeEp6QWxCZ05WQkFNTUhuTjVjM1JsYlRwcmRXSmxMV052Ym5SeWIyeHNaWEl0YldGdVlXZGwKY2pFbk1DVUdBMVVFQ2d3ZWMzbHpkR1Z0T210MVltVXRZMjl1ZEhKdmJHeGxjaTF0WVc1aFoyVnlNUXN3Q1FZRApWUVFHRXdKVlV6RVRNQkVHQTFVRUNBd0tWMkZ6YUdsdVozUnZiakVRTUE0R0ExVUVCd3dIVTJWaGRIUnNaVENDCkFpSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnSVBBRENDQWdvQ2dnSUJBS2NRTDcxaE9IalhDdGVQd1FTeTVweS8KSnFpWTJvc3VZOGw1WktCaHY1ei90aS9FNVZLVDRNUEJwbkE4akVLK2ZDK2wvc3NjUGdIYXhHWC9sa2o2ZjVGago1bE4wZHpBb283WStIRVROWStvcmlwY1NWTFRlMTJtdytrS0VSVmVwRTF5c1paelB0R2d3aHI0L01RVVRrWTJWCmladDQyakxjRGNKbExHTm1CbzBYU1ZpM0ZldHlWSXQ2NGRRQVZvVnhIM21Lek45SGFMTjI3dUtmU2FIUzQzUEoKLzZVUkphalVya2pQV1RMYXJxWkMxN2t4eDZMazAzVlVsRXpUOUNkY3FoaThHZ1ZscTFWaU0yNTBCUnp6Mml5cwo0TTBRQkhDTFk4bm9aclI5TkxlaW9HVXZJYTBoRFBXalVrenFib3hGVFQyd3NzY3MyVmhkbGhzVXptWTZ2YXFLCnRVVU9Sa0ltQ3Z6aWw0OEE0amZScDhESlk0cVM2Wk54L0ZJd3Q1Ym1YWjZOK0FnSHdMT3pQZUZlVDAvWTBDWGIKRWlrZ0NHS01nZGczYkwydVlqOWtTR0Q4Tm8wRU9jcTVmNFJua2t3Q05qaGd0R1puaXZDbmczWkFyejBiZUdlSwpSNnB0MGZGUUJIeDlCamQydFFXVS8xVjErYWxQVVgwaE9mM0NLczhMTU5rSmNWUTUvTVRBWWNDaEZhanc0ZUg0CmRsdEJhUWRSRGdPcGVWRHpXUHdzUUQvNmFKUUh3QnF2WE9JcUtONUt1RnQxMktxWHh0dFJObEt5dmZKZHhpV0cKRkNkUE8rY0hTYXJuU1FhNGNmdWJ3ZnJXODFVS045WHRVdVROQVE1UTJGOUJFZjFLU2VudjlCMEI0L3NaMmd6agpEYklzT1pIR2p1c1JUa2dTTVlQSkFnTUJBQUdqZ2U0d2dlc3dDUVlEVlIwVEJBSXdBREFkQmdOVkhTVUVGakFVCkJnZ3JCZ0VGQlFjREFnWUlLd1lCQlFVSEF3RXdEZ1lEVlIwUEFRSC9CQVFEQWdXZ01CRUdDV0NHU0FHRytFSUIKQVFRRUF3SUhnREF5QmdsZ2hrZ0JodmhDQVEwRUpSWWpTM1ZpWlNCRGIyNTBjbTlzYkdWeUlFMWhibUZuWlhJZwpRMlZ5ZEdsbWFXTmhkR1V3S0FZRFZSMFJCQ0V3SDRJWGEzVmlaUzFqYjI1MGNtOXNiR1Z5TFcxaGJtRm5aWEtICkJIOEFBQUV3SFFZRFZSME9CQllFRkJPbUxoT25aZDl2dGRCVmQ0aGxHd0tuMmw5Tk1COEdBMVVkSXdRWU1CYUEKRkdkb2lVQm5xV3Fjby9ORVZyOWFKMWVZLzlVQU1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQ0FRQnJHNjV0bHRHNwpaMmY2cThpY3JXaUFGekVwdWZBS3JuTmIyM1lhR2drQ3l6VzU5TDlYS1I2bVBGdjhIK2x0WjViRnQ4MlVBSDVQCmQxWFBOZ0szYjA2M2pFYmxGZFovY0dWZm02YWN2VVBLZ2ZnTEduWW11M2ltdDRaUXVNWE05ZzB6bWp4UzNGZzMKK0QzVzNvSEFNNHhzN0U5UllEWU51clR5VkJCMlcxckFhT3hSZFVYU2JsWXFBbVovTjI0OVJnT3VvV0ZHRE85MApOOS9qZm03Y3MrYmpUQzBXaFA1dTFkYTlpczhudVlNOUlRZ0JnY0VlUjFOTkhSYXd1WHJmUksyMTI4cjVKd3MrCmVoZkJIMTJlTlViZmkzR3FObkh0eFRhQUI3Z3piMTNRLytBeHBMUXNRU3NhT1NzZm45RGVXdTZ1aDZZWnNocEQKbjdSVHZBdnBzQytscnVwdGU2bGtJejVPMytZeFNzcFBHTVFoL055NGxXUUdSS0ZkbGdieUR5Rk05UHdDVTNmbQp5c0hLUzh5RGxKc2NLYUdRT08zeldWNTlJa3FnelZDa3l1UkEyZmw3SG9JYXFuTDNKR3VaRVpiM3FxZUdJMUFUCnZHVkZLTmJIcEpiZUgvWkxrM3pVZm92T0N4Ujh1ZVEzVm9CSG5HM3RTcWJJL3VoeXUxOUFEYStVUEpFbDd2OHkKc2FaQ1BWSUU1L0J4MnpVY1RsanRLZnNmNlBLQWZxdU5PZExVVTBHbUUxSWkwOFgwdGFCY1NBNEhRNExPK1owYwpGdkg3ZndKUkRHSWlNeVFXYjZObUtHVThlYTl2WFdrWTB4bGs4c2RkbkZJbnZqd2hqQUJZdXRnV0NvRWhvZUdwCjZRTWM1U1J4OE5rTHZWSndvd2lYcm01YWFMTnVxRHl0eUE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    client-key-data: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRZ0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1N3d2dna29BZ0VBQW9JQ0FRQ25FQys5WVRoNDF3clgKajhFRXN1YWN2eWFvbU5xTExtUEplV1NnWWIrYy83WXZ4T1ZTaytERHdhWndQSXhDdm53dnBmN0xIRDRCMnNSbAovNVpJK24rUlkrWlRkSGN3S0tPMlBoeEV6V1BxSzRxWEVsUzAzdGRwc1BwQ2hFVlhxUk5jckdXY3o3Um9NSWErClB6RUZFNUdObFltYmVOb3kzQTNDWlN4alpnYU5GMGxZdHhYcmNsU0xldUhVQUZhRmNSOTVpc3pmUjJpemR1N2kKbjBtaDB1Tnp5ZitsRVNXbzFLNUl6MWt5MnE2bVF0ZTVNY2VpNU5OMVZKUk0wL1FuWEtvWXZCb0ZaYXRWWWpOdQpkQVVjODlvc3JPRE5FQVJ3aTJQSjZHYTBmVFMzb3FCbEx5R3RJUXoxbzFKTTZtNk1SVTA5c0xMSExObFlYWlliCkZNNW1PcjJxaXJWRkRrWkNKZ3I4NHBlUEFPSTMwYWZBeVdPS2t1bVRjZnhTTUxlVzVsMmVqZmdJQjhDenN6M2gKWGs5UDJOQWwyeElwSUFoaWpJSFlOMnk5cm1JL1pFaGcvRGFOQkRuS3VYK0VaNUpNQWpZNFlMUm1aNHJ3cDROMgpRSzg5RzNobmlrZXFiZEh4VUFSOGZRWTNkclVGbFA5VmRmbXBUMUY5SVRuOXdpclBDekRaQ1hGVU9mekV3R0hBCm9SV284T0hoK0haYlFXa0hVUTREcVhsUTgxajhMRUEvK21pVUI4QWFyMXppS2lqZVNyaGJkZGlxbDhiYlVUWlMKc3IzeVhjWWxoaFFuVHp2bkIwbXE1MGtHdUhIN204SDYxdk5WQ2pmVjdWTGt6UUVPVU5oZlFSSDlTa25wNy9RZApBZVA3R2RvTTR3MnlMRG1SeG83ckVVNUlFakdEeVFJREFRQUJBb0lDQUJMaC9mdGlVejg1VXlUbFB6UllRaitpClRXek9CaG1vTHlnMUc5NFMzbFVSQkJjbklxSndTMzNrMC9xb3BWUGY4dXB4MFRoRTQyOVRPbEtyRG1JR1NrZjEKS2pIeG5vMG5jc1dsQkkzMFJ5QlBOcFYzd1hKR0k4UHkrSDV2TStWQ0c0bWtoTUd5S2xxQ2JhQndSUXFsV1JUUApPNlFDaDJzck96VG5PWnFzaS80RGpVdEZPbW1IM1MxOHdLeTFNeEpYSkc4WTlLb2lDS0FNUjlqK2x4Uis0UzJUCnZkejY4SzVDQjhiOEJNRitQVEpXcU1wcWFYMnNib2c2L0o0b2NOYklId08zc3hzOEVCOFEvKzR5bCtkYldxUWwKRUMydGEwc0xQa2F5aVhWS0Y1elArV0FtY1NCLzlWYUlWTU9UMWRYdCtWcUpMOVBhYW1DV0IyTGRPYTBOWTZXRgowVXhnaFE5MkxmRDJVeUhtNE0rU3ZPalJFT1N6YWxubUFkUXFrcXpvVHVjdFBhaHhuNTRwakVPVS82SVBXcVJiCjJRUTIvQUpzYUliWXBrTkxEcW1jQXFPWUJWT2tGdUQ5bG9DRWppeUh5QnRiZFY0S1FURlR1S0l3WWlTVTV2UkwKNDIrOHJlUEwyblUrczJ3c3l4NG9ySzhHb2tGS1I1TFRuSVJCbVB3WjBiWldMcU5OaU5mUFZ6NlNXODlZMEZkbQpmWTAzK0dpbGZ5aXdiUk9zUUtxQk4xcEhQaXBWeDduWWR4b3cwaUR5Nk9lSjdPTjg2ZEFoS2o4VkJweHdqTDAwCnZhOVQrZUxzY29MbUYvYTdJb3I0YWlxc2MrRWdEbndldTVoUFFqOEwvS211cjVHMk5GZGpEbW9kSlkrNWFvV2IKdFpHcFRPRmxyUkZWRTRxaTZCb0JBb0lCQVFEU1lXMEFqRXFjaTJQVGp4b2hsYTRBU0VKQmkyd3FCUDhUYWdhUgpiZVk4MGJ3WDRVZkpEckNVenVWdTFUNW9DZlRYMXdiWGVYc2RrUUFYOGdIUHZwZWgrNVFCM1VmNEFGNmNIUGxoClRoQ2ttR3l3RmN2MjRLWGhOdnlDaWFjd0xpUUNRYWZkSjdSY005SGRxY2xzb284eFMyY0RiaEhqam1HL2NVc3QKV0pOS3RNQVNYcHdGbzJiOEpJUVhTdXU5UVp6V0RlbzNmTExrcUtxVmY4a1Z3cnJqSzd3azNFMkxuaHRiY3hCRAo3Tlkxd0x0Nm52U1M2TWJpaitaNXN4c254RXlPY1F4YVNLRDJXNUtSUVhINWtzYlVuWkl5bzgyU2lNOXRMNzBMClRmS2RyZ2pDYmc2UDJFV3pQRHZTZTRreEczdXRQWWM0b2hqeEtlQk9aYmQrc1hwSkFvSUJBUURMU2lTdHNBT3gKbTdDZWdQbW1WbU8yMldKTDI5djV2MTJIUFg5Y2ZWdDVPSzdYY3VvNW5PdkVwbnQzN1llVk5kUXJMNmh4a3BybgpiemhDOStTdzFRU1VlNUxQQTRXWE5IWFR3WXN0a2tnZXBPU1NENlhPVkxQV3N0Z1cvTzF3alBDS3Z1SFEzMDRlCnZ4L0dJWS9aTWR5SmxlaldlMW5pN2FEN25URVF2bFpuY3RBWmxPeFpVcUh0ei84b0trNXpoU3IrODVhamlUbm0KOTlic2V6SGV0emRJMTlpSlQ3M1dseUgzbHRxeWlpVG5PNWFOYnFSWlFHWjZOdXpQUDdOaWFQdFIrc2ZSZDZ6RQpBTEdFaU1WUXpyZTFVbkJsZGxZOVYrVUZwcG5sQ08wajIxMElIQkNzY2drc0EvMi9IaTVQdVRFL1lVbXlZRmU1Ck90Z3lHN1NmbzcyQkFvSUJBQmdWM1ZQVnUra0dNRXlWTW9tcnlEcnlDdHZVS1hMNkZYWFVpcUgxc2drK2ZjbEMKR21UVFVMWUlwYzIxamlwOUVWSHdwVERnRUk5Ry9YckFVeUxFa0RtVVF0S2YwZEI3d2xrZkhCSGV6UnI2OUY2SQpjRXg0VmFWZUZUU2dxOHBoVGZBUU1qYW9pQWFTVERHVGNhTUZUVjE0WTNmS0R6UTlKY1cwSThZeVFOS3B0TitsCmd6bEdCdEZSSU9wRndvMXRTSlpkQzNhRXlUcFNjUTBpanhQMXNrMjF3Umw3TzBtRHRXQVg0VUhWaUlTbzV3M1gKeXVwU3lncEFMVU83bEoxTjVQSGQwV3M0cTJ6bytQTzJTV1VvUDZreHpQNE5NTWpZN3Q1eU83TmluaWNkT0pXQgo0aHJueUxzSFoxWG1uTU5KZ1RSSk9nVHEwZTR5UENMZGxFOWw1RGtDZ2dFQVpNWlVlR1dRN3pLbTAyeE1WZER0CmpXOGw4MFVDUDBSR01ReWpYazRtVW1sdkF3N01YZE1VYlYrNlJURlN6UHpxT0o1ZmVpMmE3SytOekdUbTBXSkgKNnZOM1MzZ0xlWEZnRjZFU1JYMEdrMnBhaEsyTkhFT1JBeFdWV1kvNGhKclpnMjRzczBaL2kyNWphZXlwU3BvVgpJWDlXOVR3Z3l3WFJqK25Vc09BcUpRNGRheEVRT1JkbGZtWmxycHVLV0duamJvK0NWWDlwWEwzdnBUdE05WU1OCnZPYURTVTVtWlVKMmJDNDBLOTJmZmFGa2VLZ29nTFlVRnZHell1bkpHemUvbmx3YlFoTjVhWkNPYjR6OWc1bDIKS0VTOXd3NXVvZW80ZGh5b25ZbFhSVGN4WHh2S2lESGZxaG93WjlXbVQ0OFdncnpQczhWZXQwd2NjSHFiaDZlOApBUUtDQVFFQXZUc2EwWmtiWWYxM0hwcjNyYlYyT25naXFTbjRiVHNneEw4cWJkNEJ0V0lDUXZyOEN1czBrNDZOCiszdm5JVG1yME1sWlRoeUROTXZMcDIwcGErVVdBejBzd1pLV29EN2JxdFVhdnFLK3ZRYTM3eGd5cjZlYnMvbkcKZllQQnZGcDIyVWg3SUN3cTd2UzVqZHlSeVVYa0k3dXJhL0NNbngxb2FFMnpqUjdFL2Fpemd4YUhxb3RQUDVXegpURmQ0U0o4N2hKM1puL3NFQTliWFBPVkM3dHdRZ0hkZGgxSVBZTWZBQzRKb0dPejJZT0Vmc2lDclVybnZQelpyCmIwY3BhY3AxN2NIV3l0SzgrelVRMHJ6NDNVYmdDZEVTZDFNeXp0SXZjSlA3MXZYZFdvMFJtbEg5R1JLcXZxdG4KSzdSN2dUb0p5NmtTc0ZTR0RzSUcxQ1F1UmpkTEt3PT0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=
```

### The kube-scheduler Kubernetes Configuration File
```bash
# Generate a kubeconfig file for the kube-scheduler service

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://server.kubernetes.local:6443 \
  --kubeconfig=kube-scheduler.kubeconfig
Cluster "kubernetes-the-hard-way" set.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-credentials system:kube-scheduler \
  --client-certificate=kube-scheduler.crt \
  --client-key=kube-scheduler.key \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig
User "system:kube-scheduler" set.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig
Context "default" created

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config use-context default \
  --kubeconfig=kube-scheduler.kubeconfig
Switched to context "default".

# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat kube-scheduler.kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZURENDQXpTZ0F3SUJBZ0lVSEZjTnZpeGtuRnlBRm15M053VWZETGtmaHhzd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1EZ3dOVm9YRFRNMk1ERXhNVEV5Ck1EZ3dOVm93UVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01DbGRoYzJocGJtZDBiMjR4RURBT0JnTlYKQkFjTUIxTmxZWFIwYkdVeEN6QUpCZ05WQkFNTUFrTkJNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QQpNSUlDQ2dLQ0FnRUF2RVJWR3k3dWJFaU9KdmNnVnkyUm5VNjhMbXVGSVI4NlgxVnRSM1BOYWlEWHVaWVkrcDk4ClJ6dVI4YjQ2TXdLMXB3SXc2VnJJOWU3MmQxMmw0UXJNZHJUdXMxTWY1ZVpFMHE1N3pPWUR0Ry9VOUxHeER1djMKYms1bThjZ1p4SThMR0o0UW02bjZXUmRVMFhVbEhBcTdzNVdyam5YUnpoZmZRcG5wM2ZHTnBJM2tRM21UWUdydwpXbFk2VUQ0ejlZeDJxa1dHdGFkRndVVVdXbHhBOWlGRlpRYUt1OFZPbnhIZkZpckowSmxnaTBJaTYyYXhyd2lOCllOK3luR2NEZDUyelhONldDc3NJamQ2V3BGb1JzMW1kY29QdXFlRzhwSk1tRFpldTlSN0IxNENoQUl6b09wRWoKY0N4M2Q3NTdubnVnSEtZa0xQWlIxQXVIMERKYngvblB2d09WZXhQVEpVbnR1eTFmenVrMnpaSXlMRDBHa0tlVwpzRTg2a1JEdEVwcmw0Sk1yaUN2MTVCdU9RNDQrVXJzWm5GcENwa0hPbWREN1E0dzRaZXNpd3dQcFhudnhmNFNoCmNoenBxcHBTY1dyclFZbno0OHVpSkQ0OUVHUzJ0RDdBZ3dvVlJDSWhzeER0alhiOFBSRjZVSWtBUUJlSnhoT2EKcERUR0tiMzNCQThCT1BVcmwxbDJtc2ljYVBzcWNrM3ZYWUpaYkRZSCt0WkxaNnFZZ2gxZnhQUCtJaFhzMXplbgp5cndiV2tlNnk0UGwwR1JXWCtHcU5NL0NXUlh3YVUwbVZTRG9wZlJvb0VKdzg2bVJtVk85K2NGOFBZUkttaFhPCldXYUw2cXdZU0NmL252NjZSdTRjdmlVNVRvV2w2VnVnRzlZdm1LM2xycFhhS2g4VWdIRkd6MDhDQXdFQUFhTTgKTURvd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZHZG9pVUJucVdxYwpvL05FVnI5YUoxZVkvOVVBTUEwR0NTcUdTSWIzRFFFQkRRVUFBNElDQVFBdVJpM1hNWmRyclNwdTRQRTFTazdWCnBlU2k0dVBEVEpONlc3ckJYWUNEVVZWUjNDNjFWbUpYMVdoZndIeUZMV1grQkpFcmRjMHVHTWNERC9qMDdUYUMKSHIwMmNqaUpjSE9uSCt2ZVVHZXZXNmRaeWx2TXp1RStpZWxPTVlEN3pvcUs5NmwwWTF5U09URDdzWFBUWm9PcAo0S0dabDF5N3ZmSTJpdTJHcVdlUDhBQXB0Qm5JY0VLOW85R0ZQcmhhN25wTS9ROEloNHZCNHFMRi9EVENDRmExCjRMajliV3VndE1GQm1ld09ic3RaeHpLc1NVekFKdk1MV2tMYVNLdXpCWldlWXBWeW4vNEorSmRmeTBJcm1tOXYKaVBMN0o3SHZ2YzJOZFFpK01pcU00ZkJobk1KQ1JBMTBFem1iT1gxUlN6b0NVTnkycFhoYmdkbDFMK2hERm1yQQpvdmNNZ1huNzFJUlU3R0V4VG02UTRtR2ZEZHpuNllEQzQ2R3RBRjVZVlFoVFg1V0FjV1BIMktTNVBKeVJvYmRNCmxmWnhMdytIa1E2dnQzaVloWXFDRjNFU0kyN2hRajFQQXp5T2FqaVl5RGxjREVRRVArWGs3bEtDaXR0UWNMQ0sKZXlCcWJXM0RiZW1MZ0dVa2dWcWRMK2lzN3RVR3pGOGU0a1J4NmRLZkw2Ny9XK0c5b0FyZjExeDBMM1MwWEhybgpZUURNemtXQ1hyZnQ0TVJ6V2p5aWRDYUJ3VlRjSHdZejc0Z1ZUMUIzWlhFYmJCamZBS3RUVFVtcEV4anFuczlxCm1RMzkvV05ybE5ZN014WGJOYkVXSStOeisrS2JnenFFNkhnbUs3SGwxc21JME1PTlpiYTZEQ1NzRHgwb1ZPMjIKMlgvU1VJMk5tNStUd2VkRFVRcktFUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://server.kubernetes.local:6443
  name: kubernetes-the-hard-way
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: system:kube-scheduler
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: system:kube-scheduler
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUdJRENDQkFpZ0F3SUJBZ0lVWmFnNXc5OXFDR3JDWnIwY1hPNUl4RnRlVFpFd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1UTXhORm9YRFRNMk1ERXhNVEV5Ck1UTXhORm93ZERFZU1Cd0dBMVVFQXd3VmMzbHpkR1Z0T210MVltVXRjMk5vWldSMWJHVnlNUjR3SEFZRFZRUUsKREJWemVYTjBaVzA2YTNWaVpTMXpZMmhsWkhWc1pYSXhDekFKQmdOVkJBWVRBbFZUTVJNd0VRWURWUVFJREFwWApZWE5vYVc1bmRHOXVNUkF3RGdZRFZRUUhEQWRUWldGMGRHeGxNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DCkFnOEFNSUlDQ2dLQ0FnRUFzNUFEYVIyOFZhdmpURlRMOHlaOWlkRDhYV3ZhTW5pTThOMEN6VnhIN3N4eUFDQ3EKZUREdittQVRpdmhmV1MxTGZqZmJ0YWpFajJLRnNpOWwrQWpPMmNzRGQxKzF6Q28xSDM5d1V4aFc5cUJSWVZaKwpVY1c1ZDViczMvNnlhN1Boc2pRd0RKdER4YUVPMlc5MXlOWXg1YjRkNU42NUdrb3lqK2pUdVRObnJSbkJSNWVWCjhpU0dqWnV1cUM4Y3IyMnlMaDBpK2ZRTXA3S2JLRmQyMXFIYmszZTZxdkNwajkxb3h1aXIybFdMYklhbk1EVnkKczRqaGY2V1NJUUY3cWZRTUVDbFIwSEZra3I4WDQ0cG1FL0ZueW9ROVczOGRQMjg0ZlBjZjVBVDF1dFZweTVVOAp0ZWV5Z0R2SHVNQzk0TDlZMVpzMUVERHozaHlzRnRTUi9vSXF0UUo3emczWDc2RXVsdHkzQ01zQkpJSDU2WVlsCmN0Zmp2bkNMSkFIc1p5RDZudkw0Y0ZldzBRSHh6V1c2VFk2aTVWTDIrVy9FK2xiaTlmRjc4alhOcVNEZnpHYzYKK3ZGZW52dkxhRU9ibDk5L1oycHJFRUFYS1VyWUwzd1RQZkJYaWk2N1h6YzViTWV1UkNVWGh3WmhPT1N4Rk1wYQpDOTJRWUdsOWZ6WW5IaUVhRklxV2RqSjBLRHJ1YXNreGZqWGk5NzZwT3d1OGxhdDNRK1l5R3UyY1o1cFdPOTJ1ClR3ckE4Mi9UUk1RazdBODVUN2ZyZjIyNGVwblQwTVQraTNZdkgrekZSbk4zVDFzbDZpL3l0QXRicWZiTTB0bFMKdThlNU5FOWxWcjZWbkgyYlIzREMvclBlRjRjZitGSEpNaFFvUzdRSUNUY0FCRldicGtES0tPOUkySmtDQXdFQQpBYU9CM0RDQjJUQUpCZ05WSFJNRUFqQUFNQjBHQTFVZEpRUVdNQlFHQ0NzR0FRVUZCd01DQmdnckJnRUZCUWNECkFUQU9CZ05WSFE4QkFmOEVCQU1DQmFBd0VRWUpZSVpJQVliNFFnRUJCQVFEQWdlQU1Da0dDV0NHU0FHRytFSUIKRFFRY0ZocExkV0psSUZOamFHVmtkV3hsY2lCRFpYSjBhV1pwWTJGMFpUQWZCZ05WSFJFRUdEQVdnZzVyZFdKbApMWE5qYUdWa2RXeGxjb2NFZndBQUFUQWRCZ05WSFE0RUZnUVVUSDNaTzNwUTFtU0ZUNzVka2hNdVVzaEdPYW93Ckh3WURWUjBqQkJnd0ZvQVVaMmlKUUdlcGFweWo4MFJXdjFvblY1ai8xUUF3RFFZSktvWklodmNOQVFFTEJRQUQKZ2dJQkFMYzRZSzAvL29PT2lPcEZMOVVnNll2T1lPckhpenNiUUlubmlQZnZaZjdLZUt0WmN4dU8vTUkxT1N5NApWcUtWU0tjQnhKcFhkeFBoMWRBdnVGR1dCWldab0R2STZTNkg5OERZUWR3a1hGRjhGbFlnckZSQVU0ZVU2d1dwCml2anNSVGNONVg3VXd0eTB3TEMxOGQ4Ky9TWlBGNUpEbVFPYVpKMm1vZXhxbGJhS01ReW5qVy93WVJ3Qjlnb1YKdWpxNGlBV1BLMnBNaGFveU1IQy9Cbm1vTlErazByWDNBS29WWC9qZUpzcXRuOFhESU13dGZ1dXo4bnhMNDR5Qgo0Sk8vdlUxMDN5YWhNNXV0SkVYcUpSS09hRGFrb3NuVGRucmdLd0VZRFlrL09KdXdONGRrbTgxdzRMQ09QNW1uClV0RmR1SWpjQ3JSQitqekpwb01GSThZQW56U3BQTWR2VjRXRWxNamRKM3BvVzRMQkIxaG9vQS94QUJ3UmM3SHcKZ0RKSzBjZGxDZ2U2U3UxTE92cU1RMDRyaDF1VFJmUlVDZWFkZUMwQWZ4YXI3S1UrVk9uN0JRaXozazlWbW0rSApwYXErUFNhUTF0Y04xbXVzY1RCNGpMRjF3Y2h6Mmlud242d3R3RllBN1RERmZPaEx4SmsxbGdEZGNCTkJMZlplCkVVUkpkL3hlYncraUZqemd0KzMzcWpqeFIreHpqMklQNzQ1QkpqSzdUU2c1emN4SmRSaDZEa3ZhQmhtaEp5UjQKVFpSZVQxYVFaN3RHZ0VWWDZlaGtqNWd3MzBudWttRmUzYVVWR0lZcEpiL3poNWFGSnFSVDdGQzlWT3p2UGlKSQo3U0NDWS8zK0lCQkFlRkFaSkpFVkI5V013bTB3S2pCaGFsTkNuLzhzSURFaWZiSDkKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    client-key-data: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRd0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1Mwd2dna3BBZ0VBQW9JQ0FRQ3prQU5wSGJ4VnErTk0KVk12ekpuMkowUHhkYTlveWVJenczUUxOWEVmdXpISUFJS3A0TU8vNllCT0srRjlaTFV0K045dTFxTVNQWW9XeQpMMlg0Q003Wnl3TjNYN1hNS2pVZmYzQlRHRmIyb0ZGaFZuNVJ4YmwzbHV6Zi9ySnJzK0d5TkRBTW0wUEZvUTdaCmIzWEkxakhsdmgzazNya2FTaktQNk5PNU0yZXRHY0ZIbDVYeUpJYU5tNjZvTHh5dmJiSXVIU0w1OUF5bnNwc28KVjNiV29kdVRkN3FxOEttUDNXakc2S3ZhVll0c2hxY3dOWEt6aU9GL3BaSWhBWHVwOUF3UUtWSFFjV1NTdnhmagppbVlUOFdmS2hEMWJmeDAvYnpoODl4L2tCUFc2MVduTGxUeTE1N0tBTzhlNHdMM2d2MWpWbXpVUU1QUGVIS3dXCjFKSCtnaXExQW52T0RkZnZvUzZXM0xjSXl3RWtnZm5waGlWeTErTytjSXNrQWV4bklQcWU4dmh3VjdEUkFmSE4KWmJwTmpxTGxVdmI1YjhUNlZ1TDE4WHZ5TmMycElOL01aenI2OFY2ZSs4dG9RNXVYMzM5bmFtc1FRQmNwU3RndgpmQk05OEZlS0xydGZOemxzeDY1RUpSZUhCbUU0NUxFVXlsb0wzWkJnYVgxL05pY2VJUm9VaXBaMk1uUW9PdTVxCnlURitOZUwzdnFrN0M3eVZxM2RENWpJYTdaeG5tbFk3M2E1UENzRHpiOU5FeENUc0R6bFB0K3QvYmJoNm1kUFEKeFA2TGRpOGY3TVZHYzNkUFd5WHFML0swQzF1cDlzelMyVks3eDdrMFQyVld2cFdjZlp0SGNNTCtzOTRYaHgvNApVY2t5RkNoTHRBZ0pOd0FFVlp1bVFNb283MGpZbVFJREFRQUJBb0lDQUFRWGRpSnZMMmRXM0Q0MUtQUVVscFA5ClA0RHIrQndDRC9rZG1pYWVrWk9ORkZSeEtoMUV4VFVqK3hJRnZKdDZPeUFJU3hFQnhGL2RqMzBhMUNTaG84QUYKL3FGWjNKbEhSWEJmTGFxeEVXczdoanMwOXJvcmlxRkJYc3F3WWJXdlVzZG1KY21sd0phNFo2K1grUHUvZU1IYQowaERRNi9BZnpIVG55ZXBNay9KWGRjWnBPMzBaN0xoOW1ZNWl5M0VxYTE3ZVlsbUdnSUxTUUxPYndaMGNzVldVCkN2eUI4U1V5ZHdTZ1VPa3YzWlpXbjZqck1ON0xNZE5BTFRza0R1SzFxVkExZHRRc2YwMlNQZXU5RDd3bzJqUDgKelM2Z2NBVE41cUEvVzlwTTdDSUtvcWRsVWsyMVZzV1NCeWdzT1M5dHdNc1dSekJrSXl4MnBBdTlvb21GZ3c1VQp1KzVnNmV0ak5kQ1QweUxaREZ6Znh2M2F6L291VHJiWDRyK1B0amJGTTQxQW1mNlZtQkk1bysxS1EzTzlNRjFFCmlZWHJkZ0RscW4vSEdQV0k2OFNHVmlYb2F1dnk1YXg3TWdtck8zbi9kbVVpT2QwV29lUC9wQklpdHUycnBrMHkKYm16dnVmaGlpbWJpMnp4V3Yrd2g1RHNkQ1dnZ0p6U1VDMXRlemFZbXRPMTJBUzdJRWhwVXNWYzEvTDlObUF3awoxOWwrYk96R3FvQUNKdlZMOHZMM3JvUy95UUZGSkNENCs5bHQ2WEFndTFXK3FHcGJKeklqKzdYS3VkcGpNMW4zCi9xZ3NDK1FKSjd0Z3IvbzdrRFIvR0dTRkl2bDhGRGk2WTBxM2VoeVl6ampiSGlMR2o4RmxqSEdMWkNTR2RyTjkKRnhuVUsxUytEM3FWcVNVeXVJUVJBb0lCQVFENHdnZXpyVzVOekhBcWk4SUFGSVV4bm9JODdxUm9TYU5hYmtVZApMU0U4REJ5K0VSWThHY1MxdlZtSnQwQmVJc3RQcytqNHZwTzdUbVlhWEloWlpPeFVXbG02Qm1vdGJSVTlXSHBjCjVjcGpTd24yRUpZK0NXMmczR3UzcldKb0dFN0VyL0dOaFZWcm50OWc5UkhrY05PbUVQT0IxSUo2aytRT0ZBUlgKc0hTWjUyWjIzU2tlcGpwM1JuWGpuT0thMU40bWl5d3hhaFhlY0xnaDFEVzNrd1VqRjBnOC9kWXlIMjBlazI0bApvdUl2aUZlZUE1SVFVNTdSZmhaNDRNOW1qc3NKVHkxUU1xUDlFd0liRXp4UDU2SU9tV3hHdTg1R2lmc2tYVWNDCmduM1p6U0RpS1ZRNTJVSlFEWHJGK2V2R3p0M280QjhuREY1dkRNRk9xTEhJSjVseEFvSUJBUUM0eWtiR2RHeEMKM3VCKzFYaUVUZkNtNG9Gd3RwVWhyN2ppNGx3bG12U25aa3lHVkovTVBLeW1XUVZIcFY0MHREak0yVzZKVm0vcgoySXFDZG9uVXBLalBaK1pWWVQ2STB2c3ZRNU5IWThJamlGTWwrR2xBaFJCOTcrT2FZMWxIbFFqWTN0d0RLT3M4Cno5UlJta1ZPenFxcENmREViNmI5WjE4bW1tb21MZnlBSW5rZVpFcEZDMVkzeEN3Zjc2Qi9QdW84VjY4eHJUWlAKQzhtUGgvZWN1R0U0MUIrbktPNC9HRzR4RFY1eS9UTWk2czZwSlZ2YmJLYWNTSHNkLys0bWcyVnZsQ2VMbkppQQp3MERPb3FzM2Q3VE0vQjQvaVNEM0p5Z1h1TEljMUhrWi9YcVBpMlJKb1JKR2pKZXNlZ2JyNEtYSEhMTXVpNEIyCmp5Qm43SG9SanQycEFvSUJBUUNqQ0VlVDh1NS8vcVRrdllRQUdYTFIrbGpSSm5hS0F2a1VvNENZaHFOcGYyYTMKQ3V2UHAvUE1TTFVPRlJRU25pc3hxVy9lMXNocjBnNEk2T3hUNmxrWlQ3M090YldRNEJVemgzRnF3US9MMDdwTAprc05sRlRqTVhLb2NUMzVYU3RjVkFWc0dyWVEyYklGcVFqUGZ6REpxZkdHYmpYT1djcWJjc3pIRlp0aUVwYXY1CjZ5aXY5YklMeWhvcGV3RHBDT292eUxiR0RBa1pLRGNGdE5jZjRUTlV0RVdiODZFV2FKSlRuN3hvM2ovdmR5UTEKWTVHdk1aNjlIaTRNT3dxeTVKTWRIczlMNkdTaDBIdG8wMHFMOC91NkpjTlkrRzFRdmMzakgxOFN2Z05OWTZ0UgpqbFN0TlQ3SXlJeldnOTJMQnJsWmpzbmNCYmMrZ05XUWYrOUVodStCQW9JQkFFaWxISlhBQng5eXh3YVZuVDlGCjlLbG11a1E1UXY5dk9WdllhU2xQZFlhcHJNUFNXTS9OdW9IYTFUeUpRak90OWZaeU5BWkJ1TllhMXJqYktPd3oKbnptS092NnRzQXZTQlhWYk4zY0ZQTGtEU3N6T2ozSVIzWjNreExGWkJTd2k1c3Q3TVRyOHh4MnRCbWJlSXdrTQpMZ011S1R6UU4vRyt4YVZEWngrRFRKU0MrT0o5d3NUSjVDY2dNOGlLUjZvK2JZOHpXV2hLRStPWFdySFdYZjE2CmJwNE1walRzM2x4bm1rb21XMDhSUXgwaStnTjg4Rk9lcnhFWlhXMDV3OEhZUGZSVFpnaDRrMnRyVnZyazhESnEKR09YTTU0ZEt2VzdzTWRMQmhTUFlVNU5vRnRwL2pmbDBITjhuUGlsTC81U1RTQml5cTY1TW9ULzZuRjYrbEc1NgpuNkVDZ2dFQkFLMUxIbFFEZnNJNW94UnU4eHZ1TXhMM3JjUkplTmlWaFBRemloYXBkSnRPdzJ6dzRFTXN1ZHJuClRRdEpnRDNnRzFxZmFQcVlBOFEveFpramhUY2NONXJsdlJ1Wi9qbnBUUS9HM1NVVS9GNEE5QjdtWFVMTUwzbVUKREkwTVEzVDUxZGpNRTB6VDhSYVkrNE5sZXhXUnkyTDZnK0ttTk5xcGoyTDJGOVg1N2VPdzFvN1FrQWVaUm9iagpNZjJKVzd1clVzMUdDbWplVU5xSEE5Z0NaTG1iWDg4MVdvTnNTaGxQVElHZHRvRkRjUG9JajhwN0pTUlB5eWtGClZOT0tKWVFSMW01UTd6VkduNXVxRkNHSUVTY0djcXJza3ptMVhONityNjkyUlR1ZlpEallhTVBQbDZabEhrM0EKN1c5Qmc5SHdSTVJoL0w1YnNqVjZ2OUg1dkpBSlVmWT0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=

```

### The admin Kubernetes Configuration File
```bash
# Generate a kubeconfig file for the admin user

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=admin.kubeconfig
Cluster "kubernetes-the-hard-way" set.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-credentials admin \
  --client-certificate=admin.crt \
  --client-key=admin.key \
  --embed-certs=true \
  --kubeconfig=admin.kubeconfig
User "admin" set.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=admin \
  --kubeconfig=admin.kubeconfig
Context "default" created.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config use-context default \
  --kubeconfig=admin.kubeconfig
Switched to context "default".

# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat admin.kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZURENDQXpTZ0F3SUJBZ0lVSEZjTnZpeGtuRnlBRm15M053VWZETGtmaHhzd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1EZ3dOVm9YRFRNMk1ERXhNVEV5Ck1EZ3dOVm93UVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01DbGRoYzJocGJtZDBiMjR4RURBT0JnTlYKQkFjTUIxTmxZWFIwYkdVeEN6QUpCZ05WQkFNTUFrTkJNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QQpNSUlDQ2dLQ0FnRUF2RVJWR3k3dWJFaU9KdmNnVnkyUm5VNjhMbXVGSVI4NlgxVnRSM1BOYWlEWHVaWVkrcDk4ClJ6dVI4YjQ2TXdLMXB3SXc2VnJJOWU3MmQxMmw0UXJNZHJUdXMxTWY1ZVpFMHE1N3pPWUR0Ry9VOUxHeER1djMKYms1bThjZ1p4SThMR0o0UW02bjZXUmRVMFhVbEhBcTdzNVdyam5YUnpoZmZRcG5wM2ZHTnBJM2tRM21UWUdydwpXbFk2VUQ0ejlZeDJxa1dHdGFkRndVVVdXbHhBOWlGRlpRYUt1OFZPbnhIZkZpckowSmxnaTBJaTYyYXhyd2lOCllOK3luR2NEZDUyelhONldDc3NJamQ2V3BGb1JzMW1kY29QdXFlRzhwSk1tRFpldTlSN0IxNENoQUl6b09wRWoKY0N4M2Q3NTdubnVnSEtZa0xQWlIxQXVIMERKYngvblB2d09WZXhQVEpVbnR1eTFmenVrMnpaSXlMRDBHa0tlVwpzRTg2a1JEdEVwcmw0Sk1yaUN2MTVCdU9RNDQrVXJzWm5GcENwa0hPbWREN1E0dzRaZXNpd3dQcFhudnhmNFNoCmNoenBxcHBTY1dyclFZbno0OHVpSkQ0OUVHUzJ0RDdBZ3dvVlJDSWhzeER0alhiOFBSRjZVSWtBUUJlSnhoT2EKcERUR0tiMzNCQThCT1BVcmwxbDJtc2ljYVBzcWNrM3ZYWUpaYkRZSCt0WkxaNnFZZ2gxZnhQUCtJaFhzMXplbgp5cndiV2tlNnk0UGwwR1JXWCtHcU5NL0NXUlh3YVUwbVZTRG9wZlJvb0VKdzg2bVJtVk85K2NGOFBZUkttaFhPCldXYUw2cXdZU0NmL252NjZSdTRjdmlVNVRvV2w2VnVnRzlZdm1LM2xycFhhS2g4VWdIRkd6MDhDQXdFQUFhTTgKTURvd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZHZG9pVUJucVdxYwpvL05FVnI5YUoxZVkvOVVBTUEwR0NTcUdTSWIzRFFFQkRRVUFBNElDQVFBdVJpM1hNWmRyclNwdTRQRTFTazdWCnBlU2k0dVBEVEpONlc3ckJYWUNEVVZWUjNDNjFWbUpYMVdoZndIeUZMV1grQkpFcmRjMHVHTWNERC9qMDdUYUMKSHIwMmNqaUpjSE9uSCt2ZVVHZXZXNmRaeWx2TXp1RStpZWxPTVlEN3pvcUs5NmwwWTF5U09URDdzWFBUWm9PcAo0S0dabDF5N3ZmSTJpdTJHcVdlUDhBQXB0Qm5JY0VLOW85R0ZQcmhhN25wTS9ROEloNHZCNHFMRi9EVENDRmExCjRMajliV3VndE1GQm1ld09ic3RaeHpLc1NVekFKdk1MV2tMYVNLdXpCWldlWXBWeW4vNEorSmRmeTBJcm1tOXYKaVBMN0o3SHZ2YzJOZFFpK01pcU00ZkJobk1KQ1JBMTBFem1iT1gxUlN6b0NVTnkycFhoYmdkbDFMK2hERm1yQQpvdmNNZ1huNzFJUlU3R0V4VG02UTRtR2ZEZHpuNllEQzQ2R3RBRjVZVlFoVFg1V0FjV1BIMktTNVBKeVJvYmRNCmxmWnhMdytIa1E2dnQzaVloWXFDRjNFU0kyN2hRajFQQXp5T2FqaVl5RGxjREVRRVArWGs3bEtDaXR0UWNMQ0sKZXlCcWJXM0RiZW1MZ0dVa2dWcWRMK2lzN3RVR3pGOGU0a1J4NmRLZkw2Ny9XK0c5b0FyZjExeDBMM1MwWEhybgpZUURNemtXQ1hyZnQ0TVJ6V2p5aWRDYUJ3VlRjSHdZejc0Z1ZUMUIzWlhFYmJCamZBS3RUVFVtcEV4anFuczlxCm1RMzkvV05ybE5ZN014WGJOYkVXSStOeisrS2JnenFFNkhnbUs3SGwxc21JME1PTlpiYTZEQ1NzRHgwb1ZPMjIKMlgvU1VJMk5tNStUd2VkRFVRcktFUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://127.0.0.1:6443
  name: kubernetes-the-hard-way
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: admin
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZxRENDQTVDZ0F3SUJBZ0lVWmFnNXc5OXFDR3JDWnIwY1hPNUl4RnRlVFkwd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1URXdOMW9YRFRNMk1ERXhNVEV5Ck1URXdOMW93S1RFT01Bd0dBMVVFQXd3RllXUnRhVzR4RnpBVkJnTlZCQW9NRG5ONWMzUmxiVHB0WVhOMFpYSnoKTUlJQ0lqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FnOEFNSUlDQ2dLQ0FnRUFzMzM3SUxHb25paEUxLzUxUkxiWQp2Q3J6aU0yclRRbm1jMkxQVi9nYjV3Y2JXZ1I4L1VJa1ZhVUM4WE1YUkRGZTR3MW9oenBsVndySGVUOVdCR25GCmZqNExvOXFUNFQvRHhpai9GNWh0VnJnYXAxVVdHSmx4THZOMUR6Z1ZMNUtWckFoVGdyTkIwKzNFVWJ6S2JiWDAKQjFUOGkrTEpKdkRJYjVtM2NLekRZV0RmRzBwYmg3U054TGl1TXRGTlRJZU02UTc5ZGJBK0tjZWhkWTdJRUEvUgo2cU5mc2ZlcE5sNWFMd25TeWxxYm0wRzFxYmlwcUQ5S25kMURtUzI3b3dXSG9BN1l4bWRMK1RvTTYrL2lpeDV2CnNSaFI5cEt6WFhsNVVwSVRpS09pa0E1bFVKYXJoZW5pL3N6K1RGdVo4dXkyalJrNmRYM0Jpc0VnSU1ickZMZjMKdDBaWUtibEV5VGV6UWhqOFBCM24wWUxrMEF2N3lBOXNuRkZKT2FCMzNIY1Z2anZCYURwTktiMlhUVkhDSW1yVwpycXBxcXhNVkVJbU9kZlZEZWxtQlVxcEhnVmdMdll2dzBBbHlNTW5Gd09tUFN1RUxheDN2dGd2T29tVjBkUCtrCm13RmFMV1VCRjFSRnVhV0NkdmhDWXNzR01zZEhxRjlTSE9rVm0zQVUxMGZ3anZKWGlicVYyTEVGNkdoSmpBZDEKVDJUQWd4SU5vL255c3YvbGpvdlhUeWZScHlvdStzL2MzMndieldyOFl0dEdHdWJBZUR1YkF0VmtFbnltRnkxcApldVU0Lzd2RXRqaDRQbEpqeWVpdkRZSHk2NXpwM2hUdDk4dm5mWmJ6dmJBY0puRGpvZlhqTFR2YndYUFlUdVFMCm1MN0Y2NDZtV1BPcVJkNS9rSGRTOVAwQ0F3RUFBYU9CcnpDQnJEQUpCZ05WSFJNRUFqQUFNQk1HQTFVZEpRUU0KTUFvR0NDc0dBUVVGQndNQ01BNEdBMVVkRHdFQi93UUVBd0lGb0RBUkJnbGdoa2dCaHZoQ0FRRUVCQU1DQjRBdwpKd1lKWUlaSUFZYjRRZ0VOQkJvV0dFRmtiV2x1SUVOc2FXVnVkQ0JEWlhKMGFXWnBZMkYwWlRBZEJnTlZIUTRFCkZnUVVMQUJmVWV4ajZ2T05vMy9uWjVpWmNwUjV0eEV3SHdZRFZSMGpCQmd3Rm9BVVoyaUpRR2VwYXB5ajgwUlcKdjFvblY1ai8xUUF3RFFZSktvWklodmNOQVFFTEJRQURnZ0lCQUxGNEVTZTlkM2tKYkxSS3RCTytqdHZBZHIyVQpCaE42L1hITmVzdXlic1NtWkRKVXFJQitzUStFR2krYWZVZ2FRVjZ0bWhJRHVmQlplZjF1OXhaZnorSk10Vmt5CkttZ3NxYm9uM2Exd09rdFJOWHo0WUh3VFBjL09yUjlQWnhjMkVXV04wdTZJeGZMb2lJa1ZaZGg0bG1yREQ2bEkKQkdQWENXL1VkTVpaTHNuNUpRVndTWGg3a2UvUmhrWTNaTnB2bDYzTmZudm5FS2pCM2hsNUd4eXRydWliVkMrNgpsSnhGVTRjbzZJVUl4MVFWMW9obXB4cTRWVFZsbTN0c0tnc2dJRnlmblc5eUEvT0IyRE85QlVDd2RsSUI5RDk3Clh5MmJkOE0xUXRFQmY1b2dOSHRqY0EvZW44d3dXYU9BTlc3WjlGMVBZNEQ5RERBQ01lM3lQRGtnSy9tVWFrRVMKamsvc0ZONDJMd0QrbDdaY3hUVVB1dGNlTUtwazVMSXVidDBhdkF3TE55US9leFl3SG9zUmdMMlBlMlU3S0RhRwpDaWo3Zk5JWG5ycVptTVNvQytld0YrWCtBSW5wS3lxc2c3TzdPSmVTZGdZUkJSK3ZNT20xT0tOanVpU3gvVnJVCk1TVERHb0o5MU9yQ3J0ODcrOEhDTjErbXYrSmxCQzN2WmJTNjhFWHRLT0J0Sk5CRGhYU2hZbGR6b2RBQlJHaG0KMTZGSWczNTZzclBVRG1TZXRhUVhyeUFMTWw5c1ZMK1lHVHh3WCtsaFhQTkswa2tMN1czcU1yT3pPQ1BnYTBCVgpZSzRUTU9seXR1TEM2QUlrSnFDS20rWkZvSVZRcVdOYXcrZHYreE45Q0NHNEdGNnNpbS9SSmRTSm5QWlpZdHNXCnZaRXhJSEY3SEN2MzRaZE8KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    client-key-data: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRZ0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1N3d2dna29BZ0VBQW9JQ0FRQ3pmZnNnc2FpZUtFVFgKL25WRXR0aThLdk9JemF0TkNlWnpZczlYK0J2bkJ4dGFCSHo5UWlSVnBRTHhjeGRFTVY3akRXaUhPbVZYQ3NkNQpQMVlFYWNWK1BndWoycFBoUDhQR0tQOFhtRzFXdUJxblZSWVltWEV1ODNVUE9CVXZrcFdzQ0ZPQ3MwSFQ3Y1JSCnZNcHR0ZlFIVlB5TDRza204TWh2bWJkd3JNTmhZTjhiU2x1SHRJM0V1SzR5MFUxTWg0enBEdjExc0Q0cHg2RjEKanNnUUQ5SHFvMSt4OTZrMlhsb3ZDZExLV3B1YlFiV3B1S21vUDBxZDNVT1pMYnVqQlllZ0R0akdaMHY1T2d6cgo3K0tMSG0reEdGSDJrck5kZVhsU2toT0lvNktRRG1WUWxxdUY2ZUwrelA1TVc1bnk3TGFOR1RwMWZjR0t3U0FnCnh1c1V0L2UzUmxncHVVVEpON05DR1B3OEhlZlJndVRRQy92SUQyeWNVVWs1b0hmY2R4VytPOEZvT2swcHZaZE4KVWNJaWF0YXVxbXFyRXhVUWlZNTE5VU42V1lGU3FrZUJXQXU5aS9EUUNYSXd5Y1hBNlk5SzRRdHJIZSsyQzg2aQpaWFIwLzZTYkFWb3RaUUVYVkVXNXBZSjIrRUppeXdZeXgwZW9YMUljNlJXYmNCVFhSL0NPOGxlSnVwWFlzUVhvCmFFbU1CM1ZQWk1DREVnMmorZkt5LytXT2k5ZFBKOUduS2k3Nno5emZiQnZOYXZ4aTIwWWE1c0I0TzVzQzFXUVMKZktZWExXbDY1VGovdThTMk9IZytVbVBKNks4TmdmTHJuT25lRk8zM3krZDlsdk85c0J3bWNPT2g5ZU10Tzl2QgpjOWhPNUF1WXZzWHJqcVpZODZwRjNuK1FkMUwwL1FJREFRQUJBb0lDQUFQTzYvbWRHMTFEc0hZK3ZXRTRXZS9nCkgydXJKWFBNZm5tN1FuZjAyUzYxTFdUakRIM1pIZWs5UjRzMDdHenplVFpyRGVrMG1Yclh6VFNxM2RuWkhxb1gKaWVxdmxBeW03REh6bzdudDczLzBCd2krMnVtcHM4ZVJ2YzJWWEltMlcvdWE3NTZweS85Qm43VTJRcnRDTFl2TQpSMUYyZmRzWUo4Q0thK1IxbmUyZWZ3MVdyZ3Q2anJsNlM2UGpZZmI2TjBpb20wTVllckVyUGFjL1lNcEtjNk05ClZTWHpBY0dZRGVUS21oRFdERkFtZkVLK0dzZHBsRjAyR1IyU1pWVkhwRUdHbngzU2lqK2U5akE1Vmo2cVppZEYKUTFQdWQrVEhVNFluZUVlaFpTMFdTUnNGSDEySGdWdnpvSCtoUCtweUVFdDlHZ3J0SUtLZmgxMTZxdmsxRUFubgp4TGoyNDhGbGQ2NU53aFFQK2gyY3ZqSGFlZk1QT2FCVWttZVZOODZCSlJYWEFXL3RaQklkeStSdVBGbENrcURoCkJvKy9Nbml3RGRYZEd1ZktGMUJRNVF4SFh6S21Ua0huT1BrNlhHdWFONGUybTgyV09qd0M0a1FmZ3lKcXNrbk8KTzNoUVVzdTNWN3Z0UFVtK1lPSkJLTXBaMTBLRnJ1MHBGWEp2WitwTFd2TXY4aEVkUlRsR0FqUkpMYmFmVE11SwpJSXMrWnMwRFFPSlVabjhDTlRNVFdQRHQ4dEFXd1k1WmlXSTN3SThkbWVRV3BSZnh5bEtKM0R1SGR1VXdZVFNiCnBjVFkwakd2QXVkVjZnMW12WWZpQlg1UndSczlmbkg5ZHdzc1BJeWpFQndNUkxzQlBiWVAvNzIwdmk1U3B1TWoKdXpJUk5ZSlh2ampxMmlLMG1mU0JBb0lCQVFEMG1qY3lpdDBQSGVWZlBnKzdsWTZBL1hDTlVYTjBnbDZ6QWFNYwo3aURySW00aW93ekpwa0NuVnJ3WjFET1ozVk14M2hIb1h0SU5QY25kbFI1U2NTVVQzTTNOYTlNK1ZQQXM1YzBLCnZEY212VyszbHRpZFFRQ3BtMktKaDIrV1dmbDFudVNtU1cxL1ZMbGxvYjVGVS9mSXpUT1RGM1ExWUMyTXNUVW0KaDBZMHRBaWxyV0JGZkNwbU5KWHJxaGxQdnZMV2hSZkx1WkRWVXp2UUFRVFhFaUFVZW9KcEdnOUl4c1F0aE5NVgpsckRReEZvbXpjTUJJdEJMc3VaZGZxS3Z2VXlYamV3SlA0L25SdmpNWktFS2ZOZ2I4aTdlY25ZVHVZdGVCaEI5CmFxU09CT0trYmpWaUtIelVISGxvY2RpTGVDNlVvaUlKQ0FQTEtjaG1zaUJiK0xzOUFvSUJBUUM3MnhYYW8yaXEKWFVCNStNQ1VYWkZlNmIrb3JZdTJmeXd2Q1QxS3EySVVjdWJGd21pTEVsWFRneFIyZVdUdlgwVGp0Y201SzRxRQpVY3JCMW9PY2NsTHNQRVpLQWZLdDZlV3FJRHg0VUNaUmVsT0t3S29RQ3M5U0ljSVFLaWhVb2tQc2hWVWVQNTVrClJ3Vm96VTBtYjBTZFV2UTVzT3RjTnpBU2k3UHFUako4bDZaQzNEcFZSNXQ0ZXV3Tm0xZW15aTY2TjlwTkNrT04KbFNQcktUbnpVLytSUkNFdk9ZemlZRiszQzJEYkdYL3ZRZ1JtL2J6ajQrNWloUUhWUDlJbWhJSVpVQW1PRHpxSAo4clFjNUgrSE4rU29mUEpGKzREdXdvNkJZNytISVVrU2ZRNG5jclJLc1BlMU16c1JaNDRJMGE1YXJxUDdWeXA5CnV6REdJVW10VWJ6QkFvSUJBUURob0tPTDdzWHRITkdwSWxGVzRxVVozUzZHWFB6WUd5NEpoMWdUNXFEYzVOeWMKL0xSZUNncVhrWTFmY2Z2TFVYcGRoSkFXUGVrYXA4VmVyUi9VUW1SR1J5WmI5N3RiUXZSdEpla1dudmxzdGMrbwpsTy9wVnIycXRoZVY3eVdDbGlwalVoZHVRRXRONmpRK1NJMS8yKzJ6LzMwMGtLejBVMnlRM0NIQUVZWTBOV0hJCm1mNDArazBPRERIQ3Vod3hFRjFtZmt5dDh0Vmp3aXhwT1pkaVlHalJHeFRTcUdReTZJNnJ3bHNJRGdHNkFYVjcKVjlBcWF4ZWl6RHB0UWRRRnNlTkY1WGMyTExpc1NTNVZNL25NOTg1Tk1RQUUxNmFObVZpeWVYdWFoTldYMzIvRQo1NWc4bkVaUlRwYTdQbERXamh6QnBERXJEWWFhVUVkNFc1VTM0Vit0QW9JQkFBM05QK0xMWkxJM25iZ1laWlhBCjlpQkNEam5IWGw5dklvRG1MZUdoaTlneXhPKzhvOCtyN2pCWERoYlNQbTh6MGF6bE8wZm1nZ3ZNc3BmaE9kUXgKdGhQekxicmNQOGMxU3hGZnd2R1grZWk4a3d5N3NRTHl1RjZ4YWoranlVakdqelQrYXMySklRci9DTSsxWGJpNApMaE5jOStLUk5BbVhhR25FWjlpTUhEdDVMTmIydFRaMHgyQm5yNVlrVnFGRGM0RnMveFh2N2h5bDIzaTRrN0JqCitIL2t3SWRtdEFvaHlJWjdTSWR3YlN6WDdkamZSWlI4dDVQM2I3WUtOVmR0SHQzYk9vaDhaL0Y3REc2ZS94dWgKS0tTVVlYeHd5UDFCd0JTVGpvdlFEejFUZ01tM0xMWGNJS2JvZDZ1RXJ6UElyQVd2bFE2dlRjamxDdVZUcHNVYwpIMEVDZ2dFQVhScVNkNktENzFmVnhXWVpNZlAvRjFZRzZjSzFtYk9tMU1KT294dGY5VVNWaERNZXpxMFBnTi9WCmZRdGFwRy81TlI5R1dUaGpIYnVOUTNZQVAraW9MaCtYMjRodTVGWEFYM3ZkTUxRbGgvaWlhU1NwUXlZL0JKN3EKTVl4V0xMVjBNeG9IOVk0UXgyRy9QbFpEWEkrcGhtTCs0dCtFdlV0Lzk5RmpCZHBoWEtQaHZZckQyb1ozZFNnMwprdmMxaEcwNmgrU2lUWTVockkrNHVtK2dMWDZQZ3JyNzdxb2JRVElVeUN6T1JmRk1oZFV0c0VGbVpvL050NTJLCkk4T1A5UldUR1JLaG5tY3NCbEZxQ056VEIwMlZRR3FmVHVyRGt3MG9td2JCMUxza3lFZ2FvZjVmdU1pcVhtNnIKTU1xWHJhTGJKdmxmdnNMcHZObXBnQkNWK0N1OFNRPT0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=
```


### Distribute the Kubernetes Configuration Files
```bash
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ls -l *.kubeconfig
-rw------- 1 root root  9953 Jan 10 12:37 admin.kubeconfig
-rw------- 1 root root 10305 Jan 10 12:34 kube-controller-manager.kubeconfig
-rw------- 1 root root 10187 Jan 10 12:33 kube-proxy.kubeconfig
-rw------- 1 root root 10215 Jan 10 12:36 kube-scheduler.kubeconfig
-rw------- 1 root root 10161 Jan 10 12:30 node-0.kubeconfig
-rw------- 1 root root 10161 Jan 10 12:31 node-1.kubeconfig
```

```bash
# Copy the kubelet and kube-proxy kubeconfig files to the node-0 and node-1 machines
for host in node-0 node-1; do
  ssh root@${host} "mkdir -p /var/lib/{kube-proxy,kubelet}"

  scp kube-proxy.kubeconfig \
    root@${host}:/var/lib/kube-proxy/kubeconfig \

  scp ${host}.kubeconfig \
    root@${host}:/var/lib/kubelet/kubeconfig
done
```

```bash
root@ip-172-31-11-186:~/kubernetes-the-hard-way# for host in node-0 node-1; do
  ssh root@${host} "mkdir -p /var/lib/{kube-proxy,kubelet}"

  scp kube-proxy.kubeconfig \
    root@${host}:/var/lib/kube-proxy/kubeconfig \

  scp ${host}.kubeconfig \
    root@${host}:/var/lib/kubelet/kubeconfig
done
root@node-0's password: 
root@node-0's password: 
kube-proxy.kubeconfig                                     100%   10KB  12.9MB/s   00:00    
root@node-0's password: 
node-0.kubeconfig                                         100%   10KB  14.0MB/s   00:00    
root@node-1's password: 
root@node-1's password: 
kube-proxy.kubeconfig                                     100%   10KB  17.6MB/s   00:00    
root@node-1's password: 
node-1.kubeconfig                                         100%   10KB  19.3MB/s   00:00    

# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-0 ls -l /var/lib/*/kubeconfig
root@node-0's password: 
-rw------- 1 root root 10187 Jan 10 12:39 /var/lib/kube-proxy/kubeconfig
-rw------- 1 root root 10161 Jan 10 12:39 /var/lib/kubelet/kubeconfig

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-1 ls -l /var/lib/*/kubeconfig
root@node-1's password: 
-rw------- 1 root root 10187 Jan 10 12:39 /var/lib/kube-proxy/kubeconfig
-rw------- 1 root root 10161 Jan 10 12:39 /var/lib/kubelet/kubeconfig
```

```bash
# Copy the kube-controller-manager and kube-scheduler kubeconfig files to the server machine
scp admin.kubeconfig \
  kube-controller-manager.kubeconfig \
  kube-scheduler.kubeconfig \
  root@server:~/
```

```bash
root@ip-172-31-11-186:~/kubernetes-the-hard-way# scp admin.kubeconfig \
  kube-controller-manager.kubeconfig \
  kube-scheduler.kubeconfig \
  root@server:~/
root@server's password: 
admin.kubeconfig                                          100% 9953    10.1MB/s   00:00    
kube-controller-manager.kubeconfig                        100%   10KB  11.8MB/s   00:00    
kube-scheduler.kubeconfig                                 100%   10KB  15.0MB/s   00:00    

# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh server ls -l /root/*.kubeconfig
root@server's password: 
-rw------- 1 root root  9953 Jan 10 12:40 /root/admin.kubeconfig
-rw------- 1 root root 10305 Jan 10 12:40 /root/kube-controller-manager.kubeconfig
-rw------- 1 root root 10215 Jan 10 12:40 /root/kube-scheduler.kubeconfig
```

## 06 - Generating the Data Encryption Config and Key

```bash
# The Encryption Key

# Generate an encryption key
root@ip-172-31-11-186:~/kubernetes-the-hard-way# export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
root@ip-172-31-11-186:~/kubernetes-the-hard-way# echo $ENCRYPTION_KEY
gKosSfT9sRCaYxhkBv0VrVJrD/m6dAUnjCxL6WjIBAM=

# The Encryption Config File

# Create the encryption-config.yaml encryption config file
# (참고) 실제 etcd 값에 기록되는 헤더 : k8s:enc:aescbc:v1:key1:<ciphertext>

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat configs/encryption-config.yaml
kind: EncryptionConfiguration           # kube-apiserver가 etcd에 저장할 리소스를 어떻게 암호화할지 정의
apiVersion: apiserver.config.k8s.io/v1  # --encryption-provider-config 플래그로 참조
resources:
  - resources:
      - secrets                         # 암호화 대상 Kubernetes 리소스 : 여기서는 Secret 리소스만 암호화
    providers:                          # 지원 providers(위 부터 적용됨) : identity, aescbc, aesgcm, kms v2, secretbox
      - aescbc:                         # etcd에 저장될 Secret을 AES-CBC 방식으로 암호화
          keys:
            - name: key1                # 키 식별자 (etcd 데이터에 기록됨)
              secret: ${ENCRYPTION_KEY}
      - identity: {}                    # 암호화하지 않음 (Plaintext), 주로 하위 호환성 / 점진적 암호화 목적

root@ip-172-31-11-186:~/kubernetes-the-hard-way# envsubst < configs/encryption-config.yaml > encryption-config.yaml


root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat encryption-config.yaml
kind: EncryptionConfiguration
apiVersion: apiserver.config.k8s.io/v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: gKosSfT9sRCaYxhkBv0VrVJrD/m6dAUnjCxL6WjIBAM=
      - identity: {}


# Copy the encryption-config.yaml encryption config file to each controller instance:
root@ip-172-31-11-186:~/kubernetes-the-hard-way# scp encryption-config.yaml root@server:~/
root@server's password: 
encryption-config.yaml                                    100%  271   387.7KB/s   00:00    

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh server ls -l /root/encryption-config.yaml
root@server's password: 
-rw-r--r-- 1 root root 271 Jan 10 12:43 /root/encryption-config.yaml
```


## 07 - Bootstrapping the etcd Cluster
```bash
# Prerequisites

# hostname 변경 : controller -> server
# http 평문 통신!
# Each etcd member must have a unique name within an etcd cluster. 
# Set the etcd name to match the hostname of the current compute instance:

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat units/etcd.service | grep controller
  --name controller \
  --initial-cluster controller=http://127.0.0.1:2380 \

# 변경 후 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat units/etcd.service | grep server
  --name server \
  --initial-cluster server=http://127.0.0.1:2380 \

# Copy etcd binaries and systemd unit files to the server machine
root@ip-172-31-11-186:~/kubernetes-the-hard-way# scp \
  downloads/controller/etcd \
  downloads/client/etcdctl \
  units/etcd.service \
  root@server:~/
root@server's password: 
etcd                                                      100%   24MB  98.1MB/s   00:00    
etcdctl                                                   100%   16MB 281.7MB/s   00:00    
etcd.service                                              100%  564     1.0MB/s   00:00    

```

```bash
# 아래는 server 가상머신 접속 후 명령 실행
# The commands in this lab must be run on the server machine. Login to the server machine using the ssh command. Example:

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh root@server
root@server's password: 
Linux ip-172-31-5-196 6.12.48+deb13-cloud-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.12.48-1 (2025-09-20) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sat Jan 10 11:48:57 2026 from 172.31.11.186
root@ip-172-31-5-196:~# 
```

```bash
# Bootstrapping an etcd Cluster

# Install the etcd Binaries
# Extract and install the etcd server and the etcdctl command line utility

root@ip-172-31-5-196:~# pwd
/root
root@ip-172-31-5-196:~# ls
admin.kubeconfig        etcd.service                        kube-scheduler.kubeconfig
ca.crt                  etcdctl                             service-accounts.crt
ca.key                  kube-api-server.crt                 service-accounts.key
encryption-config.yaml  kube-api-server.key
etcd                    kube-controller-manager.kubeconfig

root@ip-172-31-5-196:~# mv etcd etcdctl /usr/local/bin/


# Configure the etcd Server
root@ip-172-31-5-196:~# mkdir -p /etc/etcd /var/lib/etcd
root@ip-172-31-5-196:~# chmod 700 /var/lib/etcd
root@ip-172-31-5-196:~# cp ca.crt kube-api-server.key kube-api-server.crt /etc/etcd/

# Create the etcd.service systemd unit file:
root@ip-172-31-5-196:~# mv etcd.service /etc/systemd/system/

root@ip-172-31-5-196:~# tree /etc/systemd/system/
/etc/systemd/system/
├── cloud-config.target.wants
│   └── cloud-init-hotplugd.socket -> /usr/lib/systemd/system/cloud-init-hotplugd.socket
├── cloud-init.target.wants
│   ├── cloud-config.service -> /usr/lib/systemd/system/cloud-config.service
│   ├── cloud-final.service -> /usr/lib/systemd/system/cloud-final.service
│   ├── cloud-init-local.service -> /usr/lib/systemd/system/cloud-init-local.service
│   ├── cloud-init-main.service -> /usr/lib/systemd/system/cloud-init-main.service
│   └── cloud-init-network.service -> /usr/lib/systemd/system/cloud-init-network.service
├── dbus-org.freedesktop.network1.service -> /usr/lib/systemd/system/systemd-networkd.service
├── dbus-org.freedesktop.resolve1.service -> /usr/lib/systemd/system/systemd-resolved.service
├── dbus-org.freedesktop.timesync1.service -> /usr/lib/systemd/system/systemd-timesyncd.service
├── etcd.service
├── getty.target.wants
│   └── getty@tty1.service -> /usr/lib/systemd/system/getty@.service
├── hibernate.target.wants
│   └── grub-common.service -> /usr/lib/systemd/system/grub-common.service
├── hybrid-sleep.target.wants
│   └── grub-common.service -> /usr/lib/systemd/system/grub-common.service
├── multi-user.target.wants
│   ├── amazon-ssm-agent.service -> /usr/lib/systemd/system/amazon-ssm-agent.service
│   ├── e2scrub_reap.service -> /usr/lib/systemd/system/e2scrub_reap.service
│   ├── grub-common.service -> /usr/lib/systemd/system/grub-common.service
│   ├── remote-fs.target -> /usr/lib/systemd/system/remote-fs.target
│   ├── ssh.service -> /usr/lib/systemd/system/ssh.service
│   ├── systemd-networkd.service -> /usr/lib/systemd/system/systemd-networkd.service
│   └── unattended-upgrades.service -> /usr/lib/systemd/system/unattended-upgrades.service
├── network-online.target.wants
│   └── systemd-networkd-wait-online.service -> /usr/lib/systemd/system/systemd-networkd-wait-online.service
├── sockets.target.wants
│   ├── systemd-networkd.socket -> /usr/lib/systemd/system/systemd-networkd.socket
│   └── uuidd.socket -> /usr/lib/systemd/system/uuidd.socket
├── ssh.service.wants
│   └── sshd-keygen.service -> /usr/lib/systemd/system/sshd-keygen.service
├── ssh.socket.wants
│   └── sshd-keygen.service -> /usr/lib/systemd/system/sshd-keygen.service
├── sshd.service -> /usr/lib/systemd/system/ssh.service
├── sshd.service.wants
│   └── sshd-keygen.service -> /usr/lib/systemd/system/sshd-keygen.service
├── sshd@.service.wants
│   └── sshd-keygen.service -> /usr/lib/systemd/system/sshd-keygen.service
├── suspend-then-hibernate.target.wants
│   └── grub-common.service -> /usr/lib/systemd/system/grub-common.service
├── suspend.target.wants
│   └── grub-common.service -> /usr/lib/systemd/system/grub-common.service
├── sysinit.target.wants
│   ├── systemd-network-generator.service -> /usr/lib/systemd/system/systemd-network-generator.service
│   ├── systemd-pstore.service -> /usr/lib/systemd/system/systemd-pstore.service
│   ├── systemd-resolved.service -> /usr/lib/systemd/system/systemd-resolved.service
│   └── systemd-timesyncd.service -> /usr/lib/systemd/system/systemd-timesyncd.service
└── timers.target.wants
    ├── apt-daily-upgrade.timer -> /lib/systemd/system/apt-daily-upgrade.timer
    ├── apt-daily.timer -> /lib/systemd/system/apt-daily.timer
    ├── dpkg-db-backup.timer -> /lib/systemd/system/dpkg-db-backup.timer
    ├── e2scrub_all.timer -> /usr/lib/systemd/system/e2scrub_all.timer
    ├── fstrim.timer -> /lib/systemd/system/fstrim.timer
    └── man-db.timer -> /usr/lib/systemd/system/man-db.timer

17 directories, 40 files


# Start the etcd Server
root@ip-172-31-5-196:~# systemctl daemon-reload
root@ip-172-31-5-196:~# systemctl enable etcd
Created symlink '/etc/systemd/system/multi-user.target.wants/etcd.service' → '/etc/systemd/system/etcd.service'.
root@ip-172-31-5-196:~# systemctl start etcd


# 확인
root@ip-172-31-5-196:~# systemctl status etcd --no-pager
● etcd.service - etcd
     Loaded: loaded (/etc/systemd/system/etcd.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-01-10 12:50:00 UTC; 19s ago
 Invocation: bc1409d11da148168bb57df79594a7c8
       Docs: https://github.com/etcd-io/etcd
   Main PID: 2486 (etcd)
      Tasks: 7 (limit: 2293)
     Memory: 11.7M (peak: 12.9M)
        CPU: 156ms
     CGroup: /system.slice/etcd.service
             └─2486 /usr/local/bin/etcd --name server --initial-advertise-peer-urls http://…

Jan 10 12:50:00 ip-172-31-5-196 etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…mon"}
Jan 10 12:50:00 ip-172-31-5-196 etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…mon"}
Jan 10 12:50:00 ip-172-31-5-196 systemd[1]: Started etcd.service - etcd.
Jan 10 12:50:00 ip-172-31-5-196 etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…ING"}
Jan 10 12:50:00 ip-172-31-5-196 etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…3.6"}
Jan 10 12:50:00 ip-172-31-5-196 etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…3.6"}
Jan 10 12:50:00 ip-172-31-5-196 etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…3.6"}
Jan 10 12:50:00 ip-172-31-5-196 etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…5.0"}
Jan 10 12:50:00 ip-172-31-5-196 etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…6.0"}
Jan 10 12:50:00 ip-172-31-5-196 etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…379"}
Hint: Some lines were ellipsized, use -l to show in full.

root@ip-172-31-5-196:~# ss -tnlp | grep etcd
LISTEN 0      4096       127.0.0.1:2380      0.0.0.0:*    users:(("etcd",pid=2486,fd=3))           
LISTEN 0      4096       127.0.0.1:2379      0.0.0.0:*    users:(("etcd",pid=2486,fd=6))    

# List the etcd cluster members
root@ip-172-31-5-196:~# etcdctl member list
6702b0a34e2cfd39, started, server, http://127.0.0.1:2380, http://127.0.0.1:2379, false


root@ip-172-31-5-196:~# etcdctl member list -w table
+------------------+---------+--------+-----------------------+-----------------------+------------+
|        ID        | STATUS  |  NAME  |      PEER ADDRS       |     CLIENT ADDRS      | IS LEARNER |
+------------------+---------+--------+-----------------------+-----------------------+------------+
| 6702b0a34e2cfd39 | started | server | http://127.0.0.1:2380 | http://127.0.0.1:2379 |      false |
+------------------+---------+--------+-----------------------+-----------------------+------------+


root@ip-172-31-5-196:~# etcdctl endpoint status -w table
+----------------+------------------+------------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+
|    ENDPOINT    |        ID        |  VERSION   | STORAGE VERSION | DB SIZE | IN USE | PERCENTAGE NOT IN USE | QUOTA | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS | DOWNGRADE TARGET VERSION | DOWNGRADE ENABLED |
+----------------+------------------+------------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+
| 127.0.0.1:2379 | 6702b0a34e2cfd39 | 3.6.0-rc.3 |           3.6.0 |   20 kB |  16 kB |                   20% |   0 B |      true |      false |         2 |          4 |                  4 |        |                          |             false |
+----------------+------------------+------------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+


root@ip-172-31-5-196:~# exit
logout
Connection to server closed.
root@ip-172-31-11-186:~/kubernetes-the-hard-way# 
```

## 08 - Bootstrapping the Kubernetes Control Plane

| 항목               | 네트워크 대역 or IP     |
| ---------------- | ----------------- |
| **clusterCIDR**  | **10.200.0.0/16** |
| → node-0 PodCIDR | 10.200.0.0/24     |
| → node-1 PodCIDR | 10.200.1.0/24     |
| **ServiceCIDR**  | **10.32.0.0/24**  |
| → api clusterIP  | 10.32.0.1         |

### jumpbox에서 설정 파일 작성 후 server 에 전달
```bash
# Prerequisites

# kube-apiserver.service 수정 : service-cluster-ip-range 추가
# https://github.com/kelseyhightower/kubernetes-the-hard-way/issues/905
# service-cluster-ip 값은 ca.conf 에 설정한 [kube-api-server_alt_names] 항목의 Service IP 범위

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat ca.conf | grep '\[kube-api-server_alt_names' -A2
[kube-api-server_alt_names]
IP.0  = 127.0.0.1
IP.1  = 10.32.0.1


root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat units/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
  --allow-privileged=true \
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=/var/log/audit.log \
  --authorization-mode=Node,RBAC \
  --bind-address=0.0.0.0 \
  --client-ca-file=/var/lib/kubernetes/ca.crt \
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
  --etcd-servers=http://127.0.0.1:2379 \
  --event-ttl=1h \
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.crt \
  --kubelet-client-certificate=/var/lib/kubernetes/kube-api-server.crt \
  --kubelet-client-key=/var/lib/kubernetes/kube-api-server.key \
  --runtime-config='api/all=true' \
  --service-account-key-file=/var/lib/kubernetes/service-accounts.crt \
  --service-account-signing-key-file=/var/lib/kubernetes/service-accounts.key \
  --service-account-issuer=https://server.kubernetes.local:6443 \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=/var/lib/kubernetes/kube-api-server.crt \
  --tls-private-key-file=/var/lib/kubernetes/kube-api-server.key \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target


root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat << EOF > units/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --allow-privileged=true \\
  --apiserver-count=1 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.crt \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-servers=http://127.0.0.1:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.crt \\
  --kubelet-client-certificate=/var/lib/kubernetes/kube-api-server.crt \\
  --kubelet-client-key=/var/lib/kubernetes/kube-api-server.key \\
  --runtime-config='api/all=true' \\
  --service-account-key-file=/var/lib/kubernetes/service-accounts.crt \\
  --service-account-signing-key-file=/var/lib/kubernetes/service-accounts.key \\
  --service-account-issuer=https://server.kubernetes.local:6443 \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kube-api-server.crt \\
  --tls-private-key-file=/var/lib/kubernetes/kube-api-server.key \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat units/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
  --allow-privileged=true \
  --apiserver-count=1 \
  --audit-log-maxage=30 \
  --audit-log-maxbackup=3 \
  --audit-log-maxsize=100 \
  --audit-log-path=/var/log/audit.log \
  --authorization-mode=Node,RBAC \
  --bind-address=0.0.0.0 \
  --client-ca-file=/var/lib/kubernetes/ca.crt \
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
  --etcd-servers=http://127.0.0.1:2379 \
  --event-ttl=1h \
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.crt \
  --kubelet-client-certificate=/var/lib/kubernetes/kube-api-server.crt \
  --kubelet-client-key=/var/lib/kubernetes/kube-api-server.key \
  --runtime-config='api/all=true' \
  --service-account-key-file=/var/lib/kubernetes/service-accounts.crt \
  --service-account-signing-key-file=/var/lib/kubernetes/service-accounts.key \
  --service-account-issuer=https://server.kubernetes.local:6443 \
  --service-cluster-ip-range=10.32.0.0/24 \
  --service-node-port-range=30000-32767 \
  --tls-cert-file=/var/lib/kubernetes/kube-api-server.crt \
  --tls-private-key-file=/var/lib/kubernetes/kube-api-server.key \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target


# kube-apiserver가 kubelet(Node)에 접근할 수 있도록 허용하는 '시스템 내부용 RBAC' 설정
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat configs/kube-apiserver-to-kubelet.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"  # Kubernetes가 업그레이드 시 자동 관리
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""                                               # Core API group (v1) : Node 관련 서브리소스는 core group에 속함
    resources:                                           # 아래 처럼, kubelet API 대부분을 포괄
      - nodes/proxy                                      ## apiserver → kubelet 프록시 통신
      - nodes/stats                                      ## 노드/파드 리소스 통계 (cAdvisor)
      - nodes/log                                        ## metrics-server / top 명령
      - nodes/spec                                       ## kubectl logs
      - nodes/metrics                                    ## metrics-server / top 명령
    verbs:
      - "*"                                              # 대상은 “nodes 하위 리소스”로 한정 + 모든 동작 허용 (get, list, watch, create, proxy 등)
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver                            # 누가 이 권한을 쓰는가? → kube-apiserver 자신
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes                         # 사용자 kubernetes ,이 사용자는 kube-apiserver가 사용하는 클라이언트 인증서의 CN


# api-server : Subject CN 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# openssl x509 -in kube-api-server.crt -text -noout | grep kubernetes
        Subject: CN=kubernetes, C=US, ST=Washington, L=Seattle
                IP Address:127.0.0.1, IP Address:10.32.0.1, DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster, DNS:kubernetes.svc.cluster.local, DNS:server.kubernetes.local, DNS:api-server.kubernetes.local
r


# api -> kubelet 호출 시 Flow
kube-apiserver (client)
  |
  | (TLS client cert, CN=kubernetes)
  ↓
kubelet API Server 역할 (/stats, /log, /metrics)
  |
  ↓
RBAC 평가:
  User = kubernetes
  → ClusterRoleBinding system:kube-apiserver 매칭
  → ClusterRole system:kube-apiserver-to-kubelet 권한 부여

# kube-scheduler
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat units/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \
  --config=/etc/kubernetes/config/kube-scheduler.yaml \
  --v=2
Restart=on-failure
RestartSec=5

[Install]

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat configs/kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true


# kube-controller-manager : cluster-cidr 는 POD CIDR 포함하는 대역, service-cluster-ip-range 는 apiserver 설정 값 동일 설정.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat units/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \
  --bind-address=0.0.0.0 \
  --cluster-cidr=10.200.0.0/16 \ # 👀
  --cluster-name=kubernetes \
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.crt \
  --cluster-signing-key-file=/var/lib/kubernetes/ca.key \
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \
  --root-ca-file=/var/lib/kubernetes/ca.crt \
  --service-account-private-key-file=/var/lib/kubernetes/service-accounts.key \
  --service-cluster-ip-range=10.32.0.0/24 \ # 👀
  --use-service-account-credentials=true \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target


# Connect to the jumpbox and copy Kubernetes binaries and systemd unit files to the server machine

root@ip-172-31-11-186:~/kubernetes-the-hard-way# scp \
  downloads/controller/kube-apiserver \
  downloads/controller/kube-controller-manager \
  downloads/controller/kube-scheduler \
  downloads/client/kubectl \
  units/kube-apiserver.service \
  units/kube-controller-manager.service \
  units/kube-scheduler.service \
  configs/kube-scheduler.yaml \
  configs/kube-apiserver-to-kubelet.yaml \
  root@server:~/
root@server's password: 
kube-apiserver                                            100%   89MB 204.0MB/s   00:00    
kube-controller-manager                                   100%   82MB 300.3MB/s   00:00    
kube-scheduler                                            100%   63MB 282.8MB/s   00:00    
kubectl                                                   100%   55MB 290.1MB/s   00:00    
kube-apiserver.service                                    100% 1442     2.3MB/s   00:00    
kube-controller-manager.service                           100%  735     1.1MB/s   00:00    
kube-scheduler.service                                    100%  281   456.3KB/s   00:00    
kube-scheduler.yaml                                       100%  191   265.1KB/s   00:00    
kube-apiserver-to-kubelet.yaml                            100%  727     1.6MB/s   00:00    


# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh server ls -l /root
root@server's password: 
total 295440
-rw------- 1 root root     9953 Jan 10 12:40 admin.kubeconfig
-rw-r--r-- 1 root root     1899 Jan 10 12:24 ca.crt
-rw------- 1 root root     3272 Jan 10 12:24 ca.key
-rw-r--r-- 1 root root      271 Jan 10 12:43 encryption-config.yaml
-rw-r--r-- 1 root root     2354 Jan 10 12:24 kube-api-server.crt
-rw------- 1 root root     3272 Jan 10 12:24 kube-api-server.key
-rwxr-xr-x 1 root root 93261976 Jan 10 12:59 kube-apiserver
-rw-r--r-- 1 root root      727 Jan 10 12:59 kube-apiserver-to-kubelet.yaml
-rw-r--r-- 1 root root     1442 Jan 10 12:59 kube-apiserver.service
-rwxr-xr-x 1 root root 85987480 Jan 10 12:59 kube-controller-manager
-rw------- 1 root root    10305 Jan 10 12:40 kube-controller-manager.kubeconfig
-rw-r--r-- 1 root root      735 Jan 10 12:59 kube-controller-manager.service
-rwxr-xr-x 1 root root 65843352 Jan 10 12:59 kube-scheduler
-rw------- 1 root root    10215 Jan 10 12:40 kube-scheduler.kubeconfig
-rw-r--r-- 1 root root      281 Jan 10 12:59 kube-scheduler.service
-rw-r--r-- 1 root root      191 Jan 10 12:59 kube-scheduler.yaml
-rwxr-xr-x 1 root root 57323672 Jan 10 12:59 kubectl
-rw-r--r-- 1 root root     2004 Jan 10 12:24 service-accounts.crt
-rw------- 1 root root     3272 Jan 10 12:24 service-accounts.key
```


### Provision the Kubernetes Control Plane : kubectl 확인
```bash
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh root@server
root@server's password: 
Linux ip-172-31-5-196 6.12.48+deb13-cloud-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.12.48-1 (2025-09-20) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sat Jan 10 12:46:59 2026 from 172.31.11.186
root@ip-172-31-5-196:~# 
```

```bash
# Create the Kubernetes configuration directory:
root@ip-172-31-5-196:~# pwd
/root
root@ip-172-31-5-196:~# ls
admin.kubeconfig        kube-apiserver-to-kubelet.yaml      kube-scheduler.service
ca.crt                  kube-apiserver.service              kube-scheduler.yaml
ca.key                  kube-controller-manager             kubectl
encryption-config.yaml  kube-controller-manager.kubeconfig  service-accounts.crt
kube-api-server.crt     kube-controller-manager.service     service-accounts.key
kube-api-server.key     kube-scheduler
kube-apiserver          kube-scheduler.kubeconfig

root@ip-172-31-5-196:~# mkdir -p /etc/kubernetes/config


# Install the Kubernetes binaries:
root@ip-172-31-5-196:~# mv kube-apiserver \
  kube-controller-manager \
  kube-scheduler kubectl \
  /usr/local/bin/

root@ip-172-31-5-196:~# ls -l /usr/local/bin/kube-*
-rwxr-xr-x 1 root root 93261976 Jan 10 12:59 /usr/local/bin/kube-apiserver
-rwxr-xr-x 1 root root 85987480 Jan 10 12:59 /usr/local/bin/kube-controller-manager
-rwxr-xr-x 1 root root 65843352 Jan 10 12:59 /usr/local/bin/kube-scheduler


# Configure the Kubernetes API Server
root@ip-172-31-5-196:~# mkdir -p /var/lib/kubernetes/

root@ip-172-31-5-196:~# mv ca.crt ca.key \
  kube-api-server.key kube-api-server.crt \
  service-accounts.key service-accounts.crt \
  encryption-config.yaml \
  /var/lib/kubernetes/

root@ip-172-31-5-196:~# ls -l /var/lib/kubernetes/
total 28
-rw-r--r-- 1 root root 1899 Jan 10 12:24 ca.crt
-rw------- 1 root root 3272 Jan 10 12:24 ca.key
-rw-r--r-- 1 root root  271 Jan 10 12:43 encryption-config.yaml
-rw-r--r-- 1 root root 2354 Jan 10 12:24 kube-api-server.crt
-rw------- 1 root root 3272 Jan 10 12:24 kube-api-server.key
-rw-r--r-- 1 root root 2004 Jan 10 12:24 service-accounts.crt
-rw------- 1 root root 3272 Jan 10 12:24 service-accounts.key

## Create the kube-apiserver.service systemd unit file:
root@ip-172-31-5-196:~# mv kube-apiserver.service \
  /etc/systemd/system/kube-apiserver.service

root@ip-172-31-5-196:~# tree /etc/systemd/system
/etc/systemd/system
├── cloud-config.target.wants
│   └── cloud-init-hotplugd.socket -> /usr/lib/systemd/system/cloud-init-hotplugd.socket
├── cloud-init.target.wants
│   ├── cloud-config.service -> /usr/lib/systemd/system/cloud-config.service
│   ├── cloud-final.service -> /usr/lib/systemd/system/cloud-final.service
│   ├── cloud-init-local.service -> /usr/lib/systemd/system/cloud-init-local.service
│   ├── cloud-init-main.service -> /usr/lib/systemd/system/cloud-init-main.service
│   └── cloud-init-network.service -> /usr/lib/systemd/system/cloud-init-network.service
├── dbus-org.freedesktop.network1.service -> /usr/lib/systemd/system/systemd-networkd.service
├── dbus-org.freedesktop.resolve1.service -> /usr/lib/systemd/system/systemd-resolved.service
├── dbus-org.freedesktop.timesync1.service -> /usr/lib/systemd/system/systemd-timesyncd.service
├── etcd.service
├── getty.target.wants
│   └── getty@tty1.service -> /usr/lib/systemd/system/getty@.service
├── hibernate.target.wants
│   └── grub-common.service -> /usr/lib/systemd/system/grub-common.service
├── hybrid-sleep.target.wants
│   └── grub-common.service -> /usr/lib/systemd/system/grub-common.service
├── kube-apiserver.service
├── multi-user.target.wants
│   ├── amazon-ssm-agent.service -> /usr/lib/systemd/system/amazon-ssm-agent.service
│   ├── e2scrub_reap.service -> /usr/lib/systemd/system/e2scrub_reap.service
│   ├── etcd.service -> /etc/systemd/system/etcd.service
│   ├── grub-common.service -> /usr/lib/systemd/system/grub-common.service
│   ├── remote-fs.target -> /usr/lib/systemd/system/remote-fs.target
│   ├── ssh.service -> /usr/lib/systemd/system/ssh.service
│   ├── systemd-networkd.service -> /usr/lib/systemd/system/systemd-networkd.service
│   └── unattended-upgrades.service -> /usr/lib/systemd/system/unattended-upgrades.service
├── network-online.target.wants
│   └── systemd-networkd-wait-online.service -> /usr/lib/systemd/system/systemd-networkd-wait-online.service
├── sockets.target.wants
│   ├── systemd-networkd.socket -> /usr/lib/systemd/system/systemd-networkd.socket
│   └── uuidd.socket -> /usr/lib/systemd/system/uuidd.socket
├── ssh.service.wants
│   └── sshd-keygen.service -> /usr/lib/systemd/system/sshd-keygen.service
├── ssh.socket.wants
│   └── sshd-keygen.service -> /usr/lib/systemd/system/sshd-keygen.service
├── sshd.service -> /usr/lib/systemd/system/ssh.service
├── sshd.service.wants
│   └── sshd-keygen.service -> /usr/lib/systemd/system/sshd-keygen.service
├── sshd@.service.wants
│   └── sshd-keygen.service -> /usr/lib/systemd/system/sshd-keygen.service
├── suspend-then-hibernate.target.wants
│   └── grub-common.service -> /usr/lib/systemd/system/grub-common.service
├── suspend.target.wants
│   └── grub-common.service -> /usr/lib/systemd/system/grub-common.service
├── sysinit.target.wants
│   ├── systemd-network-generator.service -> /usr/lib/systemd/system/systemd-network-generator.service
│   ├── systemd-pstore.service -> /usr/lib/systemd/system/systemd-pstore.service
│   ├── systemd-resolved.service -> /usr/lib/systemd/system/systemd-resolved.service
│   └── systemd-timesyncd.service -> /usr/lib/systemd/system/systemd-timesyncd.service
└── timers.target.wants
    ├── apt-daily-upgrade.timer -> /lib/systemd/system/apt-daily-upgrade.timer
    ├── apt-daily.timer -> /lib/systemd/system/apt-daily.timer
    ├── dpkg-db-backup.timer -> /lib/systemd/system/dpkg-db-backup.timer
    ├── e2scrub_all.timer -> /usr/lib/systemd/system/e2scrub_all.timer
    ├── fstrim.timer -> /lib/systemd/system/fstrim.timer
    └── man-db.timer -> /usr/lib/systemd/system/man-db.timer


# Configure the Kubernetes Controller Manager

## Move the kube-controller-manager kubeconfig into place:
root@ip-172-31-5-196:~# mv kube-controller-manager.kubeconfig /var/lib/kubernetes/

## Create the kube-controller-manager.service systemd unit file:
root@ip-172-31-5-196:~# mv kube-controller-manager.service /etc/systemd/system/


# Configure the Kubernetes Scheduler

## Move the kube-scheduler kubeconfig into place:
root@ip-172-31-5-196:~# mv kube-scheduler.kubeconfig /var/lib/kubernetes/

## Create the kube-scheduler.yaml configuration file:
root@ip-172-31-5-196:~# mv kube-scheduler.yaml /etc/kubernetes/config/

## Create the kube-scheduler.service systemd unit file:
root@ip-172-31-5-196:~# mv kube-scheduler.service /etc/systemd/system/


# Start the Controller Services : Allow up to 10 seconds for the Kubernetes API Server to fully initialize.

root@ip-172-31-5-196:~# systemctl daemon-reload
root@ip-172-31-5-196:~# systemctl enable kube-apiserver kube-controller-manager kube-scheduler
Created symlink '/etc/systemd/system/multi-user.target.wants/kube-apiserver.service' → '/etc/systemd/system/kube-apiserver.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/kube-controller-manager.service' → '/etc/systemd/system/kube-controller-manager.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/kube-scheduler.service' → '/etc/systemd/system/kube-scheduler.service'.


root@ip-172-31-5-196:~# systemctl start  kube-apiserver kube-controller-manager kube-scheduler

# 확인
root@ip-172-31-5-196:~# ss -tlp | grep kube
LISTEN 0      4096               *:10259             *:*    users:(("kube-scheduler",pid=2738,fd=3)) 
LISTEN 0      4096               *:10257             *:*    users:(("kube-controller",pid=2737,fd=3))
LISTEN 0      4096               *:6443              *:*    users:(("kube-apiserver",pid=2733,fd=3))

root@ip-172-31-5-196:~# systemctl is-active kube-apiserver
active
root@ip-172-31-5-196:~# systemctl status kube-apiserver --no-pager
● kube-apiserver.service - Kubernetes API Server
     Loaded: loaded (/etc/systemd/system/kube-apiserver.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-01-10 13:06:28 UTC; 42s ago
 Invocation: 8daa784d9bff4be19d1904986b49acf7
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 2733 (kube-apiserver)
      Tasks: 8 (limit: 2293)
     Memory: 216.2M (peak: 217.9M)
        CPU: 4.189s
     CGroup: /system.slice/kube-apiserver.service
             └─2733 /usr/local/bin/kube-apiserver --allow-privileged=true --apiserver-count…

Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.513376    2733 sto…stem
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.522218    2733 sto…blic
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.588915    2733 all….1"}
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: W0110 13:06:32.595002    2733 lea…196]
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.595887    2733 con…ints
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.600155    2733 con…s.io
Jan 10 13:06:34 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:34.194313    2733 con…unts
Jan 10 13:06:38 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:38.651020    2733 cac…nel.
Jan 10 13:06:38 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:38.651042    2733 cac…nel.
Jan 10 13:06:51 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:51.068592    2733 apf_con…
Hint: Some lines were ellipsized, use -l to show in full.

root@ip-172-31-5-196:~# journalctl -u kube-apiserver -n 20 --no-pager
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.469673    2733 storage_rbac.go:289] created role.rbac.authorization.k8s.io/system::leader-locking-kube-scheduler in kube-system
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.477773    2733 healthz.go:280] poststarthook/rbac/bootstrap-roles check failed: readyz
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: [-]poststarthook/rbac/bootstrap-roles failed: not finished
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.479428    2733 storage_rbac.go:289] created role.rbac.authorization.k8s.io/system:controller:bootstrap-signer in kube-public
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.482988    2733 controller.go:615] quota admission added evaluator for: rolebindings.rbac.authorization.k8s.io
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.484962    2733 storage_rbac.go:321] created rolebinding.rbac.authorization.k8s.io/system::extension-apiserver-authentication-reader in kube-system
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.492357    2733 storage_rbac.go:321] created rolebinding.rbac.authorization.k8s.io/system::leader-locking-kube-controller-manager in kube-system
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.498096    2733 storage_rbac.go:321] created rolebinding.rbac.authorization.k8s.io/system::leader-locking-kube-scheduler in kube-system
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.503684    2733 storage_rbac.go:321] created rolebinding.rbac.authorization.k8s.io/system:controller:bootstrap-signer in kube-system
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.508624    2733 storage_rbac.go:321] created rolebinding.rbac.authorization.k8s.io/system:controller:cloud-provider in kube-system
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.513376    2733 storage_rbac.go:321] created rolebinding.rbac.authorization.k8s.io/system:controller:token-cleaner in kube-system
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.522218    2733 storage_rbac.go:321] created rolebinding.rbac.authorization.k8s.io/system:controller:bootstrap-signer in kube-public
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.588915    2733 alloc.go:330] "allocated clusterIPs" service="default/kubernetes" clusterIPs={"IPv4":"10.32.0.1"}
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: W0110 13:06:32.595002    2733 lease.go:265] Resetting endpoints for master service "kubernetes" to [172.31.5.196]
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.595887    2733 controller.go:615] quota admission added evaluator for: endpoints
Jan 10 13:06:32 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:32.600155    2733 controller.go:615] quota admission added evaluator for: endpointslices.discovery.k8s.io
Jan 10 13:06:34 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:34.194313    2733 controller.go:615] quota admission added evaluator for: serviceaccounts
Jan 10 13:06:38 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:38.651020    2733 cacher.go:1028] cacher (clusterroles.rbac.authorization.k8s.io): 1 objects queued in incoming channel.
Jan 10 13:06:38 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:38.651042    2733 cacher.go:1028] cacher (clusterroles.rbac.authorization.k8s.io): 2 objects queued in incoming channel.
Jan 10 13:06:51 ip-172-31-5-196 kube-apiserver[2733]: I0110 13:06:51.068592    2733 apf_controller.go:493] "Update CurrentCL" plName="exempt" seatDemandHighWatermark=1 seatDemandAvg=0.0004211936577588183 seatDemandStdev=0.020518680602355555 seatDemandSmoothed=7.99074279939449 fairFrac=2.3333333333333335 currentCL=1 concurrencyDenominator=1 backstop=false


root@ip-172-31-5-196:~# systemctl status kube-scheduler --no-pager
● kube-scheduler.service - Kubernetes Scheduler
     Loaded: loaded (/etc/systemd/system/kube-scheduler.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-01-10 13:06:28 UTC; 2min 23s ago
 Invocation: 56e270c6f1074bc2911a8bdb4dc7410b
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 2738 (kube-scheduler)
      Tasks: 9 (limit: 2293)
     Memory: 15.7M (peak: 16.2M)
        CPU: 2.282s
     CGroup: /system.slice/kube-scheduler.service
             └─2738 /usr/local/bin/kube-scheduler --config=/etc/kubernetes/config/kube-sche…

Jan 10 13:06:32 ip-172-31-5-196 kube-scheduler[2738]: I0110 13:06:32.699024    2738 ref…:160
Jan 10 13:06:32 ip-172-31-5-196 kube-scheduler[2738]: I0110 13:06:32.752827    2738 ref…:160
Jan 10 13:06:32 ip-172-31-5-196 kube-scheduler[2738]: I0110 13:06:32.834416    2738 ref…:160
Jan 10 13:06:32 ip-172-31-5-196 kube-scheduler[2738]: I0110 13:06:32.857859    2738 ref…:160
Jan 10 13:06:32 ip-172-31-5-196 kube-scheduler[2738]: I0110 13:06:32.986825    2738 ref…:160
Jan 10 13:06:33 ip-172-31-5-196 kube-scheduler[2738]: I0110 13:06:33.099800    2738 ref…:160
Jan 10 13:06:33 ip-172-31-5-196 kube-scheduler[2738]: I0110 13:06:33.125891    2738 ref…:160
Jan 10 13:06:33 ip-172-31-5-196 kube-scheduler[2738]: I0110 13:06:33.137318    2738 ref…:160
Jan 10 13:06:33 ip-172-31-5-196 kube-scheduler[2738]: I0110 13:06:33.150134    2738 lea…r...
Jan 10 13:06:33 ip-172-31-5-196 kube-scheduler[2738]: I0110 13:06:33.156638    2738 lea…uler
Hint: Some lines were ellipsized, use -l to show in full.

root@ip-172-31-5-196:~# systemctl status kube-controller-manager --no-pager
● kube-controller-manager.service - Kubernetes Controller Manager
     Loaded: loaded (/etc/systemd/system/kube-controller-manager.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-01-10 13:06:28 UTC; 2min 44s ago
 Invocation: 7f66b1976cf5402fb1612be312e75f01
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 2737 (kube-controller)
      Tasks: 5 (limit: 2293)
     Memory: 42M (peak: 42.5M)
        CPU: 3.430s
     CGroup: /system.slice/kube-controller-manager.service
             └─2737 /usr/local/bin/kube-controller-manager --bind-address=0.0.0.0 --cluster…

Jan 10 13:06:38 ip-172-31-5-196 kube-controller-manager[2737]: I0110 13:06:38.384015    …and
Jan 10 13:06:38 ip-172-31-5-196 kube-controller-manager[2737]: I0110 13:06:38.385160    …tor
Jan 10 13:06:38 ip-172-31-5-196 kube-controller-manager[2737]: I0110 13:06:38.385189    …ice
Jan 10 13:06:38 ip-172-31-5-196 kube-controller-manager[2737]: I0110 13:06:38.385206    …l=5
Jan 10 13:06:38 ip-172-31-5-196 kube-controller-manager[2737]: I0110 13:06:38.385233    …l=1
Jan 10 13:06:38 ip-172-31-5-196 kube-controller-manager[2737]: I0110 13:06:38.385724    …ent
Jan 10 13:06:38 ip-172-31-5-196 kube-controller-manager[2737]: I0110 13:06:38.385165    …ing
Jan 10 13:06:38 ip-172-31-5-196 kube-controller-manager[2737]: I0110 13:06:38.386896    …ent
Jan 10 13:06:38 ip-172-31-5-196 kube-controller-manager[2737]: I0110 13:06:38.388127    …own
Jan 10 13:06:38 ip-172-31-5-196 kube-controller-manager[2737]: I0110 13:06:38.393397    …ota
Hint: Some lines were ellipsized, use -l to show in full.


# Verify this using the kubectl command line tool

root@ip-172-31-5-196:~# kubectl cluster-info --kubeconfig admin.kubeconfig
Kubernetes control plane is running at https://127.0.0.1:6443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

root@ip-172-31-5-196:~# kubectl get node --kubeconfig admin.kubeconfig
No resources found
root@ip-172-31-5-196:~# kubectl get pod -A --kubeconfig admin.kubeconfig
No resources found
root@ip-172-31-5-196:~# kubectl get service,ep --kubeconfig admin.kubeconfig
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.32.0.1    <none>        443/TCP   3m45s

NAME                   ENDPOINTS           AGE
endpoints/kubernetes   172.31.5.196:6443   3m45s

```

```bash
# clusterroles 확인
root@ip-172-31-5-196:~# kubectl get clusterroles --kubeconfig admin.kubeconfig
NAME                                                                   CREATED AT
admin                                                                  2026-01-10T13:06:31Z
cluster-admin                                                          2026-01-10T13:06:31Z
edit                                                                   2026-01-10T13:06:31Z
system:aggregate-to-admin                                              2026-01-10T13:06:31Z
system:aggregate-to-edit                                               2026-01-10T13:06:31Z
system:aggregate-to-view                                               2026-01-10T13:06:31Z
system:auth-delegator                                                  2026-01-10T13:06:31Z
system:basic-user                                                      2026-01-10T13:06:31Z
system:certificates.k8s.io:certificatesigningrequests:nodeclient       2026-01-10T13:06:31Z
system:certificates.k8s.io:certificatesigningrequests:selfnodeclient   2026-01-10T13:06:31Z
system:certificates.k8s.io:kube-apiserver-client-approver              2026-01-10T13:06:31Z
system:certificates.k8s.io:kube-apiserver-client-kubelet-approver      2026-01-10T13:06:31Z
system:certificates.k8s.io:kubelet-serving-approver                    2026-01-10T13:06:31Z
system:certificates.k8s.io:legacy-unknown-approver                     2026-01-10T13:06:31Z
system:controller:attachdetach-controller                              2026-01-10T13:06:32Z
system:controller:certificate-controller                               2026-01-10T13:06:32Z
system:controller:clusterrole-aggregation-controller                   2026-01-10T13:06:32Z
system:controller:cronjob-controller                                   2026-01-10T13:06:32Z
system:controller:daemon-set-controller                                2026-01-10T13:06:32Z
system:controller:deployment-controller                                2026-01-10T13:06:32Z
system:controller:disruption-controller                                2026-01-10T13:06:32Z
system:controller:endpoint-controller                                  2026-01-10T13:06:32Z
system:controller:endpointslice-controller                             2026-01-10T13:06:32Z
system:controller:endpointslicemirroring-controller                    2026-01-10T13:06:32Z
system:controller:ephemeral-volume-controller                          2026-01-10T13:06:32Z
system:controller:expand-controller                                    2026-01-10T13:06:32Z
system:controller:generic-garbage-collector                            2026-01-10T13:06:32Z
system:controller:horizontal-pod-autoscaler                            2026-01-10T13:06:32Z
system:controller:job-controller                                       2026-01-10T13:06:32Z
system:controller:legacy-service-account-token-cleaner                 2026-01-10T13:06:32Z
system:controller:namespace-controller                                 2026-01-10T13:06:32Z
system:controller:node-controller                                      2026-01-10T13:06:32Z
system:controller:persistent-volume-binder                             2026-01-10T13:06:32Z
system:controller:pod-garbage-collector                                2026-01-10T13:06:32Z
system:controller:pv-protection-controller                             2026-01-10T13:06:32Z
system:controller:pvc-protection-controller                            2026-01-10T13:06:32Z
system:controller:replicaset-controller                                2026-01-10T13:06:32Z
system:controller:replication-controller                               2026-01-10T13:06:32Z
system:controller:resourcequota-controller                             2026-01-10T13:06:32Z
system:controller:root-ca-cert-publisher                               2026-01-10T13:06:32Z
system:controller:route-controller                                     2026-01-10T13:06:32Z
system:controller:service-account-controller                           2026-01-10T13:06:32Z
system:controller:service-controller                                   2026-01-10T13:06:32Z
system:controller:statefulset-controller                               2026-01-10T13:06:32Z
system:controller:ttl-after-finished-controller                        2026-01-10T13:06:32Z
system:controller:ttl-controller                                       2026-01-10T13:06:32Z
system:controller:validatingadmissionpolicy-status-controller          2026-01-10T13:06:32Z
system:discovery                                                       2026-01-10T13:06:31Z
system:heapster                                                        2026-01-10T13:06:31Z
system:kube-aggregator                                                 2026-01-10T13:06:31Z
system:kube-controller-manager                                         2026-01-10T13:06:31Z
system:kube-dns                                                        2026-01-10T13:06:31Z
system:kube-scheduler                                                  2026-01-10T13:06:32Z
system:kubelet-api-admin                                               2026-01-10T13:06:31Z
system:monitoring                                                      2026-01-10T13:06:31Z
system:node                                                            2026-01-10T13:06:31Z
system:node-bootstrapper                                               2026-01-10T13:06:31Z
system:node-problem-detector                                           2026-01-10T13:06:31Z
system:node-proxier                                                    2026-01-10T13:06:31Z
system:persistent-volume-provisioner                                   2026-01-10T13:06:31Z
system:public-info-viewer                                              2026-01-10T13:06:31Z
system:service-account-issuer-discovery                                2026-01-10T13:06:31Z
system:volume-scheduler                                                2026-01-10T13:06:31Z
view                                                                   2026-01-10T13:06:31Z



root@ip-172-31-5-196:~# kubectl describe clusterroles system:kube-scheduler --kubeconfig admin.kubeconfig
Name:         system:kube-scheduler
Labels:       kubernetes.io/bootstrapping=rbac-defaults
Annotations:  rbac.authorization.kubernetes.io/autoupdate: true
PolicyRule:
  Resources                                  Non-Resource URLs  Resource Names    Verbs
  ---------                                  -----------------  --------------    -----
  leasecandidates.coordination.k8s.io        []                 []                [create delete deletecollection get list patch update watch]
  events                                     []                 []                [create patch update]
  events.events.k8s.io                       []                 []                [create patch update]
  bindings                                   []                 []                [create]
  pods/binding                               []                 []                [create]
  tokenreviews.authentication.k8s.io         []                 []                [create]
  subjectaccessreviews.authorization.k8s.io  []                 []                [create]
  leases.coordination.k8s.io                 []                 []                [create]
  pods                                       []                 []                [delete get list watch]
  leases.coordination.k8s.io                 []                 [kube-scheduler]  [get list update watch]
  namespaces                                 []                 []                [get list watch]
  nodes                                      []                 []                [get list watch]
  persistentvolumeclaims                     []                 []                [get list watch]
  persistentvolumes                          []                 []                [get list watch]
  replicationcontrollers                     []                 []                [get list watch]
  services                                   []                 []                [get list watch]
  replicasets.apps                           []                 []                [get list watch]
  statefulsets.apps                          []                 []                [get list watch]
  replicasets.extensions                     []                 []                [get list watch]
  poddisruptionbudgets.policy                []                 []                [get list watch]
  csidrivers.storage.k8s.io                  []                 []                [get list watch]
  csinodes.storage.k8s.io                    []                 []                [get list watch]
  csistoragecapacities.storage.k8s.io        []                 []                [get list watch]
  volumeattachments.storage.k8s.io           []                 []                [get list watch]
  pods/status                                []                 []                [patch update]


# kube-scheduler subject 확인
root@ip-172-31-5-196:~# kubectl get clusterrolebindings --kubeconfig admin.kubeconfig
NAME                                                            ROLE                                                                        AGE
cluster-admin                                                   ClusterRole/cluster-admin                                                   5m1s
system:basic-user                                               ClusterRole/system:basic-user                                               5m1s
system:controller:attachdetach-controller                       ClusterRole/system:controller:attachdetach-controller                       5m1s
system:controller:certificate-controller                        ClusterRole/system:controller:certificate-controller                        5m1s
system:controller:clusterrole-aggregation-controller            ClusterRole/system:controller:clusterrole-aggregation-controller            5m1s
system:controller:cronjob-controller                            ClusterRole/system:controller:cronjob-controller                            5m1s
system:controller:daemon-set-controller                         ClusterRole/system:controller:daemon-set-controller                         5m1s
system:controller:deployment-controller                         ClusterRole/system:controller:deployment-controller                         5m1s
system:controller:disruption-controller                         ClusterRole/system:controller:disruption-controller                         5m1s
system:controller:endpoint-controller                           ClusterRole/system:controller:endpoint-controller                           5m1s
system:controller:endpointslice-controller                      ClusterRole/system:controller:endpointslice-controller                      5m1s
system:controller:endpointslicemirroring-controller             ClusterRole/system:controller:endpointslicemirroring-controller             5m1s
system:controller:ephemeral-volume-controller                   ClusterRole/system:controller:ephemeral-volume-controller                   5m1s
system:controller:expand-controller                             ClusterRole/system:controller:expand-controller                             5m1s
system:controller:generic-garbage-collector                     ClusterRole/system:controller:generic-garbage-collector                     5m1s
system:controller:horizontal-pod-autoscaler                     ClusterRole/system:controller:horizontal-pod-autoscaler                     5m1s
system:controller:job-controller                                ClusterRole/system:controller:job-controller                                5m1s
system:controller:legacy-service-account-token-cleaner          ClusterRole/system:controller:legacy-service-account-token-cleaner          5m1s
system:controller:namespace-controller                          ClusterRole/system:controller:namespace-controller                          5m1s
system:controller:node-controller                               ClusterRole/system:controller:node-controller                               5m1s
system:controller:persistent-volume-binder                      ClusterRole/system:controller:persistent-volume-binder                      5m1s
system:controller:pod-garbage-collector                         ClusterRole/system:controller:pod-garbage-collector                         5m1s
system:controller:pv-protection-controller                      ClusterRole/system:controller:pv-protection-controller                      5m1s
system:controller:pvc-protection-controller                     ClusterRole/system:controller:pvc-protection-controller                     5m1s
system:controller:replicaset-controller                         ClusterRole/system:controller:replicaset-controller                         5m1s
system:controller:replication-controller                        ClusterRole/system:controller:replication-controller                        5m1s
system:controller:resourcequota-controller                      ClusterRole/system:controller:resourcequota-controller                      5m1s
system:controller:root-ca-cert-publisher                        ClusterRole/system:controller:root-ca-cert-publisher                        5m1s
system:controller:route-controller                              ClusterRole/system:controller:route-controller                              5m1s
system:controller:service-account-controller                    ClusterRole/system:controller:service-account-controller                    5m1s
system:controller:service-controller                            ClusterRole/system:controller:service-controller                            5m1s
system:controller:statefulset-controller                        ClusterRole/system:controller:statefulset-controller                        5m1s
system:controller:ttl-after-finished-controller                 ClusterRole/system:controller:ttl-after-finished-controller                 5m1s
system:controller:ttl-controller                                ClusterRole/system:controller:ttl-controller                                5m1s
system:controller:validatingadmissionpolicy-status-controller   ClusterRole/system:controller:validatingadmissionpolicy-status-controller   5m1s
system:discovery                                                ClusterRole/system:discovery                                                5m1s
system:kube-controller-manager                                  ClusterRole/system:kube-controller-manager                                  5m1s
system:kube-dns                                                 ClusterRole/system:kube-dns                                                 5m1s
system:kube-scheduler                                           ClusterRole/system:kube-scheduler                                           5m1s
system:monitoring                                               ClusterRole/system:monitoring                                               5m1s
system:node                                                     ClusterRole/system:node                                                     5m1s
system:node-proxier                                             ClusterRole/system:node-proxier                                             5m1s
system:public-info-viewer                                       ClusterRole/system:public-info-viewer                                       5m1s
system:service-account-issuer-discovery                         ClusterRole/system:service-account-issuer-discovery                         5m1s
system:volume-scheduler                                         ClusterRole/system:volume-scheduler                                         5m1s

root@ip-172-31-5-196:~# kubectl describe clusterrolebindings system:kube-scheduler --kubeconfig admin.kubeconfig
Name:         system:kube-scheduler
Labels:       kubernetes.io/bootstrapping=rbac-defaults
Annotations:  rbac.authorization.kubernetes.io/autoupdate: true
Role:
  Kind:  ClusterRole
  Name:  system:kube-scheduler
Subjects:
  Kind  Name                   Namespace
  ----  ----                   ---------
  User  system:kube-scheduler  
```

### RBAC for Kubelet Authorization
- 이 섹션에서는 Kubernetes API 서버가 각 작업자 노드에서 Kubelet API에 액세스할 수 있도록 RBAC 권한을 구성합니다.
- Kubelet API에 대한 액세스 권한은 메트릭, 로그를 검색하고 포드에서 명령을 실행하는 데 필요합니다.
- 이 튜토리얼에서는 **Kubelet** `--authorization-mode` 플래그를 `Webhook`으로 설정합니다.
- Webhook 모드에서는 SubjectAccessReview API를 사용하여 권한을 결정합니다.

```bash
# ssh root@server # 이미 server 에 ssh 접속 상태

# api -> kubelet 접속을 위한 RBAC 설정
# Create the system:kube-apiserver-to-kubelet ClusterRole with permissions to access the Kubelet

root@ip-172-31-5-196:~# cat kube-apiserver-to-kubelet.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes

root@ip-172-31-5-196:~# kubectl apply -f kube-apiserver-to-kubelet.yaml --kubeconfig admin.kubeconfig
clusterrole.rbac.authorization.k8s.io/system:kube-apiserver-to-kubelet created
clusterrolebinding.rbac.authorization.k8s.io/system:kube-apiserver created


# 확인
root@ip-172-31-5-196:~# kubectl get clusterroles system:kube-apiserver-to-kubelet --kubeconfig admin.kubeconfig
NAME                               CREATED AT
system:kube-apiserver-to-kubelet   2026-01-10T13:13:47Z
root@ip-172-31-5-196:~# kubectl get clusterrolebindings system:kube-apiserver --kubeconfig admin.kubeconfig
NAME                    ROLE                                           AGE
system:kube-apiserver   ClusterRole/system:kube-apiserver-to-kubelet   30s
```

jumpbox 서버에서 k8s controlplane 정상 동작 확인
```bash
root@ip-172-31-11-186:~/kubernetes-the-hard-way# curl -s -k --cacert ca.crt https://server.kubernetes.local:6443/version | jq
{
  "major": "1",
  "minor": "32",
  "gitVersion": "v1.32.3",
  "gitCommit": "32cc146f75aad04beaaa245a7157eb35063a9f99",
  "gitTreeState": "clean",
  "buildDate": "2025-03-11T19:52:21Z",
  "goVersion": "go1.23.6",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

## 09 - Bootstrapping the Kubernetes Worker Nodes

### jumpbox에서 Prerequisites 사전 준비

```bash
# cni(bridge) 파일과 kubelet-config 파일 작성 및 node-0/1에 전달
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat configs/10-bridge.conf | jq
{
  "cniVersion": "1.0.0",
  "name": "bridge",
  "type": "bridge",
  "bridge": "cni0",
  "isGateway": true,
  "ipMasq": true,
  "ipam": {
    "type": "host-local",
    "ranges": [
      [
        {
          "subnet": "SUBNET"
        }
      ]
    ],
    "routes": [
      {
        "dst": "0.0.0.0/0"
      }
    ]
  }
}

# clusterDomain , clusterDNS 없어도 smoke test 까지 잘됨 -> 실습에서 coredns 미사용
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat configs/kubelet-config.yaml | yq
{
  "kind": "KubeletConfiguration",
  "apiVersion": "kubelet.config.k8s.io/v1beta1",
  "address": "0.0.0.0",
  "authentication": {
    "anonymous": {
      "enabled": false
    },
    "webhook": {
      "enabled": true
    },
    "x509": {
      "clientCAFile": "/var/lib/kubelet/ca.crt"
    }
  },
  "authorization": {
    "mode": "Webhook"
  },
  "cgroupDriver": "systemd",
  "containerRuntimeEndpoint": "unix:///var/run/containerd/containerd.sock",
  "enableServer": true,
  "failSwapOn": false,
  "maxPods": 16,
  "memorySwap": {
    "swapBehavior": "NoSwap"
  },
  "port": 10250,
  "resolvConf": "/etc/resolv.conf",
  "registerNode": true,
  "runtimeRequestTimeout": "15m",
  "tlsCertFile": "/var/lib/kubelet/kubelet.crt",
  "tlsPrivateKeyFile": "/var/lib/kubelet/kubelet.key"
}

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat configs/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
address: "0.0.0.0"
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubelet/ca.crt"
authorization:
  mode: Webhook
cgroupDriver: systemd
containerRuntimeEndpoint: "unix:///var/run/containerd/containerd.sock"
enableServer: true
failSwapOn: false
maxPods: 16
memorySwap:
  swapBehavior: NoSwap
port: 10250
resolvConf: "/etc/resolv.conf"
registerNode: true
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/kubelet.crt"
tlsPrivateKeyFile: "/var/lib/kubelet/kubelet.key"

kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
address: "0.0.0.0"                            # kubelet HTTPS 서버 바인딩 주소 : 모든 인터페이스에서 10250 포트 수신
authentication:
  anonymous:
    enabled: false                            # 익명 인증 비활성화
  webhook:
    enabled: true                             # 인증 요청을 kube-apiserver에 위임 : ServiceAccount 토큰, bootstrap 토큰 처리 가능
  x509:                                       # kubelet에 접근하는 클라이언트 인증서 검증용 CA
    clientCAFile: "/var/lib/kubelet/ca.crt"   # (상동) 대상 : kube-apiserver, metrics-server, kubectl (직접 접근 시)
authorization:                                
  mode: Webhook                               # 인가 요청을 kube-apiserver에 위임 : Node Authorizer + RBAC 적용됨
cgroupDriver: systemd
containerRuntimeEndpoint: "unix:///var/run/containerd/containerd.sock"  # CRI 엔드포인트
enableServer: true                            # kubelet API 서버 활성화 , false면 apiserver가 kubelet 접근 불가
failSwapOn: false
maxPods: 16                                   # 노드당 최대 파드 수 16개
memorySwap:
  swapBehavior: NoSwap
port: 10250                                   # kubelet HTTPS API 포트 : 로그, exec, stats, metrics 접근에 사용
resolvConf: "/etc/resolv.conf"                # 파드에 전달할 DNS 설정 파일
registerNode: true                            # kubelet이 API 서버에 Node 객체 자동 등록
runtimeRequestTimeout: "15m"                  # CRI 요청 최대 대기 시간 : 이미지 pull, container start 등
tlsCertFile: "/var/lib/kubelet/kubelet.crt"   # TLS 서버 인증서 (kubelet 자신) : kubelet HTTPS 서버의 서버 인증서
tlsPrivateKeyFile: "/var/lib/kubelet/kubelet.key"


root@ip-172-31-11-186:~/kubernetes-the-hard-way# for HOST in node-0 node-1; do
  SUBNET=$(grep ${HOST} machines.txt | cut -d " " -f 4)
  sed "s|SUBNET|$SUBNET|g" \
    configs/10-bridge.conf > 10-bridge.conf

  sed "s|SUBNET|$SUBNET|g" \
    configs/kubelet-config.yaml > kubelet-config.yaml

  scp 10-bridge.conf kubelet-config.yaml \
  root@${HOST}:~/
done
root@node-0's password: 
10-bridge.conf                                            100%  265   757.4KB/s   00:00    
kubelet-config.yaml                                       100%  610     1.6MB/s   00:00    
root@node-1's password: 
10-bridge.conf                                            100%  265   636.9KB/s   00:00    
kubelet-config.yaml                                       100%  610     1.6MB/s   00:00    


# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-0 ls -l /root
root@node-0's password: 
total 8
-rw-r--r-- 1 root root 265 Jan 10 13:22 10-bridge.conf
-rw-r--r-- 1 root root 610 Jan 10 13:22 kubelet-config.yaml

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-1 ls -l /root
root@node-1's password: 
total 8
-rw-r--r-- 1 root root 265 Jan 10 13:22 10-bridge.conf
-rw-r--r-- 1 root root 610 Jan 10 13:22 kubelet-config.yaml

# 파일 확인 및 node-0/1에 전달
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat configs/99-loopback.conf ; echo
{
  "cniVersion": "1.1.0",
  "name": "lo",
  "type": "loopback"
}

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat configs/containerd-config.toml ; echo
version = 2

[plugins."io.containerd.grpc.v1.cri"]
  [plugins."io.containerd.grpc.v1.cri".containerd]
    snapshotter = "overlayfs"
    default_runtime_name = "runc"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    runtime_type = "io.containerd.runc.v2"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
[plugins."io.containerd.grpc.v1.cri".cni]
  bin_dir = "/opt/cni/bin"
  conf_dir = "/etc/cni/net.d"

root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat configs/kube-proxy-config.yaml ; echo
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"


root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat units/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.targetroot@ip-172-31-11-186:~/kubernetes-the-hard-way# cat units/kubeletcat units/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \
  --config=/var/lib/kubelet/kubelet-config.yaml \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat units/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target


root@ip-172-31-11-186:~/kubernetes-the-hard-way# for HOST in node-0 node-1; do
  scp \
    downloads/worker/* \
    downloads/client/kubectl \
    configs/99-loopback.conf \
    configs/containerd-config.toml \
    configs/kube-proxy-config.yaml \
    units/containerd.service \
    units/kubelet.service \
    units/kube-proxy.service \
    root@${HOST}:~/
done
root@node-0's password: 
containerd                                                100%   56MB 123.6MB/s   00:00    
containerd-shim-runc-v2                                   100% 8060KB 209.5MB/s   00:00    
containerd-stress                                         100%   22MB 236.0MB/s   00:00    
crictl                                                    100%   38MB 251.5MB/s   00:00    
ctr                                                       100%   23MB 252.4MB/s   00:00    
kube-proxy                                                100%   64MB 197.2MB/s   00:00    
kubelet                                                   100%   74MB 106.4MB/s   00:00    
runc                                                      100%   11MB  89.9MB/s   00:00    
kubectl                                                   100%   55MB 128.3MB/s   00:00    
99-loopback.conf                                          100%   65    78.0KB/s   00:00    
containerd-config.toml                                    100%  470     1.4MB/s   00:00    
kube-proxy-config.yaml                                    100%  184   534.6KB/s   00:00    
containerd.service                                        100%  352     1.0MB/s   00:00    
kubelet.service                                           100%  365   901.9KB/s   00:00    
kube-proxy.service                                        100%  268   940.3KB/s   00:00    
root@node-1's password: 
containerd                                                100%   56MB 142.4MB/s   00:00    
containerd-shim-runc-v2                                   100% 8060KB 245.1MB/s   00:00    
containerd-stress                                         100%   22MB 269.9MB/s   00:00    
crictl                                                    100%   38MB 263.4MB/s   00:00    
ctr                                                       100%   23MB 242.6MB/s   00:00    
kube-proxy                                                100%   64MB 238.7MB/s   00:00    
kubelet                                                   100%   74MB 245.1MB/s   00:00    
runc                                                      100%   11MB 252.5MB/s   00:00    
kubectl                                                   100%   55MB 209.9MB/s   00:00    
99-loopback.conf                                          100%   65   149.0KB/s   00:00    
containerd-config.toml                                    100%  470     1.1MB/s   00:00    
kube-proxy-config.yaml                                    100%  184   471.0KB/s   00:00    
containerd.service                                        100%  352   978.9KB/s   00:00    
kubelet.service                                           100%  365   828.7KB/s   00:00    
kube-proxy.service                                        100%  268   519.0KB/s   00:00    


root@ip-172-31-11-186:~/kubernetes-the-hard-way# for HOST in node-0 node-1; do
  scp \
    downloads/cni-plugins/* \
    root@${HOST}:~/cni-plugins/
done
root@node-0's password: 
LICENSE                                                   100%   11KB  21.0MB/s   00:00    
README.md                                                 100% 2343     7.1MB/s   00:00    
bandwidth                                                 100% 4546KB  42.0MB/s   00:00    
bridge                                                    100% 5163KB  89.1MB/s   00:00    
dhcp                                                      100%   12MB 147.6MB/s   00:00    
dummy                                                     100% 4734KB 248.1MB/s   00:00    
firewall                                                  100% 5191KB 242.0MB/s   00:00    
host-device                                               100% 4680KB 364.0MB/s   00:00    
host-local                                                100% 3965KB 343.0MB/s   00:00    
ipvlan                                                    100% 4757KB 253.0MB/s   00:00    
loopback                                                  100% 4018KB 238.3MB/s   00:00    
macvlan                                                   100% 4788KB 240.5MB/s   00:00    
portmap                                                   100% 4603KB 286.7MB/s   00:00    
ptp                                                       100% 4958KB 280.1MB/s   00:00    
sbr                                                       100% 4232KB 208.9MB/s   00:00    
static                                                    100% 3566KB 324.0MB/s   00:00    
tap                                                       100% 4813KB 341.7MB/s   00:00    
tuning                                                    100% 4110KB 208.3MB/s   00:00    
vlan                                                      100% 4754KB 221.9MB/s   00:00    
vrf                                                       100% 4383KB 219.6MB/s   00:00    
root@node-1's password: 
LICENSE                                                   100%   11KB  18.4MB/s   00:00    
README.md                                                 100% 2343     6.0MB/s   00:00    
bandwidth                                                 100% 4546KB  28.0MB/s   00:00    
bridge                                                    100% 5163KB 264.9MB/s   00:00    
dhcp                                                      100%   12MB 200.5MB/s   00:00    
dummy                                                     100% 4734KB 303.2MB/s   00:00    
firewall                                                  100% 5191KB 302.2MB/s   00:00    
host-device                                               100% 4680KB 291.3MB/s   00:00    
host-local                                                100% 3965KB 260.0MB/s   00:00    
ipvlan                                                    100% 4757KB 263.6MB/s   00:00    
loopback                                                  100% 4018KB 155.9MB/s   00:00    
macvlan                                                   100% 4788KB 128.7MB/s   00:00    
portmap                                                   100% 4603KB 286.0MB/s   00:00    
ptp                                                       100% 4958KB 258.3MB/s   00:00    
sbr                                                       100% 4232KB 316.7MB/s   00:00    
static                                                    100% 3566KB 230.9MB/s   00:00    
tap                                                       100% 4813KB 261.4MB/s   00:00    
tuning                                                    100% 4110KB 205.0MB/s   00:00    
vlan                                                      100% 4754KB 263.0MB/s   00:00    
vrf                                                       100% 4383KB 244.2MB/s   00:00    


# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-0 ls -l /root
root@node-0's password: 
total 358584
-rw-r--r-- 1 root root      265 Jan 10 13:22 10-bridge.conf
-rw-r--r-- 1 root root       65 Jan 10 13:25 99-loopback.conf
drwxr-xr-x 2 root root     4096 Jan 10 13:25 cni-plugins
-rwxr-xr-x 1 root root 58584656 Jan 10 13:25 containerd
-rw-r--r-- 1 root root      470 Jan 10 13:25 containerd-config.toml
-rwxr-xr-x 1 root root  8253624 Jan 10 13:25 containerd-shim-runc-v2
-rwxr-xr-x 1 root root 22929761 Jan 10 13:25 containerd-stress
-rw-r--r-- 1 root root      352 Jan 10 13:25 containerd.service
-rwxr-xr-x 1 root root 40076447 Jan 10 13:25 crictl
-rwxr-xr-x 1 root root 23830881 Jan 10 13:25 ctr
-rwxr-xr-x 1 root root 66842776 Jan 10 13:25 kube-proxy
-rw-r--r-- 1 root root      184 Jan 10 13:25 kube-proxy-config.yaml
-rw-r--r-- 1 root root      268 Jan 10 13:25 kube-proxy.service
-rwxr-xr-x 1 root root 57323672 Jan 10 13:25 kubectl
-rwxr-xr-x 1 root root 77406468 Jan 10 13:25 kubelet
-rw-r--r-- 1 root root      610 Jan 10 13:22 kubelet-config.yaml
-rw-r--r-- 1 root root      365 Jan 10 13:25 kubelet.service
-rwxr-xr-x 1 root root 11854432 Jan 10 13:25 runc

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-1 ls -l /root
root@node-1's password: 
total 358584
-rw-r--r-- 1 root root      265 Jan 10 13:22 10-bridge.conf
-rw-r--r-- 1 root root       65 Jan 10 13:25 99-loopback.conf
drwxr-xr-x 2 root root     4096 Jan 10 13:25 cni-plugins
-rwxr-xr-x 1 root root 58584656 Jan 10 13:25 containerd
-rw-r--r-- 1 root root      470 Jan 10 13:25 containerd-config.toml
-rwxr-xr-x 1 root root  8253624 Jan 10 13:25 containerd-shim-runc-v2
-rwxr-xr-x 1 root root 22929761 Jan 10 13:25 containerd-stress
-rw-r--r-- 1 root root      352 Jan 10 13:25 containerd.service
-rwxr-xr-x 1 root root 40076447 Jan 10 13:25 crictl
-rwxr-xr-x 1 root root 23830881 Jan 10 13:25 ctr
-rwxr-xr-x 1 root root 66842776 Jan 10 13:25 kube-proxy
-rw-r--r-- 1 root root      184 Jan 10 13:25 kube-proxy-config.yaml
-rw-r--r-- 1 root root      268 Jan 10 13:25 kube-proxy.service
-rwxr-xr-x 1 root root 57323672 Jan 10 13:25 kubectl
-rwxr-xr-x 1 root root 77406468 Jan 10 13:25 kubelet
-rw-r--r-- 1 root root      610 Jan 10 13:22 kubelet-config.yaml
-rw-r--r-- 1 root root      365 Jan 10 13:25 kubelet.service
-rwxr-xr-x 1 root root 11854432 Jan 10 13:25 runc

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-0 ls -l /root/cni-plugins
root@node-0's password: 
total 89772
-rwxr-xr-x 1 root root    11357 Jan 10 13:25 LICENSE
-rwxr-xr-x 1 root root     2343 Jan 10 13:25 README.md
-rwxr-xr-x 1 root root  4655178 Jan 10 13:25 bandwidth
-rwxr-xr-x 1 root root  5287212 Jan 10 13:25 bridge
-rwxr-xr-x 1 root root 12762814 Jan 10 13:25 dhcp
-rwxr-xr-x 1 root root  4847854 Jan 10 13:25 dummy
-rwxr-xr-x 1 root root  5315134 Jan 10 13:25 firewall
-rwxr-xr-x 1 root root  4792010 Jan 10 13:25 host-device
-rwxr-xr-x 1 root root  4060355 Jan 10 13:25 host-local
-rwxr-xr-x 1 root root  4870719 Jan 10 13:25 ipvlan
-rwxr-xr-x 1 root root  4114939 Jan 10 13:25 loopback
-rwxr-xr-x 1 root root  4903324 Jan 10 13:25 macvlan
-rwxr-xr-x 1 root root  4713429 Jan 10 13:25 portmap
-rwxr-xr-x 1 root root  5076613 Jan 10 13:25 ptp
-rwxr-xr-x 1 root root  4333422 Jan 10 13:25 sbr
-rwxr-xr-x 1 root root  3651755 Jan 10 13:25 static
-rwxr-xr-x 1 root root  4928874 Jan 10 13:25 tap
-rwxr-xr-x 1 root root  4208424 Jan 10 13:25 tuning
-rwxr-xr-x 1 root root  4868252 Jan 10 13:25 vlan
-rwxr-xr-x 1 root root  4488658 Jan 10 13:25 vrf

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-1 ls -l /root/cni-plugins
root@node-1's password: 
total 89772
-rwxr-xr-x 1 root root    11357 Jan 10 13:25 LICENSE
-rwxr-xr-x 1 root root     2343 Jan 10 13:25 README.md
-rwxr-xr-x 1 root root  4655178 Jan 10 13:25 bandwidth
-rwxr-xr-x 1 root root  5287212 Jan 10 13:25 bridge
-rwxr-xr-x 1 root root 12762814 Jan 10 13:25 dhcp
-rwxr-xr-x 1 root root  4847854 Jan 10 13:25 dummy
-rwxr-xr-x 1 root root  5315134 Jan 10 13:25 firewall
-rwxr-xr-x 1 root root  4792010 Jan 10 13:25 host-device
-rwxr-xr-x 1 root root  4060355 Jan 10 13:25 host-local
-rwxr-xr-x 1 root root  4870719 Jan 10 13:25 ipvlan
-rwxr-xr-x 1 root root  4114939 Jan 10 13:25 loopback
-rwxr-xr-x 1 root root  4903324 Jan 10 13:25 macvlan
-rwxr-xr-x 1 root root  4713429 Jan 10 13:25 portmap
-rwxr-xr-x 1 root root  5076613 Jan 10 13:25 ptp
-rwxr-xr-x 1 root root  4333422 Jan 10 13:25 sbr
-rwxr-xr-x 1 root root  3651755 Jan 10 13:25 static
-rwxr-xr-x 1 root root  4928874 Jan 10 13:25 tap
-rwxr-xr-x 1 root root  4208424 Jan 10 13:25 tuning
-rwxr-xr-x 1 root root  4868252 Jan 10 13:25 vlan
-rwxr-xr-x 1 root root  4488658 Jan 10 13:25 vrf
```

### Provisioning a Kubernetes Worker Node : node-0, node-1 에 접속해서 실행

#### node-0 접속 후 실행
```bash
# ssh root@node-0
-----------------------------------------------------------

root@ip-172-31-8-112:~# pwd
/root
root@ip-172-31-8-112:~# ls -l
total 358584
-rw-r--r-- 1 root root      265 Jan 10 13:22 10-bridge.conf
-rw-r--r-- 1 root root       65 Jan 10 13:25 99-loopback.conf
drwxr-xr-x 2 root root     4096 Jan 10 13:25 cni-plugins
-rwxr-xr-x 1 root root 58584656 Jan 10 13:25 containerd
-rw-r--r-- 1 root root      470 Jan 10 13:25 containerd-config.toml
-rwxr-xr-x 1 root root  8253624 Jan 10 13:25 containerd-shim-runc-v2
-rwxr-xr-x 1 root root 22929761 Jan 10 13:25 containerd-stress
-rw-r--r-- 1 root root      352 Jan 10 13:25 containerd.service
-rwxr-xr-x 1 root root 40076447 Jan 10 13:25 crictl
-rwxr-xr-x 1 root root 23830881 Jan 10 13:25 ctr
-rwxr-xr-x 1 root root 66842776 Jan 10 13:25 kube-proxy
-rw-r--r-- 1 root root      184 Jan 10 13:25 kube-proxy-config.yaml
-rw-r--r-- 1 root root      268 Jan 10 13:25 kube-proxy.service
-rwxr-xr-x 1 root root 57323672 Jan 10 13:25 kubectl
-rwxr-xr-x 1 root root 77406468 Jan 10 13:25 kubelet
-rw-r--r-- 1 root root      610 Jan 10 13:22 kubelet-config.yaml
-rw-r--r-- 1 root root      365 Jan 10 13:25 kubelet.service
-rwxr-xr-x 1 root root 11854432 Jan 10 13:25 runc


# Install the OS dependencies : The socat binary enables support for the kubectl port-forward command.
root@ip-172-31-8-112:~# apt-get -y install socat conntrack ipset kmod psmisc bridge-utils
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
socat is already the newest version (1.8.0.3-1).
kmod is already the newest version (34.2-2).
kmod set to manually installed.
psmisc is already the newest version (23.7-2).
The following additional packages will be installed:
  libipset13t64
Suggested packages:
  ifupdown nftables
The following NEW packages will be installed:
  bridge-utils conntrack ipset libipset13t64
0 upgraded, 4 newly installed, 0 to remove and 25 not upgraded.
Need to get 187 kB of archives.
After this operation, 659 kB of additional disk space will be used.
Get:1 file:/etc/apt/mirrors/debian.list Mirrorlist [38 B]
Get:2 https://cdn-aws.deb.debian.org/debian trixie/main amd64 bridge-utils amd64 1.7.1-4+b1 [34.7 kB]
Get:3 https://cdn-aws.deb.debian.org/debian trixie/main amd64 conntrack amd64 1:1.4.8-2 [35.6 kB]
Get:4 https://cdn-aws.deb.debian.org/debian trixie/main amd64 libipset13t64 amd64 7.22-1+b1 [69.7 kB]
Get:5 https://cdn-aws.deb.debian.org/debian trixie/main amd64 ipset amd64 7.22-1+b1 [46.6 kB]
Fetched 187 kB in 0s (2785 kB/s)
Selecting previously unselected package bridge-utils.
(Reading database ... 33577 files and directories currently installed.)
Preparing to unpack .../bridge-utils_1.7.1-4+b1_amd64.deb ...
Unpacking bridge-utils (1.7.1-4+b1) ...
Selecting previously unselected package conntrack.
Preparing to unpack .../conntrack_1%3a1.4.8-2_amd64.deb ...
Unpacking conntrack (1:1.4.8-2) ...
Selecting previously unselected package libipset13t64:amd64.
Preparing to unpack .../libipset13t64_7.22-1+b1_amd64.deb ...
Unpacking libipset13t64:amd64 (7.22-1+b1) ...
Selecting previously unselected package ipset.
Preparing to unpack .../ipset_7.22-1+b1_amd64.deb ...
Unpacking ipset (7.22-1+b1) ...
Setting up conntrack (1:1.4.8-2) ...
Setting up libipset13t64:amd64 (7.22-1+b1) ...
Setting up bridge-utils (1.7.1-4+b1) ...
Setting up ipset (7.22-1+b1) ...
Processing triggers for man-db (2.13.1-1) ...
Processing triggers for libc-bin (2.41-12) ...

# Disable Swap : Verify if swap is disabled:
root@ip-172-31-8-112:~# swapon --show
root@ip-172-31-8-112:~#

# Create the installation directories
root@ip-172-31-8-112:~# mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

# Install the worker binaries:
root@ip-172-31-8-112:~# mv crictl kube-proxy kubelet runc /usr/local/bin/
root@ip-172-31-8-112:~# mv containerd containerd-shim-runc-v2 containerd-stress /bin/
root@ip-172-31-8-112:~# mv cni-plugins/* /opt/cni/bin/


# Configure CNI Networking

## Create the bridge network configuration file:

root@ip-172-31-8-112:~# mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/
root@ip-172-31-8-112:~# cat /etc/cni/net.d/10-bridge.conf 
{
  "cniVersion": "1.0.0",
  "name": "bridge",
  "type": "bridge",
  "bridge": "cni0",
  "isGateway": true,
  "ipMasq": true,
  "ipam": {
    "type": "host-local",
    "ranges": [
      [{"subnet": "10.200.0.0/24"}]
    ],
    "routes": [{"dst": "0.0.0.0/0"}]
  }
}

## To ensure network traffic crossing the CNI bridge network is processed by iptables, load and configure the br-netfilter kernel module:
root@ip-172-31-8-112:~# lsmod | grep netfilter
root@ip-172-31-8-112:~# modprobe br-netfilter
root@ip-172-31-8-112:~# echo "br-netfilter" >> /etc/modules-load.d/modules.conf
root@ip-172-31-8-112:~# lsmod | grep netfilter
br_netfilter           36864  0
bridge                372736  1 br_netfilter

root@ip-172-31-8-112:~# echo "net.bridge.bridge-nf-call-iptables = 1"  >> /etc/sysctl.d/kubernetes.conf
root@ip-172-31-8-112:~# echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/kubernetes.conf
root@ip-172-31-8-112:~# sysctl -p /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1


# Configure containerd : Install the containerd configuration files:
root@ip-172-31-8-112:~# mkdir -p /etc/containerd/
root@ip-172-31-8-112:~# mv containerd-config.toml /etc/containerd/config.toml
root@ip-172-31-8-112:~# mv containerd.service /etc/systemd/system/
root@ip-172-31-8-112:~# cat /etc/containerd/config.toml ; echo
version = 2

[plugins."io.containerd.grpc.v1.cri"]
  [plugins."io.containerd.grpc.v1.cri".containerd]
    snapshotter = "overlayfs"
    default_runtime_name = "runc"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    runtime_type = "io.containerd.runc.v2"
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
[plugins."io.containerd.grpc.v1.cri".cni]
  bin_dir = "/opt/cni/bin"
  conf_dir = "/etc/cni/net.d"

version = 2

[plugins."io.containerd.grpc.v1.cri"]               # CRI 플러그인 활성화 : kubelet은 이 플러그인을 통해 containerd와 통신
  [plugins."io.containerd.grpc.v1.cri".containerd]  # containerd 기본 런타임 설정
    snapshotter = "overlayfs"                       # 컨테이너 파일시스템 레이어 관리 방식 : Linux표준/성능최적
    default_runtime_name = "runc"                   # 기본 OCI 런타임 : 파드가 별도 지정 없을 경우 runc 사용
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]  # runc 런타임 상세 설정
    runtime_type = "io.containerd.runc.v2"                        # containerd 최신 runc shim
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]  # runc 옵션
    SystemdCgroup = true                                                  # containerd가 cgroup을 systemd로 관리 
[plugins."io.containerd.grpc.v1.cri".cni]           # CNI 설정
  bin_dir = "/opt/cni/bin"                          # CNI 플러그인 바이너리 위치
  conf_dir = "/etc/cni/net.d"                       # CNI 네트워크 설정 파일 위치

# kubelet ↔ containerd 연결 Flow
kubelet
  ↓ CRI (gRPC)
unix:///var/run/containerd/containerd.sock
  ↓
containerd CRI plugin
  ↓
runc
  ↓
Linux namespaces / cgroups

# Configure the Kubelet : Create the kubelet-config.yaml configuration file:
root@ip-172-31-8-112:~# mv kubelet-config.yaml /var/lib/kubelet/
root@ip-172-31-8-112:~# mv kubelet.service /etc/systemd/system/

# Configure the Kubernetes Proxy
root@ip-172-31-8-112:~# mv kube-proxy-config.yaml /var/lib/kube-proxy/
root@ip-172-31-8-112:~# mv kube-proxy.service /etc/systemd/system/

# Start the Worker Services
root@ip-172-31-8-112:~# systemctl daemon-reload
root@ip-172-31-8-112:~# systemctl enable containerd kubelet kube-proxy
Created symlink '/etc/systemd/system/multi-user.target.wants/containerd.service' → '/etc/systemd/system/containerd.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/kubelet.service' → '/etc/systemd/system/kubelet.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/kube-proxy.service' → '/etc/systemd/system/kube-proxy.service'.
root@ip-172-31-8-112:~# systemctl start containerd kubelet kube-proxy

# 확인
root@ip-172-31-8-112:~# systemctl status kubelet --no-pager
● kubelet.service - Kubernetes Kubelet
     Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-01-10 13:31:58 UTC; 5s ago
 Invocation: 96d872578a0d4e00bdb098878200fb23
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 2788 (kubelet)
      Tasks: 11 (limit: 2293)
     Memory: 20.3M (peak: 21.3M)
        CPU: 332ms
     CGroup: /system.slice/kubelet.service
             └─2788 /usr/local/bin/kubelet --config=/var/lib/kubelet/kubelet-config.yaml --…

Jan 10 13:32:02 ip-172-31-8-112 kubelet[2788]: I0110 13:32:02.021776    2788 kubelet_no…ach"
Jan 10 13:32:02 ip-172-31-8-112 kubelet[2788]: I0110 13:32:02.022662    2788 kubelet_no…ory"
Jan 10 13:32:02 ip-172-31-8-112 kubelet[2788]: I0110 13:32:02.022690    2788 kubelet_no…ure"
Jan 10 13:32:02 ip-172-31-8-112 kubelet[2788]: I0110 13:32:02.022698    2788 kubelet_no…PID"
Jan 10 13:32:02 ip-172-31-8-112 kubelet[2788]: I0110 13:32:02.022720    2788 kubelet_no…112"
Jan 10 13:32:02 ip-172-31-8-112 kubelet[2788]: E0110 13:32:02.035943    2788 kubelet_node_s…
Jan 10 13:32:02 ip-172-31-8-112 kubelet[2788]: W0110 13:32:02.110362    2788 reflector.go:5…
Jan 10 13:32:02 ip-172-31-8-112 kubelet[2788]: E0110 13:32:02.110410    2788 reflector.go:1…
Jan 10 13:32:02 ip-172-31-8-112 kubelet[2788]: I0110 13:32:02.805065    2788 csi_plugin.go:…
Jan 10 13:32:03 ip-172-31-8-112 kubelet[2788]: I0110 13:32:03.805343    2788 csi_plugin.go:…
Hint: Some lines were ellipsized, use -l to show in full.

root@ip-172-31-8-112:~# systemctl status containerd --no-pager
● containerd.service - containerd container runtime
     Loaded: loaded (/etc/systemd/system/containerd.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-01-10 13:31:53 UTC; 16s ago
 Invocation: 7dcffc0f89904034ba331f56ffaf99dc
       Docs: https://containerd.io
    Process: 2750 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 2753 (containerd)
      Tasks: 8 (limit: 2293)
     Memory: 17.7M (peak: 23.8M)
        CPU: 173ms
     CGroup: /system.slice/containerd.service
             └─2753 /bin/containerd

Jan 10 13:31:53 ip-172-31-8-112 containerd[2753]: time="2026-01-10T13:31:53.569622239Z"…trpc
Jan 10 13:31:53 ip-172-31-8-112 containerd[2753]: time="2026-01-10T13:31:53.569691074Z"…sock
Jan 10 13:31:53 ip-172-31-8-112 containerd[2753]: time="2026-01-10T13:31:53.569792564Z"…tor"
Jan 10 13:31:53 ip-172-31-8-112 containerd[2753]: time="2026-01-10T13:31:53.569864980Z"…ult"
Jan 10 13:31:53 ip-172-31-8-112 containerd[2753]: time="2026-01-10T13:31:53.569922269Z"…ver"
Jan 10 13:31:53 ip-172-31-8-112 containerd[2753]: time="2026-01-10T13:31:53.569983107Z"…NRI"
Jan 10 13:31:53 ip-172-31-8-112 containerd[2753]: time="2026-01-10T13:31:53.570033922Z"…..."
Jan 10 13:31:53 ip-172-31-8-112 containerd[2753]: time="2026-01-10T13:31:53.570086220Z"…..."
Jan 10 13:31:53 ip-172-31-8-112 containerd[2753]: time="2026-01-10T13:31:53.570148027Z"…ate"
Jan 10 13:31:53 ip-172-31-8-112 containerd[2753]: time="2026-01-10T13:31:53.570288566Z"…99s"

Hint: Some lines were ellipsized, use -l to show in full.
root@ip-172-31-8-112:~# systemctl status kube-proxy --no-pager
● kube-proxy.service - Kubernetes Kube Proxy
     Loaded: loaded (/etc/systemd/system/kube-proxy.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-01-10 13:31:53 UTC; 19s ago
 Invocation: af63226b2d8e4140bc0d2bdb6e6cf8a7
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 2751 (kube-proxy)
      Tasks: 5 (limit: 2293)
     Memory: 13.8M (peak: 14.9M)
        CPU: 94ms
     CGroup: /system.slice/kube-proxy.service
             └─2751 /usr/local/bin/kube-proxy --config=/var/lib/kube-proxy/kube-proxy-confi…

Jan 10 13:31:53 ip-172-31-8-112 systemd[1]: Started kube-proxy.service - Kubernetes Ku…roxy.
Jan 10 13:31:53 ip-172-31-8-112 kube-proxy[2751]: E0110 13:31:53.524483    2751 proxier…ATH"
Jan 10 13:31:53 ip-172-31-8-112 kube-proxy[2751]: E0110 13:31:53.525400    2751 proxier…ATH"
Jan 10 13:31:53 ip-172-31-8-112 kube-proxy[2751]: E0110 13:31:53.567005    2751 server.…und"
Jan 10 13:31:54 ip-172-31-8-112 kube-proxy[2751]: E0110 13:31:54.726877    2751 server.…und"
Jan 10 13:31:56 ip-172-31-8-112 kube-proxy[2751]: E0110 13:31:56.748438    2751 server.…und"
Jan 10 13:32:00 ip-172-31-8-112 kube-proxy[2751]: E0110 13:32:00.935709    2751 server.…und"
Jan 10 13:32:10 ip-172-31-8-112 kube-proxy[2751]: E0110 13:32:10.400630    2751 server.…und"
Hint: Some lines were ellipsized, use -l to show in full.

root@ip-172-31-8-112:~# exit
-----------------------------------------------------------
```


제대로 안됐네..
```bash
# ec2의 기본 hostname과 실습에 사용하는 hostname "node-0"이 안맞아서 발생
kubelet_node_status.go:113] "Unable to register node with API server, error getting existing node" err="nodes "ip-172-31-8-112" is forbidden: User "system:node:node-0" cannot get resource "nodes" in API group "" at the cluster scope: node 'node-0' cannot read 'ip-172-31-8-112', only its own Node object" node="ip-172-31-8-112"

root@ip-172-31-5-196:~# hostnamectl set-hostname node-0
root@ip-172-31-5-196:~# exit

root@node-0:~# service kubelet restart
root@node-0:~# journalctl -u kubelet -f
Jan 10 13:48:13 node-0 kubelet[3265]: I0110 13:48:13.051105    3265 kubelet_node_status.go:687] "Recording event message for node" node="node-0" event="NodeHasNoDiskPressure"
Jan 10 13:48:13 node-0 kubelet[3265]: I0110 13:48:13.051122    3265 kubelet_node_status.go:687] "Recording event message for node" node="node-0" event="NodeHasSufficientPID"
Jan 10 13:48:13 node-0 kubelet[3265]: I0110 13:48:13.051831    3265 kubelet_node_status.go:75] "Attempting to register node" node="node-0"
Jan 10 13:48:13 node-0 kubelet[3265]: I0110 13:48:13.056942    3265 kubelet_node_status.go:78] "Successfully registered node" node="node-0"
Jan 10 13:48:13 node-0 kubelet[3265]: I0110 13:48:13.370533    3265 kubelet_node_status.go:687] "Recording event message for node" node="node-0" event="NodeReady"
Jan 10 13:48:13 node-0 kubelet[3265]: I0110 13:48:13.370591    3265 kubelet_node_status.go:501] "Fast updating node status as it just became ready"
Jan 10 13:48:13 node-0 kubelet[3265]: I0110 13:48:13.833350    3265 apiserver.go:52] "Watching apiserver"
Jan 10 13:48:13 node-0 kubelet[3265]: I0110 13:48:13.835356    3265 reflector.go:376] Caches populated for *v1.Pod from pkg/kubelet/config/apiserver.go:66
Jan 10 13:48:13 node-0 kubelet[3265]: I0110 13:48:13.835502    3265 kubelet.go:2468] "SyncLoop ADD" source="api" pods=[]
Jan 10 13:48:13 node-0 kubelet[3265]: I0110 13:48:13.855194    3265 desired_state_of_world_populator.go:157] "Finished populating initial desired state of world"
```

jumpbox 에서 server 접속하여 kubectl node 정보 확인
```bash
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh server "kubectl get nodes -owide --kubeconfig admin.kubeconfig"
root@server's password: 
NAME     STATUS   ROLES    AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION              CONTAINER-RUNTIME
node-0   Ready    <none>   2m36s   v1.32.3   172.31.8.112   <none>        Debian GNU/Linux 13 (trixie)   6.12.48+deb13-cloud-amd64   containerd://2.1.0-beta.0
```

### node-1 접속 후 실행
```bash
# ssh root@node-1
---
root@ip-172-31-15-209:~# hostnamectl set-hostname node-1
root@ip-172-31-15-209:~# exit
```

```bash
# ssh root@node-1
---
# Install the OS dependencies : The socat binary enables support for the kubectl port-forward command.

root@node-1:~# apt-get -y install socat conntrack ipset kmod psmisc bridge-utils
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
socat is already the newest version (1.8.0.3-1).
kmod is already the newest version (34.2-2).
kmod set to manually installed.
psmisc is already the newest version (23.7-2).
The following additional packages will be installed:
  libipset13t64
Suggested packages:
  ifupdown nftables
The following NEW packages will be installed:
  bridge-utils conntrack ipset libipset13t64
0 upgraded, 4 newly installed, 0 to remove and 25 not upgraded.
Need to get 187 kB of archives.
After this operation, 659 kB of additional disk space will be used.
Get:1 file:/etc/apt/mirrors/debian.list Mirrorlist [38 B]
Get:2 https://cdn-aws.deb.debian.org/debian trixie/main amd64 bridge-utils amd64 1.7.1-4+b1 [34.7 kB]
Get:3 https://cdn-aws.deb.debian.org/debian trixie/main amd64 conntrack amd64 1:1.4.8-2 [35.6 kB]
Get:4 https://cdn-aws.deb.debian.org/debian trixie/main amd64 libipset13t64 amd64 7.22-1+b1 [69.7 kB]
Get:5 https://cdn-aws.deb.debian.org/debian trixie/main amd64 ipset amd64 7.22-1+b1 [46.6 kB]
Fetched 187 kB in 0s (2602 kB/s)
Selecting previously unselected package bridge-utils.
(Reading database ... 33577 files and directories currently installed.)
Preparing to unpack .../bridge-utils_1.7.1-4+b1_amd64.deb ...
Unpacking bridge-utils (1.7.1-4+b1) ...
Selecting previously unselected package conntrack.
Preparing to unpack .../conntrack_1%3a1.4.8-2_amd64.deb ...
Unpacking conntrack (1:1.4.8-2) ...
Selecting previously unselected package libipset13t64:amd64.
Preparing to unpack .../libipset13t64_7.22-1+b1_amd64.deb ...
Unpacking libipset13t64:amd64 (7.22-1+b1) ...
Selecting previously unselected package ipset.
Preparing to unpack .../ipset_7.22-1+b1_amd64.deb ...
Unpacking ipset (7.22-1+b1) ...
Setting up conntrack (1:1.4.8-2) ...
Setting up libipset13t64:amd64 (7.22-1+b1) ...
Setting up bridge-utils (1.7.1-4+b1) ...
Setting up ipset (7.22-1+b1) ...
Processing triggers for man-db (2.13.1-1) ...
Processing triggers for libc-bin (2.41-12) ...


# Create the installation directories
root@node-1:~# mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

# Install the worker binaries:
root@node-1:~# mv crictl kube-proxy kubelet runc /usr/local/bin/
root@node-1:~# mv containerd containerd-shim-runc-v2 containerd-stress /bin/
root@node-1:~# mv cni-plugins/* /opt/cni/bin/

# Configure CNI Networking

## Create the bridge network configuration file:
root@node-1:~# mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/
root@node-1:~# cat /etc/cni/net.d/10-bridge.conf 
{
  "cniVersion": "1.0.0",
  "name": "bridge",
  "type": "bridge",
  "bridge": "cni0",
  "isGateway": true,
  "ipMasq": true,
  "ipam": {
    "type": "host-local",
    "ranges": [
      [{"subnet": "10.200.1.0/24"}]
    ],
    "routes": [{"dst": "0.0.0.0/0"}]
  }
}

## To ensure network traffic crossing the CNI bridge network is processed by iptables, load and configure the br-netfilter kernel module:

root@node-1:~# modprobe br-netfilter
root@node-1:~# echo "br-netfilter" >> /etc/modules-load.d/modules.conf
root@node-1:~# lsmod | grep netfilter
br_netfilter           36864  0
bridge                372736  1 br_netfilter

root@node-1:~# echo "net.bridge.bridge-nf-call-iptables = 1"  >> /etc/sysctl.d/kubernetes.conf
root@node-1:~# echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/kubernetes.conf
root@node-1:~# sysctl -p /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1

# Configure containerd : Install the containerd configuration files:
root@node-1:~# mkdir -p /etc/containerd/
root@node-1:~# mv containerd-config.toml /etc/containerd/config.toml
root@node-1:~# mv containerd.service /etc/systemd/system/

# Configure the Kubelet : Create the kubelet-config.yaml configuration file:
root@node-1:~# mv kubelet-config.yaml /var/lib/kubelet/
root@node-1:~# mv kubelet.service /etc/systemd/system/

# Configure the Kubernetes Proxy
root@node-1:~# mv kube-proxy-config.yaml /var/lib/kube-proxy/
root@node-1:~# mv kube-proxy.service /etc/systemd/system/

# Start the Worker Services
root@node-1:~# systemctl daemon-reload
root@node-1:~# systemctl enable containerd kubelet kube-proxy
Created symlink '/etc/systemd/system/multi-user.target.wants/containerd.service' → '/etc/systemd/system/containerd.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/kubelet.service' → '/etc/systemd/system/kubelet.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/kube-proxy.service' → '/etc/systemd/system/kube-proxy.service'.
root@node-1:~# systemctl start containerd kubelet kube-proxy


# 확인
root@node-1:~# systemctl status kubelet --no-pager
● kubelet.service - Kubernetes Kubelet
     Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-01-10 13:57:23 UTC; 16s ago
 Invocation: 9cce20b87e6f41c8a347813b5980ed7a
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 2766 (kubelet)
      Tasks: 12 (limit: 2293)
     Memory: 22.9M (peak: 23.4M)
        CPU: 368ms
     CGroup: /system.slice/kubelet.service
             └─2766 /usr/local/bin/kubelet --config=/var/lib/kubelet/kubelet-config.yaml --…

Jan 10 13:57:23 node-1 kubelet[2766]: I0110 13:57:23.428803    2766 kubelet_node_statu…sure"
Jan 10 13:57:23 node-1 kubelet[2766]: I0110 13:57:23.428820    2766 kubelet_node_statu…tPID"
Jan 10 13:57:23 node-1 kubelet[2766]: I0110 13:57:23.429504    2766 kubelet_node_statu…de-1"
Jan 10 13:57:23 node-1 kubelet[2766]: I0110 13:57:23.440684    2766 kubelet_node_statu…de-1"
Jan 10 13:57:23 node-1 kubelet[2766]: I0110 13:57:23.651925    2766 kubelet_node_statu…eady"
Jan 10 13:57:23 node-1 kubelet[2766]: I0110 13:57:23.651984    2766 kubelet_node_statu…eady"
Jan 10 13:57:24 node-1 kubelet[2766]: I0110 13:57:24.183279    2766 apiserver.go:52] "…rver"
Jan 10 13:57:24 node-1 kubelet[2766]: I0110 13:57:24.185588    2766 reflector.go:376] …go:66
Jan 10 13:57:24 node-1 kubelet[2766]: I0110 13:57:24.185768    2766 kubelet.go:2468] "…ds=[]
Jan 10 13:57:24 node-1 kubelet[2766]: I0110 13:57:24.195451    2766 desired_state_of_w…orld"
Hint: Some lines were ellipsized, use -l to show in full.


root@node-1:~# systemctl status containerd --no-pager
● containerd.service - containerd container runtime
     Loaded: loaded (/etc/systemd/system/containerd.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-01-10 13:57:23 UTC; 20s ago
 Invocation: f2bcae872c354d84b966b373074fc258
       Docs: https://containerd.io
    Process: 2758 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 2762 (containerd)
      Tasks: 7 (limit: 2293)
     Memory: 17.7M (peak: 23.7M)
        CPU: 162ms
     CGroup: /system.slice/containerd.service
             └─2762 /bin/containerd

Jan 10 13:57:23 node-1 containerd[2762]: time="2026-01-10T13:57:23.157363594Z" level=i…vent"
Jan 10 13:57:23 node-1 containerd[2762]: time="2026-01-10T13:57:23.157402748Z" level=i…tate"
Jan 10 13:57:23 node-1 containerd[2762]: time="2026-01-10T13:57:23.157491458Z" level=i…itor"
Jan 10 13:57:23 node-1 containerd[2762]: time="2026-01-10T13:57:23.157510100Z" level=i…ault"
Jan 10 13:57:23 node-1 containerd[2762]: time="2026-01-10T13:57:23.157518835Z" level=i…rver"
Jan 10 13:57:23 node-1 containerd[2762]: time="2026-01-10T13:57:23.157532779Z" level=i… NRI"
Jan 10 13:57:23 node-1 containerd[2762]: time="2026-01-10T13:57:23.157544196Z" level=i…p..."
Jan 10 13:57:23 node-1 containerd[2762]: time="2026-01-10T13:57:23.157551019Z" level=i…s..."
Jan 10 13:57:23 node-1 containerd[2762]: time="2026-01-10T13:57:23.157562780Z" level=i…tate"
Jan 10 13:57:23 node-1 containerd[2762]: time="2026-01-10T13:57:23.157634290Z" level=i…424s"
Hint: Some lines were ellipsized, use -l to show in full.


root@node-1:~# systemctl status kube-proxy --no-pager
● kube-proxy.service - Kubernetes Kube Proxy
     Loaded: loaded (/etc/systemd/system/kube-proxy.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-01-10 13:57:23 UTC; 26s ago
 Invocation: 136beed4d4c649ab9ca9b4a1488d09a7
       Docs: https://github.com/kubernetes/kubernetes
   Main PID: 2759 (kube-proxy)
      Tasks: 6 (limit: 2293)
     Memory: 16.6M (peak: 17.3M)
        CPU: 244ms
     CGroup: /system.slice/kube-proxy.service
             └─2759 /usr/local/bin/kube-proxy --config=/var/lib/kube-proxy/kube-proxy-confi…

Jan 10 13:57:24 node-1 kube-proxy[2759]: I0110 13:57:24.269434    2759 server.go:499] …CK=""
Jan 10 13:57:24 node-1 kube-proxy[2759]: I0110 13:57:24.272154    2759 config.go:199] …ller"
Jan 10 13:57:24 node-1 kube-proxy[2759]: I0110 13:57:24.272346    2759 shared_informer…onfig
Jan 10 13:57:24 node-1 kube-proxy[2759]: I0110 13:57:24.272470    2759 config.go:105] …ller"
Jan 10 13:57:24 node-1 kube-proxy[2759]: I0110 13:57:24.272585    2759 shared_informer…onfig
Jan 10 13:57:24 node-1 kube-proxy[2759]: I0110 13:57:24.273394    2759 config.go:329] …ller"
Jan 10 13:57:24 node-1 kube-proxy[2759]: I0110 13:57:24.273514    2759 shared_informer…onfig
Jan 10 13:57:24 node-1 kube-proxy[2759]: I0110 13:57:24.372921    2759 shared_informer…onfig
Jan 10 13:57:24 node-1 kube-proxy[2759]: I0110 13:57:24.373161    2759 shared_informer…onfig
Jan 10 13:57:24 node-1 kube-proxy[2759]: I0110 13:57:24.373676    2759 shared_informer…onfig
Hint: Some lines were ellipsized, use -l to show in full.

exit
---
```

jumpbox 에서 server 접속하여 kubectl node 정보 확인

```bash
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh server "kubectl get nodes -owide --kubeconfig admin.kubeconfig"
root@server's password: 
NAME     STATUS   ROLES    AGE    VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION              CONTAINER-RUNTIME
node-0   Ready    <none>   11m    v1.32.3   172.31.8.112    <none>        Debian GNU/Linux 13 (trixie)   6.12.48+deb13-cloud-amd64   containerd://2.1.0-beta.0
node-1   Ready    <none>   110s   v1.32.3   172.31.15.209   <none>        Debian GNU/Linux 13 (trixie)   6.12.48+deb13-cloud-amd64   containerd://2.1.0-beta.0

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh server "kubectl get pod -A --kubeconfig admin.kubeconfig"
root@server's password: 
No resources found
```

## 10 - Configuring kubectl for Remote Access
jumpbox 노드에서 kubectl 을 ‘admin 자격증명’으로 사용을 위한 설정

```bash
# The Admin Kubernetes Configuration File

# You should be able to ping server.kubernetes.local based on the /etc/hosts DNS entry from a previous lab.
root@ip-172-31-11-186:~/kubernetes-the-hard-way# curl -s --cacert ca.crt https://server.kubernetes.local:6443/version | jq
{
  "major": "1",
  "minor": "32",
  "gitVersion": "v1.32.3",
  "gitCommit": "32cc146f75aad04beaaa245a7157eb35063a9f99",
  "gitTreeState": "clean",
  "buildDate": "2025-03-11T19:52:21Z",
  "goVersion": "go1.23.6",
  "compiler": "gc",
  "platform": "linux/amd64"
}

# Generate a kubeconfig file suitable for authenticating as the admin user:
root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://server.kubernetes.local:6443
Cluster "kubernetes-the-hard-way" set.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-credentials admin \
  --client-certificate=admin.crt \
  --client-key=admin.key
User "admin" set.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin
Context "kubernetes-the-hard-way" created.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl config use-context kubernetes-the-hard-way
Switched to context "kubernetes-the-hard-way".

# 위 명령어를 실행한 결과 kubectl 명령줄 도구에서 사용하는 기본 위치 ~/.kube/config에 kubectl 파일이 생성됩니다. 
# 이는 또한 구성을 지정하지 않고도 kubectl 명령어를 실행할 수 있음을 의미합니다.

# Check the version of the remote Kubernetes cluster:
root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl version
Client Version: v1.32.3
Kustomize Version: v5.5.0
Server Version: v1.32.3

# List the nodes in the remote Kubernetes cluster
root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl get nodes -v=6
I0110 14:01:47.436246    2780 loader.go:402] Config loaded from file:  /root/.kube/config
I0110 14:01:47.437132    2780 envvar.go:172] "Feature gate default state" feature="ClientsAllowCBOR" enabled=false
I0110 14:01:47.437157    2780 envvar.go:172] "Feature gate default state" feature="ClientsPreferCBOR" enabled=false
I0110 14:01:47.437165    2780 envvar.go:172] "Feature gate default state" feature="InformerResourceVersion" enabled=false
I0110 14:01:47.437308    2780 envvar.go:172] "Feature gate default state" feature="WatchListClient" enabled=false
I0110 14:01:47.437213    2780 cert_rotation.go:140] Starting client certificate rotation controller
I0110 14:01:47.461469    2780 round_trippers.go:560] GET https://server.kubernetes.local:6443/api?timeout=32s 200 OK in 23 milliseconds
I0110 14:01:47.464078    2780 round_trippers.go:560] GET https://server.kubernetes.local:6443/apis?timeout=32s 200 OK in 1 milliseconds
I0110 14:01:47.476697    2780 round_trippers.go:560] GET https://server.kubernetes.local:6443/api/v1/nodes?limit=500 200 OK in 2 milliseconds
NAME     STATUS   ROLES    AGE     VERSION
node-0   Ready    <none>   13m     v1.32.3
node-1   Ready    <none>   4m24s   v1.32.3


root@ip-172-31-11-186:~/kubernetes-the-hard-way# cat /root/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZURENDQXpTZ0F3SUJBZ0lVSEZjTnZpeGtuRnlBRm15M053VWZETGtmaHhzd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1EZ3dOVm9YRFRNMk1ERXhNVEV5Ck1EZ3dOVm93UVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01DbGRoYzJocGJtZDBiMjR4RURBT0JnTlYKQkFjTUIxTmxZWFIwYkdVeEN6QUpCZ05WQkFNTUFrTkJNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QQpNSUlDQ2dLQ0FnRUF2RVJWR3k3dWJFaU9KdmNnVnkyUm5VNjhMbXVGSVI4NlgxVnRSM1BOYWlEWHVaWVkrcDk4ClJ6dVI4YjQ2TXdLMXB3SXc2VnJJOWU3MmQxMmw0UXJNZHJUdXMxTWY1ZVpFMHE1N3pPWUR0Ry9VOUxHeER1djMKYms1bThjZ1p4SThMR0o0UW02bjZXUmRVMFhVbEhBcTdzNVdyam5YUnpoZmZRcG5wM2ZHTnBJM2tRM21UWUdydwpXbFk2VUQ0ejlZeDJxa1dHdGFkRndVVVdXbHhBOWlGRlpRYUt1OFZPbnhIZkZpckowSmxnaTBJaTYyYXhyd2lOCllOK3luR2NEZDUyelhONldDc3NJamQ2V3BGb1JzMW1kY29QdXFlRzhwSk1tRFpldTlSN0IxNENoQUl6b09wRWoKY0N4M2Q3NTdubnVnSEtZa0xQWlIxQXVIMERKYngvblB2d09WZXhQVEpVbnR1eTFmenVrMnpaSXlMRDBHa0tlVwpzRTg2a1JEdEVwcmw0Sk1yaUN2MTVCdU9RNDQrVXJzWm5GcENwa0hPbWREN1E0dzRaZXNpd3dQcFhudnhmNFNoCmNoenBxcHBTY1dyclFZbno0OHVpSkQ0OUVHUzJ0RDdBZ3dvVlJDSWhzeER0alhiOFBSRjZVSWtBUUJlSnhoT2EKcERUR0tiMzNCQThCT1BVcmwxbDJtc2ljYVBzcWNrM3ZYWUpaYkRZSCt0WkxaNnFZZ2gxZnhQUCtJaFhzMXplbgp5cndiV2tlNnk0UGwwR1JXWCtHcU5NL0NXUlh3YVUwbVZTRG9wZlJvb0VKdzg2bVJtVk85K2NGOFBZUkttaFhPCldXYUw2cXdZU0NmL252NjZSdTRjdmlVNVRvV2w2VnVnRzlZdm1LM2xycFhhS2g4VWdIRkd6MDhDQXdFQUFhTTgKTURvd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZHZG9pVUJucVdxYwpvL05FVnI5YUoxZVkvOVVBTUEwR0NTcUdTSWIzRFFFQkRRVUFBNElDQVFBdVJpM1hNWmRyclNwdTRQRTFTazdWCnBlU2k0dVBEVEpONlc3ckJYWUNEVVZWUjNDNjFWbUpYMVdoZndIeUZMV1grQkpFcmRjMHVHTWNERC9qMDdUYUMKSHIwMmNqaUpjSE9uSCt2ZVVHZXZXNmRaeWx2TXp1RStpZWxPTVlEN3pvcUs5NmwwWTF5U09URDdzWFBUWm9PcAo0S0dabDF5N3ZmSTJpdTJHcVdlUDhBQXB0Qm5JY0VLOW85R0ZQcmhhN25wTS9ROEloNHZCNHFMRi9EVENDRmExCjRMajliV3VndE1GQm1ld09ic3RaeHpLc1NVekFKdk1MV2tMYVNLdXpCWldlWXBWeW4vNEorSmRmeTBJcm1tOXYKaVBMN0o3SHZ2YzJOZFFpK01pcU00ZkJobk1KQ1JBMTBFem1iT1gxUlN6b0NVTnkycFhoYmdkbDFMK2hERm1yQQpvdmNNZ1huNzFJUlU3R0V4VG02UTRtR2ZEZHpuNllEQzQ2R3RBRjVZVlFoVFg1V0FjV1BIMktTNVBKeVJvYmRNCmxmWnhMdytIa1E2dnQzaVloWXFDRjNFU0kyN2hRajFQQXp5T2FqaVl5RGxjREVRRVArWGs3bEtDaXR0UWNMQ0sKZXlCcWJXM0RiZW1MZ0dVa2dWcWRMK2lzN3RVR3pGOGU0a1J4NmRLZkw2Ny9XK0c5b0FyZjExeDBMM1MwWEhybgpZUURNemtXQ1hyZnQ0TVJ6V2p5aWRDYUJ3VlRjSHdZejc0Z1ZUMUIzWlhFYmJCamZBS3RUVFVtcEV4anFuczlxCm1RMzkvV05ybE5ZN014WGJOYkVXSStOeisrS2JnenFFNkhnbUs3SGwxc21JME1PTlpiYTZEQ1NzRHgwb1ZPMjIKMlgvU1VJMk5tNStUd2VkRFVRcktFUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://server.kubernetes.local:6443
  name: kubernetes-the-hard-way
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: admin
  name: kubernetes-the-hard-way
current-context: kubernetes-the-hard-way
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate: /root/kubernetes-the-hard-way/admin.crt
    client-key: /root/kubernetes-the-hard-way/admin.key
```

## 11 - Provisioning Pod Network Routes
node-0/1에 PodCIDR과 통신을 위한 OS 커널에 (수동) 라우팅 설정

| 항목               | 네트워크 대역 or IP     |
| ---------------- | ----------------- |
| clusterCIDR      | 10.200.0.0/16     |
| → node-0 PodCIDR | **10.200.0.0/24** |
| → node-1 PodCIDR | **10.200.1.0/24** |
| ServiceCIDR      | 10.32.0.0/24      |
| → api clusterIP  | 10.32.0.1         |

```bash
# The Routing Table
# In this section you will gather the information required to create routes in the kubernetes-the-hard-way VPC network.

# Print the internal IP address and Pod CIDR range for each worker instance:

root@ip-172-31-11-186:~/kubernetes-the-hard-way# SERVER_IP=$(grep server machines.txt | cut -d " " -f 1)
root@ip-172-31-11-186:~/kubernetes-the-hard-way# NODE_0_IP=$(grep node-0 machines.txt | cut -d " " -f 1)
root@ip-172-31-11-186:~/kubernetes-the-hard-way# NODE_0_SUBNET=$(grep node-0 machines.txt | cut -d " " -f 4)
root@ip-172-31-11-186:~/kubernetes-the-hard-way# NODE_1_IP=$(grep node-1 machines.txt | cut -d " " -f 1)
root@ip-172-31-11-186:~/kubernetes-the-hard-way# NODE_1_SUBNET=$(grep node-1 machines.txt | cut -d " " -f 4)


root@ip-172-31-11-186:~/kubernetes-the-hard-way# echo $SERVER_IP $NODE_0_IP $NODE_0_SUBNET $NODE_1_IP $NODE_1_SUBNET
172.31.5.196 172.31.8.112 10.200.0.0/24 172.31.15.209 10.200.1.0/24


root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh server ip -c route
root@server's password: 
default via 172.31.0.1 dev ens5 proto dhcp src 172.31.5.196 metric 100 
172.31.0.0/20 dev ens5 proto kernel scope link src 172.31.5.196 metric 100 
172.31.0.1 dev ens5 proto dhcp scope link src 172.31.5.196 metric 100 
172.31.0.2 dev ens5 proto dhcp scope link src 172.31.5.196 metric 100 



root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh root@server <<EOF
  ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
  ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF
Pseudo-terminal will not be allocated because stdin is not a terminal.


root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh server ip -c route
root@server's password: 
default via 172.31.0.1 dev ens5 proto dhcp src 172.31.5.196 metric 100 
10.200.0.0/24 via 172.31.8.112 dev ens5 
10.200.1.0/24 via 172.31.15.209 dev ens5 
172.31.0.0/20 dev ens5 proto kernel scope link src 172.31.5.196 metric 100 
172.31.0.1 dev ens5 proto dhcp scope link src 172.31.5.196 metric 100 
172.31.0.2 dev ens5 proto dhcp scope link src 172.31.5.196 metric 100 





root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-0 ip -c route
root@node-0's password: 
default via 172.31.0.1 dev ens5 proto dhcp src 172.31.8.112 metric 100 
172.31.0.0/20 dev ens5 proto kernel scope link src 172.31.8.112 metric 100 
172.31.0.1 dev ens5 proto dhcp scope link src 172.31.8.112 metric 100 
172.31.0.2 dev ens5 proto dhcp scope link src 172.31.8.112 metric 100

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh root@node-0 <<EOF
  ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF
Pseudo-terminal will not be allocated because stdin is not a terminal.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-0 ip -c route
root@node-0's password: 
default via 172.31.0.1 dev ens5 proto dhcp src 172.31.8.112 metric 100 
10.200.1.0/24 via 172.31.15.209 dev ens5 
172.31.0.0/20 dev ens5 proto kernel scope link src 172.31.8.112 metric 100 
172.31.0.1 dev ens5 proto dhcp scope link src 172.31.8.112 metric 100 
172.31.0.2 dev ens5 proto dhcp scope link src 172.31.8.112 metric 100 




root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-1 ip -c route
root@node-1's password: 
default via 172.31.0.1 dev ens5 proto dhcp src 172.31.15.209 metric 100 
172.31.0.0/20 dev ens5 proto kernel scope link src 172.31.15.209 metric 100 
172.31.0.1 dev ens5 proto dhcp scope link src 172.31.15.209 metric 100 
172.31.0.2 dev ens5 proto dhcp scope link src 172.31.15.209 metric 100


root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh root@node-1 <<EOF
  ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
EOF
Pseudo-terminal will not be allocated because stdin is not a terminal.


root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-1 ip -c route
root@node-1's password: 
default via 172.31.0.1 dev ens5 proto dhcp src 172.31.15.209 metric 100 
10.200.0.0/24 via 172.31.8.112 dev ens5 
172.31.0.0/20 dev ens5 proto kernel scope link src 172.31.15.209 metric 100 
172.31.0.1 dev ens5 proto dhcp scope link src 172.31.15.209 metric 100 
172.31.0.2 dev ens5 proto dhcp scope link src 172.31.15.209 metric 100 


```



## 12 - Smoke Test

### Data Encryption

```bash
# Create a generic secret
root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl create secret generic kubernetes-the-hard-way --from-literal="mykey=mydata"
secret/kubernetes-the-hard-way created

# 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl get secret kubernetes-the-hard-way
NAME                      TYPE     DATA   AGE
kubernetes-the-hard-way   Opaque   1      14s

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl get secret kubernetes-the-hard-way -o yaml
apiVersion: v1
data:
  mykey: bXlkYXRh
kind: Secret
metadata:
  creationTimestamp: "2026-01-10T14:14:09Z"
  name: kubernetes-the-hard-way
  namespace: default
  resourceVersion: "5439"
  uid: 7d80f9b4-b106-494b-8088-35a56b08e222
type: Opaque

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl get secret kubernetes-the-hard-way -o jsonpath='{.data.mykey}' ; echo
bXlkYXRh

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl get secret kubernetes-the-hard-way -o jsonpath='{.data.mykey}' | base64 -d ; echo
mydata




# Print a hexdump of the kubernetes-the-hard-way secret stored in etcd
## etcdctl get … : etcd 내부 key 직접 조회, kubernetes API 우회(매우 강력한 접근)
## Secret 리소스의 etcd 실제 저장 경로: /registry/<resource>/<namespace>/<name> -> /registry/secrets/default/kubernetes-the-hard-way


```bash
# Create a generic secret
**kubectl create secret generic kubernetes-the-hard-way --from-literal="mykey=mydata"**

# 확인
kubectl get secret kubernetes-the-hard-way
kubectl get secret kubernetes-the-hard-way -o yaml
kubectl get secret kubernetes-the-hard-way -o jsonpath='{.data.mykey}' ; echo
kubectl get secret kubernetes-the-hard-way -o jsonpath='{.data.mykey}' | base64 -d ; echo

# Print a hexdump of the kubernetes-the-hard-way secret stored in etcd
## etcdctl get … : etcd 내부 key 직접 조회, kubernetes API 우회(매우 강력한 접근)
## Secret 리소스의 etcd 실제 저장 경로: /registry/<resource>/<namespace>/<name> -> /registry/secrets/default/kubernetes-the-hard-way
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh root@server \
    'etcdctl get /registry/secrets/default/kubernetes-the-hard-way | hexdump -C'
root@server's password: 
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret|
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a d2 1c 01 d7 80 7a 8b  |:v1:key1:.....z.|
00000050  ed a9 90 e5 9a 31 e2 c2  f4 c0 3e c4 08 5d af 4e  |.....1....>..].N|
00000060  2b b3 2c 02 26 56 e0 e3  b2 54 87 38 3d d0 49 61  |+.,.&V...T.8=.Ia|
00000070  72 9c 2c a4 8c 98 d3 da  0d 34 2b c7 13 18 b8 26  |r.,......4+....&|
00000080  ca 04 44 1d 4e d5 d5 8d  78 85 6f 20 bb 65 8d 19  |..D.N...x.o .e..|
00000090  ee 57 10 3d 07 fa 41 23  b6 d3 97 98 f0 64 ec e8  |.W.=..A#.....d..|
000000a0  0c 1f 68 a0 a8 ef d6 b3  86 7b df 41 23 09 4e f3  |..h......{.A#.N.|
000000b0  6c 4a c9 9b 21 76 67 49  5c 9b 67 6a ac 63 e1 73  |lJ..!vgI\.gj.c.s|
000000c0  fe 82 f3 f5 10 88 5b 89  06 66 2e 7a d3 b3 c8 7c  |......[..f.z...||
000000d0  d4 7b 69 d7 1d d9 a4 05  45 45 26 49 6a ec ad 6c  |.{i.....EE&Ij..l|
000000e0  74 a5 45 6a 9f 76 f3 f9  0d 55 21 84 a5 61 df da  |t.Ej.v...U!..a..|
000000f0  73 98 41 f9 38 df 36 99  67 09 2f 7b 3f 54 92 b3  |s.A.8.6.g./{?T..|
00000100  da 71 79 ec d9 58 6f 83  37 24 b5 c5 6e 8f 64 c4  |.qy..Xo.7$..n.d.|
00000110  bf 40 94 50 3d d4 51 a6  8d 8e 27 f0 80 1e 4c 9f  |.@.P=.Q...'...L.|
00000120  a8 ba 20 6f 55 e6 2d 2c  e6 71 23 58 83 a2 fe c3  |.. oU.-,.q#X....|
00000130  db 1e 1a 1f f1 7a d5 bd  43 a4 4d 94 98 8f b5 c8  |.....z..C.M.....|
00000140  64 4c de bf cc 04 63 74  8e 93 e1 73 fc 65 88 d0  |dL....ct...s.e..|
00000150  e1 24 f8 4c 1f d9 24 7c  3a 0a                    |.$.L..$|:.|
0000015a

# 참고
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret| # etcd key 이름은 항상 평문 : 어떤 리소스인지 식별 가능
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a 44 61 dc 08 37 97 eb  |:v1:key1:Da..7..|
00000050  d4 d0 5b 14 39 23 a5 74  1b 3c a4 56 e4 a1 d1 17  |..[.9#.t.<.V....|
... # Kubernetes Secret이 etcd에 AES-CBC 방식으로 정상 암호화되어 저장되고 있음을 증명하는 출력
# k8s:enc	: Kubernetes 암호화 포맷
# aescbc	: 암호화 알고리즘 (AES-CBC)
# v1	    : encryption provider 버전
# key1	  : 사용된 encryption key 이름
# 이후 데이터는 암호화된 데이터
```

### Deployments , Port Forwarding , Log, Exec, Service(NodePort)

```bash
# Deployments

# Create a deployment for the nginx web server:
root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl get pod
No resources found in default namespace.

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl create deployment nginx --image=nginx:latest
deployment.apps/nginx created

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl scale deployment nginx --replicas=2
deployment.apps/nginx scaled

root@ip-172-31-11-186:~/kubernetes-the-hard-way# kubectl get pod -owide
NAME                     READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
nginx-54c98b4f84-554rr   1/1     Running   0          19s   10.200.0.2   node-0   <none>           <none>
nginx-54c98b4f84-p92fd   1/1     Running   0          11s   10.200.1.2   node-1   <none>           <none>


root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-0 crictl ps
root@node-0's password: 
time="2026-01-10T14:18:18Z" level=warning msg="Config \"/etc/crictl.yaml\" does not exist, trying next: \"/usr/local/bin/crictl.yaml\""
time="2026-01-10T14:18:18Z" level=warning msg="runtime connect using default endpoints: [unix:///run/containerd/containerd.sock unix:///run/crio/crio.sock unix:///var/run/cri-dockerd.sock]. As the default settings are now deprecated, you should set the endpoint instead."
time="2026-01-10T14:18:18Z" level=warning msg="Image connect using default endpoints: [unix:///run/containerd/containerd.sock unix:///run/crio/crio.sock unix:///var/run/cri-dockerd.sock]. As the default settings are now deprecated, you should set the endpoint instead."
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD                      NAMESPACE
8c836a704b7ba       2e97da2b9cb35       27 seconds ago      Running             nginx               0                   97559162e52ed       nginx-54c98b4f84-554rr   default


root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-1 crictl ps
root@node-1's password: 
time="2026-01-10T14:18:56Z" level=warning msg="Config \"/etc/crictl.yaml\" does not exist, trying next: \"/usr/local/bin/crictl.yaml\""
time="2026-01-10T14:18:56Z" level=warning msg="runtime connect using default endpoints: [unix:///run/containerd/containerd.sock unix:///run/crio/crio.sock unix:///var/run/cri-dockerd.sock]. As the default settings are now deprecated, you should set the endpoint instead."
time="2026-01-10T14:18:56Z" level=warning msg="Image connect using default endpoints: [unix:///run/containerd/containerd.sock unix:///run/crio/crio.sock unix:///var/run/cri-dockerd.sock]. As the default settings are now deprecated, you should set the endpoint instead."
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD                      NAMESPACE
00354e7b921e2       2e97da2b9cb35       57 seconds ago      Running             nginx               0                   71075a3afbd6b       nginx-54c98b4f84-p92fd   default


root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-0 pstree -ap
root@node-0's password: 
systemd,1
  |-agetty,755 -o -- \\u --noreset --noclear - linux
  |-agetty,756 -o -- \\u --noreset --noclear --keep-baud 115200,57600,38400,9600 - vt220
  |-amazon-ssm-agen,1378
  |   |-ssm-agent-worke,1472
  |   |   |-{ssm-agent-worke},1473
  |   |   |-{ssm-agent-worke},1474
  |   |   |-{ssm-agent-worke},1475
  |   |   |-{ssm-agent-worke},1476
  |   |   |-{ssm-agent-worke},1477
  |   |   |-{ssm-agent-worke},1478
  |   |   |-{ssm-agent-worke},1479
  |   |   |-{ssm-agent-worke},1480
  |   |   |-{ssm-agent-worke},1483
  |   |   `-{ssm-agent-worke},1491
  |   |-{amazon-ssm-agen},1379
  |   |-{amazon-ssm-agen},1380
  |   |-{amazon-ssm-agen},1381
  |   |-{amazon-ssm-agen},1382
  |   |-{amazon-ssm-agen},1384
  |   |-{amazon-ssm-agen},1416
  |   |-{amazon-ssm-agen},1417
  |   `-{amazon-ssm-agen},2313
  |-containerd,2753
  |   |-{containerd},2764
  |   |-{containerd},2766
  |   |-{containerd},2767
  |   |-{containerd},2768
  |   |-{containerd},2770
  |   |-{containerd},2798
  |   |-{containerd},3626
  |   `-{containerd},3704
  |-containerd-shim,3666 -namespace k8s.io -id 97559162e52edec2b334f1f4d0d12bf09cd08bb694df065906a337e79f8a1eeb -address/ru
  |   |-nginx,3719
  |   |   |-nginx,3754
  |   |   `-nginx,3755
  |   |-pause,3689
  |   |-{containerd-shim},3667
  |   |-{containerd-shim},3668
  |   |-{containerd-shim},3669
  |   |-{containerd-shim},3670
  |   |-{containerd-shim},3671
  |   |-{containerd-shim},3672
  |   |-{containerd-shim},3673
  |   |-{containerd-shim},3674
  |   |-{containerd-shim},3675
  |   |-{containerd-shim},3703
  |   `-{containerd-shim},3764
  |-dbus-daemon,735 --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
  |-kube-proxy,2751 --config=/var/lib/kube-proxy/kube-proxy-config.yaml
  |   |-{kube-proxy},2755
  |   |-{kube-proxy},2756
  |   |-{kube-proxy},2757
  |   `-{kube-proxy},2759
  |-kubelet,3265 --config=/var/lib/kubelet/kubelet-config.yaml --kubeconfig=/var/lib/kubelet/kubeconfig --v=2
  |   |-{kubelet},3266
  |   |-{kubelet},3267
  |   |-{kubelet},3268
  |   |-{kubelet},3269
  |   |-{kubelet},3271
  |   |-{kubelet},3274
  |   |-{kubelet},3275
  |   |-{kubelet},3290
  |   `-{kubelet},3300
  |-polkitd,794 --no-debug --log-level=notice
  |   |-{polkitd},799
  |   |-{polkitd},800
  |   `-{polkitd},801
  |-sshd,1291
  |   `-sshd-session,3805
  |       `-sshd-session,3826
  |           `-pstree,3827 -ap
  |-systemd,3811 --user
  |   `-(sd-pam),3813
  |-systemd-journal,307
  |-systemd-logind,743
  |-systemd-network,674
  |-systemd-resolve,358
  |-systemd-timesyn,359
  |   `-{systemd-timesyn},369
  |-systemd-udevd,368
  `-unattended-upgr,782 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal


root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-1 pstree -ap
root@node-1's password: 
systemd,1
  |-agetty,761 -o -- \\u --noreset --noclear - linux
  |-agetty,763 -o -- \\u --noreset --noclear --keep-baud 115200,57600,38400,9600 - vt220
  |-amazon-ssm-agen,1377
  |   |-ssm-agent-worke,1471
  |   |   |-{ssm-agent-worke},1472
  |   |   |-{ssm-agent-worke},1473
  |   |   |-{ssm-agent-worke},1474
  |   |   |-{ssm-agent-worke},1475
  |   |   |-{ssm-agent-worke},1476
  |   |   |-{ssm-agent-worke},1477
  |   |   |-{ssm-agent-worke},1478
  |   |   |-{ssm-agent-worke},1479
  |   |   |-{ssm-agent-worke},1480
  |   |   `-{ssm-agent-worke},1481
  |   |-{amazon-ssm-agen},1378
  |   |-{amazon-ssm-agen},1379
  |   |-{amazon-ssm-agen},1380
  |   |-{amazon-ssm-agen},1381
  |   |-{amazon-ssm-agen},1383
  |   |-{amazon-ssm-agen},1448
  |   |-{amazon-ssm-agen},1449
  |   `-{amazon-ssm-agen},1992
  |-containerd,2762
  |   |-{containerd},2770
  |   |-{containerd},2771
  |   |-{containerd},2772
  |   |-{containerd},2773
  |   |-{containerd},2780
  |   |-{containerd},2969
  |   |-{containerd},3202
  |   |-{containerd},3281
  |   `-{containerd},3284
  |-containerd-shim,3241 -namespace k8s.io -id 71075a3afbd6b302dfb93d9201b14c2aa3bf6707388d6f4e2d9bb576df0fb207 -address/ru
  |   |-nginx,3298
  |   |   |-nginx,3332
  |   |   `-nginx,3333
  |   |-pause,3267
  |   |-{containerd-shim},3242
  |   |-{containerd-shim},3243
  |   |-{containerd-shim},3244
  |   |-{containerd-shim},3245
  |   |-{containerd-shim},3246
  |   |-{containerd-shim},3247
  |   |-{containerd-shim},3248
  |   |-{containerd-shim},3249
  |   |-{containerd-shim},3250
  |   |-{containerd-shim},3251
  |   `-{containerd-shim},3335
  |-dbus-daemon,735 --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
  |-kube-proxy,2759 --config=/var/lib/kube-proxy/kube-proxy-config.yaml
  |   |-{kube-proxy},2763
  |   |-{kube-proxy},2764
  |   |-{kube-proxy},2765
  |   |-{kube-proxy},2768
  |   `-{kube-proxy},2831
  |-kubelet,2766 --config=/var/lib/kubelet/kubelet-config.yaml --kubeconfig=/var/lib/kubelet/kubeconfig --v=2
  |   |-{kubelet},2774
  |   |-{kubelet},2775
  |   |-{kubelet},2776
  |   |-{kubelet},2777
  |   |-{kubelet},2779
  |   |-{kubelet},2791
  |   |-{kubelet},2795
  |   |-{kubelet},2801
  |   |-{kubelet},2804
  |   |-{kubelet},2807
  |   `-{kubelet},2812
  |-polkitd,796 --no-debug --log-level=notice
  |   |-{polkitd},800
  |   |-{polkitd},801
  |   `-{polkitd},802
  |-sshd,1290
  |   `-sshd-session,3382
  |       `-sshd-session,3403
  |           `-pstree,3404 -ap
  |-systemd,3388 --user
  |   `-(sd-pam),3390
  |-systemd-journal,307
  |-systemd-logind,742
  |-systemd-network,674
  |-systemd-resolve,358
  |-systemd-timesyn,359
  |   |-{systemd-timesyn},370
  |   `-{systemd-timesyn},492
  |-systemd-udevd,368
  `-unattended-upgr,791 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal


root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-0 brctl show
root@node-0's password: 
bridge name     bridge id               STP enabled     interfaces
cni0            8000.96fe03b893a7       no              veth05676363

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-1 brctl show
root@node-1's password: 
bridge name     bridge id               STP enabled     interfaces
cni0            8000.daab517ccb79       no              veth53358c14



# 파드 별 veth 인터페이스 생성 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-0 ip addr
root@node-0's password: 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP group default qlen 1000
    link/ether 02:8e:7c:9a:5d:49 brd ff:ff:ff:ff:ff:ff
    altname enp0s5
    altname enx028e7c9a5d49
    inet 172.31.8.112/20 metric 100 brd 172.31.15.255 scope global dynamic ens5
       valid_lft 3481sec preferred_lft 3481sec
    inet6 fe80::8e:7cff:fe9a:5d49/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
3: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 96:fe:03:b8:93:a7 brd ff:ff:ff:ff:ff:ff
    inet 10.200.0.1/24 brd 10.200.0.255 scope global cni0
       valid_lft forever preferred_lft forever
    inet6 fe80::94fe:3ff:feb8:93a7/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
4: veth05676363@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cni0 state UP group default qlen 1000
    link/ether e2:36:3f:8c:25:bd brd ff:ff:ff:ff:ff:ff link-netns cni-649028bf-5f52-ba31-229e-13bcf269d36d
    inet6 fe80::e036:3fff:fe8c:25bd/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever


root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh node-1 ip addr
root@node-1's password: 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP group default qlen 1000
    link/ether 02:59:31:bd:1f:11 brd ff:ff:ff:ff:ff:ff
    altname enp0s5
    altname enx025931bd1f11
    inet 172.31.15.209/20 metric 100 brd 172.31.15.255 scope global dynamic ens5
       valid_lft 3453sec preferred_lft 3453sec
    inet6 fe80::59:31ff:febd:1f11/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
3: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether da:ab:51:7c:cb:79 brd ff:ff:ff:ff:ff:ff
    inet 10.200.1.1/24 brd 10.200.1.255 scope global cni0
       valid_lft forever preferred_lft forever
    inet6 fe80::d8ab:51ff:fe7c:cb79/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
4: veth53358c14@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cni0 state UP group default qlen 1000
    link/ether 82:23:de:28:e8:1f brd ff:ff:ff:ff:ff:ff link-netns cni-834fff8a-34fb-a069-aa4d-ab3441082a37
    inet6 fe80::8023:deff:fe28:e81f/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever



# server 노드에서 파드 IP로 호출 확인
root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh server curl -s 10.200.1.2 | grep title
root@server's password: 
<title>Welcome to nginx!</title>

root@ip-172-31-11-186:~/kubernetes-the-hard-way# ssh server curl -s 10.200.0.2 | grep title
root@server's password: 
<title>Welcome to nginx!</title>


# Port Forwarding
# Retrieve the full name of the nginx pod:

root@ip-172-31-11-186:~/kubernetes-the-hard-way# POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
root@ip-172-31-11-186:~/kubernetes-the-hard-way# echo $POD_NAME
nginx-54c98b4f84-554rr


# Forward port 8080 on your local machine to port 80 of the nginx pod:
root@ip-172-31-11-186:~# kubectl port-forward $POD_NAME 8080:80 &
ps -ef | grep kubectl
[1] 3150
root        3150    3078  0 14:29 pts/4    00:00:00 kubectl port-forward nginx-54c98b4f84-554rr 8080:80
root        3152    3078  0 14:29 pts/4    00:00:00 grep kubectl
root@ip-172-31-11-186:~# Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080


# In a new terminal make an HTTP request using the forwarding address:
root@ip-172-31-11-186:~# curl --head http://127.0.0.1:8080
HTTP/1.1 200 OK
Server: nginx/1.29.4
Date: Sat, 10 Jan 2026 14:29:46 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 09 Dec 2025 18:28:10 GMT
Connection: keep-alive
ETag: "69386a3a-267"
Accept-Ranges: bytes


root@ip-172-31-11-186:~# kubectl port-forward $POD_NAME 8080:80 &
ps -ef | grep kubectl
[1] 3150
root        3150    3078  0 14:29 pts/4    00:00:00 kubectl port-forward nginx-54c98b4f84-554rr 8080:80
root        3152    3078  0 14:29 pts/4    00:00:00 grep kubectl
root@ip-172-31-11-186:~# Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080 # 👀
Handling connection for 8080 # 👀
Handling connection for 8080 # 👀


# Log
# Print the nginx pod logs
root@ip-172-31-11-186:~# kubectl logs $POD_NAME
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/01/10 14:17:51 [notice] 1#1: using the "epoll" event method
2026/01/10 14:17:51 [notice] 1#1: nginx/1.29.4
2026/01/10 14:17:51 [notice] 1#1: built by gcc 14.2.0 (Debian 14.2.0-19) 
2026/01/10 14:17:51 [notice] 1#1: OS: Linux 6.12.48+deb13-cloud-amd64
2026/01/10 14:17:51 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2026/01/10 14:17:51 [notice] 1#1: start worker processes
2026/01/10 14:17:51 [notice] 1#1: start worker process 29
2026/01/10 14:17:51 [notice] 1#1: start worker process 30
127.0.0.1 - - [10/Jan/2026:14:29:35 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:29:38 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:29:39 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:29:46 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"

root@ip-172-31-11-186:~# curl --head http://127.0.0.1:8080
HTTP/1.1 200 OK
Server: nginx/1.29.4
Date: Sat, 10 Jan 2026 14:32:14 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 09 Dec 2025 18:28:10 GMT
Connection: keep-alive
ETag: "69386a3a-267"
Accept-Ranges: bytes


root@ip-172-31-11-186:~# kubectl logs $POD_NAME
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/01/10 14:17:51 [notice] 1#1: using the "epoll" event method
2026/01/10 14:17:51 [notice] 1#1: nginx/1.29.4
2026/01/10 14:17:51 [notice] 1#1: built by gcc 14.2.0 (Debian 14.2.0-19) 
2026/01/10 14:17:51 [notice] 1#1: OS: Linux 6.12.48+deb13-cloud-amd64
2026/01/10 14:17:51 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2026/01/10 14:17:51 [notice] 1#1: start worker processes
2026/01/10 14:17:51 [notice] 1#1: start worker process 29
2026/01/10 14:17:51 [notice] 1#1: start worker process 30
127.0.0.1 - - [10/Jan/2026:14:29:35 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:29:38 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:29:39 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:29:46 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:32:08 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-" # 👀


# 확인 후 port-forward Killed
root@ip-172-31-11-186:~# kill -9 $(pgrep kubectl)
root@ip-172-31-11-186:~# 
[1]+  Killed                  kubectl port-forward $POD_NAME 8080:80


# Exec
# Print the nginx version by executing the nginx -v command in the nginx container:
root@ip-172-31-11-186:~# kubectl exec -ti $POD_NAME -- nginx -v
nginx version: nginx/1.29.4

# Service
# Expose the nginx deployment using a NodePort service:
root@ip-172-31-11-186:~# kubectl expose deployment nginx --port=80 --target-port=80 --type=NodePort
service/nginx exposed


# 확인
root@ip-172-31-11-186:~# kubectl get service,ep nginx
NAME            TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
service/nginx   NodePort   10.32.0.175   <none>        80:30159/TCP   7s

NAME              ENDPOINTS                     AGE
endpoints/nginx   10.200.0.2:80,10.200.1.2:80   7s


# Retrieve the node port assigned to the nginx service:
root@ip-172-31-11-186:~# NODE_PORT=$(kubectl get svc nginx --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
root@ip-172-31-11-186:~# echo $NODE_PORT
30159


# Make an HTTP request using the IP address and the nginx node port:
root@ip-172-31-11-186:~# curl -s -I http://node-0:${NODE_PORT}
HTTP/1.1 200 OK
Server: nginx/1.29.4
Date: Sat, 10 Jan 2026 14:38:24 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 09 Dec 2025 18:28:10 GMT
Connection: keep-alive
ETag: "69386a3a-267"
Accept-Ranges: bytes

root@ip-172-31-11-186:~# curl -s -I http://node-1:${NODE_PORT}
HTTP/1.1 200 OK
Server: nginx/1.29.4
Date: Sat, 10 Jan 2026 14:38:30 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 09 Dec 2025 18:28:10 GMT
Connection: keep-alive
ETag: "69386a3a-267"
Accept-Ranges: bytes
```



## 완료 후 삭제
```bash
terraform destroy
```