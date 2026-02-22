# RKE2로 워커노드 추가하기

## 노드 토큰 확인하기
```bash
# A token that can be used to register other server or agent nodes
[root@k8s-node1 ~]# cat /var/lib/rancher/rke2/server/node-token
K106bd03bc4241d7e0d077af04652d89327fb4aa3a66990ac427aae223a12dba1bf::server:d5d4104d29200f40965facb5041c0366

# 노드(서버/에이전트)가 RKE2 클러스터에 조인할 때 사용하는 전용 관리/부트스트랩 API 포트 확인
[root@k8s-node1 ~]# ss -tnlp | grep 9345
LISTEN 0      4096       127.0.0.1:9345       0.0.0.0:*    users:(("rke2",pid=38024,fd=7))                         
LISTEN 0      4096    172.31.1.135:9345       0.0.0.0:*    users:(("rke2",pid=38024,fd=6))                         
LISTEN 0      4096           [::1]:9345          [::]:*    users:(("rke2",pid=38024,fd=8))  
```

## 워커노드 추가
```bash
# Run the installer
[root@k8s-node2 ~]# curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" INSTALL_RKE2_CHANNEL=v1.33 sh -

# Configure the rke2-agent service: rke-agent 설정 파일 작성 
## The rke2 server process listens on port 9345 for new nodes to register.
[root@k8s-node2 ~]# TOKEN=K106bd03bc4241d7e0d077af04652d89327fb4aa3a66990ac427aae223a12dba1bf::server:d5d4104d29200f40965facb5041c0366

[root@k8s-node2 ~]# mkdir -p /etc/rancher/rke2/

[root@k8s-node2 ~]# cat << EOF > /etc/rancher/rke2/config.yaml
server: https://172.31.1.135:9345
token: $TOKEN
EOF

[root@k8s-node2 ~]# cat /etc/rancher/rke2/config.yaml
server: https://172.31.1.135:9345
token: K106bd03bc4241d7e0d077af04652d89327fb4aa3a66990ac427aae223a12dba1bf::server:d5d4104d29200f40965facb5041c0366

# Enabled/Start the service
[root@k8s-node2 ~]# systemctl enable --now rke2-agent.service
Created symlink /etc/systemd/system/multi-user.target.wants/rke2-agent.service → /usr/lib/systemd/system/rke2-agent.service.
```

## 워커노드 추가 후 상태 확인
```bash
[root@k8s-node1 ~]# kubectl get node
NAME        STATUS   ROLES                       AGE   VERSION
k8s-node1   Ready    control-plane,etcd,master   12m   v1.33.8+rke2r1
k8s-node2   Ready    <none>                      19s   v1.33.8+rke2r1

[root@k8s-node1 ~]# kubectl get pod -A
NAMESPACE     NAME                                         READY   STATUS      RESTARTS   AGE
kube-system   etcd-k8s-node1                               1/1     Running     0          12m
kube-system   helm-install-rke2-canal-cfrm6                0/1     Completed   0          12m
kube-system   helm-install-rke2-coredns-tpw67              0/1     Completed   0          12m
kube-system   helm-install-rke2-metrics-server-h6ssr       0/1     Completed   0          12m
kube-system   helm-install-rke2-runtimeclasses-tt66j       0/1     Completed   0          12m
kube-system   kube-apiserver-k8s-node1                     1/1     Running     0          12m
kube-system   kube-controller-manager-k8s-node1            1/1     Running     0          12m
kube-system   kube-proxy-k8s-node1                         1/1     Running     0          12m
kube-system   kube-proxy-k8s-node2                         1/1     Running     0          40s
kube-system   kube-scheduler-k8s-node1                     1/1     Running     0          12m
kube-system   rke2-canal-pdp5m                             2/2     Running     0          40s
kube-system   rke2-canal-rlb7w                             2/2     Running     0          12m
kube-system   rke2-coredns-rke2-coredns-559595db99-shj84   1/1     Running     0          12m
kube-system   rke2-metrics-server-fdcdf575d-xfdhc          1/1     Running     0          12m
```