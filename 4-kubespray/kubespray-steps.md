# kubespray로 진행되는 k8s 설치 상세

- 로그 원문: [kubespray_install.log](./kubespray_install.log)
- 실행 시각: 2026-01-31 14:57:10 ~ 15:04:15 UTC
- 대상: k8s-ctr (단일 노드)
- 결과: ok=611, changed=139, failed=0 (ignored=2)

## 버전/구성 요소
- `OS`: Rocky Linux 10.1
- `Kubernetes`: v1.33.3 (kubelet/kubeadm/kubectl)
- `Etcd`: v3.5.25 (kubeadm은 external etcd 모드로 동작)
- `Container runtime`: containerd 2.1.5 + runc 1.3.4
- `Tools`: crictl 1.33.0, nerdctl 2.1.6, helm(바이너리 다운로드 및 completion 설치)
- `CNI plugins`: v1.8.0
- `CNI`: Flannel v0.27.3 + flannel-cni-plugin v1.7.1-flannel1
- `Add-ons`: CoreDNS v1.12.0, metrics-server v0.8.0, cluster-proportional-autoscaler v1.8.8, Node Feature Discovery

## 프로비저닝 순서 (PLAY 기준)


1. Check Ansible version
2. Inventory setup and validation
3. Install bastion ssh config (skip)
4. Bootstrap hosts for Ansible
5. Gather facts (network/hardware)
6. Prepare for etcd install
7. Add worker nodes to the etcd play if needed
8. Install etcd
9. Install Kubernetes nodes
10. Install the control plane
11. Invoke kubeadm and install a CNI
12. Install Calico Route Reflector (skip)
13. Patch Kubernetes for Windows
14. Install Kubernetes apps
15. Apply resolv.conf changes now that cluster DNS is up
16. Play recap


## 각 단계에서 수행된 상세 작업

### 사전 검사
- Ansible 버전 범위 확인(2.17.3<= <2.18.0)
- python netaddr/jinja 확인
- 인벤토리 그룹 매핑/검증 (컨트롤플레인/etcd/버전/옵션/네트워크 대역/짝수 etcd host 등)

### OS 부트스트랩
- /etc/os-release 확인 및 Rocky 전용 태스크 포함
- dnf.conf 프록시 적용, fastestmirror 확인, legacy docker repo 제거
- 필수 패키지 설치, remote tmp 생성
- 호스트네임 설정, bash_completion dir 생성

### 네트워크 설정 수집
- default IPv4/IPv6 수집, fallback IP 설정
- main ip/access ip 설정, 네트워크/하드웨어 fact 수집

### Pre Install
- kube/kube-cert 사용자 생성
- swap 제거/비활성화 및 swap.target mask
- resolv.conf 점검/수집, dns_early 설정
- NetworkManager/systemd-resolved 확인, 접근 IP ping/호스트명/네임서버 검증

### 디렉터리/권한 준비
- /etc/kubernetes, manifests, scripts, kubelet-plugins, /etc/kubernetes/ssl 생성
- /etc/kubernetes/pki 링크 생성
- /etc/cni/net.d 및 /opt/cni/bin 생성

### DNS/NetworkManager 설정
- k8s.conf 생성으로 K8S 인터페이스 관리 제외
- dns.conf에 네임서버/검색 도메인/옵션 추가

### SELinux/커널 파라미터
- SELinux permissive 전환
- sysctl 파일 정리 및 ip_forward/커널 파라미터 설정
- fapolicyd 비활성 시도

### 컨테이너 런타임
- runc 패키지 제거 후 바이너리 설치
- crictl 설치 및 /etc/crictl.yaml 생성
- nerdctl 설치 및 /etc/nerdctl/nerdctl.toml 생성

### containerd 구성
- containerd 설치
- base_runtime_spec 생성/저장
- /etc/containerd/config.toml 및 registry hosts 파일 구성
- systemd 서비스 등록/재시작

### 아티팩트/이미지 다운로드
- kubelet/kubectl/kubeadm, etcd/etcdctl/etcdutl 다운로드
- CNI plugins, flannel/coredns/metrics-server/cpa/nginx/kube-* 이미지 확보
- 캐시 확인 후 필요 시 pull

### Etcd 설치
- etcd 사용자 생성
- CA/member/admin/node 인증서 생성/배포(스크립트)
- CA 신뢰 추가
- etcd 바이너리 배치 및 서비스 시작
- 초기 health check 실패 후 정상화

### 노드 구성
- kubelet cgroup driver 감지/설정
- /var/lib/cni 생성
- kubelet 바이너리 배치
- nodePort range 예약
- br_netfilter 모듈 설정 및 bridge sysctl 적용
- kubelet env/config/service 작성 및 systemd reload/restart

### 컨트롤 플레인
- etcd_secret 변경 시 기존 static pod manifests 삭제
- kube-scheduler config 생성
- kubectl 설치 및 bash completion
- kubeadm-config 생성
- kubeadm init(--skip-phases=addon/coredns)

### 컨트롤 플레인 핸들러
- kube-scheduler/kube-controller-manager 컨테이너 제거 후 healthz 대기
- apiserver healthz 확인

### kubeadm 후속
- kubeconfig 생성
- kubeadm token 생성(24h)
- upload-certs 재실행 및 certificate-key 파싱
- component kubeconfigs server 필드 업데이트
- kubelet client cert rotation fix 적용

### kubeadm 출력
- external etcd 모드로 etcd 관련 cert 생성 단계는 kubeadm에서 생략
- kube-proxy 기본 애드온 적용 및 join 명령 출력

### 인증서/클라이언트
- k8s-certs-renew 스크립트 및 systemd timer 설치
- /root/.kube/config 복사
- API 서버 헬스체크

### kube-proxy 처리
- ConfigMap server 필드 갱신 후 kube-proxy 파드 강제 재시작

### 노드 라벨
- role/inventory 기반 라벨 리스트 설정 및 적용(빈 목록 확인 로그 포함)

### CNI/Flannel
- CNI plugins 복사
- flannel 매니페스트 생성/적용
- /run/flannel/subnet.env 생성 대기

### Windows 노드 용도 패치
- kube-proxy DS에 linux nodeSelector 적용
- 사용자 매니페스트 디렉터리 생성

### Kubernetes apps
- 노드 등록용 ClusterRoleBinding 생성
- PriorityClass(k8s-cluster-critical) 적용
- CoreDNS/metrics-server/cluster-proportional-autoscaler/Node Feature Discovery 매니페스트 생성 및 적용
- helm 다운로드 및 completion 설치

### DNS 후처리
- dns_early false로 전환 후 NetworkManager dns.conf 재정렬
- 컨트롤 플레인 파드 재시작 핸들러 수행

### 스킵된 단계
- bastion ssh config
- Calico Route Reflector (해당 호스트 없음)

## 로그에서 확인된 경고/특이사항
- kubeadm init 경고: clusterDNS 값이 권장(10.233.0.10)과 다름 (10.233.0.3 사용)
- kubeadm 경고: UpgradeConfiguration 문서가 v1beta4로 인식되어 무시됨
- control-plane 체크 중 kubectl get nodes 실패 1회 발생했으나 ignore 처리 (API 서버 준비 전)
- etcd health check에서 초기 연결 실패가 있었고 이후 서비스 재시작으로 정상화
