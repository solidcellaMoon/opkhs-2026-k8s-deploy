# Control Plane 구동

Master Node를 구동해보자.

## 기본 환경 정보 출력 저장
```bash
[root@k8s-ctr ~]# crictl images
IMAGE               TAG                 IMAGE ID            SIZE

[root@k8s-ctr ~]# crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD                 NAMESPACE

[root@k8s-ctr ~]# cat /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS=

[root@k8s-ctr ~]# tree /etc/kubernetes  | tee -a etc_kubernetes-1.txt
/etc/kubernetes
└── manifests

1 directory, 0 files

[root@k8s-ctr ~]# tree /var/lib/kubelet | tee -a var_lib_kubelet-1.txt
/var/lib/kubelet

0 directories, 0 files

[root@k8s-ctr ~]# tree /run/containerd/ -L 3 | tee -a run_containerd-1.txt
/run/containerd/
├── containerd.sock
├── containerd.sock.ttrpc
├── io.containerd.grpc.v1.cri
├── io.containerd.runtime.v2.task
└── io.containerd.sandbox.controller.v1.shim

3 directories, 2 files

pstree -alnp | tee -a pstree-1.txt
systemd-cgls --no-pager | tee -a systemd-cgls-1.txt
lsns | tee -a lsns-1.txt
ip addr | tee -a ip_addr-1.txt 
ss -tnlp | tee -a ss-1.txt
df -hT | tee -a df-1.txt
findmnt | tee -a findmnt-1.txt
sysctl -a | tee -a sysctl-1.txt
```

## kubeadm init을 통한 Control Plane 구동

```bash
# kubeadm Configuration 파일 작성
cat << EOF > kubeadm-init.yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: InitConfiguration
bootstrapTokens:
- token: "123456.1234567890123456"
  ttl: "0s"
  usages:
  - signing
  - authentication
nodeRegistration:
  kubeletExtraArgs:
    - name: node-ip
      value: "172.31.7.91"  # 미설정 시 10.0.2.15 맵핑
  criSocket: "unix:///run/containerd/containerd.sock"
localAPIEndpoint:
  advertiseAddress: "172.31.7.91"
---
apiVersion: kubeadm.k8s.io/v1beta4
kind: ClusterConfiguration
kubernetesVersion: "1.32.11"
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/16"
EOF


# (옵션) 컨테이너 이미지 미리 다운로드 : 특히 업그레이드 작업 시, 작업 시간 단축을 위해서 수행할 것
[root@k8s-ctr ~]# kubeadm config images pull
I0124 13:39:38.797893   19556 version.go:261] remote version is much newer: v1.35.0; falling back to: stable-1.32
[config/images] Pulled registry.k8s.io/kube-apiserver:v1.32.11
[config/images] Pulled registry.k8s.io/kube-controller-manager:v1.32.11
[config/images] Pulled registry.k8s.io/kube-scheduler:v1.32.11
[config/images] Pulled registry.k8s.io/kube-proxy:v1.32.11
[config/images] Pulled registry.k8s.io/coredns/coredns:v1.11.3
[config/images] Pulled registry.k8s.io/pause:3.10
[config/images] Pulled registry.k8s.io/etcd:3.5.24-0


# k8s controlplane 초기화 설정 수행
kubeadm init --config="kubeadm-init.yaml" --dry-run

[root@k8s-ctr ~]# tree /etc/kubernetes
/etc/kubernetes
├── manifests
└── tmp
    └── kubeadm-init-dryrun2765897431
        ├── admin.conf
        ├── apiserver.crt
        ├── apiserver-etcd-client.crt
        ├── apiserver-etcd-client.key
        ├── apiserver.key
        ├── apiserver-kubelet-client.crt
        ├── apiserver-kubelet-client.key
        ├── ca.crt
        ├── ca.key
        ├── config.yaml
        ├── controller-manager.conf
        ├── etcd
        │   ├── ca.crt
        │   ├── ca.key
        │   ├── healthcheck-client.crt
        │   ├── healthcheck-client.key
        │   ├── peer.crt
        │   ├── peer.key
        │   ├── server.crt
        │   └── server.key
        ├── etcd.yaml
        ├── front-proxy-ca.crt
        ├── front-proxy-ca.key
        ├── front-proxy-client.crt
        ├── front-proxy-client.key
        ├── kubeadm-flags.env
        ├── kube-apiserver.yaml
        ├── kube-controller-manager.yaml
        ├── kubelet.conf
        ├── kube-scheduler.yaml
        ├── sa.key
        ├── sa.pub
        ├── scheduler.conf
        └── super-admin.conf

4 directories, 33 files

[root@k8s-ctr ~]# kubeadm init --config="kubeadm-init.yaml"
[init] Using Kubernetes version: v1.32.11
...
Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.31.7.91:6443 --token 123456.1234567890123456 \
        --discovery-token-ca-cert-hash sha256:6325553fc03e0e9da0920cc80bd14ce892fb84f9b040f484c7c93d5df4c767ba 
```

## 클러스터 초기 상태 확인

