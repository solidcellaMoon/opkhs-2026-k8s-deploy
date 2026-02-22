# Cluster API로 in-memory k8s 구성

Provider는 개발/디버깅 용도의 In-Memory Provider를 사용한다.
- https://release-1-9.cluster-api.sigs.k8s.io/developer/core/overview
  - `In Memory infrastructure provider (CAPIM) - The In Memory provider is not designed for production use and is intended for development & test only.`  

실습 편의를 위해, RKE2 k8s 위에서 진행한다.

## CAPIM (In Memory Provider) 란?

Cluster API Core에서 제공하는 개발/디버깅 용도의 Provider로, 실제 노드 워크로드는 하나 없이 가짜 클러스터를 생성한다. (즉, dummy)
- CAPD(Doker Provider)는 실제로 노드가 Docker 컨테이너로 동작한다. 다만 여러 대를 띄우고 싶을 경우, 개발 환경의 컴퓨팅 리소스에 영향을 받는 문제가 있음.

만약 Cluster API 리소스 간의 연관 관계 확인 및 디버깅을 빠르게 하고 싶다면, 실제 노드가 생성되지 않아 빠르게 클러스터 형태를 구성할 수 있는 CAPIM을 사용하는 것도 방법이다.

상세한 정보는 공식 문서 내의 아래 항목 참고.

- https://cluster-api.sigs.k8s.io/developer/core/tuning

> Additionally, Cluster API includes CAPD with support for both Docker and in-memory backend. Both allow you to quickly create development clusters with the limited resources available on a developer workstation, however:
>
> - CAPD with docker backend gives you a fully functional cluster running in containers; scalability and performance are limited by the size of your machine.
> 
> - CAPD with the inmemory backend gives you a fake cluster running in memory; you can scale more easily but the clusters do not support any Kubernetes feature other than what is strictly required for CAPI, CABPK and KCP to work.

