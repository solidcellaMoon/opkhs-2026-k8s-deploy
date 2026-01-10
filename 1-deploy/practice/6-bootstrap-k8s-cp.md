# 6. k8s control plane 구동

| 항목               | 네트워크 대역 or IP     |
| ---------------- | ----------------- |
| **clusterCIDR**  | **10.200.0.0/16** |
| → node-0 PodCIDR | 10.200.0.0/24     |
| → node-1 PodCIDR | 10.200.1.0/24     |
| **ServiceCIDR**  | **10.32.0.0/24**  |
| → api clusterIP  | 10.32.0.1         |


## jumpbox에서 설정 파일 작성 후 server 에 전달

### Prerequisites

kube-apiserver.service 수정 : service-cluster-ip-range 추가
- https://github.com/kelseyhightower/kubernetes-the-hard-way/issues/905
- service-cluster-ip 값은 ca.conf 에 설정한 [kube-api-server_alt_names] 항목의 Service IP 범위

```bash
root@jumpbox:~/kubernetes-the-hard-way# cat ca.conf | grep '\[kube-api-server_alt_names' -A2
[kube-api-server_alt_names]
IP.0  = 127.0.0.1
IP.1  = 10.32.0.1

# 여기서 일부 설정을 고쳐야 한다.
root@jumpbox:~/kubernetes-the-hard-way# cat units/kube-apiserver.service
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


root@jumpbox:~/kubernetes-the-hard-way# cat << EOF > units/kube-apiserver.service
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


root@jumpbox:~/kubernetes-the-hard-way# cat units/kube-apiserver.service
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
root@jumpbox:~/kubernetes-the-hard-way# cat configs/kube-apiserver-to-kubelet.yaml
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
root@jumpbox:~/kubernetes-the-hard-way# openssl x509 -in kube-api-server.crt -text -noout | grep kubernetes
        Subject: CN=kubernetes, C=US, ST=Washington, L=Seattle
                IP Address:127.0.0.1, IP Address:10.32.0.1, DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster, DNS:kubernetes.svc.cluster.local, DNS:server.kubernetes.local, DNS:api-server.kubernetes.local
```

api -> kubelet 호출 시 Flow
```bash
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
```

이어서 진행한다.
```bash
# kube-scheduler
root@jumpbox:~/kubernetes-the-hard-way# cat units/kube-scheduler.service
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

root@jumpbox:~/kubernetes-the-hard-way# cat configs/kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true


# kube-controller-manager : cluster-cidr 는 POD CIDR 포함하는 대역, service-cluster-ip-range 는 apiserver 설정 값 동일 설정.

root@jumpbox:~/kubernetes-the-hard-way# cat units/kube-controller-manager.service
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

root@jumpbox:~/kubernetes-the-hard-way# scp \
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
root@jumpbox:~/kubernetes-the-hard-way# ssh server ls -l /root
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

## k8s control plane 구동 후 kubectl로 확인

```bash
# Create the Kubernetes configuration directory:
root@server:~# pwd
/root
root@server:~# ls
admin.kubeconfig        kube-apiserver-to-kubelet.yaml      kube-scheduler.service
ca.crt                  kube-apiserver.service              kube-scheduler.yaml
ca.key                  kube-controller-manager             kubectl
encryption-config.yaml  kube-controller-manager.kubeconfig  service-accounts.crt
kube-api-server.crt     kube-controller-manager.service     service-accounts.key
kube-api-server.key     kube-scheduler
kube-apiserver          kube-scheduler.kubeconfig

root@server:~# mkdir -p /etc/kubernetes/config


# Install the Kubernetes binaries:
root@server:~# mv kube-apiserver \
  kube-controller-manager \
  kube-scheduler kubectl \
  /usr/local/bin/

root@server:~# ls -l /usr/local/bin/kube-*
-rwxr-xr-x 1 root root 93261976 Jan 10 12:59 /usr/local/bin/kube-apiserver
-rwxr-xr-x 1 root root 85987480 Jan 10 12:59 /usr/local/bin/kube-controller-manager
-rwxr-xr-x 1 root root 65843352 Jan 10 12:59 /usr/local/bin/kube-scheduler


# Configure the Kubernetes API Server
root@server:~# mkdir -p /var/lib/kubernetes/

