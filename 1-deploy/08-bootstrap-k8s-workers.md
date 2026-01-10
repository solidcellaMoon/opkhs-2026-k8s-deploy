# k8s worker node 구동

## jumpbox에서 사전 준비
```bash
# cni(bridge) 파일과 kubelet-config 파일 작성 및 node-0/1에 전달
root@jumpbox:~/kubernetes-the-hard-way# cat configs/10-bridge.conf | jq
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
root@jumpbox:~/kubernetes-the-hard-way# cat configs/kubelet-config.yaml
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


root@jumpbox:~/kubernetes-the-hard-way# for HOST in node-0 node-1; do
  SUBNET=$(grep ${HOST} machines.txt | cut -d " " -f 4)
  sed "s|SUBNET|$SUBNET|g" \
    configs/10-bridge.conf > 10-bridge.conf

  sed "s|SUBNET|$SUBNET|g" \
    configs/kubelet-config.yaml > kubelet-config.yaml

  scp 10-bridge.conf kubelet-config.yaml \
  root@${HOST}:~/
done
10-bridge.conf                                            100%  265   757.4KB/s   00:00    
kubelet-config.yaml                                       100%  610     1.6MB/s   00:00     
10-bridge.conf                                            100%  265   636.9KB/s   00:00    
kubelet-config.yaml                                       100%  610     1.6MB/s   00:00    

# 확인
root@jumpbox:~/kubernetes-the-hard-way# ssh node-0 ls -l /root
total 8
-rw-r--r-- 1 root root 265 Jan 10 13:22 10-bridge.conf
-rw-r--r-- 1 root root 610 Jan 10 13:22 kubelet-config.yaml

root@jumpbox:~/kubernetes-the-hard-way# ssh node-1 ls -l /root
total 8
-rw-r--r-- 1 root root 265 Jan 10 13:22 10-bridge.conf
-rw-r--r-- 1 root root 610 Jan 10 13:22 kubelet-config.yaml


# 파일 확인 및 node-0/1에 전달
root@jumpbox:~/kubernetes-the-hard-way# cat configs/99-loopback.conf ; echo
{
  "cniVersion": "1.1.0",
  "name": "lo",
  "type": "loopback"
}

root@jumpbox:~/kubernetes-the-hard-way# cat configs/containerd-config.toml ; echo
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

root@jumpbox:~/kubernetes-the-hard-way# cat configs/kube-proxy-config.yaml ; echo
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"


root@jumpbox:~/kubernetes-the-hard-way# cat units/containerd.service
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
WantedBy=multi-user.targetroot@jumpbox:~/kubernetes-the-hard-way# cat units/kubeletcat units/kubelet.service
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
root@jumpbox:~/kubernetes-the-hard-way# cat units/kube-proxy.service
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


root@jumpbox:~/kubernetes-the-hard-way# for HOST in node-0 node-1; do
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


root@jumpbox:~/kubernetes-the-hard-way# for HOST in node-0 node-1; do
  scp \
    downloads/cni-plugins/* \
    root@${HOST}:~/cni-plugins/
done
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
root@jumpbox:~/kubernetes-the-hard-way# ssh node-0 ls -l /root
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

root@jumpbox:~/kubernetes-the-hard-way# ssh node-1 ls -l /root
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

root@jumpbox:~/kubernetes-the-hard-way# ssh node-0 ls -l /root/cni-plugins
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

root@jumpbox:~/kubernetes-the-hard-way# ssh node-1 ls -l /root/cni-plugins
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

## worker node 구동: node-0, node-1 에 접속해서 실행

### node-0 접속 후 실행
```bash
root@node-0:~# pwd
/root
root@node-0:~# ls -l
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
root@node-0:~# apt-get -y install socat conntrack ipset kmod psmisc bridge-utils
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
root@node-0:~# swapon --show
root@node-0:~#

# Create the installation directories
root@node-0:~# mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

# Install the worker binaries:
root@node-0:~# mv crictl kube-proxy kubelet runc /usr/local/bin/
root@node-0:~# mv containerd containerd-shim-runc-v2 containerd-stress /bin/
root@node-0:~# mv cni-plugins/* /opt/cni/bin/


# Configure CNI Networking

## Create the bridge network configuration file:

root@node-0:~# mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/
root@node-0:~# cat /etc/cni/net.d/10-bridge.conf 
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
root@node-0:~# lsmod | grep netfilter
root@node-0:~# modprobe br-netfilter
root@node-0:~# echo "br-netfilter" >> /etc/modules-load.d/modules.conf
root@node-0:~# lsmod | grep netfilter
br_netfilter           36864  0
bridge                372736  1 br_netfilter

root@node-0:~# echo "net.bridge.bridge-nf-call-iptables = 1"  >> /etc/sysctl.d/kubernetes.conf
root@node-0:~# echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/kubernetes.conf
root@node-0:~# sysctl -p /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1


# Configure containerd : Install the containerd configuration files:
root@node-0:~# mkdir -p /etc/containerd/
root@node-0:~# mv containerd-config.toml /etc/containerd/config.toml
root@node-0:~# mv containerd.service /etc/systemd/system/
root@node-0:~# cat /etc/containerd/config.toml ; echo
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
```

kubelet ↔ containerd 연결 Flow
```bash
kubelet
  ↓ CRI (gRPC)
unix:///var/run/containerd/containerd.sock
  ↓
containerd CRI plugin
  ↓
runc
  ↓
Linux namespaces / cgroups
```

이어서 진행
```bash
# Configure the Kubelet : Create the kubelet-config.yaml configuration file:
root@node-0:~# mv kubelet-config.yaml /var/lib/kubelet/
root@node-0:~# mv kubelet.service /etc/systemd/system/

