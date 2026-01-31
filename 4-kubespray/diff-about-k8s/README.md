# k8s 설치 전/후 서버 환경 변경 비교

1. ip addr 비교 분석
2. ss 비교 분석
3. df 비교 분석
4. findmnt 비교 분석
5. sysctl 비교 분석

## ip addr 비교 분석

ip_addr-1: k8s 설치 전 / ip_addr-2: k8s 설치 후

- 설치 전에는 `lo`와 기본 NIC(`ens5`)만 존재했으나, 설치 후에는 CNI/오버레이 네트워크 인터페이스가 추가됨.
- 쿠버네티스 설치 후 CNI(Flannel) 구성으로 인해 Pod 네트워크(10.233.64.0/24)가 생성되었고, 이를 위해 `flannel.1`, `cni0`, 다수의 `veth` 인터페이스가 생성됨.
- 기본 EC2 네트워크(`ens5`)는 그대로 유지되어 외부 통신 경로는 변하지 않으며, Pod 트래픽은 CNI 오버레이를 통해 내부적으로 라우팅됨.

### 설치 전 (ip_addr-1)
- 인터페이스: `lo`, `ens5` 2개
- `ens5`:
  - IPv4: `172.31.9.85/20` (브로드캐스트 `172.31.15.255`)
  - MTU: `9001`
  - 상태: `UP`
- 추가적인 CNI/오버레이 인터페이스 없음

###  설치 후 (ip_addr-2)
- 기존 `lo`, `ens5`는 유지 (IP/MTU 동일)
- 신규 인터페이스 추가:
  - `flannel.1`: 플란넬 오버레이 VXLAN 인터페이스
    - IPv4: `10.233.64.0/32`
    - MTU: `8951` (오버레이 헤더 반영으로 감소)
  - `cni0`: CNI 브리지
    - IPv4: `10.233.64.1/24` (Pod 네트워크 대역)
    - MTU: `8951`
  - 다수의 `veth*`: 파드 네임스페이스와 연결되는 veth 페어
    - `cni0`에 연결되어 각 파드 트래픽을 브리지로 전달

---

## ss 비교 분석

ss-1: k8s 설치 전 / ss-2: k8s 설치 후

- **컨트롤 플레인 추가**: `kube-apiserver`, `kube-controller`, `kube-scheduler`, `etcd`가 신규로 리스닝.
- **노드 에이전트 활성화**: `kubelet`, `kube-proxy`, `containerd`가 활성화되고 일부는 loopback으로만 노출됨.
- **외부 노출 포트 증가**: `6443`, `10256`, `10257`, `10259`는 모든 인터페이스에서 리스닝.
- **etcd 바인딩**: `2379/2380`은 노드 IP와 loopback에 바인딩되어, 외부 접근 범위가 제한됨.

### 설치 전 (ss-1)
- 열려 있는 포트는 `22/ssh`와 `9090`뿐임.
- `sshd`와 `systemd`만 리스닝 중으로, k8s 관련 프로세스는 없다.

### 설치 후 (ss-2)
- k8s 컨트롤 플레인 및 노드 구성 요소가 리스닝한다.
- 주요 리스닝 포트/프로세스:
  - `6443` : `kube-apiserver` (모든 인터페이스)
  - `2379/2380` : `etcd` (노드 IP와 loopback)
  - `10257` : `kube-controller` (모든 인터페이스)
  - `10259` : `kube-scheduler` (모든 인터페이스)
  - `10256` : `kube-proxy` (모든 인터페이스)
  - `10250` : `kubelet` (노드 IP)
  - `10248` : `kubelet` (loopback)
  - `10249` : `kube-proxy` (loopback)
  - `33355` : `containerd` (loopback)
  - 기존 `22/ssh`, `9090(systemd)`는 유지

---

## df 비교 분석

df-1: k8s 설치 전 / df-2: k8s 설치 후

