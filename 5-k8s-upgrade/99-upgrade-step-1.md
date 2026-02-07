# Kubespray 업그레이드 로그 분석 (kubespray_upgrade-1.log)

## 대상/환경 요약
- 노드: k8s-node1, k8s-node2, k8s-node3 (Rocky Linux 10.1)
- 목표 버전: Kubernetes v1.32.10 (kubeadm/kubelet/kubectl)
- 컨테이너 런타임: containerd 기반 (nerdctl 사용)

## 전체 절차 개요 (플레이 순서 기준)
1. 사전 점검/검증
   - Ansible 버전, Python 의존성(netaddr, jinja) 확인
   - 인벤토리 검증(그룹 구성, 네트워크 대역 충돌, Kubernetes 버전 지원 여부 등)
2. 호스트 부트스트랩 및 기본 설정
   - OS 정보 수집, 필수 패키지 설치/정리
   - swap 비활성화, DNS/resolv.conf 점검, 호스트명/네트워크 팩트 수집
3. 바이너리/이미지 준비
   - kubeadm/kubelet/kubectl, etcd, CNI 등 다운로드
   - kubeadm config images list로 컨트롤 플레인 이미지 계산
   - nerdctl로 이미지 pull (예: kube-proxy v1.32.10)
4. etcd 구성/검증
   - etcd 사용자/그룹 생성, 인증서 체크 및 동기화
   - etcd 설정 갱신 및 서비스 상태 확인
5. 컨트롤 플레인 업그레이드 (역호환 유지를 위해 순차 처리)
   - 노드별 반복: Ready 확인 → cordon → drain → kubeadm 업그레이드 → uncordon
   - static pod manifest 갱신 및 kubelet config 업그레이드
6. 네트워크 플러그인 업그레이드
   - CNI 플러그인 복사(/opt/cni/bin)
   - Flannel 매니페스트 적용 및 subnet.env 대기
7. 워커 업그레이드 단계
   - "Finally handle worker upgrades" 플레이는 대상 노드 없음으로 스킵
8. Kubernetes 앱 재적용
   - CoreDNS 및 Metrics Server 매니페스트 재적용
   - kube-proxy DaemonSet 노드셀렉터 패치(Windows 대상 대비용)

## 컨트롤 플레인 업그레이드 상세
- 순서: k8s-node1 -> k8s-node2 -> k8s-node3
- 공통 로직:
  - upgrade/pre-upgrade: Ready/스케줄 가능 여부 확인
  - cordon 및 drain (DaemonSet 제외, emptyDir 삭제, grace-period 300s)
  - kubeadm upgrade node (v1.32.10)
  - static pod manifest 재작성(kube-apiserver, kube-controller-manager, kube-scheduler)
  - kubeconfig 및 kubelet config 업데이트
  - upgrade/post-upgrade: uncordon

## 네트워크/애드온 처리 흐름
- 플레이 이름은 "Upgrade calico and external cloud provider"이지만 실제 수행은 Flannel 기준으로 진행됨
- CNI 플러그인 복사 후 Flannel 매니페스트 적용 및 /run/flannel/subnet.env 생성 대기
- 이후 CoreDNS/metrics-server 등 기본 애드온을 재적용

## 관찰된 경고/특이사항
- kubeadm 업그레이드 시 deprecated config 경고(v1beta4/v1alpha1)
- clusterDNS 권장값(10.233.0.10)과 실제값(10.233.0.3) 불일치 경고
- CRI sandbox image 권장값(registry.k8s.io/pause:3.10) 경고

## 스킵된 플레이
- bastion ssh config
- non-cluster container engine upgrade
- worker nodes etcd 추가
- Calico Route Reflector

## 결과 요약
- 모든 노드 성공(failed=0)
- 주요 소요 상위: kubeadm 업그레이드, flannel subnet.env 대기, etcd cert 동기화
