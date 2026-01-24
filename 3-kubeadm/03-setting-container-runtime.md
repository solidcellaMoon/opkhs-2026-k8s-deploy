# 컨테이너 런타임 세팅

이하 내용은 Control Plane, Worker Node 모두 진행해야 한다.

실습에서는 kubelet이 사용할 CRI 구현체로 containerd를 사용한다.
- k8s v1.24부터는 Docker shim이 제거되었기 때문에, Docker 데몬이 아니라 CRI를 직접 제공하는 런타임(containerd 또는 CRI-O)을 사용해야 함.

## 패키지 및 바이너리 설치

containerd는 쿠버네티스 버전과의 호환성을 고려해 버전을 고정하는 편이 안전하다.
- 실습에서는 명시적으로 `containerd.io-2.1.5-1.el9`를 설치함.

```bash
[root@k8s-ctr ~]# dnf --version
4.14.0
  Installed: dnf-0:4.14.0-25.el9.noarch at Sat 31 May 2025 04:49:59 AM GMT
  Built    : Rocky Linux Build System (Peridot) <releng@rockylinux.org> at Sun 04 May 2025 03:12:14 AM GMT

  Installed: rpm-0:4.16.1.3-37.el9.x86_64 at Sat 31 May 2025 04:49:59 AM GMT
  Built    : Rocky Linux Build System (Peridot) <releng@rockylinux.org> at Tue 22 Apr 2025 04:29:17 AM GMT

# Docker 저장소 추가 : dockerd 설치 X, containerd 설치 OK
[root@k8s-ctr ~]# dnf repolist
repo id                       repo name
appstream                     Rocky Linux 9 - AppStream
baseos                        Rocky Linux 9 - BaseOS
extras                        Rocky Linux 9 - Extras

[root@k8s-ctr ~]# tree /etc/yum.repos.d/
/etc/yum.repos.d/
├── rocky-addons.repo
├── rocky-devel.repo
├── rocky-extras.repo
└── rocky.repo

0 directories, 4 files

[root@k8s-ctr ~]# dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
Adding repo from: https://download.docker.com/linux/centos/docker-ce.repo

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

[root@k8s-ctr ~]# cat /etc/yum.repos.d/docker-ce.repo
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://download.docker.com/linux/centos/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-stable-source]
name=Docker CE Stable - Sources
baseurl=https://download.docker.com/linux/centos/$releasever/source/stable
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-test]
name=Docker CE Test - $basearch
baseurl=https://download.docker.com/linux/centos/$releasever/$basearch/test
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg

[docker-ce-test-source]
name=Docker CE Test - Sources
baseurl=https://download.docker.com/linux/centos/$releasever/source/test
enabled=0
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg


[root@k8s-ctr ~]# dnf makecache
Docker CE Stable - x86_64                   1.0 MB/s |  67 kB     00:00    
Rocky Linux 9 - BaseOS                      6.7 kB/s | 4.3 kB     00:00    
Rocky Linux 9 - AppStream                   8.4 kB/s | 4.8 kB     00:00    
Rocky Linux 9 - Extras                      5.2 kB/s | 3.1 kB     00:00    
Metadata cache created.

# 설치 가능한 모든 containerd.io 버전 확인
[root@k8s-ctr ~]# dnf list --showduplicates containerd.io
Last metadata expiration check: 0:00:13 ago on Sat 24 Jan 2026 01:17:21 PM UTC.
Available Packages
containerd.io.x86_64             1.6.4-3.1.el9              docker-ce-stable
containerd.io.x86_64             1.6.6-3.1.el9              docker-ce-stable
containerd.io.x86_64             1.6.7-3.1.el9              docker-ce-stable
containerd.io.x86_64             1.6.8-3.1.el9              docker-ce-stable
containerd.io.x86_64             1.6.9-3.1.el9              docker-ce-stable
containerd.io.x86_64             1.6.10-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.11-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.12-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.13-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.14-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.15-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.16-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.18-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.19-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.20-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.21-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.22-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.24-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.25-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.26-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.27-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.28-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.28-3.2.el9             docker-ce-stable
containerd.io.x86_64             1.6.31-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.32-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.6.33-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.7.18-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.7.19-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.7.20-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.7.21-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.7.22-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.7.23-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.7.24-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.7.25-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.7.26-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.7.27-3.1.el9             docker-ce-stable
containerd.io.x86_64             1.7.28-1.el9               docker-ce-stable
containerd.io.x86_64             1.7.28-2.el9               docker-ce-stable
containerd.io.x86_64             1.7.29-1.el9               docker-ce-stable
containerd.io.x86_64             2.1.5-1.el9                docker-ce-stable
containerd.io.x86_64             2.2.0-2.el9                docker-ce-stable
containerd.io.x86_64             2.2.1-1.el9                docker-ce-stable
[root@k8s-ctr ~]# 


# containerd 설치
[root@k8s-ctr ~]# dnf install -y containerd.io-2.1.5-1.el9
...
Upgraded:
  selinux-policy-38.1.65-1.el9.noarch                                       
  selinux-policy-targeted-38.1.65-1.el9.noarch                              
Installed:
  container-selinux-4:2.240.0-3.el9_7.noarch                                
  containerd.io-2.1.5-1.el9.x86_64     


# 설치된 파일 확인 - runc
[root@k8s-ctr ~]# which runc && runc --version
/usr/bin/runc
runc version 1.3.3
commit: v1.3.3-0-gd842d771
spec: 1.2.1
go: go1.24.9
libseccomp: 2.5.2

# 설치된 파일 확인 - containerd
[root@k8s-ctr ~]# which containerd && containerd --version
/usr/bin/containerd
containerd containerd.io v2.1.5 fcd43222d6b07379a4be9786bda52438f0dd16a1

# 설치된 파일 확인 - containerd-shim-runc-v2
[root@k8s-ctr ~]# which containerd-shim-runc-v2 && containerd-shim-runc-v2 -v
/usr/bin/containerd-shim-runc-v2
containerd-shim-runc-v2:
  Version:  v2.1.5
  Revision: fcd43222d6b07379a4be9786bda52438f0dd16a1
  Go version: go1.24.9

# 설치된 파일 확인 - ctr
[root@k8s-ctr ~]# which ctr && ctr --version
/usr/bin/ctr
ctr containerd.io v2.1.5

# containerd 기본 설정 파일 확인
[root@k8s-ctr ~]# cat /etc/containerd/config.toml
#   Copyright 2018-2022 Docker Inc.

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#       http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

disabled_plugins = ["cri"]

#root = "/var/lib/containerd"
#state = "/run/containerd"
#subreaper = true
#oom_score = 0

#[grpc]
#  address = "/run/containerd/containerd.sock"
#  uid = 0
#  gid = 0

#[debug]
#  address = "/run/containerd/debug.sock"
#  uid = 0
#  gid = 0
#  level = "info"


[root@k8s-ctr ~]# tree /usr/lib/systemd/system | grep containerd
├── containerd.service

[root@k8s-ctr ~]# cat /usr/lib/systemd/system/containerd.service
# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target dbus.service

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
```