## Cluster API Core & Dev Provider 설치
```bash
[root@k8s-node1 ~]# mkdir cluster-api
[root@k8s-node1 ~]# cd cluster-api/

[root@k8s-node1 cluster-api]# curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.12.2/clusterctl-linux-amd64 -o clusterctl
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 68.2M  100 68.2M    0     0  29.4M      0  0:00:02  0:00:02 --:--:-- 37.5M

[root@k8s-node1 cluster-api]# chmod +x clusterctl && cp clusterctl /usr/local/bin/clusterctl

## 버전 확인
[root@k8s-node1 cluster-api]# clusterctl version -o json | jq
{
  "clusterctl": {
    "major": "1",
    "minor": "12",
    "gitVersion": "v1.12.2",
    "gitCommit": "9ee80d1ff529c48ae0b8e022ec01d70ac496e8e5",
    "gitTreeState": "clean",
    "buildDate": "2026-01-20T16:48:19Z",
    "goVersion": "go1.24.12",
    "compiler": "gc",
    "platform": "linux/amd64"
  }
}

New clusterctl version available: v1.12.2 -> v1.12.3
sigs.k8s.io/cluster-api

# [Docker 프로바이더] Initialize the management cluster : 현재 k8s 를 관리 클러스터로 변환
## Docker 프로바이더는 프로덕션 환경에 사용하도록 설계되지 않았으며 개발 환경 전용
## ClusterTopology관리형 토폴로지 및 ClusterClass 지원을 활성화하는 데 필요한 기능은 다음과 같이 활성화
## https://cluster-api.sigs.k8s.io/tasks/experimental-features/experimental-features

# Enable the experimental Cluster topology feature
[root@k8s-node1 cluster-api]# export CLUSTER_TOPOLOGY=true

# Initialize the management cluster
[root@k8s-node1 cluster-api]# clusterctl init --infrastructure docker 
Fetching providers
Installing cert-manager version="v1.19.1"
Waiting for cert-manager to be available...
spec.privateKey.rotationPolicy: In cert-manager >= v1.18.0, the default value changed from `Never` to `Always`.
Installing provider="cluster-api" version="v1.12.3" targetNamespace="capi-system"
spec.privateKey.rotationPolicy: In cert-manager >= v1.18.0, the default value changed from `Never` to `Always`.
Installing provider="bootstrap-kubeadm" version="v1.12.3" targetNamespace="capi-kubeadm-bootstrap-system"
spec.privateKey.rotationPolicy: In cert-manager >= v1.18.0, the default value changed from `Never` to `Always`.
Installing provider="control-plane-kubeadm" version="v1.12.3" targetNamespace="capi-kubeadm-control-plane-system"
spec.privateKey.rotationPolicy: In cert-manager >= v1.18.0, the default value changed from `Never` to `Always`.
Installing provider="infrastructure-docker" version="v1.12.3" targetNamespace="capd-system"
spec.privateKey.rotationPolicy: In cert-manager >= v1.18.0, the default value changed from `Never` to `Always`.

Your management cluster has been initialized successfully!

You can now create your first workload cluster by running the following:

  clusterctl generate cluster [name] --kubernetes-version [version] | kubectl apply -f -


New clusterctl version available: v1.12.2 -> v1.12.3
sigs.k8s.io/cluster-api


# 확인
## 관련 crd 설치
[root@k8s-node1 cluster-api]# kubectl get crd
NAME                                                         CREATED AT
addons.k3s.cattle.io                                         2026-02-22T13:26:34Z
adminnetworkpolicies.policy.networking.k8s.io                2026-02-22T13:26:49Z
baselineadminnetworkpolicies.policy.networking.k8s.io        2026-02-22T13:26:49Z
bgpconfigurations.crd.projectcalico.org                      2026-02-22T13:26:49Z
bgpfilters.crd.projectcalico.org                             2026-02-22T13:26:49Z
bgppeers.crd.projectcalico.org                               2026-02-22T13:26:49Z
blockaffinities.crd.projectcalico.org                        2026-02-22T13:26:49Z
caliconodestatuses.crd.projectcalico.org                     2026-02-22T13:26:49Z
certificaterequests.cert-manager.io                          2026-02-22T13:43:55Z
certificates.cert-manager.io                                 2026-02-22T13:43:55Z
challenges.acme.cert-manager.io                              2026-02-22T13:43:55Z
clusterclasses.cluster.x-k8s.io                              2026-02-22T13:44:11Z
clusterinformations.crd.projectcalico.org                    2026-02-22T13:26:49Z
clusterissuers.cert-manager.io                               2026-02-22T13:43:55Z
clusterresourcesetbindings.addons.cluster.x-k8s.io           2026-02-22T13:44:11Z
clusterresourcesets.addons.cluster.x-k8s.io                  2026-02-22T13:44:12Z
clusters.cluster.x-k8s.io                                    2026-02-22T13:44:12Z
devclusters.infrastructure.cluster.x-k8s.io                  2026-02-22T13:44:17Z
devclustertemplates.infrastructure.cluster.x-k8s.io          2026-02-22T13:44:17Z
devmachines.infrastructure.cluster.x-k8s.io                  2026-02-22T13:44:17Z
devmachinetemplates.infrastructure.cluster.x-k8s.io          2026-02-22T13:44:18Z
dockerclusters.infrastructure.cluster.x-k8s.io               2026-02-22T13:44:18Z
dockerclustertemplates.infrastructure.cluster.x-k8s.io       2026-02-22T13:44:18Z
dockermachinepools.infrastructure.cluster.x-k8s.io           2026-02-22T13:44:18Z
dockermachinepooltemplates.infrastructure.cluster.x-k8s.io   2026-02-22T13:44:18Z
dockermachines.infrastructure.cluster.x-k8s.io               2026-02-22T13:44:18Z
dockermachinetemplates.infrastructure.cluster.x-k8s.io       2026-02-22T13:44:18Z
etcdsnapshotfiles.k3s.cattle.io                              2026-02-22T13:26:34Z
extensionconfigs.runtime.cluster.x-k8s.io                    2026-02-22T13:44:12Z
felixconfigurations.crd.projectcalico.org                    2026-02-22T13:26:49Z
globalnetworkpolicies.crd.projectcalico.org                  2026-02-22T13:26:49Z
globalnetworksets.crd.projectcalico.org                      2026-02-22T13:26:49Z
helmchartconfigs.helm.cattle.io                              2026-02-22T13:26:34Z
helmcharts.helm.cattle.io                                    2026-02-22T13:26:34Z
hostendpoints.crd.projectcalico.org                          2026-02-22T13:26:49Z
ipaddressclaims.ipam.cluster.x-k8s.io                        2026-02-22T13:44:12Z
ipaddresses.ipam.cluster.x-k8s.io                            2026-02-22T13:44:12Z
ipamblocks.crd.projectcalico.org                             2026-02-22T13:26:49Z
ipamconfigs.crd.projectcalico.org                            2026-02-22T13:26:49Z
ipamhandles.crd.projectcalico.org                            2026-02-22T13:26:49Z
ippools.crd.projectcalico.org                                2026-02-22T13:26:49Z
ipreservations.crd.projectcalico.org                         2026-02-22T13:26:49Z
issuers.cert-manager.io                                      2026-02-22T13:43:55Z
kubeadmconfigs.bootstrap.cluster.x-k8s.io                    2026-02-22T13:44:14Z
kubeadmconfigtemplates.bootstrap.cluster.x-k8s.io            2026-02-22T13:44:14Z
kubeadmcontrolplanes.controlplane.cluster.x-k8s.io           2026-02-22T13:44:16Z
kubeadmcontrolplanetemplates.controlplane.cluster.x-k8s.io   2026-02-22T13:44:16Z
kubecontrollersconfigurations.crd.projectcalico.org          2026-02-22T13:26:49Z
machinedeployments.cluster.x-k8s.io                          2026-02-22T13:44:12Z
machinedrainrules.cluster.x-k8s.io                           2026-02-22T13:44:12Z
machinehealthchecks.cluster.x-k8s.io                         2026-02-22T13:44:13Z
machinepools.cluster.x-k8s.io                                2026-02-22T13:44:13Z
machines.cluster.x-k8s.io                                    2026-02-22T13:44:13Z
machinesets.cluster.x-k8s.io                                 2026-02-22T13:44:13Z
networkpolicies.crd.projectcalico.org                        2026-02-22T13:26:49Z
networksets.crd.projectcalico.org                            2026-02-22T13:26:49Z
orders.acme.cert-manager.io                                  2026-02-22T13:43:55Z
providers.clusterctl.cluster.x-k8s.io                        2026-02-22T13:43:48Z
stagedglobalnetworkpolicies.crd.projectcalico.org            2026-02-22T13:26:49Z
stagedkubernetesnetworkpolicies.crd.projectcalico.org        2026-02-22T13:26:49Z
stagednetworkpolicies.crd.projectcalico.org                  2026-02-22T13:26:49Z
tiers.crd.projectcalico.org                                  2026-02-22T13:26:49Z

[root@k8s-node1 cluster-api]# kubectl get crd | grep x-k8s
clusterclasses.cluster.x-k8s.io                              2026-02-22T13:44:11Z
clusterresourcesetbindings.addons.cluster.x-k8s.io           2026-02-22T13:44:11Z
clusterresourcesets.addons.cluster.x-k8s.io                  2026-02-22T13:44:12Z
clusters.cluster.x-k8s.io                                    2026-02-22T13:44:12Z
devclusters.infrastructure.cluster.x-k8s.io                  2026-02-22T13:44:17Z
devclustertemplates.infrastructure.cluster.x-k8s.io          2026-02-22T13:44:17Z
devmachines.infrastructure.cluster.x-k8s.io                  2026-02-22T13:44:17Z
devmachinetemplates.infrastructure.cluster.x-k8s.io          2026-02-22T13:44:18Z
dockerclusters.infrastructure.cluster.x-k8s.io               2026-02-22T13:44:18Z
dockerclustertemplates.infrastructure.cluster.x-k8s.io       2026-02-22T13:44:18Z
dockermachinepools.infrastructure.cluster.x-k8s.io           2026-02-22T13:44:18Z
dockermachinepooltemplates.infrastructure.cluster.x-k8s.io   2026-02-22T13:44:18Z
dockermachines.infrastructure.cluster.x-k8s.io               2026-02-22T13:44:18Z
dockermachinetemplates.infrastructure.cluster.x-k8s.io       2026-02-22T13:44:18Z
extensionconfigs.runtime.cluster.x-k8s.io                    2026-02-22T13:44:12Z
ipaddressclaims.ipam.cluster.x-k8s.io                        2026-02-22T13:44:12Z
ipaddresses.ipam.cluster.x-k8s.io                            2026-02-22T13:44:12Z
kubeadmconfigs.bootstrap.cluster.x-k8s.io                    2026-02-22T13:44:14Z
kubeadmconfigtemplates.bootstrap.cluster.x-k8s.io            2026-02-22T13:44:14Z
kubeadmcontrolplanes.controlplane.cluster.x-k8s.io           2026-02-22T13:44:16Z
kubeadmcontrolplanetemplates.controlplane.cluster.x-k8s.io   2026-02-22T13:44:16Z
machinedeployments.cluster.x-k8s.io                          2026-02-22T13:44:12Z
machinedrainrules.cluster.x-k8s.io                           2026-02-22T13:44:12Z
machinehealthchecks.cluster.x-k8s.io                         2026-02-22T13:44:13Z
machinepools.cluster.x-k8s.io                                2026-02-22T13:44:13Z
machines.cluster.x-k8s.io                                    2026-02-22T13:44:13Z
machinesets.cluster.x-k8s.io                                 2026-02-22T13:44:13Z
providers.clusterctl.cluster.x-k8s.io                        2026-02-22T13:43:48Z

## capd-system, capi-(kueadm-X/Y, system), cert-manager 네임스페이스가 생성
[root@k8s-node1 cluster-api]# kubectl get pod -A
NAMESPACE                           NAME                                                            READY   STATUS      RESTARTS   AGE
capd-system                         capd-controller-manager-6bdb8d5798-2vrc7                        1/1     Running     0          70s
capi-kubeadm-bootstrap-system       capi-kubeadm-bootstrap-controller-manager-69c6987b48-9c8rl      1/1     Running     0          74s
capi-kubeadm-control-plane-system   capi-kubeadm-control-plane-controller-manager-cdb78888c-82rrq   1/1     Running     0          72s
capi-system                         capi-controller-manager-b6d474994-x46nt                         1/1     Running     0          75s
cert-manager                        cert-manager-7f6864ff99-l6zp4                                   1/1     Running     0          93s
cert-manager                        cert-manager-cainjector-6595c6777-9qkfc                         1/1     Running     0          93s
cert-manager                        cert-manager-webhook-58fd9998b4-hkcx6                           1/1     Running     0          93s
kube-system                         etcd-k8s-node1                                                  1/1     Running     0          18m
kube-system                         helm-install-rke2-canal-cfrm6                                   0/1     Completed   0          18m
kube-system                         helm-install-rke2-coredns-tpw67                                 0/1     Completed   0          18m
kube-system                         helm-install-rke2-metrics-server-h6ssr                          0/1     Completed   0          18m
kube-system                         helm-install-rke2-runtimeclasses-tt66j                          0/1     Completed   0          18m
kube-system                         kube-apiserver-k8s-node1                                        1/1     Running     0          18m
kube-system                         kube-controller-manager-k8s-node1                               1/1     Running     0          18m
kube-system                         kube-proxy-k8s-node1                                            1/1     Running     0          18m
kube-system                         kube-proxy-k8s-node2                                            1/1     Running     0          6m39s
kube-system                         kube-scheduler-k8s-node1                                        1/1     Running     0          18m
kube-system                         rke2-canal-pdp5m                                                2/2     Running     0          6m39s
kube-system                         rke2-canal-rlb7w                                                2/2     Running     0          18m
kube-system                         rke2-coredns-rke2-coredns-559595db99-shj84                      1/1     Running     0          18m
kube-system                         rke2-metrics-server-fdcdf575d-xfdhc                             1/1     Running     0          18m
```

