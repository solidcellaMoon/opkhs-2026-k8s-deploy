# RKE2로 k8s 설치

## 스크립트 기반으로 RKE2 설치
- `INSTALL_RKE2_VERSION`: GitHub에서 다운로드할 RKE2 버전 - stable(기본값)
- `INSTALL_RKE2_TYPE`: 생성할 systemd 서비스의 유형 - server(기본값), agent
- `INSTALL_RKE2_CHANNEL_URL`: RKE2 다운로드 URL을 가져오기 위한 채널 URL
  - [https://update.rke2.io/v1-release/channels](https://update.rke2.io/v1-release/channels) (기본값)
- `INSTALL_RKE2_CHANNEL`: RKE2 다운로드 URL을 가져오는 데 사용할 채널 - stable(기본값), latest, testing
- `INSTALL_RKE2_METHOD`: 사용할 설치 방법 - rpm(RPM 기반 시스템 경우 기본값), tar(그외 경우 기본값)

```bash
# systemd 기반 시스템에 서비스로 편리하게 설치할 수 있는 설치 스크립트를 제공 : 서비스와 바이너리 파일이 컴퓨터에 설치
# https://docs.rke2.io/install/methods
[root@k8s-node1 ~]# curl -sfL https://get.rke2.io --output install.sh
[root@k8s-node1 ~]# chmod +x install.sh

[root@k8s-node1 ~]# INSTALL_RKE2_CHANNEL=v1.33 ./install.sh
[INFO]  using stable RPM repositories
[INFO]  using 1.33 series from channel stable
Rancher RKE2 Common (v1.33)                                        5.0 kB/s | 659  B     00:00    
Rancher RKE2 Common (v1.33)                                         10 kB/s | 2.4 kB     00:00    
Importing GPG key 0xE257814A:
 Userid     : "Rancher (CI) <ci@rancher.com>"
 Fingerprint: C8CF F216 4551 26E9 B9C9 18BE 925E A29A E257 814A
 From       : https://rpm.rancher.io/public.key
Rancher RKE2 Common (v1.33)                                        7.2 kB/s | 2.6 kB     00:00    
Rancher RKE2 1.33 (v1.33)                                          1.4 kB/s | 659  B     00:00    
Rancher RKE2 1.33 (v1.33)                                           77 kB/s | 2.4 kB     00:00    
Importing GPG key 0xE257814A:
 Userid     : "Rancher (CI) <ci@rancher.com>"
 Fingerprint: C8CF F216 4551 26E9 B9C9 18BE 925E A29A E257 814A
 From       : https://rpm.rancher.io/public.key
Rancher RKE2 1.33 (v1.33)                                           17 kB/s | 5.9 kB     00:00    
Dependencies resolved.
===================================================================================================
 Package                    Arch      Version                  Repository                     Size
===================================================================================================
Installing:
 rke2-server                x86_64    1.33.8~rke2r1-0.el9      rancher-rke2-1.33-stable      8.4 k
Upgrading:
 selinux-policy             noarch    38.1.65-1.el9            baseos                         42 k
 selinux-policy-targeted    noarch    38.1.65-1.el9            baseos                        6.5 M
Installing dependencies:
 container-selinux          noarch    4:2.240.0-3.el9_7        appstream                      58 k
 iptables-nft               x86_64    1.8.10-11.el9_5          baseos                        187 k
 libnftnl                   x86_64    1.2.6-4.el9_4            baseos                         87 k
 rke2-common                x86_64    1.33.8~rke2r1-0.el9      rancher-rke2-1.33-stable       27 M
 rke2-selinux               noarch    0.22-1.el9               rancher-rke2-common-stable     22 k

Transaction Summary
===================================================================================================
Install  6 Packages
Upgrade  2 Packages

Total download size: 34 M
Downloading Packages:
(1/8): rke2-selinux-0.22-1.el9.noarch.rpm                          101 kB/s |  22 kB     00:00    
(2/8): rke2-server-1.33.8~rke2r1-0.el9.x86_64.rpm                   32 kB/s | 8.4 kB     00:00    
(3/8): iptables-nft-1.8.10-11.el9_5.x86_64.rpm                     3.0 MB/s | 187 kB     00:00    
(4/8): libnftnl-1.2.6-4.el9_4.x86_64.rpm                           4.4 MB/s |  87 kB     00:00    
(5/8): container-selinux-2.240.0-3.el9_7.noarch.rpm                5.4 MB/s |  58 kB     00:00    
(6/8): selinux-policy-38.1.65-1.el9.noarch.rpm                     4.2 MB/s |  42 kB     00:00    
(7/8): selinux-policy-targeted-38.1.65-1.el9.noarch.rpm             88 MB/s | 6.5 MB     00:00    
(8/8): rke2-common-1.33.8~rke2r1-0.el9.x86_64.rpm                   24 MB/s |  27 MB     00:01    
---------------------------------------------------------------------------------------------------
Total                                                               15 MB/s |  34 MB     00:02     
Rancher RKE2 Common (v1.33)                                         70 kB/s | 2.4 kB     00:00    
Importing GPG key 0xE257814A:
 Userid     : "Rancher (CI) <ci@rancher.com>"
 Fingerprint: C8CF F216 4551 26E9 B9C9 18BE 925E A29A E257 814A
 From       : https://rpm.rancher.io/public.key
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Running scriptlet: selinux-policy-targeted-38.1.65-1.el9.noarch                              1/1 
  Preparing        :                                                                           1/1 
  Upgrading        : selinux-policy-38.1.65-1.el9.noarch                                      1/10 
  Running scriptlet: selinux-policy-38.1.65-1.el9.noarch                                      1/10 
  Running scriptlet: selinux-policy-targeted-38.1.65-1.el9.noarch                             2/10 
  Upgrading        : selinux-policy-targeted-38.1.65-1.el9.noarch                             2/10 
  Running scriptlet: selinux-policy-targeted-38.1.65-1.el9.noarch                             2/10 
  Running scriptlet: container-selinux-4:2.240.0-3.el9_7.noarch                               3/10 
  Installing       : container-selinux-4:2.240.0-3.el9_7.noarch                               3/10 
  Running scriptlet: container-selinux-4:2.240.0-3.el9_7.noarch                               3/10 
  Running scriptlet: rke2-selinux-0.22-1.el9.noarch                                           4/10 
  Installing       : rke2-selinux-0.22-1.el9.noarch                                           4/10 
  Running scriptlet: rke2-selinux-0.22-1.el9.noarch                                           4/10 
  Installing       : libnftnl-1.2.6-4.el9_4.x86_64                                            5/10 
  Installing       : iptables-nft-1.8.10-11.el9_5.x86_64                                      6/10 
  Running scriptlet: iptables-nft-1.8.10-11.el9_5.x86_64                                      6/10 
  Installing       : rke2-common-1.33.8~rke2r1-0.el9.x86_64                                   7/10 
  Installing       : rke2-server-1.33.8~rke2r1-0.el9.x86_64                                   8/10 
  Running scriptlet: rke2-server-1.33.8~rke2r1-0.el9.x86_64                                   8/10 
  Running scriptlet: selinux-policy-38.1.53-5.el9_6.noarch                                    9/10 
  Cleanup          : selinux-policy-38.1.53-5.el9_6.noarch                                    9/10 
  Running scriptlet: selinux-policy-38.1.53-5.el9_6.noarch                                    9/10 
  Cleanup          : selinux-policy-targeted-38.1.53-5.el9_6.noarch                          10/10 
  Running scriptlet: selinux-policy-targeted-38.1.53-5.el9_6.noarch                          10/10 
  Running scriptlet: selinux-policy-targeted-38.1.65-1.el9.noarch                            10/10 
  Running scriptlet: container-selinux-4:2.240.0-3.el9_7.noarch                              10/10 
  Running scriptlet: rke2-selinux-0.22-1.el9.noarch                                          10/10 
  Running scriptlet: selinux-policy-targeted-38.1.53-5.el9_6.noarch                          10/10 
  Verifying        : rke2-selinux-0.22-1.el9.noarch                                           1/10 
  Verifying        : rke2-common-1.33.8~rke2r1-0.el9.x86_64                                   2/10 
  Verifying        : rke2-server-1.33.8~rke2r1-0.el9.x86_64                                   3/10 
  Verifying        : iptables-nft-1.8.10-11.el9_5.x86_64                                      4/10 
  Verifying        : libnftnl-1.2.6-4.el9_4.x86_64                                            5/10 
  Verifying        : container-selinux-4:2.240.0-3.el9_7.noarch                               6/10 
  Verifying        : selinux-policy-38.1.65-1.el9.noarch                                      7/10 
  Verifying        : selinux-policy-38.1.53-5.el9_6.noarch                                    8/10 
  Verifying        : selinux-policy-targeted-38.1.65-1.el9.noarch                             9/10 
  Verifying        : selinux-policy-targeted-38.1.53-5.el9_6.noarch                          10/10 

Upgraded:
  selinux-policy-38.1.65-1.el9.noarch         selinux-policy-targeted-38.1.65-1.el9.noarch        
Installed:
  container-selinux-4:2.240.0-3.el9_7.noarch         iptables-nft-1.8.10-11.el9_5.x86_64           
  libnftnl-1.2.6-4.el9_4.x86_64                      rke2-common-1.33.8~rke2r1-0.el9.x86_64        
  rke2-selinux-0.22-1.el9.noarch                     rke2-server-1.33.8~rke2r1-0.el9.x86_64        

Complete!

# rke2 버전 확인
[root@k8s-node1 ~]# rke2 --version
rke2 version v1.33.8+rke2r1 (eb75e3c1774cee5a584259d6fee77eb8cfa9b430)
go version go1.24.12 X:boringcrypto

# repo 추가 확인
[root@k8s-node1 ~]# dnf repolist
repo id                                          repo name
appstream                                        Rocky Linux 9 - AppStream
baseos                                           Rocky Linux 9 - BaseOS
extras                                           Rocky Linux 9 - Extras
rancher-rke2-1.33-stable                         Rancher RKE2 1.33 (v1.33)
rancher-rke2-common-stable                       Rancher RKE2 Common (v1.33)

[root@k8s-node1 ~]# tree /etc/yum.repos.d/
/etc/yum.repos.d/
├── rancher-rke2.repo
├── rocky-addons.repo
├── rocky-devel.repo
├── rocky-extras.repo
└── rocky.repo

0 directories, 5 files


[root@k8s-node1 ~]# cat /etc/yum.repos.d/rancher-rke2.repo
[rancher-rke2-common-stable]
name=Rancher RKE2 Common (v1.33)
baseurl=https://rpm.rancher.io/rke2/stable/common/centos/9/noarch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://rpm.rancher.io/public.key
[rancher-rke2-1.33-stable]
name=Rancher RKE2 1.33 (v1.33)
baseurl=https://rpm.rancher.io/rke2/stable/1.33/centos/9/x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://rpm.rancher.io/public.key

# 디렉터리 생성 확인
[root@k8s-node1 ~]# tree /etc/rancher/
/etc/rancher/
└── rke2

1 directory, 0 files

[root@k8s-node1 ~]# tree /var/lib/rancher/
/var/lib/rancher/
└── rke2
    ├── agent
    │   ├── containerd
    │   │   └── io.containerd.snapshotter.v1.overlayfs
    │   │       └── snapshots
    │   └── logs
    ├── data
    └── server

8 directories, 0 files

# rke2 명령 확인
# https://docs.rke2.io/install/configuration#running-the-binary-directly
# rke2 server: Run the RKE2 management server, which will also launch the Kubernetes control plane components such as the API server, controller-manager, and scheduler. Only Supported on Linux.
# rke2 agent: Run the RKE2 node agent. This will cause RKE2 to run as a worker node, launching the Kubernetes node services kubelet and kube-proxy. Supported on Linux and Windows.
[root@k8s-node1 ~]# rke2 --h
NAME:
   rke2 - Rancher Kubernetes Engine 2

USAGE:
   rke2 [global options] command [command options]

VERSION:
   v1.33.8+rke2r1 (eb75e3c1774cee5a584259d6fee77eb8cfa9b430)

COMMANDS:
   server           Run management server
   agent            Run node agent
   etcd-snapshot    Manage etcd snapshots
   certificate      Manage RKE2 certificates
   secrets-encrypt  Control secrets encryption and keys rotation
   token            Manage tokens
   completion       Install shell completion script
   help, h          Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --help, -h     show help
   --version, -v  print the version

# RKE2 설정 : cni 플러그인(canal) 등
# https://docs.rke2.io/install/configuration
# https://docs.rke2.io/advanced


[root@k8s-node1 ~]# cat << EOF > /etc/rancher/rke2/config.yaml
write-kubeconfig-mode: "0644"

debug: true

cni: canal

bind-address: 172.31.1.135
advertise-address: 172.31.1.135
node-ip: 172.31.1.135

disable-cloud-controller: true

disable:
  - servicelb
  - rke2-coredns-autoscaler
  - rke2-ingress-nginx
  - rke2-snapshot-controller
  - rke2-snapshot-controller-crd
  - rke2-snapshot-validation-webhook
EOF
```

내부적으로 SUSE에서 만든 helm controller를 사용하고 있다. (Rancher, k3s 모두 해당함.)
- https://github.com/k3s-io/helm-controller/

```bash
# canal cni 플러그인 helm chart values 파일 작성
# https://docs.rke2.io/networking/basic_network_options
# https://github.com/rancher/rke2-charts/blob/main-source/packages/rke2-canal/charts/values.yaml
[root@k8s-node1 ~]# mkdir -p /var/lib/rancher/rke2/server/manifests/
[root@k8s-node1 ~]# cat << EOF > /var/lib/rancher/rke2/server/manifests/rke2-canal-config.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-canal
  namespace: kube-system
spec:
  valuesContent: |-
    flannel:
      iface: "eth0"
EOF

# coredns 의 autoscaler 미설치를 위한 helm chart values 파일 작성
# https://docs.rke2.io/add-ons/helm#customizing-packaged-components-with-helmchartconfig
# https://github.com/rancher/rke2-charts/tree/main/charts/rke2-coredns/rke2-coredns/1.45.200
[root@k8s-node1 ~]# cat << EOF > /var/lib/rancher/rke2/server/manifests/rke2-coredns-config.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-coredns
  namespace: kube-system
spec:
  valuesContent: |-
    autoscaler:
      enabled: false
EOF
```

## control-plane 구동

```bash
# RKE2 시작 : 2분 정도 소요 -> coredns 파드까지 정상화 대략 1~2분 추가 소요
[root@k8s-node1 ~]# systemctl enable --now rke2-server.service
Created symlink /etc/systemd/system/multi-user.target.wants/rke2-server.service → /usr/lib/systemd/system/rke2-server.service.

[root@k8s-node1 ~]# systemctl status rke2-server --no-pager
● rke2-server.service - Rancher Kubernetes Engine v2 (server)
     Loaded: loaded (/usr/lib/systemd/system/rke2-server.service; enabled; preset: disabled)
     Active: active (running) since Sun 2026-02-22 13:26:37 UTC; 30s ago
       Docs: https://github.com/rancher/rke2#readme
    Process: 38022 ExecStartPre=/sbin/modprobe br_netfilter (code=exited, status=0/SUCCESS)
    Process: 38023 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
   Main PID: 38024 (rke2)
      Tasks: 104
     Memory: 2.1G
        CPU: 48.850s
     CGroup: /system.slice/rke2-server.service
             ├─38024 "/usr/bin/rke2 server"
             ├─38045 containerd -c /var/lib/rancher/rke2/agent/etc/containerd/config.toml
             ├─38093 kubelet --volume-plugin-dir=/var/lib/kubelet/volumeplugins --file-check-frequency=5s --sync-frequ…
             ├─38152 /var/lib/rancher/rke2/data/v1.33.8-rke2r1-1b2872361ec5/bin/containerd-shim-runc-v2 -namespace k8s…
             ├─38163 /var/lib/rancher/rke2/data/v1.33.8-rke2r1-1b2872361ec5/bin/containerd-shim-runc-v2 -namespace k8s…
             ├─38313 /var/lib/rancher/rke2/data/v1.33.8-rke2r1-1b2872361ec5/bin/containerd-shim-runc-v2 -namespace k8s…
             ├─38401 /var/lib/rancher/rke2/data/v1.33.8-rke2r1-1b2872361ec5/bin/containerd-shim-runc-v2 -namespace k8s…
             ├─38416 /var/lib/rancher/rke2/data/v1.33.8-rke2r1-1b2872361ec5/bin/containerd-shim-runc-v2 -namespace k8s…
             └─39046 /var/lib/rancher/rke2/data/v1.33.8-rke2r1-1b2872361ec5/bin/containerd-shim-runc-v2 -namespace k8s…

Feb 22 13:27:05 k8s-node1 rke2[38024]: time="2026-02-22T13:27:05.100893600Z" level=info msg="connecting to shi…ersion=3
Feb 22 13:27:05 k8s-node1 rke2[38024]: time="2026-02-22T13:27:05.194736436Z" level=info msg="StartContainer fo…ssfully"
Feb 22 13:27:05 k8s-node1 rke2[38024]: time="2026-02-22T13:27:05.201489256Z" level=info msg="received container exit e…
Feb 22 13:27:06 k8s-node1 rke2[38024]: time="2026-02-22T13:27:06.058879602Z" level=info msg="CreateContainer w…-node\""
Feb 22 13:27:06 k8s-node1 rke2[38024]: time="2026-02-22T13:27:06.079356395Z" level=info msg="Container 8446a16…ces: []"
Feb 22 13:27:06 k8s-node1 rke2[38024]: time="2026-02-22T13:27:06.092387480Z" level=info msg="CreateContainer w…0fe70\""
Feb 22 13:27:06 k8s-node1 rke2[38024]: time="2026-02-22T13:27:06.092953696Z" level=info msg="StartContainer fo…0fe70\""
Feb 22 13:27:06 k8s-node1 rke2[38024]: time="2026-02-22T13:27:06.095129198Z" level=info msg="connecting to shi…ersion=3
Feb 22 13:27:06 k8s-node1 rke2[38024]: time="2026-02-22T13:27:06.192660247Z" level=info msg="StartContainer fo…ssfully"
Feb 22 13:27:06 k8s-node1 rke2[38024]: time="2026-02-22T13:27:06.194228747Z" level=info msg="PullImage \"ranch…60206\""
Hint: Some lines were ellipsized, use -l to show in full.
```

이어서 확인한다.

```bash
# 프로세스 확인
[root@k8s-node1 ~]# pstree -a | grep -v color | grep 'rke2$' -A5
  |-rke2
  |   |-containerd -c /var/lib/rancher/rke2/agent/etc/containerd/config.toml
  |   |   `-11*[{containerd}]
  |   |-kubelet --volume-plugin-dir=/var/lib/kubelet/volumeplugins --file-check-frequency=5s --sync-frequency=30s...
  |   |   `-10*[{kubelet}]
  |   `-10*[{rke2}]

[root@k8s-node1 ~]# pstree -a | grep -v color | grep 'containerd-shim ' -A2
  |-containerd-shim -namespace k8s.io -idbc66feac31b77e7c41546bd4662
  |   |-kube-proxy --cluster-cidr=10.42.0.0/16 --conntrack-max-per-core=0 --conntrack-tcp-timeout-close-wait=0s...
  |   |   `-6*[{kube-proxy}]
--
  |-containerd-shim -namespace k8s.io -idc30196634e7e46cefd470e8b06c
  |   |-etcd --config-file=/var/lib/rancher/rke2/server/db/etcd/config
  |   |   `-8*[{etcd}]
--
  |-containerd-shim -namespace k8s.io -id249b5a9aaddf90e5c3d47296fe3
  |   |-kube-apiserver --admission-control-config-file=/etc/rancher/rke2/rke2-pss.yaml --advertise-address=172.31.1.135...
  |   |   `-11*[{kube-apiserver}]
--
  |-containerd-shim -namespace k8s.io -id17834d789d0a96cb7761138ec06
  |   |-kube-controller --permit-port-sharing=true --flex-volume-plugin-dir=/var/lib/kubelet/volumeplugins--terminated-pod-gc-thres
  |   |   `-6*[{kube-controller}]
--
  |-containerd-shim -namespace k8s.io -id40608e183173ebf5551ec8d747f
  |   |-kube-scheduler --permit-port-sharing=true ...
  |   |   `-7*[{kube-scheduler}]
--
  |-containerd-shim -namespace k8s.io -id3715f8a305e2590a3ea78fc4cb9
  |   |-flanneld --ip-masq --kube-subnet-mgr --iptables-forward-rules=false --ip-blackhole-route
  |   |   |-(timeout)
--
  |-containerd-shim -namespace k8s.io -id1f98075c4d982a8f8853c1649c9
  |   |-coredns -conf /etc/coredns/Corefile
  |   |   `-7*[{coredns}]
--
  |-containerd-shim -namespace k8s.io -idb1fd3f5cd2810a27a1aabc41b5a
  |   |-metrics-server --secure-port=10250 --cert-dir=/tmp --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname...
  |   |   `-8*[{metrics-server}]
```

```bash
# 자격증명 파일 복사
[root@k8s-node1 ~]# mkdir ~/.kube

[root@k8s-node1 ~]# ls -l /etc/rancher/rke2/rke2.yaml
-rw-r--r--. 1 root root 2972 Feb 22 13:25 /etc/rancher/rke2/rke2.yaml

[root@k8s-node1 ~]# cp /etc/rancher/rke2/rke2.yaml ~/.kube/config

# /etc/rancher 디렉터리 확인
[root@k8s-node1 ~]# tree /etc/rancher/
/etc/rancher/
├── node
│   └── password
└── rke2
    ├── config.yaml
    ├── rke2-pss.yaml
    └── rke2.yaml

2 directories, 4 files

[root@k8s-node1 ~]# cat /etc/rancher/node/password
40b9b5942aaa8aeebc122e6d629d204a

[root@k8s-node1 ~]# cat /etc/rancher/rke2/config.yaml
write-kubeconfig-mode: "0644"

debug: true

cni: canal

bind-address: 172.31.1.135
advertise-address: 172.31.1.135
node-ip: 172.31.1.135

disable-cloud-controller: true

disable:
  - servicelb
  - rke2-coredns-autoscaler
  - rke2-ingress-nginx
  - rke2-snapshot-controller
  - rke2-snapshot-controller-crd
  - rke2-snapshot-validation-webhook

[root@k8s-node1 ~]# cat /etc/rancher/rke2/rke2-pss.yaml 
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: PodSecurity
  configuration:
    apiVersion: pod-security.admission.config.k8s.io/v1beta1
    kind: PodSecurityConfiguration
    defaults:
      enforce: "privileged"
      enforce-version: "latest"
    exemptions:
      usernames: []
      runtimeClasses: []
      namespaces: []


# 바이너리 파일 확인
[root@k8s-node1 ~]# tree /var/lib/rancher/rke2/bin/
/var/lib/rancher/rke2/bin/
├── containerd
├── containerd-shim-runc-v2
├── crictl
├── ctr
├── kubectl
├── kubelet
└── runc

0 directories, 7 files

# PATH 안 건드리고 표준 위치로 바이너리 노출 설정: 심볼릭 링크 방식 
ln -s /var/lib/rancher/rke2/bin/containerd /usr/local/bin/containerd
ln -s /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/kubectl
ln -s /var/lib/rancher/rke2/bin/crictl /usr/local/bin/crictl
ln -s /var/lib/rancher/rke2/bin/runc /usr/local/bin/runc
ln -s /var/lib/rancher/rke2/bin/ctr /usr/local/bin/ctr
ln -s /var/lib/rancher/rke2/agent/etc/crictl.yaml /etc/crictl.yaml

# 바이너리 확인
[root@k8s-node1 ~]# runc --version
runc version 1.4.0
commit: v1.4.0-0-g8bd78a99
spec: 1.3.0
go: go1.24.11 X:boringcrypto
libseccomp: 2.5.4

[root@k8s-node1 ~]# containerd --version
containerd github.com/k3s-io/containerd v2.1.5-k3s1 e77c15f30e5162d6abab671b0d74ca2243e2916e

[root@k8s-node1 ~]# kubectl version
Client Version: v1.33.8+rke2r1
Kustomize Version: v5.6.0
Server Version: v1.33.8+rke2r1

# 확인
[root@k8s-node1 ~]# kubectl cluster-info -v=6
I0222 13:33:34.697775   46119 loader.go:402] Config loaded from file:  /root/.kube/config
I0222 13:33:34.698376   46119 envvar.go:172] "Feature gate default state" feature="WatchListClient" enabled=false
I0222 13:33:34.698401   46119 envvar.go:172] "Feature gate default state" feature="ClientsAllowCBOR" enabled=false
I0222 13:33:34.698410   46119 envvar.go:172] "Feature gate default state" feature="ClientsPreferCBOR" enabled=false
I0222 13:33:34.698422   46119 envvar.go:172] "Feature gate default state" feature="InformerResourceVersion" enabled=false
I0222 13:33:34.698433   46119 envvar.go:172] "Feature gate default state" feature="InOrderInformers" enabled=true
I0222 13:33:34.711506   46119 round_trippers.go:632] "Response" verb="GET" url="https://172.31.1.135:6443/api/v1/namespaces/kube-system/services?labelSelector=kubernetes.io%2Fcluster-service%3Dtrue" status="200 OK" milliseconds=7
Kubernetes control plane is running at https://172.31.1.135:6443
CoreDNS is running at https://172.31.1.135:6443/api/v1/namespaces/kube-system/services/rke2-coredns-rke2-coredns:udp-53/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

# 노드, 파드 정보 확인
[root@k8s-node1 ~]# kubectl get node -owide
NAME        STATUS   ROLES                       AGE     VERSION          INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                      KERNEL-VERSION                 CONTAINER-RUNTIME
k8s-node1   Ready    control-plane,etcd,master   7m19s   v1.33.8+rke2r1   172.31.1.135   <none>        Rocky Linux 9.6 (Blue Onyx)   5.14.0-570.17.1.el9_6.x86_64   containerd://2.1.5-k3s1

[root@k8s-node1 ~]# kubectl get pod -A
NAMESPACE     NAME                                         READY   STATUS      RESTARTS   AGE
kube-system   etcd-k8s-node1                               1/1     Running     0          7m28s
kube-system   helm-install-rke2-canal-cfrm6                0/1     Completed   0          7m28s
kube-system   helm-install-rke2-coredns-tpw67              0/1     Completed   0          7m28s
kube-system   helm-install-rke2-metrics-server-h6ssr       0/1     Completed   0          7m28s
kube-system   helm-install-rke2-runtimeclasses-tt66j       0/1     Completed   0          7m28s
kube-system   kube-apiserver-k8s-node1                     1/1     Running     0          7m28s
kube-system   kube-controller-manager-k8s-node1            1/1     Running     0          7m28s
kube-system   kube-proxy-k8s-node1                         1/1     Running     0          7m28s
kube-system   kube-scheduler-k8s-node1                     1/1     Running     0          7m28s
kube-system   rke2-canal-rlb7w                             2/2     Running     0          7m19s
kube-system   rke2-coredns-rke2-coredns-559595db99-shj84   1/1     Running     0          7m21s
kube-system   rke2-metrics-server-fdcdf575d-xfdhc          1/1     Running     0          6m50s
```