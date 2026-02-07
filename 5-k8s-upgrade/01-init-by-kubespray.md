# kubespray로 k8s 프로비저닝

```bash
# 작업용 inventory 디렉터리 확인
[root@admin-lb ~]# cd /root/kubespray/

[root@admin-lb kubespray]# git describe --tags
v2.29.1

[root@admin-lb kubespray]# git --no-pager tag | grep -A 3 "2.29.1"
v2.29.1
v2.3.0
v2.30.0
v2.4.0

[root@admin-lb kubespray]# tree inventory/mycluster/
inventory/mycluster/
├── group_vars
│   ├── all
│   │   ├── all.yml
│   │   ├── aws.yml
│   │   ├── azure.yml
│   │   ├── containerd.yml
│   │   ├── coreos.yml
│   │   ├── cri-o.yml
│   │   ├── docker.yml
│   │   ├── etcd.yml
│   │   ├── gcp.yml
│   │   ├── hcloud.yml
│   │   ├── huaweicloud.yml
│   │   ├── oci.yml
│   │   ├── offline.yml
│   │   ├── openstack.yml
│   │   ├── upcloud.yml
│   │   └── vsphere.yml
│   └── k8s_cluster
│       ├── addons.yml
│       ├── k8s-cluster.yml
│       ├── k8s-net-calico.yml
│       ├── k8s-net-cilium.yml
│       ├── k8s-net-custom-cni.yml
│       ├── k8s-net-flannel.yml
│       ├── k8s-net-kube-ovn.yml
│       ├── k8s-net-kube-router.yml
│       ├── k8s-net-macvlan.yml
│       └── kube_control_plane.yml
└── inventory.ini

3 directories, 27 files


# inventory.ini 확인
[root@admin-lb kubespray]# cat /root/kubespray/inventory/mycluster/inventory.ini
[kube_control_plane]
k8s-node1 ansible_host=172.31.15.233 ip=172.31.15.233 etcd_member_name=etcd1
k8s-node2 ansible_host=172.31.5.26 ip=172.31.5.26 etcd_member_name=etcd2
k8s-node3 ansible_host=172.31.2.242 ip=172.31.2.242 etcd_member_name=etcd3

[etcd:children]
kube_control_plane

[kube_node]
k8s-node4 ansible_host=172.31.2.93 ip=172.31.2.93
#k8s-node5 ansible_host=172.31.12.49 ip=172.31.12.49


# 확인
[root@admin-lb kubespray]# ansible-inventory -i /root/kubespray/inventory/mycluster/inventory.ini --list
...
        "hostvars": {
            "k8s-node1": {
                "allow_unsupported_distribution_setup": false,
                "ansible_host": "172.31.1.127", # <- inventory.ini에 직접 썼던 내용.
                "bin_dir": "/usr/local/bin",
                "docker_bin_dir": "/usr/bin",
                "docker_container_storage_setup": false,
...

[root@admin-lb kubespray]# ansible-inventory -i /root/kubespray/inventory/mycluster/inventory.ini --graph
@all:
  |--@ungrouped:
  |--@etcd:
  |  |--@kube_control_plane:
  |  |  |--k8s-node1
  |  |  |--k8s-node2
  |  |  |--k8s-node3
  |--@kube_node:
  |  |--k8s-node4


# k8s_cluster.yml # for every node in the cluster (not etcd when it's separate)
sed -i 's|kube_owner: kube|kube_owner: root|g' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
sed -i 's|kube_network_plugin: calico|kube_network_plugin: flannel|g' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
sed -i 's|kube_proxy_mode: ipvs|kube_proxy_mode: iptables|g' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
sed -i 's|enable_nodelocaldns: true|enable_nodelocaldns: false|g' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

[root@admin-lb kubespray]# grep -iE 'kube_owner|kube_network_plugin:|kube_proxy_mode|enable_nodelocaldns:' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
kube_owner: root
kube_network_plugin: flannel
kube_proxy_mode: iptables
enable_nodelocaldns: false

## coredns autoscaler 미설치
echo "enable_dns_autoscaler: false" >> inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# flannel 설정 수정
echo "flannel_interface: ens5" >> inventory/mycluster/group_vars/k8s_cluster/k8s-net-flannel.yml

[root@admin-lb kubespray]# grep "^[^#]" inventory/mycluster/group_vars/k8s_cluster/k8s-net-flannel.yml
flannel_interface: ens5


# addons
sed -i 's|metrics_server_enabled: false|metrics_server_enabled: true|g' inventory/mycluster/group_vars/k8s_cluster/addons.yml
[root@admin-lb kubespray]# grep -iE 'metrics_server_enabled:' inventory/mycluster/group_vars/k8s_cluster/addons.yml
metrics_server_enabled: true

echo "metrics_server_requests_cpu: 25m"     >> inventory/mycluster/group_vars/k8s_cluster/addons.yml
echo "metrics_server_requests_memory: 16Mi" >> inventory/mycluster/group_vars/k8s_cluster/addons.yml


# 지원 버전 정보 확인 (실습 당시, 최신 버전은 1.33.7까지 지원)
cat roles/kubespray_defaults/vars/main/checksums.yml | grep -i kube -A40


# 배포: 아래처럼 반드시 ~/kubespray 디렉토리에서 ansible-playbook 를 실행하자.

# 배포 전, Task 목록 확인.
ansible-playbook -i inventory/mycluster/inventory.ini -v cluster.yml --list-tasks

# 배포!!
ANSIBLE_FORCE_COLOR=true ansible-playbook -i inventory/mycluster/inventory.ini -v cluster.yml -e kube_version="1.32.9" | tee kubespray_install.log

# 설치 확인
# 로그 확인
more kubespray_install.log

# facts 수집 정보 확인
tree /tmp
├── k8s-node1
├── k8s-node2
├── k8s-node3
...

[root@admin-lb kubespray]# mkdir /root/.kube

[root@admin-lb kubespray]# scp k8s-node1:/root/.kube/config /root/.kube/
config                                         100% 5665     7.3MB/s   00:00    

[root@admin-lb kubespray]# cat /root/.kube/config | grep server
    server: https://127.0.0.1:6443 # <- 이건 k8s-node1 IP로 변경하기

sed -i 's/127.0.0.1/172.31.1.127/g' /root/.kube/config


[root@admin-lb kubespray]# kubectl get node -owide -v=6
I0207 14:55:11.524140   39271 loader.go:402] Config loaded from file:  /root/.kube/config
I0207 14:55:11.524712   39271 envvar.go:172] "Feature gate default state" feature="ClientsAllowCBOR" enabled=false
I0207 14:55:11.524732   39271 envvar.go:172] "Feature gate default state" feature="ClientsPreferCBOR" enabled=false
I0207 14:55:11.524749   39271 envvar.go:172] "Feature gate default state" feature="InformerResourceVersion" enabled=false
I0207 14:55:11.524760   39271 envvar.go:172] "Feature gate default state" feature="WatchListClient" enabled=false
I0207 14:55:11.531664   39271 round_trippers.go:560] GET https://172.31.1.127:6443/api?timeout=32s 200 OK in 6 milliseconds
I0207 14:55:11.533890   39271 round_trippers.go:560] GET https://172.31.1.127:6443/apis?timeout=32s 200 OK in 0 milliseconds
I0207 14:55:11.544148   39271 round_trippers.go:560] GET https://172.31.1.127:6443/api/v1/nodes?limit=500 200 OK in 4 milliseconds
NAME        STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                 CONTAINER-RUNTIME
k8s-node1   Ready    control-plane   18m   v1.32.9   172.31.1.127   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.8.1.el10_1.x86_64   containerd://2.1.5
k8s-node2   Ready    control-plane   18m   v1.32.9   172.31.2.170   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.8.1.el10_1.x86_64   containerd://2.1.5
k8s-node3   Ready    control-plane   18m   v1.32.9   172.31.2.118   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.8.1.el10_1.x86_64   containerd://2.1.5
k8s-node4   Ready    <none>          17m   v1.32.9   172.31.7.101   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.8.1.el10_1.x86_64   containerd://2.1.5


# [kube_control_plane] 과 [kube_node] 포함 노드 비교
[root@admin-lb kubespray]# ansible-inventory -i /root/kubespray/inventory/mycluster/inventory.ini --graph
@all:
  |--@ungrouped:
  |--@etcd:
  |  |--@kube_control_plane:
  |  |  |--k8s-node1
  |  |  |--k8s-node2
  |  |  |--k8s-node3
  |--@kube_node:
  |  |--k8s-node4

[root@admin-lb kubespray]# kubectl describe node | grep -E 'Name:|Taints'
Name:               k8s-node1
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
Name:               k8s-node2
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
Name:               k8s-node3
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
Name:               k8s-node4
Taints:             <none>

# 노드별 파드 CIDR 확인
[root@admin-lb kubespray]# kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.podCIDR}{"\n"}{end}'
k8s-node1       10.233.64.0/24
k8s-node2       10.233.65.0/24
k8s-node3       10.233.66.0/24
k8s-node4       10.233.67.0/24

# 자동완성 및 단축키 설정
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
echo 'source <(kubectl completion bash)' >> /etc/profile
echo 'alias k=kubectl' >> /etc/profile
echo 'complete -F __start_kubectl k' >> /etc/profile
```