## in-memory provider로 워크로드 클러스터 구성

- CAPIM은 개발/디버깅 시에 사용하는 Provider라 공식 문서 상에 상세한 사용 가이드는 따로 없는 편이다.
- 다만 Cluster API Core가 Release 될 때마다, in-memory Provider의 quickstart manifest를 같이 제공하고 있다. (아래 커맨드의 wget 링크 참고)

구성 순서는 아래와 같다.
- `clusterclass-in-memory.yaml` 받아오기.
- 위 내용을 토대로 `cluster.yaml`구성.
- 위의 두 yaml을 배포 후, clusterctl로 상태를 확인한다.

```bash
[root@k8s-node1 cluster-api]# wget https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.12.2/clusterclass-in-memory.yaml
--2026-02-22 14:38:21--  https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.12.2/clusterclass-in-memory.yaml
Resolving github.com (github.com)... 20.200.245.247
Connecting to github.com (github.com)|20.200.245.247|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://release-assets.githubusercontent.com/github-production-release-asset/124157517/48f797e2-a543-4ffe-aefe-e91c595cba75?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-22T15%3A30%3A41Z&rscd=attachment%3B+filename%3Dclusterclass-in-memory.yaml&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-22T14%3A30%3A16Z&ske=2026-02-22T15%3A30%3A41Z&sks=b&skv=2018-11-09&sig=Sd00Zugy8sP14SbsnnOpJpijscbd57owqUfMBaokzIw%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MTc3MTQwMSwibmJmIjoxNzcxNzcxMTAxLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.vuDSFp6jpQ1qmDYLW_nkeiXlKrUlFSPEsdt3-5INljg&response-content-disposition=attachment%3B%20filename%3Dclusterclass-in-memory.yaml&response-content-type=application%2Foctet-stream [following]
--2026-02-22 14:38:21--  https://release-assets.githubusercontent.com/github-production-release-asset/124157517/48f797e2-a543-4ffe-aefe-e91c595cba75?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-02-22T15%3A30%3A41Z&rscd=attachment%3B+filename%3Dclusterclass-in-memory.yaml&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-02-22T14%3A30%3A16Z&ske=2026-02-22T15%3A30%3A41Z&sks=b&skv=2018-11-09&sig=Sd00Zugy8sP14SbsnnOpJpijscbd57owqUfMBaokzIw%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3MTc3MTQwMSwibmJmIjoxNzcxNzcxMTAxLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.vuDSFp6jpQ1qmDYLW_nkeiXlKrUlFSPEsdt3-5INljg&response-content-disposition=attachment%3B%20filename%3Dclusterclass-in-memory.yaml&response-content-type=application%2Foctet-stream
Resolving release-assets.githubusercontent.com (release-assets.githubusercontent.com)... 185.199.109.133, 185.199.108.133, 185.199.110.133, ...
Connecting to release-assets.githubusercontent.com (release-assets.githubusercontent.com)|185.199.109.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 4839 (4.7K) [application/octet-stream]
Saving to: ‘clusterclass-in-memory.yaml’

clusterclass-in-memory.yaml    100%[====================================================>]   4.73K  --.-KB/s    in 0s      

2026-02-22 14:38:21 (57.2 MB/s) - ‘clusterclass-in-memory.yaml’ saved [4839/4839]



# cluster.yaml 구성
[root@k8s-node1 cluster-api]# cat << EOF > cluster.yaml
apiVersion: cluster.x-k8s.io/v1beta2
kind: Cluster
metadata:
  name: capi-quickstart
spec:
  clusterNetwork:
    pods:
      cidrBlocks:
      - 10.10.0.0/16
    serviceDomain: myk8s-1.local
    services:
      cidrBlocks:
      - 10.20.0.0/16
  topology:
    classRef:
      name: in-memory
    controlPlane:
      replicas: 3
    version: v1.34.3
    workers:
      machineDeployments:
      - class: default-worker
        name: md-0
        replicas: 3
EOF

# 순서대로 manifest 배포
kubectl apply -f clusterclass-in-memory.yaml
kubectl apply -f cluster.yaml


# 잠깐 시간 지난 뒤에 확인. 혹은 실시간으로도 확인해보자.
[root@k8s-node1 cluster-api]# clusterctl describe cluster capi-quickstart
NAME                                                        REPLICAS AVAILABLE READY UP TO DATE STATUS REASON     SINCE  MESSAGE                                                                                  
Cluster/capi-quickstart                                     6/6      6         6     6          True   Available  2m10s                                                                                           
├─ClusterInfrastructure - DevCluster/capi-quickstart-7g8fb                                                                                                                                                        
├─ControlPlane - KubeadmControlPlane/capi-quickstart-9j4rq  3/3      3         3     3          True   Available  2m21s                                                                                           
│ └─3 Machines...                                                    3         3     3          True   Ready      2m21s  See capi-quickstart-9j4rq-48vvg, capi-quickstart-9j4rq-6w2kk, ...                        
└─Workers                                                                                                                                                                                                         
  └─MachineDeployment/capi-quickstart-md-0-4ng7s            3/3      3         3     3          True   Available  2m10s                                                                                           
    └─3 Machines...                                                  3         3     3          True   Ready      2m12s  See capi-quickstart-md-0-4ng7s-gswch-8wbqp, capi-quickstart-md-0-4ng7s-gswch-dvk9n, ...  

New clusterctl version available: v1.12.2 -> v1.12.3
sigs.k8s.io/cluster-api
```