root@server:~# mv ca.crt ca.key \
  kube-api-server.key kube-api-server.crt \
  service-accounts.key service-accounts.crt \
  encryption-config.yaml \
  /var/lib/kubernetes/

root@server:~# ls -l /var/lib/kubernetes/
total 28
-rw-r--r-- 1 root root 1899 Jan 10 12:24 ca.crt
-rw------- 1 root root 3272 Jan 10 12:24 ca.key
-rw-r--r-- 1 root root  271 Jan 10 12:43 encryption-config.yaml
-rw-r--r-- 1 root root 2354 Jan 10 12:24 kube-api-server.crt
-rw------- 1 root root 3272 Jan 10 12:24 kube-api-server.key
-rw-r--r-- 1 root root 2004 Jan 10 12:24 service-accounts.crt
-rw------- 1 root root 3272 Jan 10 12:24 service-accounts.key

## Create the kube-apiserver.service systemd unit file:
root@server:~# mv kube-apiserver.service \
  /etc/systemd/system/kube-apiserver.service

root@server:~# tree /etc/systemd/system
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
root@server:~# mv kube-controller-manager.kubeconfig /var/lib/kubernetes/

## Create the kube-controller-manager.service systemd unit file:
root@server:~# mv kube-controller-manager.service /etc/systemd/system/


# Configure the Kubernetes Scheduler

## Move the kube-scheduler kubeconfig into place:
root@server:~# mv kube-scheduler.kubeconfig /var/lib/kubernetes/

## Create the kube-scheduler.yaml configuration file:
root@server:~# mv kube-scheduler.yaml /etc/kubernetes/config/

## Create the kube-scheduler.service systemd unit file:
root@server:~# mv kube-scheduler.service /etc/systemd/system/


# Start the Controller Services : Allow up to 10 seconds for the Kubernetes API Server to fully initialize.

root@server:~# systemctl daemon-reload
root@server:~# systemctl enable kube-apiserver kube-controller-manager kube-scheduler
Created symlink '/etc/systemd/system/multi-user.target.wants/kube-apiserver.service' → '/etc/systemd/system/kube-apiserver.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/kube-controller-manager.service' → '/etc/systemd/system/kube-controller-manager.service'.
Created symlink '/etc/systemd/system/multi-user.target.wants/kube-scheduler.service' → '/etc/systemd/system/kube-scheduler.service'.


root@server:~# systemctl start  kube-apiserver kube-controller-manager kube-scheduler

# 확인
root@server:~# ss -tlp | grep kube
LISTEN 0      4096               *:10259             *:*    users:(("kube-scheduler",pid=2738,fd=3)) 
LISTEN 0      4096               *:10257             *:*    users:(("kube-controller",pid=2737,fd=3))
LISTEN 0      4096               *:6443              *:*    users:(("kube-apiserver",pid=2733,fd=3))
```


```bash
root@server:~# systemctl is-active kube-apiserver
active
root@server:~# systemctl status kube-apiserver --no-pager
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

Jan 10 13:06:32 server kube-apiserver[2733]: I0110 13:06:32.513376    2733 sto…stem
Jan 10 13:06:32 server kube-apiserver[2733]: I0110 13:06:32.522218    2733 sto…blic
Jan 10 13:06:32 server kube-apiserver[2733]: I0110 13:06:32.588915    2733 all….1"}
Jan 10 13:06:32 server kube-apiserver[2733]: W0110 13:06:32.595002    2733 lea…196]


root@server:~# systemctl status kube-scheduler --no-pager
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

Jan 10 13:06:32 server kube-scheduler[2738]: I0110 13:06:32.699024    2738 ref…:160
Jan 10 13:06:32 server kube-scheduler[2738]: I0110 13:06:32.752827    2738 ref…:160
Jan 10 13:06:32 server kube-scheduler[2738]: I0110 13:06:32.834416    2738 ref…:160
Jan 10 13:06:32 server kube-scheduler[2738]: I0110 13:06:32.857859    2738 ref…:160
Jan 10 13:06:32 server kube-scheduler[2738]: I0110 13:06:32.986825    2738 ref…:160
Jan 10 13:06:33 server kube-scheduler[2738]: I0110 13:06:33.099800    2738 ref…:160
Jan 10 13:06:33 server kube-scheduler[2738]: I0110 13:06:33.125891    2738 ref…:160
Jan 10 13:06:33 server kube-scheduler[2738]: I0110 13:06:33.137318    2738 ref…:160
Jan 10 13:06:33 server kube-scheduler[2738]: I0110 13:06:33.150134    2738 lea…r...
Jan 10 13:06:33 server kube-scheduler[2738]: I0110 13:06:33.156638    2738 lea…uler
Hint: Some lines were ellipsized, use -l to show in full.