- k8s 설치 후, 루트 파티션 사용량이 **3.1G → 5.5G(+2.4G)**로 증가하며 사용률도 **6% → 10%**로 상승함.
- `containerd`/`kubelet` 구동으로 인해 **overlay, shm, tmpfs 기반 마운트가 다수 추가**됨.
- `/boot`, `/boot/efi`, `devtmpfs`, `tmpfs(/dev/shm)` 등 기본 시스템 파티션은 **변화 없음**.
- **루트 파티션 증가(약 2.4G)**는 kubelet/컨테이너 런타임 설치, 이미지 다운로드, 기본 애드온 실행으로 인한 디스크 사용 증가로 해석됨.
- **overlay 마운트 다수 생성**은 컨테이너 런타임(containerd)이 파드별 rootfs를 overlay로 구성하고 있음을 의미함.
- **`/var/lib/kubelet/pods/*/volumes/...` tmpfs 마운트**는 쿠버네티스가 서비스어카운트 토큰 및 API 접근 정보를 projected volume으로 제공하는 정상 동작 현상.

즉, K8s 설치 후에는 컨테이너 런타임과 kubelet 동작으로 인해 **디스크 사용량 증가** 및 **컨테이너/파드 관련 임시 마운트 증가**가 확인되며, 기본 부트/EFI 파티션은 변동이 없다.

### 주요 항목 비교

| 항목 | df-1 (설치 전) | df-2 (설치 후) | 변화 |
| --- | --- | --- | --- |
| `/` (root) | 59G 중 3.1G 사용 (6%) | 59G 중 5.5G 사용 (10%) | +2.4G 사용 증가 |
| `/run` | 548K 사용 | 2.9M 사용 | 런타임/서비스 증가로 사용량 상승 |
| `/boot` | 498M 사용 (54%) | 동일 | 변화 없음 |
| `/boot/efi` | 13M 사용 (7%) | 동일 | 변화 없음 |
| `/run/user/0` | 없음 | 1.6G tmpfs 마운트 | root 세션/서비스용 tmpfs 추가 |
| `containerd overlay` | 없음 | 다수 추가 | 컨테이너 루트fs 오버레이 |
| `containerd shm` | 없음 | 다수 추가 | 컨테이너 IPC 공유 메모리 |
| `kubelet projected` | 없음 | 다수 추가 | Pod 서비스어카운트 토큰/Config 저장 |

### overlay / shm 보완 설명
- df-2 기준 `overlay` 마운트 **22개** 확인: 모두 `overlay` 타입이며 `/run/containerd/io.containerd.runtime.v2.task/k8s.io/<id>/rootfs` 형태로 생성됨.
- df-2 기준 `shm` 마운트 **11개** 확인: 모두 `tmpfs 64M`로 `/run/containerd/io.containerd.grpc.v1.cri/sandboxes/<id>/shm` 형태로 생성됨.
- 공통 특성: `overlay`는 루트 파티션(`/`)과 동일한 용량(59G)·사용량(5.5G)을 보여 컨테이너가 호스트 디스크를 오버레이로 공유함을 나타내고, `shm`은 컨테이너 IPC를 위한 공유 메모리로 0% 사용 상태가 다수.

---

## findmnt 비교 분석

findmnt-1: k8s 설치 전 / findmnt-2: k8s 설치 후
- k8s 설치 이후 **컨테이너 런타임(containerd)**, **CNI 네트워크 네임스페이스**, **kubelet 파드 볼륨** 관련 마운트가 대거 추가됨.
- 기본 시스템/디스크 마운트는 동일하며, 주요 차이는 **컨테이너 및 파드 실행을 위한 런타임/네트워킹/볼륨 계층**의 생성 여부임.

### 공통 구성
- 루트(/)와 /boot, /boot/efi의 기본 디스크 파티션 구성은 동일
- /dev, /sys, /proc, /run 등 기본 가상 파일시스템 구성은 동일
- /var/lib/nfs/rpc_pipefs는 설치 전후 동일

### 설치 후 추가된 마운트
- **containerd 관련 마운트 (ID별 상세는 원문 참조)**
  - `/run/containerd/.../shm` : 각 컨테이너 샌드박스 공유 메모리(tmpfs)
  - `/run/containerd/.../rootfs` : overlayfs 기반 컨테이너 루트 파일시스템
  - 의미: 컨테이너 런타임(containerd) 사용으로 오버레이 스냅샷 다수 생성(샌드박스/컨테이너 ID 다수)
