# k8s 관련 바이너리, 툴 설치

이하 내용은 Control Plane, Worker Node 모두 진행해야 한다.

## repo 추가
```bash
## exclude=... : 실수로 dnf update 시 kubelet 자동 업그레이드 방지
[root@k8s-ctr ~]# dnf repolist
repo id                           repo name
appstream                         Rocky Linux 9 - AppStream
baseos                            Rocky Linux 9 - BaseOS
docker-ce-stable                  Docker CE Stable - x86_64
extras                            Rocky Linux 9 - Extras

[root@k8s-ctr ~]# tree /etc/yum.repos.d/
/etc/yum.repos.d/
├── docker-ce.repo
├── rocky-addons.repo
├── rocky-devel.repo
├── rocky-extras.repo
└── rocky.repo

0 directories, 5 files

[root@k8s-ctr ~]# cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni



[root@k8s-ctr ~]# dnf makecache
Docker CE Stable - x86_64                    61 kB/s | 2.0 kB     00:00    
Kubernetes                                   68 kB/s |  28 kB     00:00    
Rocky Linux 9 - BaseOS                      7.6 kB/s | 4.3 kB     00:00    
Rocky Linux 9 - AppStream                   9.9 kB/s | 4.8 kB     00:00    
Rocky Linux 9 - Extras                      5.9 kB/s | 3.1 kB     00:00    
Metadata cache created.
```

