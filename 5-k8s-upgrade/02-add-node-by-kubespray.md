# kubespray로 k8s 노드 추가/삭제 작업

```bash
# inventory.ini 수정
cat << EOF > /root/kubespray/inventory/mycluster/inventory.ini
[kube_control_plane]
k8s-node1 ansible_host=172.31.1.127 ip=172.31.1.127 etcd_member_name=etcd1
k8s-node2 ansible_host=172.31.2.170 ip=172.31.2.170 etcd_member_name=etcd2
k8s-node3 ansible_host=172.31.2.118 ip=172.31.2.118 etcd_member_name=etcd3

[etcd:children]
kube_control_plane

[kube_node]
k8s-node4 ansible_host=172.31.7.101 ip=172.31.7.101
k8s-node5 ansible_host=172.31.1.69 ip=172.31.1.69 # <- 새로 추가
EOF

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
  |  |--k8s-node5

# ansible 연결 확인
[root@admin-lb kubespray]# ansible -i inventory/mycluster/inventory.ini k8s-node5 -m ping
[WARNING]: Platform linux on host k8s-node5 is using the discovered Python interpreter at
/usr/bin/python3.12, but future installation of another Python interpreter could change the meaning
of that path. See https://docs.ansible.com/ansible-
core/2.17/reference_appendices/interpreter_discovery.html for more information.
k8s-node5 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.12"
    },
    "changed": false,
    "ping": "pong"
}

# 워커 노드 추가 수행
ansible-playbook -i inventory/mycluster/inventory.ini -v scale.yml --list-tasks
ANSIBLE_FORCE_COLOR=true ansible-playbook -i inventory/mycluster/inventory.ini -v scale.yml --limit=k8s-node5 -e kube_version="1.32.9" | tee kubespray_add_worker_node.log

# 확인
[root@admin-lb kubespray]# k get node -owide
NAME        STATUS   ROLES           AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                  CONTAINER-RUNTIME
k8s-node1   Ready    control-plane   76m     v1.32.9   172.31.1.127   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.29.1.el10_1.x86_64   containerd://2.1.5
k8s-node2   Ready    control-plane   75m     v1.32.9   172.31.2.170   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.29.1.el10_1.x86_64   containerd://2.1.5
k8s-node3   Ready    control-plane   75m     v1.32.9   172.31.2.118   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.29.1.el10_1.x86_64   containerd://2.1.5
k8s-node4   Ready    <none>          75m     v1.32.9   172.31.7.101   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.29.1.el10_1.x86_64   containerd://2.1.5
k8s-node5   Ready    <none>          2m53s   v1.32.9   172.31.1.69    <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.28.1.el10_1.x86_64   containerd://2.1.5

[root@admin-lb kubespray]# k get pod -n kube-system -owide |grep k8s-node5
kube-flannel-xk6cz                  1/1     Running   1 (2m35s ago)   3m9s   172.31.1.69    k8s-node5   <none>           <none>
kube-proxy-slf6f                    1/1     Running   0               3m9s   172.31.1.69    k8s-node5   <none>           <none>
nginx-proxy-k8s-node5               1/1     Running   0               3m8s   172.31.1.69    k8s-node5   <none>           <none>
```

## k8s-node5 삭제하기
```bash
ansible-playbook -i inventory/mycluster/inventory.ini -v remove-node.yml -e node=k8s-node5
# yes 입력!

# 확인
[root@admin-lb kubespray]# k get node -owide
NAME        STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                  CONTAINER-RUNTIME
k8s-node1   Ready    control-plane   80m   v1.32.9   172.31.1.127   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.29.1.el10_1.x86_64   containerd://2.1.5
k8s-node2   Ready    control-plane   80m   v1.32.9   172.31.2.170   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.29.1.el10_1.x86_64   containerd://2.1.5
k8s-node3   Ready    control-plane   80m   v1.32.9   172.31.2.118   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.29.1.el10_1.x86_64   containerd://2.1.5
k8s-node4   Ready    <none>          79m   v1.32.9   172.31.7.101   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.29.1.el10_1.x86_64   containerd://2.1.5

# 삭제 확인
[root@admin-lb kubespray]# ssh k8s-node5 tree /etc/kubernetes
/etc/kubernetes  [error opening dir]

0 directories, 0 files

[root@admin-lb kubespray]# ssh k8s-node5 tree /var/lib/kubelet
/var/lib/kubelet  [error opening dir]

0 directories, 0 files


# inventory.ini 수정
cat << EOF > /root/kubespray/inventory/mycluster/inventory.ini
[kube_control_plane]
k8s-node1 ansible_host=172.31.1.127 ip=172.31.1.127 etcd_member_name=etcd1
k8s-node2 ansible_host=172.31.2.170 ip=172.31.2.170 etcd_member_name=etcd2
k8s-node3 ansible_host=172.31.2.118 ip=172.31.2.118 etcd_member_name=etcd3

[etcd:children]
kube_control_plane

[kube_node]
k8s-node4 ansible_host=172.31.7.101 ip=172.31.7.101
EOF
```

## k8s-node5 재추가
```bash
# inventory.ini 수정
cat << EOF > /root/kubespray/inventory/mycluster/inventory.ini
[kube_control_plane]
k8s-node1 ansible_host=172.31.1.127 ip=172.31.1.127 etcd_member_name=etcd1
k8s-node2 ansible_host=172.31.2.170 ip=172.31.2.170 etcd_member_name=etcd2
k8s-node3 ansible_host=172.31.2.118 ip=172.31.2.118 etcd_member_name=etcd3

[etcd:children]
kube_control_plane

[kube_node]
k8s-node4 ansible_host=172.31.7.101 ip=172.31.7.101
k8s-node5 ansible_host=172.31.1.69 ip=172.31.1.69
EOF

# 워커 노드 추가 재실행
ANSIBLE_FORCE_COLOR=true ansible-playbook -i inventory/mycluster/inventory.ini -v scale.yml --limit=k8s-node5 -e kube_version="1.32.9" | tee kubespray_add_worker_node.log

# 확인
[root@admin-lb kubespray]# k get node -owide
NAME        STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                  CONTAINER-RUNTIME
k8s-node1   Ready    control-plane   85m   v1.32.9   172.31.1.127   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.29.1.el10_1.x86_64   containerd://2.1.5
k8s-node2   Ready    control-plane   85m   v1.32.9   172.31.2.170   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.29.1.el10_1.x86_64   containerd://2.1.5
k8s-node3   Ready    control-plane   85m   v1.32.9   172.31.2.118   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.29.1.el10_1.x86_64   containerd://2.1.5
k8s-node4   Ready    <none>          84m   v1.32.9   172.31.7.101   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.29.1.el10_1.x86_64   containerd://2.1.5
k8s-node5   Ready    <none>          78s   v1.32.9   172.31.1.69    <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.28.1.el10_1.x86_64   containerd://2.1.5
```