## workload cluster 상태 확인

만들어진 cluster의 kubeconfig를 확인한다.

```bash
[root@k8s-node1 cluster-api]# clusterctl get kubeconfig capi-quickstart
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM2akNDQWRLZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJMk1ESXlNakUwTXprd09Gb1hEVE0yTURJeU1ERTBORFF3T0Zvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTnpuCjFsQzR1QVFheEFJek1Ud3g1UTUzQVA1OVlnSnVmdzFPUFdLaW9LYmdFOThLcEpmU01ZcTNNVUhoVThQQld4ajUKUTQvaHFCZFJYVnlvUWRUTTEyVmd4bCtyQlNRUXZtcnNOUkl0UmRKZEJzdWIvQW05WTQ2TTZCcUh6c052cXlZdgpJa3lGbmoxQjBYejZMdFd4MjZOc3hpZVZRa1NKN2w3Qm1Qa3NKb3JVb1h6WE82OGpuQlUrY0lEbVRQTUpnQUNrCkdGSEZHTjRHOEowSVV6OEw5RndyVGFJQkdXbjlRNXl4THJZRG5rUTFBQzBRc2NwSjRzM1p6b0s0VkZwSldNV0IKTTRpakVQWU83RFliUFZxdG0xNkI3RVR4VEp6VmxaSmZUUkxLaGFnSVJYYVhFbWdLNFBaclc5bnBObHNWTTR4Rwo3NUZ6VmIrNWxYTkdGL1k3Q0MwQ0F3RUFBYU5GTUVNd0RnWURWUjBQQVFIL0JBUURBZ0trTUJJR0ExVWRFd0VCCi93UUlNQVlCQWY4Q0FRQXdIUVlEVlIwT0JCWUVGRkl6QkNJbUV2cUFLeHFXeGhaL0xycjdEbXFoTUEwR0NTcUcKU0liM0RRRUJDd1VBQTRJQkFRQ2MzWlNnZitneUlDSUJSZTdOcGxQbWxqY1lWcDdpcEdNSVF4clVXaFp4cVV2Zgowb2RBaWg1QnFNMG5wL0lsdm0yWnJaNUF0QVgyRjFoUkJtd0s5WTI5cGljNDRGK2xlZXNwSG9UN3pEQkh1VER2CkpVT0lKUTZzVmVyOUFMWEh6K1phYjJMMEtNVTFteVdpYjBKMWt4RWxKVUxQOWYwem95c0xTejB6Z2JCUGtPOWsKK3B0SkZtQmNBa1l1eVo2TE5nSURVWnZvVTNwbEo3bThuQi9FV0psM0lncXR4VzNveldYUFVZek4yazRaSXIwZgpQK1VSV2VYeEQrdjhTMXJFZjdydHNHcGQ5TjlxcjFSaU8ybG5rUVU3eXk1cWtBc1ViUkR3RS9HaEdjVUd2dElyCk5ZaUN3Kyt5YlAzbVozWnRpUEI5bVhiRis2Vko0b1pnbkwwU1lwRDAKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    server: https://10.42.1.8:20000 # 👀 이 IP는?
  name: capi-quickstart
contexts:
- context:
    cluster: capi-quickstart
    user: capi-quickstart-admin
  name: capi-quickstart-admin@capi-quickstart
current-context: capi-quickstart-admin@capi-quickstart
kind: Config
users:
- name: capi-quickstart-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURFekNDQWZ1Z0F3SUJBZ0lJVFdzL2JUbjdlRmt3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TmpBeU1qSXhORE01TURoYUZ3MHlOekF5TWpJeE5EUTBNRGxhTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTJibko4aFdON2h1N0JhUkwKRVNxSnRVK3RHVXNlVEN6R3pOZC9DT21zY3FGUDZYWUc5OGhOeG5aWVFhTUEyb2FlNU9BQ1ZCK1pocS85T2hPTwp3WVRMbmJEenJubzBmRjBtbTdES2EyWVpyczk3bUd2L2dkMU9KbmI4RHIwckRkSlZDeEtrRVVyRTVKbUs0V0lVCklKeUpSUVJibS82T1dCRnVpMnA5d1JqNGhkbmM0Yy9XSm9EMjJuNEljT2t3Y2wzYU1Kd2RabzlyRS9PM0IvLzAKTkN0NkR0MEo1c3QrVWxyNkdFb0tudFF4MFg5UXVsWnprcGlSWVUvVmp4cThkZSttQm1BYlNkUHhBNHcxaG1KSQp1UG5hL0RqaEtOa0d2bnpUNGJyRFdEakhEOUd4aVdGZWFjYWllY2p5MjV1Q3VVUHUrdVdlUktTa01tOXdla1JWCk9iOHhjd0lEQVFBQm8wZ3dSakFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0h3WURWUjBqQkJnd0ZvQVVVak1FSWlZUytvQXJHcGJHRm44dXV2c09hcUV3RFFZSktvWklodmNOQVFFTApCUUFEZ2dFQkFIRDJ1akd1WlhPdFd4c1lHNnBXVkxTZVdxWFoyWU5ueStkWnZVVnhVQndNWWFUNDViSVp6Vzh0ClFFNXBQb0RxcHRCekxBcFRET3FoS2lVQTR0eUdPZWpYTFgxdTh3aStQaVVYSXZMekVRdUpJdzkzckRVTGdyNGcKdWpFZjJwc1haQUNhdzZSdDJNZ3dOaitJSU1HcGhpazFpQ3hweWxtWU8vZGlqdFJYMXBjOWd4dm8zbmFnZU11OQowRksrMVkvem9jclJBemw3bGoxeEZ6TzV5SDJwOEEvaTY4OW9TRFBMTkRvV0UyUGUvWTJXeWViOXFyRVl1UWJiCkVaTXkxSGlubEJjbEl2Rk01bmNJVUFLU0NtdUdZYnRoS0I1TW1yRmZZUVNkd1V0TXY3ZGhCeHV3cDYyY1RscDYKVHBlenZkaWZUbERNWG5wYmYzNUpaaW52ZGNBQ1lBRT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb3dJQkFBS0NBUUVBMmJuSjhoV043aHU3QmFSTEVTcUp0VSt0R1VzZVRDekd6TmQvQ09tc2NxRlA2WFlHCjk4aE54blpZUWFNQTJvYWU1T0FDVkIrWmhxLzlPaE9Pd1lUTG5iRHpybm8wZkYwbW03REthMllacnM5N21Hdi8KZ2QxT0puYjhEcjByRGRKVkN4S2tFVXJFNUptSzRXSVVJSnlKUlFSYm0vNk9XQkZ1aTJwOXdSajRoZG5jNGMvVwpKb0QyMm40SWNPa3djbDNhTUp3ZFpvOXJFL08zQi8vME5DdDZEdDBKNXN0K1VscjZHRW9LbnRReDBYOVF1bFp6CmtwaVJZVS9WanhxOGRlK21CbUFiU2RQeEE0dzFobUpJdVBuYS9EamhLTmtHdm56VDRickRXRGpIRDlHeGlXRmUKYWNhaWVjankyNXVDdVVQdSt1V2VSS1NrTW05d2VrUlZPYjh4Y3dJREFRQUJBb0lCQUFvNzVlYW5wYmE1L2ZYNwpiWDNla245L3djS3RHYno1NDlSUUVzd1A4OGVsbG5TQ1ZEeUVZVWVCVzQrbVFrMkRRMmU5c2M1VGQrdHhUVVZVCkV3TThvemVEMEVoMHZRL1ZieEdsWXpaZUk3bm9UY1p4MlI0NUVVblVrTzkrYTg0b0ExQlViWHJVbVdHblovUkYKSUc0Ui9ZL05ieUxyZWJSaENXR3JQVUw4MGYyMGxDanI1ZHFJRWFvWTZhdndSSUg3Q1A4SG42UEpTdVFKWmRDaApYcWtPVjJMVHh3VUcvTkZha25IZXpTYjljWkF6TUF0M0t2REFqOStrWEQrM05wWVpUaWNmUVM5QnZMWmNrVDFtCkhkU0tHZW1DeWVFRkJKRW90V21WTzlTbFFSc2FKQkFCTjJzTVdaSThDN2dBbG56bW9yTkpDaTJIcnBDSktyNFkKOXovRENHMENnWUVBNEpCMUY3TS9RU2k2SFVZTk95K3M5RkVWQkFUbDB0MG52SWQrbERwQlNaRjRpODdKNEdaUwowZ2xTbWVoTnpEREkyUXJzNG5iWDcwZWs2aFcyNk1XZjQ4U1k4OFNrQUNIby9zSzNDb2VBQWZiVTRydW43RkFUCnRJVjJ3anhiSERVdGR6UFFpeGxCOEppTjA2M3JUc3dVVlRLaFRkTnVldmxpclJ1Y1kxR28xWVVDZ1lFQStEUkQKYzc4RENKT0NYb2I3LzdYK1Q0aWlGL25wM0QrVTcxSitCcy85THZBNlZJN3RPbFgwejJSVnVCMjdQdzVPSndWSQpOV2tVZVZ6V1diUmEza0lxd2NPdEhoWkswOVFjS1poaVRQa0RUZ1YwLzJYdHlFVFdCZ2Y4bFlxaXVlaGY1emYvCjBRSFd0VDBNNjVFNGZrTnYzMjMwZnhsWFpQOWwvam45ZUprb1FKY0NnWUVBa1RJVjQzc01IUTgrTnd0Q0p0Q08KblhHSGl3KzNvWDFJNGdjaGVxbW42TzliNTltT2diN25NZExCUzYzK0QxWkRwc0gvby9WL2JNRUFDako4RDBrbwpObGE1Sm5Rd0xiMi9MbW1yZSsxY2dPaWRnUFFnZ1JUTmlOejZpbUFIOE5jWlRJZCtBVklWWm9EY3dzOGk0OUhrCkc2b2V6WGsxWitHelFZWW11YmprMXhrQ2dZQmc0cFhKNHEvZWN5WWFtL3BXTU1aYWFXMU1pcU04OUJ6QTVxU0gKS0QwZVMydVpna2tiMGwzRGJ0ai9DNndCeXlXNm1aYzhNZzVwNlZGS3B0b3BsQTU0b0ZjOVBWcHNJWW4wdXFUMApndWRGVjEvNktlR05vVUVpRFpBTkY1YTVsdm1JbWhWamtxSXJFTyt3TEhtdTM4Z1ZvU2dsVE5FT2ZadGtoMkpuCjV2RU5kUUtCZ0RoMk5YeFllYUNsbzZjQWltakJFa3M0TmM4SHE0bzFzaEt6QnNuMjRNTzJuRXQ5SXZKYU42UjQKeUF2bWtyZlFjdHlDWmJqREQxbnpYVVZCVTRxaUxMWWNRWG9KK011WFU0WGpPdUVOcGRKVlBxZCswVzBINzdveAo3LytwRWdRbXRNdXpBSEZIVVBCRzJmVElQWnpTTU4xWmE1SWkxSmUzY1NZU2k2aTBvR2Y1Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==###
```

