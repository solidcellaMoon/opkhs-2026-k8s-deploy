# 노드 용도 서버에서 필요한 커널 세팅 진행

이하 내용은 Control Plane, Worker Node 모두 진행해야 한다.

## Swap Off

- 실습 환경에서는 EC2 user-data에서 미리 swapoff를 처리했기 때문에 커맨드 자체는 생략.
- 왜 swapoff를 해야하는가?
  - k8s는 기본적으로 swap이 켜진 노드를 거부함.
  - kubelet의 스케줄링/eviction 정책은 실제 메모리를 기준으로 설계돼서, swap이 있다면 리소스 계산이 왜곡될 수 있다.
- 특히 메모리 부족 상황에서 OS가 swap을 쓰기 시작하면, 파드의 상태가 애매해지고(갑작스러운 지연/타임아웃) 원인 추적이 어려워진다.

## 커널 파라미터 설정

- `overlay`: OverlayFS를 활성화하기 위함. (여러 파일시스템 레이어를 하나로 겹쳐 보이게 만드는 기술)
  - 효과: 이미지 재사용이 쉬워지고, 컨테이너는 가벼워진다.
  - 동작 방식:
    - Base Image(Lower Layer)는 수정되지 않음
    - 컨테이너에서 파일을 새로 만들면, Upper Layer에만 생성
    - 기존 파일을 수정하면, Upper Layer에 복사 후 수정
    - 컨테이너가 삭제되면, Upper Layer만 사라지고 Lower Layer는 그대로 유지
- `br_netfilter`: 브릿지 네트워크 트래픽이 iptables를 거치도록 함.
  - CNI가 구성한 bridge를 통과하는 패킷이 iptables 규칙을 통과해야 네트워크 정책, 서비스 라우팅, kube-proxy 규칙이 정상적으로 동작함.
  - 이 모듈이 없으면 k8s 내부 통신이 비정상적으로 보인다.

sysctl 항목 설명
- `net.bridge.bridge-nf-call-iptables`: 브릿지로 들어온 IPv4 트래픽을 iptables로 전달.
- `net.bridge.bridge-nf-call-ip6tables`: 브릿지로 들어온 IPv6 트래픽을 ip6tables로 전달.
- `net.ipv4.ip_forward`: 노드가 라우팅 역할을 할 수 있게 하여 Pod 간, Pod-서비스 간 패킷 전달을 활성화.

```bash
# 커널 모듈 확인
[root@k8s-ctr ~]# lsmod
Module                  Size  Used by
tls                   159744  0
rfkill                 40960  1
intel_rapl_msr         20480  0
intel_rapl_common      57344  1 intel_rapl_msr
intel_uncore_frequency_common    16384  0
nfit                   90112  0
libnvdimm             253952  1 nfit
vfat                   24576  1
fat                   102400  1 vfat
rapl                   24576  0
ppdev                  24576  0
pcspkr                 12288  0
parport_pc             49152  0
i2c_piix4              28672  0
parport                90112  2 parport_pc,ppdev
drm                   811008  0
fuse                  212992  1
xfs                  2686976  2
libcrc32c              12288  1 xfs
crct10dif_pclmul       12288  1
crc32_pclmul           12288  0
crc32c_intel           24576  1
nvme                   65536  3
ena                   159744  0
ghash_clmulni_intel    16384  0
nvme_core             245760  4 nvme
nvme_auth              28672  1 nvme_core
serio_raw              16384  0
sunrpc                892928  1
dm_mirror              28672  0
dm_region_hash         28672  1 dm_mirror
dm_log                 24576  2 dm_region_hash,dm_mirror
dm_mod                245760  2 dm_log,dm_mirror

# 없다...
[root@k8s-ctr ~]# lsmod | grep -iE 'overlay|br_netfilter'
[root@k8s-ctr ~]# 


# 커널 모듈 로드
[root@k8s-ctr ~]# modprobe overlay
[root@k8s-ctr ~]# modprobe br_netfilter

[root@k8s-ctr ~]# lsmod | grep -iE 'overlay|br_netfilter'
br_netfilter           36864  0
bridge                417792  1 br_netfilter
overlay               229376  0


# 
[root@k8s-ctr ~]# cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
overlay
br_netfilter

[root@k8s-ctr ~]# tree /etc/modules-load.d/
/etc/modules-load.d/
└── k8s.conf

0 directories, 1 file


# 커널 파라미터 설정 : 네트워크 설정 - 브릿지 트래픽이 iptables를 거치도록 함
[root@k8s-ctr ~]# cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1

[root@k8s-ctr ~]# tree /etc/sysctl.d/
/etc/sysctl.d/
├── 99-sysctl.conf -> ../sysctl.conf
└── k8s.conf

0 directories, 2 files

# 설정 적용
[root@k8s-ctr ~]# sysctl --system

# 적용 확인
[root@k8s-ctr ~]# sysctl net.bridge.bridge-nf-call-iptables
net.bridge.bridge-nf-call-iptables = 1

[root@k8s-ctr ~]# sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1
```