```bash
# crictl 확인
[root@k8s-ctr ~]# crictl images
IMAGE                                     TAG                 IMAGE ID            SIZE
registry.k8s.io/coredns/coredns           v1.11.3             c69fa2e9cbf5f       18.6MB
registry.k8s.io/etcd                      3.5.24-0            8cb12dd0c3e42       23.7MB
registry.k8s.io/kube-apiserver            v1.32.11            7757c58248a29       29.1MB
registry.k8s.io/kube-controller-manager   v1.32.11            0175d0a8243db       26.7MB
registry.k8s.io/kube-proxy                v1.32.11            4d8fb2dc57519       31.2MB
registry.k8s.io/kube-scheduler            v1.32.11            23d6a1fb92fda       21.1MB
registry.k8s.io/pause                     3.10                873ed75102791       320kB

[root@k8s-ctr ~]# crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD                               NAMESPACE
d39bcfcefe10f       4d8fb2dc57519       32 seconds ago      Running             kube-proxy                0                   f123c57aa10c5       kube-proxy-9mmtj                  kube-system
baf9e47a27bd2       23d6a1fb92fda       44 seconds ago      Running             kube-scheduler            0                   6f9d7f5f73054       kube-scheduler-k8s-ctr            kube-system
8fe92955898fd       8cb12dd0c3e42       44 seconds ago      Running             etcd                      0                   d96321f881611       etcd-k8s-ctr                      kube-system
22428ce31397e       0175d0a8243db       44 seconds ago      Running             kube-controller-manager   0                   e8e663905eb9c       kube-controller-manager-k8s-ctr   kube-system
3eb004e7463a5       7757c58248a29       44 seconds ago      Running             kube-apiserver            0                   eed0b187abb95       kube-apiserver-k8s-ctr            kube-system


# kubeconfig 작성
[root@k8s-ctr ~]# mkdir -p /root/.kube
[root@k8s-ctr ~]# cp -i /etc/kubernetes/admin.conf /root/.kube/config
[root@k8s-ctr ~]# chown $(id -u):$(id -g) /root/.kube/config
[root@k8s-ctr ~]# alias k=kubectl

# 확인
[root@k8s-ctr ~]# k cluster-info
Kubernetes control plane is running at https://172.31.7.91:6443
CoreDNS is running at https://172.31.7.91:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

[root@k8s-ctr ~]# k get node -owide
NAME      STATUS     ROLES           AGE    VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                      KERNEL-VERSION                 CONTAINER-RUNTIME
k8s-ctr   NotReady   control-plane   100s   v1.32.11   172.31.7.91   <none>        Rocky Linux 9.6 (Blue Onyx)   5.14.0-570.17.1.el9_6.x86_64   containerd://2.1.5

[root@k8s-ctr ~]# k get nodes -o json | jq ".items[] | {name:.metadata.name} + .status.capacity"
{
  "name": "k8s-ctr",
  "cpu": "4",
  "ephemeral-storage": "61719532Ki",
  "hugepages-1Gi": "0",
  "hugepages-2Mi": "0",
  "memory": "15900228Ki",
  "pods": "110"
}

[root@k8s-ctr ~]# k get pod -n kube-system -owide
NAME                              READY   STATUS    RESTARTS   AGE     IP            NODE      NOMINATED NODE   READINESS GATES
coredns-668d6bf9bc-m9wgw          0/1     Pending   0          2m20s   <none>        <none>    <none>           <none>
coredns-668d6bf9bc-s2444          0/1     Pending   0          2m20s   <none>        <none>    <none>           <none>
etcd-k8s-ctr                      1/1     Running   0          2m26s   172.31.7.91   k8s-ctr   <none>           <none>
kube-apiserver-k8s-ctr            1/1     Running   0          2m26s   172.31.7.91   k8s-ctr   <none>           <none>
kube-controller-manager-k8s-ctr   1/1     Running   0          2m26s   172.31.7.91   k8s-ctr   <none>           <none>
kube-proxy-9mmtj                  1/1     Running   0          2m20s   172.31.7.91   k8s-ctr   <none>           <none>
kube-scheduler-k8s-ctr            1/1     Running   0          2m26s   172.31.7.91   k8s-ctr   <none>           <none>

# coredns 의 service name 확인 : kube-dns
[root@k8s-ctr ~]# k get svc -n kube-system
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   2m56s

# cluster-info ConfigMap 공개 : cluster-info는 '신원 확인 전, 최소한의 신뢰 부트스트랩 데이터'
[root@k8s-ctr ~]# k -n kube-public get configmap cluster-info
NAME           DATA   AGE
cluster-info   2      3m34s

[root@k8s-ctr ~]# k -n kube-public get configmap cluster-info -o yaml
apiVersion: v1
data:
  jws-kubeconfig-123456: eyJhbGciOiJIUzI1NiIsImtpZCI6IjEyMzQ1NiJ9..ZjrFdGm-o5MjilGZDPmveikrlwVRgvfdS2mwsbDzzXA
  kubeconfig: |
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJZC82d0l2MURaTU13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TmpBeE1qUXhNek0xTkRCYUZ3MHpOakF4TWpJeE16UXdOREJhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURGSTVJbTZZWi9kTHErNkVicTYvdk5lQ1krWEY3aWQ4ekd4cFhtTnZXRkFseDNvdmt0MWtZZ3BmMmEKazFlL2NITDZQMVl2dlJlL1NhckRqZ2huSEFOQXhtdXF4ZkJCTzZjNkxmRERVQTZCdE9iRjMrcmJIV01WRkU2NQpKT1N0TFgzQWpkSEJIaHc1TnBBNVAzRTRmUDBmQ0NDKytnUEFrNFArM2tCcThrQndxcjNZTnlpaXUxK0FxeFZrCjZjMlFKN0lTTGxYQnZQd2s2NTA4K3JwR240T3NmMERPUGtySVlLcmJJK00yK29kYlZDWkVDQW1GenlvbG9CRTUKd0RXQXB1cFljcEpWWmVEZk05a2ltWUdxenE2bzFLWkdEcW9INzJiNGtpYWdUZ3FKRmJDdWZteVhvcmF6emg5cgpvZFF6WExPSDNuM0w4YUZHaEErN1EvN21jVitaQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSWFEzbDBqNkpidU5SdWQzaUlsNFNJL0tEcy9UQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ0FTTlNaVnAyRQp4T1VIQTlkUUszRVMvSW1ob213QS9tdkw4NitMUGxpWGhtNm9ML09BclB3dHk0UGJMeGpjNzUvZHlVWTQxMXJRCllCS0Z2Y0ozQncxWGFKRi9PQWZEeDZSM2ovRXVNNGRRTlFqMnNud0pLbDJQeVB3QjJGaEo0RWRQbkp2ekxTTGIKZjhXbnlmOXBDRVdkaTd1MVc3ejdqUkVzaVhieUlXMVdVVSs3MTAvYzdHUEdZM1pjZ2ZjdmF3WG5xd3pFcDB0eAorZTNpWTk4RDYxMXM2NDBqaHJMUVhrcThNQjQ3U3Q2VnhSQW5qZUs3Z2RNOSswSE5HMGo3WFNLcWpIcTFCNHRzClNGU2JTaEhiZ0RkQ1N2UlZVZWhhVU5aS21sVVVPQjFjYmtWT0Urc05ESzAvMk4zUFBDUmRMSTg3MXRwY3FYdisKY2FSSjBCVWZRT2I2Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
        server: https://172.31.7.91:6443
      name: ""
    contexts: null
    current-context: ""
    kind: Config
    preferences: {}
    users: null
kind: ConfigMap
metadata:
  creationTimestamp: "2026-01-24T13:40:51Z"
  name: cluster-info
  namespace: kube-public
  resourceVersion: "294"
  uid: 8d6d4d93-ca0e-4d20-b456-e16957060766

[root@k8s-ctr ~]# k -n kube-public get configmap cluster-info -o jsonpath='{.data.kubeconfig}' | grep certificate-authority-data | cut -d ':' -f2 | tr -d ' ' | base64 -d | openssl x509 -text -noout
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 8646541998922360003 (0x77feb022fd4364c3)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=kubernetes
        Validity
            Not Before: Jan 24 13:35:40 2026 GMT
            Not After : Jan 22 13:40:40 2036 GMT
        Subject: CN=kubernetes
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:c5:23:92:26:e9:86:7f:74:ba:be:e8:46:ea:eb:
                    fb:cd:78:26:3e:5c:5e:e2:77:cc:c6:c6:95:e6:36:
                    f5:85:02:5c:77:a2:f9:2d:d6:46:20:a5:fd:9a:93:
                    57:bf:70:72:fa:3f:56:2f:bd:17:bf:49:aa:c3:8e:
                    08:67:1c:03:40:c6:6b:aa:c5:f0:41:3b:a7:3a:2d:
                    f0:c3:50:0e:81:b4:e6:c5:df:ea:db:1d:63:15:14:
                    4e:b9:24:e4:ad:2d:7d:c0:8d:d1:c1:1e:1c:39:36:
                    90:39:3f:71:38:7c:fd:1f:08:20:be:fa:03:c0:93:
                    83:fe:de:40:6a:f2:40:70:aa:bd:d8:37:28:a2:bb:
                    5f:80:ab:15:64:e9:cd:90:27:b2:12:2e:55:c1:bc:
                    fc:24:eb:9d:3c:fa:ba:46:9f:83:ac:7f:40:ce:3e:
                    4a:c8:60:aa:db:23:e3:36:fa:87:5b:54:26:44:08:
                    09:85:cf:2a:25:a0:11:39:c0:35:80:a6:ea:58:72:
                    92:55:65:e0:df:33:d9:22:99:81:aa:ce:ae:a8:d4:
                    a6:46:0e:aa:07:ef:66:f8:92:26:a0:4e:0a:89:15:
                    b0:ae:7e:6c:97:a2:b6:b3:ce:1f:6b:a1:d4:33:5c:
                    b3:87:de:7d:cb:f1:a1:46:84:0f:bb:43:fe:e6:71:
                    5f:99
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment, Certificate Sign
            X509v3 Basic Constraints: critical
                CA:TRUE
            X509v3 Subject Key Identifier: 
                57:43:79:74:8F:A2:5B:B8:D4:6E:77:78:88:97:84:88:FC:A0:EC:FD
            X509v3 Subject Alternative Name: 
                DNS:kubernetes
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        80:48:d4:99:56:9d:84:c4:e5:07:03:d7:50:2b:71:12:fc:89:
        a1:a2:6c:00:fe:6b:cb:f3:af:8b:3e:58:97:86:6e:a8:2f:f3:
        80:ac:fc:2d:cb:83:db:2f:18:dc:ef:9f:dd:c9:46:38:d7:5a:
        d0:60:12:85:bd:c2:77:07:0d:57:68:91:7f:38:07:c3:c7:a4:
        77:8f:f1:2e:33:87:50:35:08:f6:b2:7c:09:2a:5d:8f:c8:fc:
        01:d8:58:49:e0:47:4f:9c:9b:f3:2d:22:db:7f:c5:a7:c9:ff:
        69:08:45:9d:8b:bb:b5:5b:bc:fb:8d:11:2c:89:76:f2:21:6d:
        56:51:4f:bb:d7:4f:dc:ec:63:c6:63:76:5c:81:f7:2f:6b:05:
        e7:ab:0c:c4:a7:4b:71:f9:ed:e2:63:df:03:eb:5d:6c:eb:8d:
        23:86:b2:d0:5e:4a:bc:30:1e:3b:4a:de:95:c5:10:27:8d:e2:
        bb:81:d3:3d:fb:41:cd:1b:48:fb:5d:22:aa:8c:7a:b5:07:8b:
        6c:48:54:9b:4a:11:db:80:37:42:4a:f4:55:51:e8:5a:50:d6:
        4a:9a:55:14:38:1d:5c:6e:45:4e:13:eb:0d:0c:ad:3f:d8:dd:
        cf:3c:24:5d:2c:8f:3b:d6:da:5c:a9:7b:fe:71:a4:49:d0:15:
        1f:40:e6:fa
```

