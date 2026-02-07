# Kubespray 업그레이드 로그 분석 (kubespray_upgrade-4.log)

## 대상/환경 요약
- 노드: k8s-node4, k8s-node5 (워커 노드)
- OS: Rocky Linux 10.1
- 주요 바이너리: kubeadm/kubelet v1.34.3
- 주요 이미지: CoreDNS v1.12.1, pause 3.10.1, metrics-server v0.8.0
- 컨테이너 런타임: containerd (nerdctl 사용)

## 전체 절차 개요 (플레이 순서 기준)
1. 사전 점검/검증
   - Ansible 버전, Python 의존성(netaddr, jinja) 확인
   - 인벤토리 검증(그룹 구성, 네트워크 대역 충돌, Kubernetes 버전 지원 여부 등)
2. 호스트 부트스트랩 및 기본 설정
   - OS 정보 수집, 필수 패키지 설치/정리
   - swap 비활성화, DNS/resolv.conf 점검
3. 바이너리/이미지 준비
   - kubeadm/kubelet v1.34.3 다운로드 및 배치
   - CoreDNS(v1.12.1), pause(3.10.1), metrics-server(v0.8.0) 등 이미지 확보
4. etcd 클라이언트 인증서 처리
   - worker 노드를 `_kubespray_needs_etcd` 그룹에 추가
   - etcd 사용자/그룹 생성 및 cert 확인/동기화
5. 네트워크 플러그인 처리
   - CNI 플러그인 복사(/opt/cni/bin)
   - Flannel subnet.env 생성 대기
6. 워커 업그레이드 (배치 단위)
   - 노드별 반복: Ready 확인 -> cordon -> drain -> kubelet/설정 갱신 -> kube-proxy 재기동 -> uncordon
7. 후처리
   - NetworkManager DNS/resolv.conf 갱신

## 워커 업그레이드 상세
- 순서: k8s-node4 -> k8s-node5 (배치 1개씩 처리)
- 공통 로직:
  - upgrade/pre-upgrade: Ready/스케줄 가능 여부 확인
  - cordon 및 drain (DaemonSet 제외, emptyDir 삭제, grace-period 300s)
  - kubelet 설정/바이너리 갱신 및 서비스 재시작
  - kube-proxy ConfigMap 서버 주소 갱신 후 pod 강제 재시작
  - upgrade/post-upgrade: uncordon

## 네트워크/애드온 처리 흐름
- 플레이 이름은 "Upgrade calico and external cloud provider"이지만 실제 수행은 Flannel 기준으로 진행됨
- CNI 플러그인 복사 후 Flannel subnet.env 대기
- Install Kubernetes apps 플레이는 이번 실행에서는 스킵됨

## 관찰된 경고/특이사항
- drain 시 DaemonSet 관리 Pod 무시 경고
- kube-proxy pod 강제 삭제 시 즉시 삭제 경고(삭제 후에도 잠시 유지될 수 있음)
- coredns 이미지 pull 필요 여부가 노드별로 달랐음(k8s-node4만 pull 수행)

## 스킵된 플레이
- bastion ssh config
- non-cluster container engine upgrade
- control plane 업그레이드(대상 없음)
- Patch Kubernetes for Windows
- Calico Route Reflector
- Install Kubernetes apps

## 결과 요약
- 모든 노드 성공(failed=0, ignored=0)
- 플레이 리캡: k8s-node4 ok=365 changed=33, k8s-node5 ok=341 changed=28
- 주요 소요 상위: flannel subnet.env 대기, drain 단계, containerd/런타임 바이너리 처리
