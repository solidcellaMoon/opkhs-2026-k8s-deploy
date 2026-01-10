# jumpbox 서버에서 k8s 구성을 위한 초기 설정 진행

```bash
# Sync GitHub Repository
root@jumpbox:~# pwd
/root

root@jumpbox:~# git clone --depth 1 https://github.com/kelseyhightower/kubernetes-the-hard-way.git
Cloning into 'kubernetes-the-hard-way'...
remote: Enumerating objects: 41, done.
remote: Counting objects: 100% (41/41), done.
remote: Compressing objects: 100% (40/40), done.
remote: Total 41 (delta 3), reused 14 (delta 1), pack-reused 0 (from 0)
Receiving objects: 100% (41/41), 29.27 KiB | 7.32 MiB/s, done.
Resolving deltas: 100% (3/3), done.


root@jumpbox:~# cd kubernetes-the-hard-way && tree
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

root@jumpbox:~/kubernetes-the-hard-way# pwd
/root/kubernetes-the-hard-way

# ---

# Download Binaries : k8s 구성을 위한 컴포넌트 다운로드

# CPU 아키텍처 확인
root@jumpbox:~/kubernetes-the-hard-way# dpkg --print-architecture
amd64

# CPU 아키텍처 별 다운로드 목록 정보 다름
root@jumpbox:~/kubernetes-the-hard-way# ls -l downloads-*
-rw-r--r-- 1 root root 839 Jan  4 14:46 downloads-amd64.txt
-rw-r--r-- 1 root root 839 Jan  4 14:46 downloads-arm64.txt

# https://kubernetes.io/releases/download/
root@jumpbox:~/kubernetes-the-hard-way# cat downloads-$(dpkg --print-architecture).txt
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
root@jumpbox:~/kubernetes-the-hard-way# wget -q --show-progress \
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
root@jumpbox:~/kubernetes-the-hard-way# ls -oh downloads
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
root@jumpbox:~/kubernetes-the-hard-way# ARCH=$(dpkg --print-architecture)
root@jumpbox:~/kubernetes-the-hard-way# echo $ARCH
amd64

root@jumpbox:~/kubernetes-the-hard-way# mkdir -p downloads/{client,cni-plugins,controller,worker}
root@jumpbox:~/kubernetes-the-hard-way# tree -d downloads
downloads
├── client
├── cni-plugins
├── controller
└── worker

5 directories

# 압축 풀기
root@jumpbox:~/kubernetes-the-hard-way# tar -xvf downloads/crictl-v1.32.0-linux-${ARCH}.tar.gz \
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


root@jumpbox:~/kubernetes-the-hard-way# tar -xvf downloads/containerd-2.1.0-beta.0-linux-${ARCH}.tar.gz \
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


root@jumpbox:~/kubernetes-the-hard-way# tar -xvf downloads/cni-plugins-linux-${ARCH}-v1.6.2.tgz \
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
root@jumpbox:~/kubernetes-the-hard-way# tar -xvf downloads/etcd-v3.6.0-rc.3-linux-${ARCH}.tar.gz \
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
root@jumpbox:~/kubernetes-the-hard-way# tree downloads/worker/
downloads/worker/
├── containerd
├── containerd-shim-runc-v2
├── containerd-stress
├── crictl
└── ctr

1 directory, 5 files

root@jumpbox:~/kubernetes-the-hard-way# tree downloads/cni-plugins
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

root@jumpbox:~/kubernetes-the-hard-way# ls -l downloads/{etcd,etcdctl}
-rwxr-xr-x 1 admin admin 25219224 Mar 27  2025 downloads/etcd
-rwxr-xr-x 1 admin admin 16421016 Mar 27  2025 downloads/etcdctl

# 파일 이동 
root@jumpbox:~/kubernetes-the-hard-way# mv downloads/{etcdctl,kubectl} downloads/client/
root@jumpbox:~/kubernetes-the-hard-way# mv downloads/{etcd,kube-apiserver,kube-controller-manager,kube-scheduler} downloads/controller/
root@jumpbox:~/kubernetes-the-hard-way# mv downloads/{kubelet,kube-proxy} downloads/worker/
root@jumpbox:~/kubernetes-the-hard-way# mv downloads/runc.${ARCH} downloads/worker/runc

# 확인
root@jumpbox:~/kubernetes-the-hard-way# tree downloads/client/
downloads/client/
├── etcdctl
└── kubectl

1 directory, 2 files

root@jumpbox:~/kubernetes-the-hard-way# tree downloads/controller/
downloads/controller/
├── etcd
├── kube-apiserver
├── kube-controller-manager
└── kube-scheduler

1 directory, 4 files

root@jumpbox:~/kubernetes-the-hard-way# tree downloads/worker/
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
root@jumpbox:~/kubernetes-the-hard-way# ls -l downloads/*gz
-rw-r--r-- 1 root root 52794236 Jan  6  2025 downloads/cni-plugins-linux-amd64-v1.6.2.tgz
-rw-r--r-- 1 root root 38807044 Mar 18  2025 downloads/containerd-2.1.0-beta.0-linux-amd64.tar.gz
-rw-r--r-- 1 root root 19100418 Dec  9  2024 downloads/crictl-v1.32.0-linux-amd64.tar.gz
-rw-r--r-- 1 root root 23577153 Mar 27  2025 downloads/etcd-v3.6.0-rc.3-linux-amd64.tar.gz

root@jumpbox:~/kubernetes-the-hard-way# rm -rf downloads/*gz


# Make the binaries executable.
root@jumpbox:~/kubernetes-the-hard-way# ls -l downloads/{client,cni-plugins,controller,worker}/*
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

root@jumpbox:~/kubernetes-the-hard-way# chmod +x downloads/{client,cni-plugins,controller,worker}/*

root@jumpbox:~/kubernetes-the-hard-way# ls -l downloads/{client,cni-plugins,controller,worker}/*
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
root@jumpbox:~/kubernetes-the-hard-way# tree -ug downloads
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

root@jumpbox:~/kubernetes-the-hard-way# chown root:root downloads/client/etcdctl
root@jumpbox:~/kubernetes-the-hard-way# chown root:root downloads/controller/etcd
root@jumpbox:~/kubernetes-the-hard-way# chown root:root downloads/worker/crictl

root@jumpbox:~/kubernetes-the-hard-way# tree -ug downloads
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
root@jumpbox:~/kubernetes-the-hard-way# ls -l downloads/client/kubectl
-rwxr-xr-x 1 root root 57323672 Mar 12  2025 downloads/client/kubectl

root@jumpbox:~/kubernetes-the-hard-way# cp downloads/client/kubectl /usr/local/bin/

# can be verified by running the kubectl command:
root@jumpbox:~/kubernetes-the-hard-way# kubectl version --client
Client Version: v1.32.3
Kustomize Version: v5.5.0
```