kubeconfig에서 API Server 용도로 정의된 IP는 capd-system의 controller-manager pod와 동일하다.
- 디버깅 용도로 capd-controller-manager가 마치 k8s api-server 처럼 보이도록 최소한의 역할을 해주고 있는 것.

```bash
[root@k8s-node1 cluster-api]# kubectl get po -n capd-system -o wide
NAME                                       READY   STATUS    RESTARTS   AGE   IP          NODE        NOMINATED NODE   READINESS GATES
capd-controller-manager-6bdb8d5798-2vrc7   1/1     Running   0          68m   10.42.1.8   k8s-node2   <none>           <none>


# 한번 해당 workload cluster로 kubectl 요청을 시도해보자.
[root@k8s-node1 cluster-api]# clusterctl get kubeconfig capi-quickstart > kubeconfig


# 한번 해당 workload cluster로 kubectl 요청을 시도해보자. -> 응답이 온다! (다만 제한적이라 실제처럼 사용하다 보면 한계가 보임.)
[root@k8s-node1 cluster-api]# kubectl get node --kubeconfig kubeconfig 
NAME                                     AGE
capi-quickstart-md-0-4ng7s-gswch-8wbqp   26m
capi-quickstart-9j4rq-c6q8j              26m
capi-quickstart-9j4rq-6w2kk              26m
capi-quickstart-9j4rq-48vvg              26m
capi-quickstart-md-0-4ng7s-gswch-dvk9n   26m
capi-quickstart-md-0-4ng7s-gswch-w89c2   26m

[root@k8s-node1 cluster-api]# kubectl get po -A --kubeconfig kubeconfig 
NAMESPACE     NAME                                                  AGE
kube-system   kube-controller-manager-capi-quickstart-9j4rq-48vvg   27m
kube-system   kube-apiserver-capi-quickstart-9j4rq-6w2kk            27m
kube-system   kube-scheduler-capi-quickstart-9j4rq-6w2kk            27m
kube-system   kube-controller-manager-capi-quickstart-9j4rq-6w2kk   27m
kube-system   etcd-capi-quickstart-9j4rq-6w2kk                      27m
kube-system   etcd-capi-quickstart-9j4rq-c6q8j                      27m
kube-system   kube-apiserver-capi-quickstart-9j4rq-c6q8j            27m
kube-system   kube-scheduler-capi-quickstart-9j4rq-c6q8j            27m
kube-system   kube-controller-manager-capi-quickstart-9j4rq-c6q8j   27m
kube-system   etcd-capi-quickstart-9j4rq-48vvg                      27m
kube-system   kube-apiserver-capi-quickstart-9j4rq-48vvg            27m
kube-system   kube-scheduler-capi-quickstart-9j4rq-48vvg            27m

[root@k8s-node1 cluster-api]# kubectl get ns --kubeconfig kubeconfig 
NAME          AGE
default       28m
kube-public   28m
kube-system   28m
```