## 설치
```bash
## --disableexcludes=... kubernetes repo에 설정된 exclude 규칙을 이번 설치에서만 무시(1회성 옵션 처럼 사용)
## 설치 가능 버전 확인
[root@k8s-ctr ~]# dnf list --showduplicates kubelet
Last metadata expiration check: 0:00:21 ago on Sat 24 Jan 2026 01:26:52 PM UTC.
Error: No matching Packages to list

# '--disableexcludes=kubernetes' 아래 처럼 있는 경우와 없는 경우 비교해보기
dnf list --showduplicates kubelet --disableexcludes=kubernetes

dnf list --showduplicates kubeadm --disableexcludes=kubernetes

dnf list --showduplicates kubectl --disableexcludes=kubernetes
Last metadata expiration check: 0:01:10 ago on Sat 24 Jan 2026 01:26:52 PM UTC.
Available Packages
kubeadm.aarch64           1.32.0-150500.1.1            kubernetes
kubeadm.ppc64le           1.32.0-150500.1.1            kubernetes
kubeadm.s390x             1.32.0-150500.1.1            kubernetes
kubeadm.src               1.32.0-150500.1.1            kubernetes
...



## 버전 정보 미지정 시, 제공 가능 최신 버전 설치됨.
[root@k8s-ctr ~]# dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
Last metadata expiration check: 0:01:50 ago on Sat 24 Jan 2026 01:26:52 PM UTC.
Dependencies resolved.
=================================================================
 Package         Arch    Version               Repository   Size
=================================================================
Installing:
 kubeadm         x86_64  1.32.11-150500.1.1    kubernetes   12 M
 kubectl         x86_64  1.32.11-150500.1.1    kubernetes   11 M
 kubelet         x86_64  1.32.11-150500.1.1    kubernetes   15 M
Installing dependencies:
 cri-tools       x86_64  1.32.0-150500.1.1     kubernetes  7.1 M
 iptables-nft    x86_64  1.8.10-11.el9_5       baseos      187 k
 kubernetes-cni  x86_64  1.6.0-150500.1.1      kubernetes  8.0 M
 libnftnl        x86_64  1.2.6-4.el9_4         baseos       87 k

Transaction Summary
=================================================================
Install  7 Packages

Total download size: 53 M
Installed size: 291 M
Downloading Packages:
(1/7): cri-tools-1.32.0-150500.1  24 MB/s | 7.1 MB     00:00    
(2/7): kubeadm-1.32.11-150500.1.  32 MB/s |  12 MB     00:00    
(3/7): kubectl-1.32.11-150500.1.  26 MB/s |  11 MB     00:00    
(4/7): iptables-nft-1.8.10-11.el 2.4 MB/s | 187 kB     00:00    
(5/7): kubelet-1.32.11-150500.1.  55 MB/s |  15 MB     00:00    
(6/7): libnftnl-1.2.6-4.el9_4.x8 1.3 MB/s |  87 kB     00:00    
(7/7): kubernetes-cni-1.6.0-1505  31 MB/s | 8.0 MB     00:00    
-----------------------------------------------------------------
Total                             47 MB/s |  53 MB     00:01     
Kubernetes                       8.4 kB/s | 1.7 kB     00:00    
Importing GPG key 0x9A296436:
 Userid     : "isv:kubernetes OBS Project <isv:kubernetes@build.opensuse.org>"
 Fingerprint: DE15 B144 86CD 377B 9E87 6E1A 2346 54DA 9A29 6436
 From       : https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                         1/1 
  Installing       : libnftnl-1.2.6-4.el9_4.x86_64           1/7 
  Installing       : iptables-nft-1.8.10-11.el9_5.x86_64     2/7 
  Running scriptlet: iptables-nft-1.8.10-11.el9_5.x86_64     2/7 
  Installing       : kubernetes-cni-1.6.0-150500.1.1.x86_6   3/7 
  Installing       : cri-tools-1.32.0-150500.1.1.x86_64      4/7 
  Installing       : kubeadm-1.32.11-150500.1.1.x86_64       5/7 
  Installing       : kubelet-1.32.11-150500.1.1.x86_64       6/7 
  Running scriptlet: kubelet-1.32.11-150500.1.1.x86_64       6/7 
  Installing       : kubectl-1.32.11-150500.1.1.x86_64       7/7 
  Running scriptlet: kubectl-1.32.11-150500.1.1.x86_64       7/7 
  Verifying        : cri-tools-1.32.0-150500.1.1.x86_64      1/7 
  Verifying        : kubeadm-1.32.11-150500.1.1.x86_64       2/7 
  Verifying        : kubectl-1.32.11-150500.1.1.x86_64       3/7 
  Verifying        : kubelet-1.32.11-150500.1.1.x86_64       4/7 
  Verifying        : kubernetes-cni-1.6.0-150500.1.1.x86_6   5/7 
  Verifying        : iptables-nft-1.8.10-11.el9_5.x86_64     6/7 
  Verifying        : libnftnl-1.2.6-4.el9_4.x86_64           7/7 

Installed:
  cri-tools-1.32.0-150500.1.1.x86_64                             
  iptables-nft-1.8.10-11.el9_5.x86_64                            
  kubeadm-1.32.11-150500.1.1.x86_64                              
  kubectl-1.32.11-150500.1.1.x86_64                              
  kubelet-1.32.11-150500.1.1.x86_64                              
  kubernetes-cni-1.6.0-150500.1.1.x86_64                         
  libnftnl-1.2.6-4.el9_4.x86_64                                  

Complete!


# kubelet 활성화 (실제 기동은 kubeadm init 후에 시작됨)
[root@k8s-ctr ~]# systemctl enable --now kubelet
Created symlink /etc/systemd/system/multi-user.target.wants/kubelet.service → /usr/lib/systemd/system/kubelet.service.

[root@k8s-ctr ~]# ps -ef |grep kubelet
root       18972   16899  0 13:29 pts/0    00:00:00 grep --color=auto kubelet


# 설치 파일들 확인
[root@k8s-ctr ~]# which kubeadm && kubeadm version -o yaml
/usr/bin/kubeadm
clientVersion:
  buildDate: "2025-12-16T18:06:36Z"
  compiler: gc
  gitCommit: 2195eae9e91f2e72114365d9bb9c670d0c08de12
  gitTreeState: clean
  gitVersion: v1.32.11
  goVersion: go1.24.11
  major: "1"
  minor: "32"
  platform: linux/amd64

[root@k8s-ctr ~]# which kubectl && kubectl version --client=true
/usr/bin/kubectl
Client Version: v1.32.11
Kustomize Version: v5.5.0

[root@k8s-ctr ~]# which kubelet && kubelet --version
/usr/bin/kubelet
Kubernetes v1.32.11

# cri-tools
[root@k8s-ctr ~]# which crictl && crictl version
/usr/bin/crictl
WARN[0000] Config "/etc/crictl.yaml" does not exist, trying next: "/usr/bin/crictl.yaml" 
WARN[0000] runtime connect using default endpoints: [unix:///run/containerd/containerd.sock unix:///run/crio/crio.sock unix:///var/run/cri-dockerd.sock]. As the default settings are now deprecated, you should set the endpoint instead. 
Version:  0.1.0
RuntimeName:  containerd
RuntimeVersion:  v2.1.5
RuntimeApiVersion:  v1


# /etc/crictl.yaml 파일 작성
[root@k8s-ctr ~]# cat << EOF > /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
EOF

[root@k8s-ctr ~]# crictl info | jq
{
  "cniconfig": {
    "Networks": [
      {
        "Config": {
          "CNIVersion": "0.3.1",
          "Name": "cni-loopback",
          "Plugins": [
            {
              "Network": {
                "ipam": {},
                "type": "loopback"
              },
              "Source": "{\"type\":\"loopback\"}"
            }
          ],
          "Source": "{\n\"cniVersion\": \"0.3.1\",\n\"name\": \"cni-loopback\",\n\"plugins\": [{\n  \"type\": \"loopback\"\n}]\n}"
        },
        "IFName": "lo"
      }
    ],
    "PluginConfDir": "/etc/cni/net.d",
    "PluginDirs": [
      "/opt/cni/bin"
    ],
    "PluginMaxConfNum": 1,
    "Prefix": "eth"
  },
  "config": {
    "cdiSpecDirs": [
      "/etc/cdi",
      "/var/run/cdi"
    ],
    "cni": {
      "binDir": "",
      "binDirs": [
        "/opt/cni/bin"
      ],
      "confDir": "/etc/cni/net.d",
      "confTemplate": "",
      "ipPref": "",
      "maxConfNum": 1,
      "setupSerially": false,
      "useInternalLoopback": false
    },
    "containerd": {
      "defaultRuntimeName": "runc",
      "ignoreBlockIONotEnabledErrors": false,
      "ignoreRdtNotEnabledErrors": false,
      "runtimes": {
        "runc": {
          "ContainerAnnotations": [],
          "PodAnnotations": [],
          "baseRuntimeSpec": "",
          "cgroupWritable": false,
          "cniConfDir": "",
          "cniMaxConfNum": 0,
          "io_type": "",
          "options": {
            "BinaryName": "",
            "CriuImagePath": "",
            "CriuWorkPath": "",
            "IoGid": 0,
            "IoUid": 0,
            "NoNewKeyring": false,
            "Root": "",
            "ShimCgroup": "",
            "SystemdCgroup": true
          },
          "privileged_without_host_devices": false,
          "privileged_without_host_devices_all_devices_allowed": false,
          "runtimePath": "",
          "runtimeType": "io.containerd.runc.v2",
          "sandboxer": "podsandbox",
          "snapshotter": ""
        }
      }
    },
    "containerdEndpoint": "/run/containerd/containerd.sock",
    "containerdRootDir": "/var/lib/containerd",
    "device_ownership_from_security_context": false,
    "disableApparmor": false,
    "disableHugetlbController": true,
    "disableProcMount": false,
    "drainExecSyncIOTimeout": "0s",
    "enableCDI": true,
    "enableSelinux": false,
    "enableUnprivilegedICMP": true,
    "enableUnprivilegedPorts": true,
    "ignoreDeprecationWarnings": [],
    "ignoreImageDefinedVolumes": false,
    "maxContainerLogLineSize": 16384,
    "netnsMountsUnderStateDir": false,
    "restrictOOMScoreAdj": false,
    "rootDir": "/var/lib/containerd/io.containerd.grpc.v1.cri",
    "selinuxCategoryRange": 1024,
    "stateDir": "/run/containerd/io.containerd.grpc.v1.cri",
    "tolerateMissingHugetlbController": true,
    "unsetSeccompProfile": ""
  },
  "golang": "go1.24.9",
  "lastCNILoadStatus": "cni config load failed: no network config found in /etc/cni/net.d: cni plugin not initialized: failed to load cni config",
  "lastCNILoadStatus.default": "cni config load failed: no network config found in /etc/cni/net.d: cni plugin not initialized: failed to load cni config",
  "runtimeHandlers": [
    {
      "features": {
        "recursive_read_only_mounts": true,
        "user_namespaces": true
      }
    },
    {
      "features": {
        "recursive_read_only_mounts": true,
        "user_namespaces": true
      },
      "name": "runc"
    }
  ],
  "status": {
    "conditions": [
      {
        "message": "",
        "reason": "",
        "status": true,
        "type": "RuntimeReady"
      },
      {
        "message": "Network plugin returns error: cni plugin not initialized",
        "reason": "NetworkPluginNotReady",
        "status": false,
        "type": "NetworkReady"
      },
      {
        "message": "",
        "reason": "",
        "status": true,
        "type": "ContainerdHasNoDeprecationWarnings"
      }
    ]
  }
}

# kubernetes-cni : 파드 네트워크 구성을 위한 CNI 바이너리 파일 확인
[root@k8s-ctr ~]# ls -al /opt/cni/bin
total 64076
drwxr-xr-x. 2 root root    4096 Jan 24 13:28 .
drwxr-xr-x. 3 root root      17 Jan 24 13:28 ..
-rwxr-xr-x. 1 root root 3309880 Dec 11  2024 bandwidth
-rwxr-xr-x. 1 root root 3777952 Dec 11  2024 bridge
-rwxr-xr-x. 1 root root 9449208 Dec 11  2024 dhcp
-rwxr-xr-x. 1 root root 3446480 Dec 11  2024 dummy
-rwxr-xr-x. 1 root root 3789192 Dec 11  2024 firewall
-rwxr-xr-x. 1 root root 3396776 Dec 11  2024 host-device
-rwxr-xr-x. 1 root root 2846448 Dec 11  2024 host-local
-rwxr-xr-x. 1 root root 3459824 Dec 11  2024 ipvlan
-rw-r--r--. 1 root root   11357 Dec 11  2024 LICENSE
-rwxr-xr-x. 1 root root 2900672 Dec 11  2024 loopback
-rwxr-xr-x. 1 root root 3485960 Dec 11  2024 macvlan
-rwxr-xr-x. 1 root root 3346144 Dec 11  2024 portmap
-rwxr-xr-x. 1 root root 3615264 Dec 11  2024 ptp
-rw-r--r--. 1 root root    2343 Dec 11  2024 README.md
-rwxr-xr-x. 1 root root 3068152 Dec 11  2024 sbr
-rwxr-xr-x. 1 root root 2564560 Dec 11  2024 static
-rwxr-xr-x. 1 root root 3501048 Dec 11  2024 tap
-rwxr-xr-x. 1 root root 2964944 Dec 11  2024 tuning
-rwxr-xr-x. 1 root root 3455344 Dec 11  2024 vlan
-rwxr-xr-x. 1 root root 3177696 Dec 11  2024 vrf


[root@k8s-ctr ~]# tree /opt/cni
/opt/cni
└── bin
    ├── bandwidth
    ├── bridge
    ├── dhcp
    ├── dummy
    ├── firewall
    ├── host-device
    ├── host-local
    ├── ipvlan
    ├── LICENSE
    ├── loopback
    ├── macvlan
    ├── portmap
    ├── ptp
    ├── README.md
    ├── sbr
    ├── static
    ├── tap
    ├── tuning
    ├── vlan
    └── vrf

1 directory, 20 files

[root@k8s-ctr ~]# tree /etc/cni/
/etc/cni/
└── net.d

1 directory, 0 files


#
[root@k8s-ctr ~]# systemctl is-active kubelet
activating

[root@k8s-ctr ~]# systemctl status kubelet --no-pager
● kubelet.service - kubelet: The Kubernetes Node Agent
     Loaded: loaded (/usr/lib/systemd/system/kubelet.service; enabled; preset: disabled)


[root@k8s-ctr ~]# journalctl -u kubelet --no-pager
...
Jan 24 13:32:15 k8s-ctr kubelet[19151]: E0124 13:32:15.718850   19151 run.go:72] "command failed" err="failed to load kubelet config file, path: /var/lib/kubelet/config.yaml, error: failed to load Kubelet config file /var/lib/kubelet/config.yaml, error failed to read kubelet config file \"/var/lib/kubelet/config.yaml\", error: open /var/lib/kubelet/config.yaml: no such file or directory"
Jan 24 13:32:15 k8s-ctr systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
Jan 24 13:32:15 k8s-ctr systemd[1]: kubelet.service: Failed with result 'exit-code'.

[root@k8s-ctr ~]# tree /usr/lib/systemd/system | grep kubelet -A1
├── kubelet.service
├── kubelet.service.d
│   └── 10-kubeadm.conf


[root@k8s-ctr ~]# cat /usr/lib/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target


[root@k8s-ctr ~]# cat /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/sysconfig/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS

[root@k8s-ctr ~]# tree /etc/kubernetes
/etc/kubernetes
└── manifests

1 directory, 0 files
[root@k8s-ctr ~]# tree /var/lib/kubelet/
/var/lib/kubelet/

0 directories, 0 files
[root@k8s-ctr ~]# cat /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS=



# cgroup , namespace 정보 확인
[root@k8s-ctr ~]# systemd-cgls --no-pager
Control group /:
-.slice
├─user.slice (#1169)
│ → user.invocation_id: d76d1bf42ddc48eebd9fcd66570a26fc
│ → trusted.invocation_id: d76d1bf42ddc48eebd9fcd66570a26fc
│ └─user-1000.slice (#4074)
│   → user.invocation_id: 4c6be1bd18af478fae7f27e7d3598bdc
│   → trusted.invocation_id: 4c6be1bd18af478fae7f27e7d3598bdc
│   ├─user@1000.service … (#4152)
│   │ → user.invocation_id: 6d104f0cd9b74f75ba5b8cd3984b4ef2
│   │ → user.delegate: 1
│   │ → trusted.invocation_id: 6d104f0cd9b74f75ba5b8cd3984b4ef2
│   │ → trusted.delegate: 1
│   │ └─init.scope (#4191)
│   │   ├─16774 /usr/lib/systemd/systemd --user
│   │   └─16776 (sd-pam)
│   └─session-3.scope (#4620)
│     → user.invocation_id: 6bc8c0890c8d4530bf5d6690cde0b35c
│     → trusted.invocation_id: 6bc8c0890c8d4530bf5d6690cde0b35c
│     ├─16867 sshd: rocky [priv]
│     ├─16870 sshd: rocky@pts/0
│     ├─16871 -bash
│     ├─16896 sudo su -
│     ├─16898 su -
│     ├─16899 -bash
│     └─19230 systemd-cgls --no-pager
├─init.scope (#24)
│ └─1 /usr/lib/systemd/systemd --switched-root --system --deseri…
└─system.slice (#63)
  ├─rngd.service (#2860)
  │ → user.invocation_id: f2d7bcfb6b5b4c83b2b23ff577ab47f8
  │ → trusted.invocation_id: f2d7bcfb6b5b4c83b2b23ff577ab47f8
  │ └─743 /usr/sbin/rngd -f --fill-watermark=0 -x pkcs11 -x nist…
  ├─irqbalance.service (#2821)
  │ → user.invocation_id: 4c61cbba5ca847c1a9918bffb36553d5
  │ → trusted.invocation_id: 4c61cbba5ca847c1a9918bffb36553d5
  │ └─742 /usr/sbin/irqbalance
  ├─containerd.service … (#5702)
  │ → user.invocation_id: 552dfe132bf74a9e90d1f13c6ea0aba7
  │ → user.delegate: 1
  │ → trusted.invocation_id: 552dfe132bf74a9e90d1f13c6ea0aba7
  │ → trusted.delegate: 1
  │ └─18589 /usr/bin/containerd
  ├─packagekit.service (#5926)
  │ → user.invocation_id: ac1004eac8eb4f1f9c18de7b9df72545
  │ → trusted.invocation_id: ac1004eac8eb4f1f9c18de7b9df72545
  │ └─18929 /usr/libexec/packagekitd
  ├─systemd-udevd.service … (#2144)
  │ → user.invocation_id: cdd32e3873514ea0bec99940a350f419
  │ → user.delegate: 1
  │ → trusted.invocation_id: cdd32e3873514ea0bec99940a350f419
  │ → trusted.delegate: 1
  │ └─udev (#2183)
  │   └─640 /usr/lib/systemd/systemd-udevd
  ├─dbus-broker.service (#2665)
  │ → user.invocation_id: 6fb0758147e646b0b55177e0c1adc476
  │ → trusted.invocation_id: 6fb0758147e646b0b55177e0c1adc476
  │ ├─737 /usr/bin/dbus-broker-launch --scope system --audit
  │ └─738 dbus-broker --log 4 --controller 9 --machine-id ec2769…
  ├─system-serial\x2dgetty.slice (#1091)
  │ → user.invocation_id: eb6ac6deface47d6977f5a1c4c38a264
  │ → trusted.invocation_id: eb6ac6deface47d6977f5a1c4c38a264
  │ └─serial-getty@ttyS0.service (#3484)
  │   → user.invocation_id: 6472791047c54bc980b75d02df684895
  │   → trusted.invocation_id: 6472791047c54bc980b75d02df684895
  │   └─940 /sbin/agetty -o -p -- \u --keep-baud 115200,57600,38…
  ├─polkit.service (#3986)
  │ → user.invocation_id: cea9dca97ce6487b89b85ebc0fab2f4a
  │ → trusted.invocation_id: cea9dca97ce6487b89b85ebc0fab2f4a
  │ └─10474 /usr/lib/polkit-1/polkitd --no-debug
  ├─chronyd.service (#2704)
  │ → user.invocation_id: 0f147bfc2ea844d8808541e3bc1c6112
  │ → trusted.invocation_id: 0f147bfc2ea844d8808541e3bc1c6112
  │ └─750 /usr/sbin/chronyd -F 2
  ├─auditd.service (#2470)
  │ → user.invocation_id: f572ebdc088e48b091a5768c3fb7948f
  │ → trusted.invocation_id: f572ebdc088e48b091a5768c3fb7948f
  │ ├─708 /sbin/auditd
  │ └─710 /usr/sbin/sedispatch
  ├─systemd-journald.service (#1637)
  │ → user.invocation_id: 291ce4d31ab0479e92190ec6334f5f1d
  │ → trusted.invocation_id: 291ce4d31ab0479e92190ec6334f5f1d
  │ └─622 /usr/lib/systemd/systemd-journald
  ├─sshd.service (#4030)
  │ → user.invocation_id: 3dd9966ae04a4144b835ee3f316bd3b5
  │ → trusted.invocation_id: 3dd9966ae04a4144b835ee3f316bd3b5
  │ └─12695 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 start…
  ├─crond.service (#3406)
  │ → user.invocation_id: 214e4c9b8d6b40f4af00c6aacc698c85
  │ → trusted.invocation_id: 214e4c9b8d6b40f4af00c6aacc698c85
  │ ├─  938 /usr/sbin/crond -n
  │ └─16942 /usr/sbin/anacron -s
  ├─NetworkManager.service (#2977)
  │ → user.invocation_id: f0b39776b716446eae836bb72e743d97
  │ → trusted.invocation_id: f0b39776b716446eae836bb72e743d97
  │ └─779 /usr/sbin/NetworkManager --no-daemon
  ├─gssproxy.service (#3094)
  │ → user.invocation_id: e4d8564cad5147a0b2d924ea0695aeda
  │ → trusted.invocation_id: e4d8564cad5147a0b2d924ea0695aeda
  │ └─795 /usr/sbin/gssproxy -D
  ├─rsyslog.service (#3289)
  │ → user.invocation_id: b6f78d648ee7474b8c2357a8dc042def
  │ → trusted.invocation_id: b6f78d648ee7474b8c2357a8dc042def
  │ └─934 /usr/sbin/rsyslogd -n
  ├─rpcbind.service (#2509)
  │ → user.invocation_id: 1cd7ad0964654e02ba65bae36e0b9e19
  │ → trusted.invocation_id: 1cd7ad0964654e02ba65bae36e0b9e19
  │ └─706 /usr/bin/rpcbind -w -f
  ├─system-getty.slice (#1013)
  │ → user.invocation_id: 114d5fabf5b343729b45f808f713693b
  │ → trusted.invocation_id: 114d5fabf5b343729b45f808f713693b
  │ └─getty@tty1.service (#3445)
  │   → user.invocation_id: b7ccc4a9934441efbc90befbc385ad1d
  │   → trusted.invocation_id: b7ccc4a9934441efbc90befbc385ad1d
  │   └─939 /sbin/agetty -o -p -- \u --noclear - linux
  └─systemd-logind.service (#2899)
    → user.invocation_id: 66ff345a599149cda97200fc97c108c4
    → trusted.invocation_id: 66ff345a599149cda97200fc97c108c4
    └─744 /usr/lib/systemd/systemd-logind

[root@k8s-ctr ~]# lsns
        NS TYPE   NPROCS   PID USER   COMMAND
4026531834 time      138     1 root   /usr/lib/systemd/systemd --
4026531835 cgroup    138     1 root   /usr/lib/systemd/systemd --
4026531836 pid       138     1 root   /usr/lib/systemd/systemd --
4026531837 user      137     1 root   /usr/lib/systemd/systemd --
4026531838 uts       134     1 root   /usr/lib/systemd/systemd --
4026531839 ipc       138     1 root   /usr/lib/systemd/systemd --
4026531840 net       137     1 root   /usr/lib/systemd/systemd --
4026531841 mnt       129     1 root   /usr/lib/systemd/systemd --
4026531862 mnt         1    46 root   kdevtmpfs
4026532126 mnt         1   640 root   /usr/lib/systemd/systemd-ud
4026532127 uts         1   640 root   /usr/lib/systemd/systemd-ud
4026532169 mnt         2   737 dbus   /usr/bin/dbus-broker-launch
4026532170 mnt         1   750 chrony /usr/sbin/chronyd -F 2
4026532171 net         1   742 root   /usr/sbin/irqbalance
4026532231 mnt         1   742 root   /usr/sbin/irqbalance
4026532232 mnt         1   744 root   /usr/lib/systemd/systemd-lo
4026532233 uts         1   750 chrony /usr/sbin/chronyd -F 2
4026532234 uts         1   742 root   /usr/sbin/irqbalance
4026532235 user        1   742 root   /usr/sbin/irqbalance
4026532236 uts         1   744 root   /usr/lib/systemd/systemd-lo
4026532330 mnt         1   779 root   /usr/sbin/NetworkManager --
4026532336 mnt         1   934 root   /usr/sbin/rsyslogd -n


# containerd의 유닉스 도메인 소켓 확인 : kubelet에서 사용 , containerd client 3종(ctr, nerdctr, crictl)도 사용
[root@k8s-ctr ~]# ls -l /run/containerd/containerd.sock
srw-rw----. 1 root root 0 Jan 24 13:23 /run/containerd/containerd.sock

[root@k8s-ctr ~]# ss -xl | grep containerd
u_str LISTEN 0      4096        /run/containerd/containerd.sock.ttrpc 50021            * 0   
u_str LISTEN 0      4096              /run/containerd/containerd.sock 50023            * 0   

[root@k8s-ctr ~]# ss -xnp | grep containerd
u_str ESTAB 0      0                                 * 52226            * 50008 users:(("containerd",pid=18589,fd=2),("containerd",pid=18589,fd=1))      
```