root@server:~# systemctl status kube-controller-manager --no-pager
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

Jan 10 13:06:38 server kube-controller-manager[2737]: I0110 13:06:38.384015    …and
Jan 10 13:06:38 server kube-controller-manager[2737]: I0110 13:06:38.385160    …tor
Jan 10 13:06:38 server kube-controller-manager[2737]: I0110 13:06:38.385189    …ice
Jan 10 13:06:38 server kube-controller-manager[2737]: I0110 13:06:38.385206    …l=5
Jan 10 13:06:38 server kube-controller-manager[2737]: I0110 13:06:38.385233    …l=1
Jan 10 13:06:38 server kube-controller-manager[2737]: I0110 13:06:38.385724    …ent
Jan 10 13:06:38 server kube-controller-manager[2737]: I0110 13:06:38.385165    …ing
Jan 10 13:06:38 server kube-controller-manager[2737]: I0110 13:06:38.386896    …ent
Jan 10 13:06:38 server kube-controller-manager[2737]: I0110 13:06:38.388127    …own
Jan 10 13:06:38 server kube-controller-manager[2737]: I0110 13:06:38.393397    …ota
Hint: Some lines were ellipsized, use -l to show in full.
```

kubectl로 확인한다.

```bash
root@server:~# kubectl cluster-info --kubeconfig admin.kubeconfig
Kubernetes control plane is running at https://127.0.0.1:6443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

root@server:~# kubectl get node --kubeconfig admin.kubeconfig
No resources found
root@server:~# kubectl get pod -A --kubeconfig admin.kubeconfig
No resources found
root@server:~# kubectl get service,ep --kubeconfig admin.kubeconfig
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.32.0.1    <none>        443/TCP   3m45s

NAME                   ENDPOINTS           AGE
endpoints/kubernetes   172.31.5.196:6443   3m45s
```


```bash
# clusterroles 확인
root@server:~# kubectl get clusterroles --kubeconfig admin.kubeconfig
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



root@server:~# kubectl describe clusterroles system:kube-scheduler --kubeconfig admin.kubeconfig
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
root@server:~# kubectl get clusterrolebindings --kubeconfig admin.kubeconfig
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

root@server:~# kubectl describe clusterrolebindings system:kube-scheduler --kubeconfig admin.kubeconfig
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

## RBAC for Kubelet Authorization
- k8s API 서버가 각 작업자 노드에서 Kubelet API에 액세스할 수 있도록 RBAC 구성
- Kubelet API에 대한 액세스 권한은 메트릭, 로그를 검색하고 포드에서 명령을 실행하는 데 필요
- Kubelet의 `--authorization-mode` 플래그를 `Webhook`으로 설정
- Webhook 모드에서는 SubjectAccessReview API를 사용하여 권한 결정

```bash
# api -> kubelet 접속을 위한 RBAC 설정
root@server:~# cat kube-apiserver-to-kubelet.yaml
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

root@server:~# kubectl apply -f kube-apiserver-to-kubelet.yaml --kubeconfig admin.kubeconfig
clusterrole.rbac.authorization.k8s.io/system:kube-apiserver-to-kubelet created
clusterrolebinding.rbac.authorization.k8s.io/system:kube-apiserver created


# 확인
root@server:~# kubectl get clusterroles system:kube-apiserver-to-kubelet --kubeconfig admin.kubeconfig
NAME                               CREATED AT
system:kube-apiserver-to-kubelet   2026-01-10T13:13:47Z
root@server:~# kubectl get clusterrolebindings system:kube-apiserver --kubeconfig admin.kubeconfig
NAME                    ROLE                                           AGE
system:kube-apiserver   ClusterRole/system:kube-apiserver-to-kubelet   30s
```

## jumpbox 서버에서 k8s controlplane 정상 동작 최종 확인
```bash
root@jumpbox:~/kubernetes-the-hard-way# curl -s -k --cacert ca.crt https://server.kubernetes.local:6443/version | jq
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