- **CNI 네임스페이스 마운트**
  - `/run/netns/cni-...` : nsfs 네트워크 네임스페이스
  - 의미: 파드 네트워크 구성을 위한 CNI 네임스페이스 다수 생성
- **kubelet 파드 볼륨 마운트**
  - `/var/lib/kubelet/pods/.../volumes/k8s.io~projected/kube-api-access-*` : tmpfs
  - 의미: 서비스어카운트 토큰/CA/네임스페이스 정보가 들어가는 projected 볼륨
  - 크기(size): `15009012k`, `307200k`, `204800k` 등으로 파드별 상이
- **추가 tmpfs 사용자 런타임**
  - `/run/user/0` : root 사용자 tmpfs
- **binfmt_misc 실마운트**
  - `/proc/sys/fs/binfmt_misc` 아래에 `binfmt_misc`가 실제 마운트됨
  - 의미: systemd-binfmt가 활성화되어 커널 binfmt_misc 지원 사용

### 설치 후 옵션/구조 변화
- `/sys/fs/cgroup` 옵션 변화
  - 설치 전: `nsdelegate,memory_recursiveprot` 포함
  - 설치 후: 해당 옵션이 보이지 않음
  - 의미: cgroup2 마운트 옵션이 변경됨(시스템 구성 또는 kubelet/containerd 영향 가능)

---

## sysctl 비교 분석

sysctl-1: k8s 설치 전 / sysctl-2: k8s 설치 후

- 삭제된 키 없음. 기존 키는 그대로 유지됨.
- 값 변경 10개: 그중 정책성 변경 4개, 나머지 6개는 런타임 카운터/상태성 값 변화.
- 신규 키 1,036개: 대부분 CNI/Flannel/가상 인터페이스(veth) 생성에 따른 per-interface sysctl과 conntrack 관련 항목.

### 설정 변경 일부 정리
| 키 | 설치 전 | 설치 후 | 의미/해석 |
| --- | --- | --- | --- |
| `kernel.panic` | `0` | `10` | 커널 패닉 시 자동 재부팅까지의 대기 시간(초). 0은 자동 재부팅 비활성. |
| `net.ipv4.conf.all.route_localnet` | `0` | `1` | 127/8(로컬넷) 트래픽 라우팅 허용. 보통 NodePort/프록시 흐름을 위해 활성화되는 경우가 있음. |
| `net.ipv4.ip_local_reserved_ports` | *(비어 있음)* | `30000-32767` | 로컬 포트 예약 범위. 일반적으로 k8s NodePort 범위를 예약. |
| `vm.overcommit_memory` | `0` | `1` | 메모리 overcommit 허용(더 관대한 할당). |

### 런타임/상태성 변화
아래 항목은 시스템 사용량/상태에 따라 변하는 값으로 보이며, 설정 변경으로 보기 어렵다.
- `fs.dentry-state`, `fs.file-nr`, `fs.inode-nr`, `fs.inode-state`
- `kernel.ns_last_pid`
- `kernel.random.uuid`

### 신규 키(설치 후에만 존재)
대부분 네트워크 인터페이스 생성과 netfilter/conntrack 활성화에 따른 자동 노출 항목이다.

#### 네트워크 인터페이스별 sysctl
- `net.ipv4.conf.cni0.*`, `net.ipv4.conf.flannel/1.*`, `net.ipv4.conf.veth*.*`
- `net.ipv6.conf.cni0.*`, `net.ipv6.conf.flannel/1.*`, `net.ipv6.conf.veth*.*`
- `net.ipv4.neigh.*`, `net.ipv6.neigh.*` (cni0/flannel/veth 등에 대한 neighbor 관련 값)

#### conntrack/netfilter
- `net.netfilter.*` (conntrack timeout/버킷/임계치 등)
- `net.nf_conntrack_max = 131072`