## containerd 기본 세팅

```bash
# 기본 설정 생성 및 SystemdCgroup 활성화 (매우 중요)
[root@k8s-ctr ~]# containerd config default | tee /etc/containerd/config.toml
...

# SystemdCgroup을 확인하고 활성화
[root@k8s-ctr ~]# cat /etc/containerd/config.toml | grep -i systemdcgroup
            SystemdCgroup = false

[root@k8s-ctr ~]# sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

[root@k8s-ctr ~]# cat /etc/containerd/config.toml | grep -i systemdcgroup
            SystemdCgroup = true

# systemd unit 파일 최신 상태 읽기
[root@k8s-ctr ~]# systemctl daemon-reload

# containerd start 와 enabled
[root@k8s-ctr ~]# systemctl enable --now containerd
Created symlink /etc/systemd/system/multi-user.target.wants/containerd.service → /usr/lib/systemd/system/containerd.service.

# 
systemctl status containerd --no-pager
journalctl -u containerd.service --no-pager
pstree -alnp
systemd-cgls --no-pager


# containerd의 유닉스 도메인 소켓 확인 : kubelet에서 사용 , containerd client 3종(ctr, nerdctr, crictl)도 사용
[root@k8s-ctr ~]# containerd config dump | grep -n containerd.sock
11:  address = '/run/containerd/containerd.sock'

[root@k8s-ctr ~]# ls -l /run/containerd/containerd.sock
srw-rw----. 1 root root 0 Jan 24 13:23 /run/containerd/containerd.sock

[root@k8s-ctr ~]# ss -xl | grep containerd
u_str LISTEN 0      4096        /run/containerd/containerd.sock.ttrpc 50021            * 0   
u_str LISTEN 0      4096              /run/containerd/containerd.sock 50023            * 0   

[root@k8s-ctr ~]# ss -xnp | grep containerd
u_str ESTAB 0      0                                 * 52226            * 50008 users:(("containerd",pid=18589,fd=2),("containerd",pid=18589,fd=1))                                  

# 플러그인 확인
[root@k8s-ctr ~]# ctr --address /run/containerd/containerd.sock version
Client:
  Version:  v2.1.5
  Revision: fcd43222d6b07379a4be9786bda52438f0dd16a1
  Go version: go1.24.9

Server:
  Version:  v2.1.5
  Revision: fcd43222d6b07379a4be9786bda52438f0dd16a1
  UUID: a3358ece-3435-4ccf-ab25-4e98b60b27b7

[root@k8s-ctr ~]# ctr plugins ls
TYPE                                      ID                       PLATFORMS      STATUS    
io.containerd.content.v1                  content                  -              ok        
io.containerd.image-verifier.v1           bindir                   -              ok        
io.containerd.internal.v1                 opt                      -              ok        
io.containerd.warning.v1                  deprecations             -              ok        
io.containerd.snapshotter.v1              blockfile                linux/amd64    skip      
io.containerd.snapshotter.v1              devmapper                linux/amd64    skip      
io.containerd.snapshotter.v1              erofs                    linux/amd64    skip      
io.containerd.snapshotter.v1              native                   linux/amd64    ok        
io.containerd.snapshotter.v1              overlayfs                linux/amd64    ok        
io.containerd.snapshotter.v1              zfs                      linux/amd64    skip      
io.containerd.event.v1                    exchange                 -              ok        
io.containerd.monitor.task.v1             cgroups                  linux/amd64    ok        
io.containerd.metadata.v1                 bolt                     -              ok        
io.containerd.gc.v1                       scheduler                -              ok        
io.containerd.differ.v1                   erofs                    -              skip      
io.containerd.differ.v1                   walking                  linux/amd64    ok        
io.containerd.lease.v1                    manager                  -              ok        
io.containerd.service.v1                  containers-service       -              ok        
io.containerd.service.v1                  content-service          -              ok        
io.containerd.service.v1                  diff-service             -              ok        
io.containerd.service.v1                  images-service           -              ok        
io.containerd.service.v1                  introspection-service    -              ok        
io.containerd.service.v1                  namespaces-service       -              ok        
io.containerd.service.v1                  snapshots-service        -              ok        
io.containerd.shim.v1                     manager                  -              ok        
io.containerd.runtime.v2                  task                     linux/amd64    ok        
io.containerd.service.v1                  tasks-service            -              ok        
io.containerd.grpc.v1                     containers               -              ok        
io.containerd.grpc.v1                     content                  -              ok        
io.containerd.grpc.v1                     diff                     -              ok        
io.containerd.grpc.v1                     events                   -              ok        
io.containerd.grpc.v1                     images                   -              ok        
io.containerd.grpc.v1                     introspection            -              ok        
io.containerd.grpc.v1                     leases                   -              ok        
io.containerd.grpc.v1                     namespaces               -              ok        
io.containerd.sandbox.store.v1            local                    -              ok        
io.containerd.transfer.v1                 local                    -              ok        
io.containerd.cri.v1                      images                   -              ok        
io.containerd.cri.v1                      runtime                  linux/amd64    ok        
io.containerd.podsandbox.controller.v1    podsandbox               -              ok        
io.containerd.sandbox.controller.v1       shim                     -              ok        
io.containerd.grpc.v1                     sandbox-controllers      -              ok        
io.containerd.grpc.v1                     sandboxes                -              ok        
io.containerd.grpc.v1                     snapshots                -              ok        
io.containerd.streaming.v1                manager                  -              ok        
io.containerd.grpc.v1                     streaming                -              ok        
io.containerd.grpc.v1                     tasks                    -              ok        
io.containerd.grpc.v1                     transfer                 -              ok        
io.containerd.grpc.v1                     version                  -              ok        
io.containerd.monitor.container.v1        restart                  -              ok        
io.containerd.tracing.processor.v1        otlp                     -              skip      
io.containerd.internal.v1                 tracing                  -              skip      
io.containerd.ttrpc.v1                    otelttrpc                -              ok        
io.containerd.grpc.v1                     healthcheck              -              ok        
io.containerd.nri.v1                      nri                      -              ok        
io.containerd.grpc.v1                     cri                      -              ok        
```