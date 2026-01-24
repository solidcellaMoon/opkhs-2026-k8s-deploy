# Worker Node 구동

02~04 내용들을 k8s-w1, k8s-w2에 동일하게 수행한다.
아래는 이어서, kubeadm join으로 worker node를 만드는 과정부터 진행함.
- kubeadm join은 k8s-w1, k8s-w2 둘다 동일하게 수행해둔다.

## kubeadm join
```bash
# 기본 환경 정보 출력 저장
crictl images
crictl ps
cat /etc/sysconfig/kubelet
tree /etc/kubernetes  | tee -a etc_kubernetes-1.txt
tree /var/lib/kubelet | tee -a var_lib_kubelet-1.txt
tree /run/containerd/ -L 3 | tee -a run_containerd-1.txt
pstree -alnp | tee -a pstree-1.txt
systemd-cgls --no-pager | tee -a systemd-cgls-1.txt
lsns | tee -a lsns-1.txt
ip addr | tee -a ip_addr-1.txt 
ss -tnlp | tee -a ss-1.txt
df -hT | tee -a df-1.txt
findmnt | tee -a findmnt-1.txt
sysctl -a | tee -a sysctl-1.txt

# kubeadm Configuration 파일 작성
[root@k8s-w1 ~]# NODEIP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
[root@k8s-w1 ~]# echo $NODEIP
172.31.8.194

[root@k8s-w1 ~]# cat << EOF > kubeadm-join.yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: JoinConfiguration
discovery:
  bootstrapToken:
    token: "123456.1234567890123456"
    apiServerEndpoint: "172.31.7.91:6443"
    unsafeSkipCAVerification: true
nodeRegistration:
  criSocket: "unix:///run/containerd/containerd.sock"
  kubeletExtraArgs:
    - name: node-ip
      value: "$NODEIP"
EOF

[root@k8s-w1 ~]# cat kubeadm-join.yaml
apiVersion: kubeadm.k8s.io/v1beta4
kind: JoinConfiguration
discovery:
  bootstrapToken:
    token: "123456.1234567890123456"
    apiServerEndpoint: "172.31.7.91:6443"
    unsafeSkipCAVerification: true
nodeRegistration:
  criSocket: "unix:///run/containerd/containerd.sock"
  kubeletExtraArgs:
    - name: node-ip
      value: "172.31.8.194"

[root@k8s-w1 ~]# kubeadm join --config="kubeadm-join.yaml"
[preflight] Running pre-flight checks
[preflight] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[preflight] Use 'kubeadm init phase upload-config --config your-config.yaml' to re-upload it.
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 503.304213ms
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

# crictl 확인
[root@k8s-w1 ~]# crictl images
IMAGE                                   TAG                 IMAGE ID            SIZE
ghcr.io/flannel-io/flannel-cni-plugin   v1.7.1-flannel1     cca2af40a4a9e       4.88MB
ghcr.io/flannel-io/flannel              v0.27.3             5de71980e553f       34MB
registry.k8s.io/kube-proxy              v1.32.11            4d8fb2dc57519       31.2MB
registry.k8s.io/pause                   3.10                873ed75102791       320kB

[root@k8s-w1 ~]# crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD                     NAMESPACE
d08c3bcb375c3       5de71980e553f       12 seconds ago      Running             kube-flannel        0                   3f52cc3ba85cc       kube-flannel-ds-9fj94   kube-flannel
7008deb08294e       4d8fb2dc57519       23 seconds ago      Running             kube-proxy          0                   c07496bfe4abb       kube-proxy-wvktp        kube-system


# cluster-info cm 호출 가능 확인
[root@k8s-w1 ~]# curl -s -k https://172.31.7.91:6443/api/v1/namespaces/kube-public/configmaps/cluster-info | jq
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
```

## worker ndoe 관련 정보 확인
```bash
[root@k8s-ctr ~]# k get node
NAME      STATUS   ROLES           AGE     VERSION
k8s-ctr   Ready    control-plane   33m     v1.32.11
k8s-w1    Ready    <none>          2m43s   v1.32.11
k8s-w2    Ready    <none>          38s     v1.32.11

# 노드별 파드 CIDR 확인 
[root@k8s-ctr ~]# k get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.podCIDR}{"\n"}{end}'
k8s-ctr 10.244.0.0/24
k8s-w1  10.244.1.0/24
k8s-w2  10.244.3.0/24

# 다른 노드의 파드 CIDR(Per Node Pod CIDR)에 대한 라우팅이 자동으로 커널 라우팅에 추가됨을 확인 : flannel.1 을 통해 VXLAN 통한 라우팅
[root@k8s-ctr ~]# ip -c route | grep flannel
10.244.1.0/24 via 10.244.1.0 dev flannel.1 onlink 
10.244.3.0/24 via 10.244.3.0 dev flannel.1 onlink 

# k8s-ctr 에서 10.244.1.0 IP로 통신 가능(vxlan overlay 사용) 확인
[root@k8s-ctr ~]# ping -c 1 10.244.1.0
PING 10.244.1.0 (10.244.1.0) 56(84) bytes of data.
64 bytes from 10.244.1.0: icmp_seq=1 ttl=64 time=0.932 ms

--- 10.244.1.0 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.932/0.932/0.932/0.000 ms

# 워커 노드에 Taints 정보 확인
[root@k8s-ctr ~]# k describe node k8s-w1 | grep Taints
Taints:             <none>

# k8s-w1 노드에 배치된 파드 확인
[root@k8s-ctr ~]# k get pod -A -owide | grep k8s-w2
kube-flannel   kube-flannel-ds-vkgb7             1/1     Running   0          2m48s   172.31.5.17    k8s-w2    <none>           <none>
kube-system    kube-proxy-qtfn5                  1/1     Running   0          2m48s   172.31.5.17    k8s-w2    <none>           <none>

[root@k8s-ctr ~]# k get pod -A -owide | grep k8s-w1
kube-flannel   kube-flannel-ds-9fj94             1/1     Running   0          5m1s    172.31.8.194   k8s-w1    <none>           <none>
kube-system    kube-proxy-wvktp                  1/1     Running   0          5m1s    172.31.8.194   k8s-w1    <none>           <none>

```