## kubeadm init 시 생성되는 객체
- Namespace: kube-public
- ConfigMap: cluster-info
- Role + RoleBinding 
```
대상: system:unauthenticated (인증 안 된 사용자)
권한: get on configmaps/cluster-info
```
👉 아직 클러스터 인증서가 없는 노드(worker) 가 (kubeadm join 전) API Server에 처음 접속해서 최소 정보(엔드포인트 + CA)를 얻기 위해 필요

```bash
[root@k8s-ctr ~]# curl -s -k https://172.31.7.91:6443/api/v1/namespaces/kube-public/configmaps/cluster-info | jq
{
  "kind": "ConfigMap",
  "apiVersion": "v1",
  "metadata": {
    "name": "cluster-info",
    "namespace": "kube-public",
    "uid": "8d6d4d93-ca0e-4d20-b456-e16957060766",
    "resourceVersion": "294",
    "creationTimestamp": "2026-01-24T13:40:51Z",
    "managedFields": [
      {
        "manager": "kubeadm",
        "operation": "Update",
        "apiVersion": "v1",
        "time": "2026-01-24T13:40:51Z",
        "fieldsType": "FieldsV1",
        "fieldsV1": {
          "f:data": {
            ".": {},
            "f:kubeconfig": {}
          }
        }
      },
      {
        "manager": "kube-controller-manager",
        "operation": "Update",
        "apiVersion": "v1",
        "time": "2026-01-24T13:40:57Z",
        "fieldsType": "FieldsV1",
        "fieldsV1": {
          "f:data": {
            "f:jws-kubeconfig-123456": {}
          }
        }
      }
    ]
  },
  "data": {
    "jws-kubeconfig-123456": "eyJhbGciOiJIUzI1NiIsImtpZCI6IjEyMzQ1NiJ9..ZjrFdGm-o5MjilGZDPmveikrlwVRgvfdS2mwsbDzzXA",
    "kubeconfig": "apiVersion: v1\nclusters:\n- cluster:\n    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJZC82d0l2MURaTU13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TmpBeE1qUXhNek0xTkRCYUZ3MHpOakF4TWpJeE16UXdOREJhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURGSTVJbTZZWi9kTHErNkVicTYvdk5lQ1krWEY3aWQ4ekd4cFhtTnZXRkFseDNvdmt0MWtZZ3BmMmEKazFlL2NITDZQMVl2dlJlL1NhckRqZ2huSEFOQXhtdXF4ZkJCTzZjNkxmRERVQTZCdE9iRjMrcmJIV01WRkU2NQpKT1N0TFgzQWpkSEJIaHc1TnBBNVAzRTRmUDBmQ0NDKytnUEFrNFArM2tCcThrQndxcjNZTnlpaXUxK0FxeFZrCjZjMlFKN0lTTGxYQnZQd2s2NTA4K3JwR240T3NmMERPUGtySVlLcmJJK00yK29kYlZDWkVDQW1GenlvbG9CRTUKd0RXQXB1cFljcEpWWmVEZk05a2ltWUdxenE2bzFLWkdEcW9INzJiNGtpYWdUZ3FKRmJDdWZteVhvcmF6emg5cgpvZFF6WExPSDNuM0w4YUZHaEErN1EvN21jVitaQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSWFEzbDBqNkpidU5SdWQzaUlsNFNJL0tEcy9UQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ0FTTlNaVnAyRQp4T1VIQTlkUUszRVMvSW1ob213QS9tdkw4NitMUGxpWGhtNm9ML09BclB3dHk0UGJMeGpjNzUvZHlVWTQxMXJRCllCS0Z2Y0ozQncxWGFKRi9PQWZEeDZSM2ovRXVNNGRRTlFqMnNud0pLbDJQeVB3QjJGaEo0RWRQbkp2ekxTTGIKZjhXbnlmOXBDRVdkaTd1MVc3ejdqUkVzaVhieUlXMVdVVSs3MTAvYzdHUEdZM1pjZ2ZjdmF3WG5xd3pFcDB0eAorZTNpWTk4RDYxMXM2NDBqaHJMUVhrcThNQjQ3U3Q2VnhSQW5qZUs3Z2RNOSswSE5HMGo3WFNLcWpIcTFCNHRzClNGU2JTaEhiZ0RkQ1N2UlZVZWhhVU5aS21sVVVPQjFjYmtWT0Urc05ESzAvMk4zUFBDUmRMSTg3MXRwY3FYdisKY2FSSjBCVWZRT2I2Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K\n    server: https://172.31.7.91:6443\n  name: \"\"\ncontexts: null\ncurrent-context: \"\"\nkind: Config\npreferences: {}\nusers: null\n"
  }
}

# 403
[root@k8s-ctr ~]# curl -s -k https://172.31.7.91:6443/api/v1/namespaces/default/pods 
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "pods is forbidden: User \"system:anonymous\" cannot list resource \"pods\" in API group \"\" in the namespace \"default\"",
  "reason": "Forbidden",
  "details": {
    "kind": "pods"
  },
  "code": 403
}
  
[root@k8s-ctr ~]# k -n kube-public get role
NAME                                   CREATED AT
kubeadm:bootstrap-signer-clusterinfo   2026-01-24T13:40:51Z
system:controller:bootstrap-signer     2026-01-24T13:40:51Z

[root@k8s-ctr ~]# k -n kube-public get rolebinding
NAME                                   ROLE                                        AGE
kubeadm:bootstrap-signer-clusterinfo   Role/kubeadm:bootstrap-signer-clusterinfo   5m10s
system:controller:bootstrap-signer     Role/system:controller:bootstrap-signer     5m10s
```