# Configure the Kubernetes Proxy
root@node-0:~# mv kube-proxy-config.yaml /var/lib/kube-proxy/
root@node-0:~# mv kube-proxy.service /etc/systemd/system/

# Start the Worker Services
root@node-0:~# systemctl daemon-reload
root@node-0:~# systemctl enable containerd kubelet kube-proxy
Created symlink '/etc/systemd/system/multi-user.target.wants/containerd.service' → '/etc/systemd/system/containerd.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/kubelet.service' → '/etc/systemd/system/kubelet.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/kube-proxy.service' → '/etc/systemd/system/kube-proxy.service'.
root@node-0:~# systemctl start containerd kubelet kube-proxy

# 확인
root@node-0:~# systemctl status kubelet --no-pager
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

Jan 10 13:32:02 node-0 kubelet[2788]: I0110 13:32:02.021776    2788 kubelet_no…ach"
Jan 10 13:32:02 node-0 kubelet[2788]: I0110 13:32:02.022662    2788 kubelet_no…ory"
Jan 10 13:32:02 node-0 kubelet[2788]: I0110 13:32:02.022690    2788 kubelet_no…ure"
Jan 10 13:32:02 node-0 kubelet[2788]: I0110 13:32:02.022698    2788 kubelet_no…PID"
Jan 10 13:32:02 node-0 kubelet[2788]: I0110 13:32:02.022720    2788 kubelet_no…112"
Jan 10 13:32:02 node-0 kubelet[2788]: E0110 13:32:02.035943    2788 kubelet_node_s…
Jan 10 13:32:02 node-0 kubelet[2788]: W0110 13:32:02.110362    2788 reflector.go:5…
Jan 10 13:32:02 node-0 kubelet[2788]: E0110 13:32:02.110410    2788 reflector.go:1…
Jan 10 13:32:02 node-0 kubelet[2788]: I0110 13:32:02.805065    2788 csi_plugin.go:…
Jan 10 13:32:03 node-0 kubelet[2788]: I0110 13:32:03.805343    2788 csi_plugin.go:…
Hint: Some lines were ellipsized, use -l to show in full.


root@node-0:~# systemctl status containerd --no-pager
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

Jan 10 13:31:53 node-0 containerd[2753]: time="2026-01-10T13:31:53.569622239Z"…trpc
Jan 10 13:31:53 node-0 containerd[2753]: time="2026-01-10T13:31:53.569691074Z"…sock
Jan 10 13:31:53 node-0 containerd[2753]: time="2026-01-10T13:31:53.569792564Z"…tor"
Jan 10 13:31:53 node-0 containerd[2753]: time="2026-01-10T13:31:53.569864980Z"…ult"
Jan 10 13:31:53 node-0 containerd[2753]: time="2026-01-10T13:31:53.569922269Z"…ver"
Jan 10 13:31:53 node-0 containerd[2753]: time="2026-01-10T13:31:53.569983107Z"…NRI"
Jan 10 13:31:53 node-0 containerd[2753]: time="2026-01-10T13:31:53.570033922Z"…..."
Jan 10 13:31:53 node-0 containerd[2753]: time="2026-01-10T13:31:53.570086220Z"…..."
Jan 10 13:31:53 node-0 containerd[2753]: time="2026-01-10T13:31:53.570148027Z"…ate"
Jan 10 13:31:53 node-0 containerd[2753]: time="2026-01-10T13:31:53.570288566Z"…99s"

Hint: Some lines were ellipsized, use -l to show in full.


root@node-0:~# systemctl status kube-proxy --no-pager
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

Jan 10 13:31:53 node-0 systemd[1]: Started kube-proxy.service - Kubernetes Ku…roxy.
Jan 10 13:31:53 node-0 kube-proxy[2751]: E0110 13:31:53.524483    2751 proxier…ATH"
Jan 10 13:31:53 node-0 kube-proxy[2751]: E0110 13:31:53.525400    2751 proxier…ATH"
Jan 10 13:31:53 node-0 kube-proxy[2751]: E0110 13:31:53.567005    2751 server.…und"
Jan 10 13:31:54 node-0 kube-proxy[2751]: E0110 13:31:54.726877    2751 server.…und"
Jan 10 13:31:56 node-0 kube-proxy[2751]: E0110 13:31:56.748438    2751 server.…und"
Jan 10 13:32:00 node-0 kube-proxy[2751]: E0110 13:32:00.935709    2751 server.…und"
Jan 10 13:32:10 node-0 kube-proxy[2751]: E0110 13:32:10.400630    2751 server.…und"
Hint: Some lines were ellipsized, use -l to show in full.

root@node-0:~# exit
```

이후, node-1에 접속하여 node-0과 똑같이 구성해준다.

### jumpbox 에서 server 접속하여 kubectl node 정보 최종 확인
```bash
root@jumpbox:~/kubernetes-the-hard-way# ssh server "kubectl get nodes -owide --kubeconfig admin.kubeconfig"
NAME     STATUS   ROLES    AGE    VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION              CONTAINER-RUNTIME
node-0   Ready    <none>   11m    v1.32.3   172.31.8.112    <none>        Debian GNU/Linux 13 (trixie)   6.12.48+deb13-cloud-amd64   containerd://2.1.0-beta.0
node-1   Ready    <none>   110s   v1.32.3   172.31.15.209   <none>        Debian GNU/Linux 13 (trixie)   6.12.48+deb13-cloud-amd64   containerd://2.1.0-beta.0

root@jumpbox:~/kubernetes-the-hard-way# ssh server "kubectl get pod -A --kubeconfig admin.kubeconfig"
No resources found
```