## 편의성 툴 설치 (helm, k9s)
```bash
# helm 3 설치 : https://helm.sh/docs/intro/install
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | DESIRED_VERSION=v3.18.6 bash
helm version

# k9s 설치 : https://github.com/derailed/k9s
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
wget https://github.com/derailed/k9s/releases/latest/download/k9s_linux_${CLI_ARCH}.tar.gz
tar -xzf k9s_linux_*.tar.gz
ls -al k9s
chown root:root k9s
mv k9s /usr/local/bin/
chmod +x /usr/local/bin/k9s
k9s
```

## CNI 설치 (Flannel)
```bash
# 현재 k8s 클러스터에 파드 전체 CIDR 확인
[root@k8s-ctr ~]# k describe pod -n kube-system kube-controller-manager-k8s-ctr
Name:                 kube-controller-manager-k8s-ctr
Namespace:            kube-system
Priority:             2000001000
Priority Class Name:  system-node-critical
Node:                 k8s-ctr/172.31.7.91
Start Time:           Sat, 24 Jan 2026 13:40:52 +0000
Labels:               component=kube-controller-manager
                      tier=control-plane
Annotations:          kubernetes.io/config.hash: 7314ab3f0ec6401c196ca943fad44a05
                      kubernetes.io/config.mirror: 7314ab3f0ec6401c196ca943fad44a05
                      kubernetes.io/config.seen: 2026-01-24T13:40:52.261119667Z
                      kubernetes.io/config.source: file
Status:               Running
SeccompProfile:       RuntimeDefault
IP:                   172.31.7.91
IPs:
  IP:           172.31.7.91
Controlled By:  Node/k8s-ctr
Containers:
  kube-controller-manager:
    Container ID:  containerd://22428ce31397e899ed91246eda761f275891991e731d6c23b3d5768e02eec386
    Image:         registry.k8s.io/kube-controller-manager:v1.32.11
    Image ID:      registry.k8s.io/kube-controller-manager@sha256:ce7b2ead5eef1a1554ef28b2b79596c6a8c6d506a87a7ab1381e77fe3d72f55f
    Port:          <none>
    Host Port:     <none>
    Command:
      kube-controller-manager
      --allocate-node-cidrs=true
      --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf
      --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf
      --bind-address=127.0.0.1
      --client-ca-file=/etc/kubernetes/pki/ca.crt
      --cluster-cidr=10.244.0.0/16 # 👀
      --cluster-name=kubernetes
      --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
      --cluster-signing-key-file=/etc/kubernetes/pki/ca.key
      --controllers=*,bootstrapsigner,tokencleaner
      --kubeconfig=/etc/kubernetes/controller-manager.conf
      --leader-elect=true
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
      --root-ca-file=/etc/kubernetes/pki/ca.crt
      --service-account-private-key-file=/etc/kubernetes/pki/sa.key
      --service-cluster-ip-range=10.96.0.0/16
      --use-service-account-credentials=true
    State:          Running
      Started:      Sat, 24 Jan 2026 13:40:47 +0000
    Ready:          True
    Restart Count:  0
    Requests:
      cpu:        200m
    Liveness:     http-get https://127.0.0.1:10257/healthz delay=10s timeout=15s period=10s #success=1 #failure=8
    Startup:      http-get https://127.0.0.1:10257/healthz delay=10s timeout=15s period=10s #success=1 #failure=24
    Environment:  <none>
    Mounts:
      /etc/kubernetes/controller-manager.conf from kubeconfig (ro)
      /etc/kubernetes/pki from k8s-certs (ro)
      /etc/pki/ca-trust from etc-pki-ca-trust (ro)
      /etc/pki/tls/certs from etc-pki-tls-certs (ro)
      /etc/ssl/certs from ca-certs (ro)
      /usr/libexec/kubernetes/kubelet-plugins/volume/exec from flexvolume-dir (rw)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  ca-certs:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/ssl/certs
    HostPathType:  DirectoryOrCreate
  etc-pki-ca-trust:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/pki/ca-trust
    HostPathType:  DirectoryOrCreate
  etc-pki-tls-certs:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/pki/tls/certs
    HostPathType:  DirectoryOrCreate
  flexvolume-dir:
    Type:          HostPath (bare host directory volume)
    Path:          /usr/libexec/kubernetes/kubelet-plugins/volume/exec
    HostPathType:  DirectoryOrCreate
  k8s-certs:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/kubernetes/pki
    HostPathType:  DirectoryOrCreate
  kubeconfig:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/kubernetes/controller-manager.conf
    HostPathType:  FileOrCreate
QoS Class:         Burstable
Node-Selectors:    <none>
Tolerations:       :NoExecute op=Exists
Events:            <none>

# 노드별 파드 CIDR 확인 
[root@k8s-ctr ~]# k get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.podCIDR}{"\n"}{end}'
k8s-ctr 10.244.0.0/24


# Deploying Flannel with Helm
# https://github.com/flannel-io/flannel/blob/master/Documentation/configuration.md
helm repo add flannel https://flannel-io.github.io/flannel
helm repo update
k create namespace kube-flannel
cat << EOF > flannel.yaml
podCidr: "10.244.0.0/16"
flannel:
  cniBinDir: "/opt/cni/bin"
  cniConfDir: "/etc/cni/net.d"
  args:
  - "--ip-masq"
  - "--kube-subnet-mgr"
  - "--iface=eth0"  
  backend: "vxlan"
EOF
helm install flannel flannel/flannel --namespace kube-flannel --version 0.27.3 -f flannel.yaml


# 확인
helm list -A
[root@k8s-ctr ~]# k get ds,pod,cm -n kube-flannel -owide
NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE   CONTAINERS     IMAGES                               SELECTOR
daemonset.apps/kube-flannel-ds   1         1         1       1            1           <none>          21s   kube-flannel   ghcr.io/flannel-io/flannel:v0.27.3   app=flannel

NAME                        READY   STATUS    RESTARTS   AGE   IP            NODE      NOMINATED NODE   READINESS GATES
pod/kube-flannel-ds-8mxwr   1/1     Running   0          21s   172.31.7.91   k8s-ctr   <none>           <none>

NAME                         DATA   AGE
configmap/kube-flannel-cfg   2      21s
configmap/kube-root-ca.crt   1      4m49s

[root@k8s-ctr ~]# k describe cm -n kube-flannel kube-flannel-cfg
Name:         kube-flannel-cfg
Namespace:    kube-flannel
Labels:       app=flannel
              app.kubernetes.io/managed-by=Helm
              tier=node
Annotations:  meta.helm.sh/release-name: flannel
              meta.helm.sh/release-namespace: kube-flannel

Data
====
cni-conf.json:
----
{
  "name": "cbr0",
  "cniVersion": "0.3.1",
  "plugins": [
    {
      "type": "flannel",
      "delegate": {
        "hairpinMode": true,
        "isDefaultGateway": true
      }
    },
    {
      "type": "portmap",
      "capabilities": {
        "portMappings": true
      }
    }
  ]
}


net-conf.json:
----
{
  "Network": "10.244.0.0/16",
  "Backend": {
    "Type": "vxlan"
  }
}



BinaryData
====

Events:  <none>

[root@k8s-ctr ~]# k describe ds -n kube-flannel
Name:           kube-flannel-ds
Selector:       app=flannel
Node-Selector:  <none>
Labels:         app=flannel
                app.kubernetes.io/managed-by=Helm
                tier=node
Annotations:    deprecated.daemonset.template.generation: 1
                meta.helm.sh/release-name: flannel
                meta.helm.sh/release-namespace: kube-flannel
Desired Number of Nodes Scheduled: 1
Current Number of Nodes Scheduled: 1
Number of Nodes Scheduled with Up-to-date Pods: 1
Number of Nodes Scheduled with Available Pods: 1
Number of Nodes Misscheduled: 0
Pods Status:  1 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:           app=flannel
                    tier=node
  Service Account:  flannel
  Init Containers:
   install-cni-plugin:
    Image:      ghcr.io/flannel-io/flannel-cni-plugin:v1.7.1-flannel1
    Port:       <none>
    Host Port:  <none>
    Command:
      cp
    Args:
      -f
      /flannel
      /opt/cni/bin/flannel
    Environment:  <none>
    Mounts:
      /opt/cni/bin from cni-plugin (rw)
   install-cni:
    Image:      ghcr.io/flannel-io/flannel:v0.27.3
    Port:       <none>
    Host Port:  <none>
    Command:
      cp
    Args:
      -f
      /etc/kube-flannel/cni-conf.json
      /etc/cni/net.d/10-flannel.conflist
    Environment:  <none>
    Mounts:
      /etc/cni/net.d from cni (rw)
      /etc/kube-flannel/ from flannel-cfg (rw)
  Containers:
   kube-flannel:
    Image:      ghcr.io/flannel-io/flannel:v0.27.3
    Port:       <none>
    Host Port:  <none>
    Command:
      /opt/bin/flanneld
      --ip-masq
      --kube-subnet-mgr
      --iface=eth0
    Requests:
      cpu:     100m
      memory:  50Mi
    Environment:
      POD_NAME:                    (v1:metadata.name)
      POD_NAMESPACE:               (v1:metadata.namespace)
      EVENT_QUEUE_DEPTH:          5000
      CONT_WHEN_CACHE_NOT_READY:  false
    Mounts:
      /etc/kube-flannel/ from flannel-cfg (rw)
      /run/flannel from run (rw)
      /run/xtables.lock from xtables-lock (rw)
  Volumes:
   run:
    Type:          HostPath (bare host directory volume)
    Path:          /run/flannel
    HostPathType:  
   cni-plugin:
    Type:          HostPath (bare host directory volume)
    Path:          /opt/cni/bin
    HostPathType:  
   cni:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/cni/net.d
    HostPathType:  
   flannel-cfg:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      kube-flannel-cfg
    Optional:  false
   xtables-lock:
    Type:               HostPath (bare host directory volume)
    Path:               /run/xtables.lock
    HostPathType:       FileOrCreate
  Priority Class Name:  system-node-critical
  Node-Selectors:       <none>
  Tolerations:          :NoExecute op=Exists
                        :NoSchedule op=Exists
Events:
  Type    Reason            Age   From                  Message
  ----    ------            ----  ----                  -------
  Normal  SuccessfulCreate  48s   daemonset-controller  Created pod: kube-flannel-ds-8mxwr

# coredns 파드 정상 기동 확인
[root@k8s-ctr ~]# k get pod -n kube-system -owide
NAME                              READY   STATUS    RESTARTS   AGE   IP            NODE      NOMINATED NODE   READINESS GATES
coredns-668d6bf9bc-m9wgw          1/1     Running   0          17m   10.244.0.3    k8s-ctr   <none>           <none>
coredns-668d6bf9bc-s2444          1/1     Running   0          17m   10.244.0.2    k8s-ctr   <none>           <none>
etcd-k8s-ctr                      1/1     Running   0          17m   172.31.7.91   k8s-ctr   <none>           <none>
kube-apiserver-k8s-ctr            1/1     Running   0          17m   172.31.7.91   k8s-ctr   <none>           <none>
kube-controller-manager-k8s-ctr   1/1     Running   0          17m   172.31.7.91   k8s-ctr   <none>           <none>
kube-proxy-9mmtj                  1/1     Running   0          17m   172.31.7.91   k8s-ctr   <none>           <none>
kube-scheduler-k8s-ctr            1/1     Running   0          17m   172.31.7.91   k8s-ctr   <none>           <none>

# network 정보 확인
[root@k8s-ctr ~]# ip -c route | grep 10.244.
10.244.0.0/24 dev cni0 proto kernel scope link src 10.244.0.1 

# cni0, flannel.1, vethY.. 확인
[root@k8s-ctr ~]# ip addr 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP group default qlen 1000
    link/ether 02:28:b0:60:60:fd brd ff:ff:ff:ff:ff:ff
    altname enp0s5
    altname ens5
    inet 172.31.7.91/20 brd 172.31.15.255 scope global dynamic noprefixroute eth0
       valid_lft 3349sec preferred_lft 3349sec
    inet6 fe80::28:b0ff:fe60:60fd/64 scope link 
       valid_lft forever preferred_lft forever
3: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UNKNOWN group default 
    link/ether be:e5:a7:00:c2:e4 brd ff:ff:ff:ff:ff:ff
    inet 10.244.0.0/32 scope global flannel.1
       valid_lft forever preferred_lft forever
    inet6 fe80::bce5:a7ff:fe00:c2e4/64 scope link 
       valid_lft forever preferred_lft forever
4: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue state UP group default qlen 1000
    link/ether 1e:e6:95:9f:b7:9d brd ff:ff:ff:ff:ff:ff
    inet 10.244.0.1/24 brd 10.244.0.255 scope global cni0
       valid_lft forever preferred_lft forever
    inet6 fe80::1ce6:95ff:fe9f:b79d/64 scope link 
       valid_lft forever preferred_lft forever
5: veth38a26eb8@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue master cni0 state UP group default qlen 1000
    link/ether be:1c:a8:30:91:db brd ff:ff:ff:ff:ff:ff link-netns cni-29b274c3-0084-c61d-2ca4-244974622992
    inet6 fe80::bc1c:a8ff:fe30:91db/64 scope link 
       valid_lft forever preferred_lft forever
6: vethed04cad6@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue master cni0 state UP group default qlen 1000
    link/ether 7e:f3:a5:3b:bc:83 brd ff:ff:ff:ff:ff:ff link-netns cni-25762349-fd42-f26f-d628-7248112636c1
    inet6 fe80::7cf3:a5ff:fe3b:bc83/64 scope link 
       valid_lft forever preferred_lft forever

[root@k8s-ctr ~]# bridge link
5: veth38a26eb8@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 master cni0 state forwarding priority 32 cost 2 
6: vethed04cad6@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 master cni0 state forwarding priority 32 cost 2 

[root@k8s-ctr ~]# lsns -t net
        NS TYPE NPROCS   PID USER     NETNSID NSFS                                                COMMAND
4026531840 net     158     1 root  unassigned                                                     /usr/li
4026532171 net       1   742 root  unassigned                                                     /usr/sb
4026532311 net       2 23160 65535          0 /run/netns/cni-29b274c3-0084-c61d-2ca4-244974622992 /pause
4026532393 net       2 23334 65535          1 /run/netns/cni-25762349-fd42-f26f-d628-7248112636c1 /pause

# iptables 규칙 확인
[root@k8s-ctr ~]# iptables -t nat -S
-P PREROUTING ACCEPT
-P INPUT ACCEPT
-P OUTPUT ACCEPT
-P POSTROUTING ACCEPT
-N FLANNEL-POSTRTG
-N KUBE-KUBELET-CANARY
-N KUBE-MARK-MASQ
-N KUBE-NODEPORTS
-N KUBE-POSTROUTING
-N KUBE-PROXY-CANARY
-N KUBE-SEP-6E7XQMQ4RAYOWTTM
-N KUBE-SEP-IT2ZTR26TO4XFPTO
-N KUBE-SEP-N4G2XR5TDX7PQE7P
-N KUBE-SEP-YIL6JZP7A3QYXJU2
-N KUBE-SEP-Z256WNARC5DJQIZM
-N KUBE-SEP-ZP3FB6NMPNCO4VBJ
-N KUBE-SEP-ZXMNUKOKXUTL2MK2
-N KUBE-SERVICES
-N KUBE-SVC-ERIFXISQEP7F7OF4
-N KUBE-SVC-JD5MR3NA4I4DYORP
-N KUBE-SVC-NPX46M4PTMTKRN6Y
-N KUBE-SVC-TCOU7JCQXEZGVUNU
-A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A POSTROUTING -m comment --comment "kubernetes postrouting rules" -j KUBE-POSTROUTING
-A POSTROUTING -m comment --comment "flanneld masq" -j FLANNEL-POSTRTG
-A FLANNEL-POSTRTG -m mark --mark 0x4000/0x4000 -m comment --comment "flanneld masq" -j RETURN
-A FLANNEL-POSTRTG -s 10.244.0.0/24 -d 10.244.0.0/16 -m comment --comment "flanneld masq" -j RETURN
-A FLANNEL-POSTRTG -s 10.244.0.0/16 -d 10.244.0.0/24 -m comment --comment "flanneld masq" -j RETURN
-A FLANNEL-POSTRTG ! -s 10.244.0.0/16 -d 10.244.0.0/24 -m comment --comment "flanneld masq" -j RETURN
-A FLANNEL-POSTRTG -s 10.244.0.0/16 ! -d 224.0.0.0/4 -m comment --comment "flanneld masq" -j MASQUERADE --random-fully
-A FLANNEL-POSTRTG ! -s 10.244.0.0/16 -d 10.244.0.0/16 -m comment --comment "flanneld masq" -j MASQUERADE --random-fully
-A KUBE-MARK-MASQ -j MARK --set-xmark 0x4000/0x4000
-A KUBE-POSTROUTING -m mark ! --mark 0x4000/0x4000 -j RETURN
-A KUBE-POSTROUTING -j MARK --set-xmark 0x4000/0x0
-A KUBE-POSTROUTING -m comment --comment "kubernetes service traffic requiring SNAT" -j MASQUERADE --random-fully
-A KUBE-SEP-6E7XQMQ4RAYOWTTM -s 10.244.0.3/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
-A KUBE-SEP-6E7XQMQ4RAYOWTTM -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.244.0.3:53
-A KUBE-SEP-IT2ZTR26TO4XFPTO -s 10.244.0.2/32 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-MARK-MASQ
-A KUBE-SEP-IT2ZTR26TO4XFPTO -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp" -m tcp -j DNAT --to-destination 10.244.0.2:53
-A KUBE-SEP-N4G2XR5TDX7PQE7P -s 10.244.0.2/32 -m comment --comment "kube-system/kube-dns:metrics" -j KUBE-MARK-MASQ
-A KUBE-SEP-N4G2XR5TDX7PQE7P -p tcp -m comment --comment "kube-system/kube-dns:metrics" -m tcp -j DNAT --to-destination 10.244.0.2:9153
-A KUBE-SEP-YIL6JZP7A3QYXJU2 -s 10.244.0.2/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
-A KUBE-SEP-YIL6JZP7A3QYXJU2 -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.244.0.2:53
-A KUBE-SEP-Z256WNARC5DJQIZM -s 172.31.7.91/32 -m comment --comment "default/kubernetes:https" -j KUBE-MARK-MASQ
-A KUBE-SEP-Z256WNARC5DJQIZM -p tcp -m comment --comment "default/kubernetes:https" -m tcp -j DNAT --to-destination 172.31.7.91:6443
-A KUBE-SEP-ZP3FB6NMPNCO4VBJ -s 10.244.0.3/32 -m comment --comment "kube-system/kube-dns:metrics" -j KUBE-MARK-MASQ
-A KUBE-SEP-ZP3FB6NMPNCO4VBJ -p tcp -m comment --comment "kube-system/kube-dns:metrics" -m tcp -j DNAT --to-destination 10.244.0.3:9153
-A KUBE-SEP-ZXMNUKOKXUTL2MK2 -s 10.244.0.3/32 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-MARK-MASQ
-A KUBE-SEP-ZXMNUKOKXUTL2MK2 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp" -m tcp -j DNAT --to-destination 10.244.0.3:53
-A KUBE-SERVICES -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-SVC-NPX46M4PTMTKRN6Y
-A KUBE-SERVICES -d 10.96.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-SVC-TCOU7JCQXEZGVUNU
-A KUBE-SERVICES -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-SVC-ERIFXISQEP7F7OF4
-A KUBE-SERVICES -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-SVC-JD5MR3NA4I4DYORP
-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
-A KUBE-SVC-ERIFXISQEP7F7OF4 ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-MARK-MASQ
-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp -> 10.244.0.2:53" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-IT2ZTR26TO4XFPTO
-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp -> 10.244.0.3:53" -j KUBE-SEP-ZXMNUKOKXUTL2MK2
-A KUBE-SVC-JD5MR3NA4I4DYORP ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-MARK-MASQ
-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment "kube-system/kube-dns:metrics -> 10.244.0.2:9153" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-N4G2XR5TDX7PQE7P
-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment "kube-system/kube-dns:metrics -> 10.244.0.3:9153" -j KUBE-SEP-ZP3FB6NMPNCO4VBJ
-A KUBE-SVC-NPX46M4PTMTKRN6Y ! -s 10.244.0.0/16 -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-MARK-MASQ
-A KUBE-SVC-NPX46M4PTMTKRN6Y -m comment --comment "default/kubernetes:https -> 172.31.7.91:6443" -j KUBE-SEP-Z256WNARC5DJQIZM
-A KUBE-SVC-TCOU7JCQXEZGVUNU ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-MARK-MASQ
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns -> 10.244.0.2:53" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-YIL6JZP7A3QYXJU2
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns -> 10.244.0.3:53" -j KUBE-SEP-6E7XQMQ4RAYOWTTM


[root@k8s-ctr ~]# iptables -t filter -S
-P INPUT ACCEPT
-P FORWARD ACCEPT
-P OUTPUT ACCEPT
-N FLANNEL-FWD
-N KUBE-EXTERNAL-SERVICES
-N KUBE-FIREWALL
-N KUBE-FORWARD
-N KUBE-KUBELET-CANARY
-N KUBE-NODEPORTS
-N KUBE-PROXY-CANARY
-N KUBE-PROXY-FIREWALL
-N KUBE-SERVICES
-A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes load balancer firewall" -j KUBE-PROXY-FIREWALL
-A INPUT -m comment --comment "kubernetes health check service ports" -j KUBE-NODEPORTS
-A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes externally-visible service portals" -j KUBE-EXTERNAL-SERVICES
-A INPUT -j KUBE-FIREWALL
-A FORWARD -m conntrack --ctstate NEW -m comment --comment "kubernetes load balancer firewall" -j KUBE-PROXY-FIREWALL
-A FORWARD -m comment --comment "kubernetes forwarding rules" -j KUBE-FORWARD
-A FORWARD -m conntrack --ctstate NEW -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A FORWARD -m conntrack --ctstate NEW -m comment --comment "kubernetes externally-visible service portals" -j KUBE-EXTERNAL-SERVICES
-A FORWARD -m comment --comment "flanneld forward" -j FLANNEL-FWD
-A OUTPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes load balancer firewall" -j KUBE-PROXY-FIREWALL
-A OUTPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -j KUBE-FIREWALL
-A FLANNEL-FWD -s 10.244.0.0/16 -m comment --comment "flanneld forward" -j ACCEPT
-A FLANNEL-FWD -d 10.244.0.0/16 -m comment --comment "flanneld forward" -j ACCEPT
-A KUBE-FIREWALL ! -s 127.0.0.0/8 -d 127.0.0.0/8 -m comment --comment "block incoming localnet connections" -m conntrack ! --ctstate RELATED,ESTABLISHED,DNAT -j DROP
-A KUBE-FORWARD -m conntrack --ctstate INVALID -j DROP
-A KUBE-FORWARD -m comment --comment "kubernetes forwarding rules" -m mark --mark 0x4000/0x4000 -j ACCEPT
-A KUBE-FORWARD -m comment --comment "kubernetes forwarding conntrack rule" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT


[root@k8s-ctr ~]# iptables-save
# Generated by iptables-save v1.8.10 (nf_tables) on Sat Jan 24 14:00:18 2026
*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:KUBE-IPTABLES-HINT - [0:0]
:KUBE-KUBELET-CANARY - [0:0]
:KUBE-PROXY-CANARY - [0:0]
COMMIT
# Completed on Sat Jan 24 14:00:18 2026
# Generated by iptables-save v1.8.10 (nf_tables) on Sat Jan 24 14:00:18 2026
*filter
:INPUT ACCEPT [216396:139009553]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [213892:40780367]
:FLANNEL-FWD - [0:0]
:KUBE-EXTERNAL-SERVICES - [0:0]
:KUBE-FIREWALL - [0:0]
:KUBE-FORWARD - [0:0]
:KUBE-KUBELET-CANARY - [0:0]
:KUBE-NODEPORTS - [0:0]
:KUBE-PROXY-CANARY - [0:0]
:KUBE-PROXY-FIREWALL - [0:0]
:KUBE-SERVICES - [0:0]
-A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes load balancer firewall" -j KUBE-PROXY-FIREWALL
-A INPUT -m comment --comment "kubernetes health check service ports" -j KUBE-NODEPORTS
-A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes externally-visible service portals" -j KUBE-EXTERNAL-SERVICES
-A INPUT -j KUBE-FIREWALL
-A FORWARD -m conntrack --ctstate NEW -m comment --comment "kubernetes load balancer firewall" -j KUBE-PROXY-FIREWALL
-A FORWARD -m comment --comment "kubernetes forwarding rules" -j KUBE-FORWARD
-A FORWARD -m conntrack --ctstate NEW -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A FORWARD -m conntrack --ctstate NEW -m comment --comment "kubernetes externally-visible service portals" -j KUBE-EXTERNAL-SERVICES
-A FORWARD -m comment --comment "flanneld forward" -j FLANNEL-FWD
-A OUTPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes load balancer firewall" -j KUBE-PROXY-FIREWALL
-A OUTPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -j KUBE-FIREWALL
-A FLANNEL-FWD -s 10.244.0.0/16 -m comment --comment "flanneld forward" -j ACCEPT
-A FLANNEL-FWD -d 10.244.0.0/16 -m comment --comment "flanneld forward" -j ACCEPT
-A KUBE-FIREWALL ! -s 127.0.0.0/8 -d 127.0.0.0/8 -m comment --comment "block incoming localnet connections" -m conntrack ! --ctstate RELATED,ESTABLISHED,DNAT -j DROP
-A KUBE-FORWARD -m conntrack --ctstate INVALID -j DROP
-A KUBE-FORWARD -m comment --comment "kubernetes forwarding rules" -m mark --mark 0x4000/0x4000 -j ACCEPT
-A KUBE-FORWARD -m comment --comment "kubernetes forwarding conntrack rule" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
COMMIT
# Completed on Sat Jan 24 14:00:18 2026
# Generated by iptables-save v1.8.10 (nf_tables) on Sat Jan 24 14:00:18 2026
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:FLANNEL-POSTRTG - [0:0]
:KUBE-KUBELET-CANARY - [0:0]
:KUBE-MARK-MASQ - [0:0]
:KUBE-NODEPORTS - [0:0]
:KUBE-POSTROUTING - [0:0]
:KUBE-PROXY-CANARY - [0:0]
:KUBE-SEP-6E7XQMQ4RAYOWTTM - [0:0]
:KUBE-SEP-IT2ZTR26TO4XFPTO - [0:0]
:KUBE-SEP-N4G2XR5TDX7PQE7P - [0:0]
:KUBE-SEP-YIL6JZP7A3QYXJU2 - [0:0]
:KUBE-SEP-Z256WNARC5DJQIZM - [0:0]
:KUBE-SEP-ZP3FB6NMPNCO4VBJ - [0:0]
:KUBE-SEP-ZXMNUKOKXUTL2MK2 - [0:0]
:KUBE-SERVICES - [0:0]
:KUBE-SVC-ERIFXISQEP7F7OF4 - [0:0]
:KUBE-SVC-JD5MR3NA4I4DYORP - [0:0]
:KUBE-SVC-NPX46M4PTMTKRN6Y - [0:0]
:KUBE-SVC-TCOU7JCQXEZGVUNU - [0:0]
-A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A POSTROUTING -m comment --comment "kubernetes postrouting rules" -j KUBE-POSTROUTING
-A POSTROUTING -m comment --comment "flanneld masq" -j FLANNEL-POSTRTG
-A FLANNEL-POSTRTG -m mark --mark 0x4000/0x4000 -m comment --comment "flanneld masq" -j RETURN
-A FLANNEL-POSTRTG -s 10.244.0.0/24 -d 10.244.0.0/16 -m comment --comment "flanneld masq" -j RETURN
-A FLANNEL-POSTRTG -s 10.244.0.0/16 -d 10.244.0.0/24 -m comment --comment "flanneld masq" -j RETURN
-A FLANNEL-POSTRTG ! -s 10.244.0.0/16 -d 10.244.0.0/24 -m comment --comment "flanneld masq" -j RETURN
-A FLANNEL-POSTRTG -s 10.244.0.0/16 ! -d 224.0.0.0/4 -m comment --comment "flanneld masq" -j MASQUERADE --random-fully
-A FLANNEL-POSTRTG ! -s 10.244.0.0/16 -d 10.244.0.0/16 -m comment --comment "flanneld masq" -j MASQUERADE --random-fully
-A KUBE-MARK-MASQ -j MARK --set-xmark 0x4000/0x4000
-A KUBE-POSTROUTING -m mark ! --mark 0x4000/0x4000 -j RETURN
-A KUBE-POSTROUTING -j MARK --set-xmark 0x4000/0x0
-A KUBE-POSTROUTING -m comment --comment "kubernetes service traffic requiring SNAT" -j MASQUERADE --random-fully
-A KUBE-SEP-6E7XQMQ4RAYOWTTM -s 10.244.0.3/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
-A KUBE-SEP-6E7XQMQ4RAYOWTTM -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.244.0.3:53
-A KUBE-SEP-IT2ZTR26TO4XFPTO -s 10.244.0.2/32 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-MARK-MASQ
-A KUBE-SEP-IT2ZTR26TO4XFPTO -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp" -m tcp -j DNAT --to-destination 10.244.0.2:53
-A KUBE-SEP-N4G2XR5TDX7PQE7P -s 10.244.0.2/32 -m comment --comment "kube-system/kube-dns:metrics" -j KUBE-MARK-MASQ
-A KUBE-SEP-N4G2XR5TDX7PQE7P -p tcp -m comment --comment "kube-system/kube-dns:metrics" -m tcp -j DNAT --to-destination 10.244.0.2:9153
-A KUBE-SEP-YIL6JZP7A3QYXJU2 -s 10.244.0.2/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
-A KUBE-SEP-YIL6JZP7A3QYXJU2 -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.244.0.2:53
-A KUBE-SEP-Z256WNARC5DJQIZM -s 172.31.7.91/32 -m comment --comment "default/kubernetes:https" -j KUBE-MARK-MASQ
-A KUBE-SEP-Z256WNARC5DJQIZM -p tcp -m comment --comment "default/kubernetes:https" -m tcp -j DNAT --to-destination 172.31.7.91:6443
-A KUBE-SEP-ZP3FB6NMPNCO4VBJ -s 10.244.0.3/32 -m comment --comment "kube-system/kube-dns:metrics" -j KUBE-MARK-MASQ
-A KUBE-SEP-ZP3FB6NMPNCO4VBJ -p tcp -m comment --comment "kube-system/kube-dns:metrics" -m tcp -j DNAT --to-destination 10.244.0.3:9153
-A KUBE-SEP-ZXMNUKOKXUTL2MK2 -s 10.244.0.3/32 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-MARK-MASQ
-A KUBE-SEP-ZXMNUKOKXUTL2MK2 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp" -m tcp -j DNAT --to-destination 10.244.0.3:53
-A KUBE-SERVICES -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-SVC-NPX46M4PTMTKRN6Y
-A KUBE-SERVICES -d 10.96.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-SVC-TCOU7JCQXEZGVUNU
-A KUBE-SERVICES -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-SVC-ERIFXISQEP7F7OF4
-A KUBE-SERVICES -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-SVC-JD5MR3NA4I4DYORP
-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
-A KUBE-SVC-ERIFXISQEP7F7OF4 ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-MARK-MASQ
-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp -> 10.244.0.2:53" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-IT2ZTR26TO4XFPTO
-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp -> 10.244.0.3:53" -j KUBE-SEP-ZXMNUKOKXUTL2MK2
-A KUBE-SVC-JD5MR3NA4I4DYORP ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-MARK-MASQ
-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment "kube-system/kube-dns:metrics -> 10.244.0.2:9153" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-N4G2XR5TDX7PQE7P
-A KUBE-SVC-JD5MR3NA4I4DYORP -m comment --comment "kube-system/kube-dns:metrics -> 10.244.0.3:9153" -j KUBE-SEP-ZP3FB6NMPNCO4VBJ
-A KUBE-SVC-NPX46M4PTMTKRN6Y ! -s 10.244.0.0/16 -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-MARK-MASQ
-A KUBE-SVC-NPX46M4PTMTKRN6Y -m comment --comment "default/kubernetes:https -> 172.31.7.91:6443" -j KUBE-SEP-Z256WNARC5DJQIZM
-A KUBE-SVC-TCOU7JCQXEZGVUNU ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-MARK-MASQ
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns -> 10.244.0.2:53" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-YIL6JZP7A3QYXJU2
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns -> 10.244.0.3:53" -j KUBE-SEP-6E7XQMQ4RAYOWTTM
COMMIT
# Completed on Sat Jan 24 14:00:18 2026
```