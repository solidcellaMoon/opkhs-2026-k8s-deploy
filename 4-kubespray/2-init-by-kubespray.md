# kubespray로 k8s 프로비저닝

## kubespray 초기 구성 진행
```bash
# Clone Kubespray Repository
[root@k8s-ctr ~]# git clone -b v2.29.1 https://github.com/kubernetes-sigs/kubespray.git /root/kubespray
[root@k8s-ctr ~]# cd /root/kubespray

# 최상단 plybook 확인 -> 각각 import_playbook 확인
[root@k8s-ctr kubespray]# ls -l *.yml
-rw-r--r--. 1 root root  88 Jan 31 14:20 cluster.yml
-rw-r--r--. 1 root root  30 Jan 31 14:20 _config.yml
-rw-r--r--. 1 root root 747 Jan 31 14:20 galaxy.yml
-rw-r--r--. 1 root root 105 Jan 31 14:20 recover-control-plane.yml
-rw-r--r--. 1 root root  85 Jan 31 14:20 remove-node.yml
-rw-r--r--. 1 root root  85 Jan 31 14:20 remove_node.yml
-rw-r--r--. 1 root root  85 Jan 31 14:20 reset.yml
-rw-r--r--. 1 root root  85 Jan 31 14:20 scale.yml
-rw-r--r--. 1 root root  93 Jan 31 14:20 upgrade-cluster.yml
-rw-r--r--. 1 root root  93 Jan 31 14:20 upgrade_cluster.yml

[root@k8s-ctr kubespray]# tree -L 2
.
├── ansible.cfg
├── CHANGELOG.md
├── cluster.yml
├── CNAME
├── code-of-conduct.md
├── _config.yml
├── contrib
│   ├── aws_iam
│   ├── aws_inventory
│   ├── azurerm
│   ├── offline
│   ├── os-services
│   └── terraform
├── CONTRIBUTING.md
├── Dockerfile
├── docs
│   ├── advanced
│   ├── ansible
│   ├── calico_peer_example
│   ├── cloud_controllers
│   ├── cloud_providers
│   ├── CNI
│   ├── CRI
│   ├── CSI
│   ├── developers
│   ├── external_storage_provisioners
│   ├── figures
│   ├── getting_started
│   ├── img
│   ├── ingress
│   ├── operating_systems
│   ├── operations
│   ├── roadmap
│   ├── _sidebar.md
│   └── upgrades
├── extra_playbooks
│   ├── files
│   ├── inventory -> ../inventory
│   ├── migrate_openstack_provider.yml
│   ├── roles -> ../roles
│   ├── upgrade-only-k8s.yml
│   └── wait-for-cloud-init.yml
├── galaxy.yml
├── index.html
├── inventory
│   ├── local
│   └── sample
├── library
│   └── kube.py -> ../plugins/modules/kube.py
├── LICENSE
├── logo
│   ├── LICENSE
│   ├── logo-clear.png
│   ├── logo-clear.svg
│   ├── logo-dark.png
│   ├── logo-dark.svg
│   ├── logos.pdf
│   ├── logo-text-clear.png
│   ├── logo-text-clear.svg
│   ├── logo-text-dark.png
│   ├── logo-text-dark.svg
│   ├── logo-text-mixed.png
│   ├── logo-text-mixed.svg
│   └── usage_guidelines.md
├── meta
│   └── runtime.yml
├── OWNERS
├── OWNERS_ALIASES
├── pipeline.Dockerfile
├── playbooks
│   ├── ansible_version.yml
│   ├── boilerplate.yml
│   ├── cluster.yml
│   ├── facts.yml
│   ├── install_etcd.yml
│   ├── internal_facts.yml
│   ├── recover_control_plane.yml
│   ├── remove_node.yml
│   ├── reset.yml
│   ├── scale.yml
│   └── upgrade_cluster.yml
├── plugins
│   └── modules
├── README.md
├── recover-control-plane.yml
├── RELEASE.md
├── remove-node.yml
├── remove_node.yml
├── requirements.txt
├── reset.yml
├── roles
│   ├── adduser
│   ├── bastion-ssh-config
│   ├── bootstrap-os
│   ├── bootstrap_os
│   ├── container-engine
│   ├── download
│   ├── dynamic_groups
│   ├── etcd
│   ├── etcdctl_etcdutl
│   ├── etcd_defaults
│   ├── helm-apps
│   ├── kubernetes
│   ├── kubernetes-apps
│   ├── kubespray-defaults
│   ├── kubespray_defaults
│   ├── network_facts
│   ├── network_plugin
│   ├── recover_control_plane
│   ├── remove-node
│   ├── remove_node
│   ├── reset
│   ├── system_packages
│   ├── upgrade
│   ├── validate_inventory
│   └── win_nodes
├── scale.yml
├── scripts
│   ├── assert-sorted-checksums.yml
│   ├── collect-info.yaml
│   ├── component_hash_update
│   ├── Dockerfile.j2
│   ├── galaxy_version.py
│   ├── gen_docs_sidebar.sh
│   ├── get_node_ids.sh
│   ├── gitlab-runner.sh
│   ├── openstack-cleanup
│   ├── pipeline.Dockerfile.j2
│   ├── propagate_ansible_variables.yml
│   └── readme_versions.md.j2
├── SECURITY_CONTACTS
├── test-infra
│   ├── image-builder
│   └── vagrant-docker
├── tests
│   ├── ansible.cfg
│   ├── cloud_playbooks
│   ├── common_vars.yml
│   ├── files
│   ├── Makefile
│   ├── requirements.txt
│   ├── scripts
│   └── testcases
├── upgrade-cluster.yml
├── upgrade_cluster.yml
└── Vagrantfile

76 directories, 70 files



# Install Python Dependencies
[root@k8s-ctr kubespray]# cat requirements.txt
ansible==10.7.0
# Needed for community.crypto module
cryptography==46.0.2
# Needed for jinja2 json_query templating
jmespath==1.0.1
# Needed for ansible.utils.ipaddr
netaddr==1.3.0

[root@k8s-ctr kubespray]# pip3 install -r /root/kubespray/requirements.txt
# ...

# ansible 버전 확인 : Ansible 2.17.3 이상
[root@k8s-ctr kubespray]# which ansible
/usr/local/bin/ansible

[root@k8s-ctr kubespray]# ansible --version
ansible [core 2.17.14]
  config file = /root/kubespray/ansible.cfg
  configured module search path = ['/root/kubespray/library']
  ansible python module location = /usr/local/lib/python3.12/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.12.11 (main, Aug 14 2025, 00:00:00) [GCC 14.3.1 20250617 (Red Hat 14.3.1-2)] (/usr/bin/python3)
  jinja version = 3.1.6
  libyaml = True

# pip list 확인
[root@k8s-ctr kubespray]# pip list
Package                   Version
------------------------- -----------
ansible                   10.7.0
ansible-core              2.17.14
attrs                     23.2.0
awscli                    2.27.0
awscrt                    0.27.2
cffi                      2.0.0
charset-normalizer        3.4.2
cloud-init                24.4
cockpit                   344
colorama                  0.4.6
configobj                 5.0.8
cryptography              46.0.2
dasbus                    1.7
dbus-python               1.3.2
distro                    1.9.0
dnf                       4.20.0
docutils                  0.20.1
file-magic                0.4.0
idna                      3.7
Jinja2                    3.1.6
jmespath                  1.0.1
jsonpatch                 1.33
jsonpointer               2.3
jsonschema                4.19.1
jsonschema-specifications 2023.11.2
libcomps                  0.1.21
libdnf                    0.73.1
MarkupSafe                2.1.3
netaddr                   1.3.0
oauthlib                  3.2.2
packaging                 24.2
pexpect                   4.9.0
pip                       23.3.2
ply                       3.11
prompt_toolkit            3.0.41
ptyprocess                0.7.0
pycparser                 2.20
PyGObject                 3.46.0
pyserial                  3.5
python-dateutil           2.9.0.post0
PyYAML                    6.0.1
pyynl                     0.0.1
referencing               0.31.1
requests                  2.32.4
resolvelib                1.0.1
rpds-py                   0.17.1
rpm                       4.19.1.1
ruamel.yaml               0.18.5
ruamel.yaml.clib          0.2.7
selinux                   3.9
sepolicy                  3.9
setools                   4.5.1
setroubleshoot            3.3.33
setuptools                69.0.3
six                       1.16.0
sos                       4.10.0
systemd-python            235
urllib3                   1.26.19
wcwidth                   0.2.6
```

## asible.cfg 확인
- `[ssh_connection]`: 통신 속도 및 안정성 최적화
- `pipelining=True`: SSH 세션을 여러 번 열지 않고 하나의 세션에서 여러 명령을 한꺼번에 실행
- `ssh_args = -o ControlMaster=auto -o ControlPersist=30m -o ConnectionAttempts=100 -o UserKnownHostsFile=/dev/null`
  - `ControlMaster=auto -o ControlPersist=30m`:  번 연결된 SSH 커넥션을 30분 동안 유지한다. 매번 로그인할 필요가 없어 성능 향상 효과.
  - `ConnectionAttempts=100`: 네트워크 불안정으로 연결 실패 시 100번까지 재시도.
  - `UserKnownHostsFile=/dev/null`: 접속 대상의 지문(fingerprint)을 저장하지 않아 관리 편함.
- `force_valid_group_names = ignore`: Ansible은 원래 그룹 이름에 -나 . 사용을 제한하지만, 쿠버네티스 리소스 명칭 규칙상 이를 허용하도록 설정.
- `host_key_checking=False`: 새 서버 접속 시 "Are you sure you want to continue connecting?"이라는 확인 창이 뜨지 않게 함.
- `gathering = smart`: 대상 서버의 정보(Fact)를 한 번만 수집하고 /tmp에 JSON 파일로 저장함.
- `fact_caching = jsonfile`: 재실행 시 서버 정보를 다시 수집하지 않아 시간이 단축. 86400(24시간) 동안 캐시 유지.
- `callbacks_enabled = profile_tasks`: 각 Task가 실행되는 데 걸리는 시간 표시. 어떤 단계에서 병목이 생기는지 확인할 때 유용.
- `inventory_ignore_extension`: 백업용이나 임시 파일을 인벤토리로 인식하여 에러가 발생하는 것 방지.
- `ignore_patterns`: 배포 결과물(artifacts)이나 중요 정보(credentials) 폴더 내의 파일을 인벤토리 스캔 대상에서 제외.

```bash
# 해당 폴더에서 ansible-playbook 실행 시 적용되는 ansible.cfg
[root@k8s-ctr kubespray]# cat ansible.cfg
[ssh_connection]
pipelining=True
ssh_args = -o ControlMaster=auto -o ControlPersist=30m -o ConnectionAttempts=100 -o UserKnownHostsFile=/dev/null
#control_path = ~/.ssh/ansible-%%r@%%h:%%p
[defaults]
# https://github.com/ansible/ansible/issues/56930 (to ignore group names with - and .)
force_valid_group_names = ignore

host_key_checking=False
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp
fact_caching_timeout = 86400
timeout = 300
stdout_callback = default
display_skipped_hosts = no
library = ./library
callbacks_enabled = profile_tasks
roles_path = roles:$VIRTUAL_ENV/usr/local/share/kubespray/roles:$VIRTUAL_ENV/usr/local/share/ansible/roles:/usr/share/kubespray/roles
deprecation_warnings=False
inventory_ignore_extensions = ~, .orig, .bak, .ini, .cfg, .retry, .pyc, .pyo, .creds, .gpg
[inventory]
ignore_patterns = artifacts, credentials
```

## kubespary 를 통한 k8s 배포용 파라미터 설정 1
```bash
# inventory 디렉터리 복사
[root@k8s-ctr kubespray]# cp -rfp /root/kubespray/inventory/sample /root/kubespray/inventory/mycluster

[root@k8s-ctr kubespray]# tree inventory/mycluster/
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

4 directories, 27 files

# inventory.ini 작성
cat << EOF > /root/kubespray/inventory/mycluster/inventory.ini
k8s-ctr ansible_host=172.31.9.85 ip=172.31.9.85 ansible_user=root ansible_password='qwe123'

[kube_control_plane]
k8s-ctr

[etcd:children]
kube_control_plane

[kube_node]
k8s-ctr
EOF

[root@k8s-ctr kubespray]# cat /root/kubespray/inventory/mycluster/inventory.ini
k8s-ctr ansible_host=172.31.9.85 ip=172.31.9.85

[kube_control_plane]
k8s-ctr

[etcd:children]
kube_control_plane

[kube_node]
k8s-ctr

# https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ansible/vars.md
## inventory/mycluster/group_vars/all.yml # for every node, including etcd
[root@k8s-ctr kubespray]# grep "^[^#]" inventory/mycluster/group_vars/all/all.yml
---
bin_dir: /usr/local/bin
loadbalancer_apiserver_port: 6443
loadbalancer_apiserver_healthcheck_port: 8081
no_proxy_exclude_workers: false
kube_webhook_token_auth: false
kube_webhook_token_auth_url_skip_tls_verify: false
ntp_enabled: false
ntp_manage_config: false
ntp_servers:
  - "0.pool.ntp.org iburst"
  - "1.pool.ntp.org iburst"
  - "2.pool.ntp.org iburst"
  - "3.pool.ntp.org iburst"
unsafe_show_logs: false
allow_unsupported_distribution_setup: false

## inventory/mycluster/group_vars/k8s_cluster.yml # for every node in the cluster (not etcd when it's separate)
[root@k8s-ctr kubespray]# grep "^[^#]" inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
---
kube_config_dir: /etc/kubernetes
kube_script_dir: "{{ bin_dir }}/kubernetes-scripts"
kube_manifest_dir: "{{ kube_config_dir }}/manifests"
kube_cert_dir: "{{ kube_config_dir }}/ssl"
kube_token_dir: "{{ kube_config_dir }}/tokens"
kube_api_anonymous_auth: true
local_release_dir: "/tmp/releases"
retry_stagger: 5
kube_owner: kube
kube_cert_group: kube-cert
kube_log_level: 2
credentials_dir: "{{ inventory_dir }}/credentials"
kube_network_plugin: calico
kube_network_plugin_multus: false
kube_service_addresses: 10.233.0.0/18
kube_pods_subnet: 10.233.64.0/18
kube_network_node_prefix: 24
kube_service_addresses_ipv6: fd85:ee78:d8a6:8607::1000/116
kube_pods_subnet_ipv6: fd85:ee78:d8a6:8607::1:0000/112
kube_network_node_prefix_ipv6: 120
kube_apiserver_ip: "{{ kube_service_subnets.split(',') | first | ansible.utils.ipaddr('net') | ansible.utils.ipaddr(1) | ansible.utils.ipaddr('address') }}"
kube_apiserver_port: 6443  # (https)
kube_proxy_mode: ipvs
kube_proxy_strict_arp: false
kube_proxy_nodeport_addresses: >-
  {%- if kube_proxy_nodeport_addresses_cidr is defined -%}
  [{{ kube_proxy_nodeport_addresses_cidr }}]
  {%- else -%}
  []
  {%- endif -%}
kube_encrypt_secret_data: false
cluster_name: cluster.local
ndots: 2
dns_mode: coredns
enable_nodelocaldns: true
enable_nodelocaldns_secondary: false
nodelocaldns_ip: 169.254.25.10
nodelocaldns_health_port: 9254
nodelocaldns_second_health_port: 9256
nodelocaldns_bind_metrics_host_ip: false
nodelocaldns_secondary_skew_seconds: 5
enable_coredns_k8s_external: false
coredns_k8s_external_zone: k8s_external.local
enable_coredns_k8s_endpoint_pod_names: false
resolvconf_mode: host_resolvconf
deploy_netchecker: false
skydns_server: "{{ kube_service_subnets.split(',') | first | ansible.utils.ipaddr('net') | ansible.utils.ipaddr(3) | ansible.utils.ipaddr('address') }}"
skydns_server_secondary: "{{ kube_service_subnets.split(',') | first | ansible.utils.ipaddr('net') | ansible.utils.ipaddr(4) | ansible.utils.ipaddr('address') }}"
dns_domain: "{{ cluster_name }}"
container_manager: containerd
kata_containers_enabled: false
kubeadm_certificate_key: "{{ lookup('password', credentials_dir + '/kubeadm_certificate_key.creds length=64 chars=hexdigits') | lower }}"
k8s_image_pull_policy: IfNotPresent
kubernetes_audit: false
default_kubelet_config_dir: "{{ kube_config_dir }}/dynamic_kubelet_dir"
volume_cross_zone_attachment: false
persistent_volumes_enabled: false
event_ttl_duration: "1h0m0s"
auto_renew_certificates: false
kubeadm_patches_dir: "{{ kube_config_dir }}/patches"
kubeadm_patches: []
remove_anonymous_access: false
```

## kubespary 를 통한 k8s 배포용 파라미터 설정 2
테스트할 기능 관련 수정
```bash
sed -i 's|kube_network_plugin: calico|kube_network_plugin: flannel|g' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
sed -i 's|kube_proxy_mode: ipvs|kube_proxy_mode: iptables|g' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
sed -i 's|enable_nodelocaldns: true|enable_nodelocaldns: false|g' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
sed -i 's|auto_renew_certificates: false|auto_renew_certificates: true|g' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
sed -i 's|# auto_renew_certificates_systemd_calendar|auto_renew_certificates_systemd_calendar|g' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

[root@k8s-ctr kubespray]# grep -iE 'kube_network_plugin:|kube_proxy_mode|enable_nodelocaldns:|^auto_renew_certificates' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
kube_network_plugin: flannel
kube_proxy_mode: iptables
enable_nodelocaldns: false
auto_renew_certificates: true
auto_renew_certificates_systemd_calendar: "Mon *-*-1,2,3,4,5,6,7 03:00:00"

## flannel 설정 수정  inventory/mycluster/group_vars/k8s_cluster/k8s-net-flannel.yml
[root@k8s-ctr kubespray]# cat inventory/mycluster/group_vars/k8s_cluster/k8s-net-flannel.yml
# see roles/network_plugin/flannel/defaults/main.yml

## interface that should be used for flannel operations
## This is actually an inventory cluster-level item
# flannel_interface:

## Select interface that should be used for flannel operations by regexp on Name or IP
## This is actually an inventory cluster-level item
## example: select interface with ip from net 10.0.0.0/23
## single quote and escape backslashes
# flannel_interface_regexp: '10\\.0\\.[0-2]\\.\\d{1,3}'

# You can choose what type of flannel backend to use: 'vxlan',  'host-gw' or 'wireguard'
# please refer to flannel's docs : https://github.com/coreos/flannel/blob/master/README.md
# flannel_backend_type: "vxlan"
# flannel_vxlan_vni: 1
# flannel_vxlan_port: 8472
# flannel_vxlan_direct_routing: false

[root@k8s-ctr kubespray]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP group default qlen 1000
    link/ether 02:e7:fe:e5:06:93 brd ff:ff:ff:ff:ff:ff
    altname enp0s5
    altname enx02e7fee50693
    inet 172.31.9.85/20 brd 172.31.15.255 scope global dynamic noprefixroute ens5
       valid_lft 2629sec preferred_lft 2629sec
    inet6 fe80::e7:feff:fee5:693/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever

[root@k8s-ctr kubespray]# echo "flannel_interface: ens5" >> inventory/mycluster/group_vars/k8s_cluster/k8s-net-flannel.yml

[root@k8s-ctr kubespray]# grep "^[^#]" inventory/mycluster/group_vars/k8s_cluster/k8s-net-flannel.yml
flannel_interface: ens5


## inventory/mycluster/group_vars/kube_control_plane.yml # for the control plane
[root@k8s-ctr kubespray]# cat inventory/mycluster/group_vars/k8s_cluster/kube_control_plane.yml 
# Reservation for control plane kubernetes components
# kube_memory_reserved: 512Mi
# kube_cpu_reserved: 200m
# kube_ephemeral_storage_reserved: 2Gi
# kube_pid_reserved: "1000"

# Reservation for control plane host system
# system_memory_reserved: 256Mi
# system_cpu_reserved: 250m
# system_ephemeral_storage_reserved: 2Gi
# system_pid_reserved: "1000"

## addons.yml
[root@k8s-ctr kubespray]# grep "^[^#]" inventory/mycluster/group_vars/k8s_cluster/addons.yml
---
helm_enabled: false
registry_enabled: false
metrics_server_enabled: false
local_path_provisioner_enabled: false
local_volume_provisioner_enabled: false
gateway_api_enabled: false
ingress_nginx_enabled: false
ingress_publish_status_address: ""
ingress_alb_enabled: false
cert_manager_enabled: false
metallb_enabled: false
metallb_speaker_enabled: "{{ metallb_enabled }}"
metallb_namespace: "metallb-system"
argocd_enabled: false
kube_vip_enabled: false
node_feature_discovery_enabled: false
```

## kubespary 를 통한 k8s 배포용 파라미터 설정 3
```bash
# 테스트할 기능 관련 수정
sed -i 's|helm_enabled: false|helm_enabled: true|g' inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i 's|metrics_server_enabled: false|metrics_server_enabled: true|g' inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i 's|node_feature_discovery_enabled: false|node_feature_discovery_enabled: true|g' inventory/mycluster/group_vars/k8s_cluster/addons.yml

[root@k8s-ctr kubespray]# grep -iE 'helm_enabled:|metrics_server_enabled:|node_feature_discovery_enabled:' inventory/mycluster/group_vars/k8s_cluster/addons.yml
helm_enabled: true
metrics_server_enabled: true
node_feature_discovery_enabled: true

# etcd.yml : 파드가 아닌 systemd unit
[root@k8s-ctr kubespray]# grep "^[^#]" inventory/mycluster/group_vars/all/etcd.yml
---
etcd_data_dir: /var/lib/etcd
etcd_deployment_type: host

# containerd.yml 
[root@k8s-ctr kubespray]# cat inventory/mycluster/group_vars/all/containerd.yml
---
# Please see roles/container-engine/containerd/defaults/main.yml for more configuration options

# containerd_storage_dir: "/var/lib/containerd"
# containerd_state_dir: "/run/containerd"
# containerd_oom_score: 0

# containerd_default_runtime: "runc"
# containerd_snapshotter: "native"

# containerd_runc_runtime:
#   name: runc
#   type: "io.containerd.runc.v2"
#   engine: ""
#   root: ""

# containerd_additional_runtimes:
# Example for Kata Containers as additional runtime:
#   - name: kata
#     type: "io.containerd.kata.v2"
#     engine: ""
#     root: ""

# containerd_grpc_max_recv_message_size: 16777216
# containerd_grpc_max_send_message_size: 16777216

# Containerd debug socket location: unix or tcp format
# containerd_debug_address: ""

# Containerd log level
# containerd_debug_level: "info"

# Containerd logs format, supported values: text, json
# containerd_debug_format: ""

# Containerd debug socket UID
# containerd_debug_uid: 0

# Containerd debug socket GID
# containerd_debug_gid: 0

# containerd_metrics_address: ""

# containerd_metrics_grpc_histogram: false

# Registries defined within containerd.
# containerd_registries_mirrors:
#  - prefix: docker.io
#    mirrors:
#     - host: https://registry-1.docker.io
#       capabilities: ["pull", "resolve"]
#       skip_verify: false
#       header:
#         Authorization: "Basic XXX"

# containerd_max_container_log_line_size: 16384

# containerd_registry_auth:
#   - registry: 10.0.0.2:5000
#     username: user
#     password: pass
```

# kubespray로 k8s 설치 진행
```bash
# 기본 환경 정보 출력 저장
ip addr | tee -a ip_addr-1.txt 
ss -tnlp | tee -a ss-1.txt
df -hT | tee -a df-1.txt
findmnt | tee -a findmnt-1.txt
sysctl -a | tee -a sysctl-1.txt

# 지원 버전 정보 확인
[root@k8s-ctr kubespray]# cat roles/kubespray_defaults/vars/main/checksums.yml | grep -i kube -A40
kubelet_checksums:
  arm64:
    1.33.7: sha256:3035c44e0d429946d6b4b66c593d371cf5bbbfc85df39d7e2a03c422e4fe404a
    1.33.6: sha256:7d8b7c63309cfe2da2331a1ae13cce070b9ba01e487099e7881a4281667c131d
    1.33.5: sha256:c6ad0510c089d49244eede2638b4a4ff125258fd29a0649e7eef05c7f79c737f
    1.33.4: sha256:623329b1a5f4858e3a5406d3947807b75144f4e71dde11ef1a71362c3a8619cc
    1.33.3: sha256:3f69bb32debfaf25fce91aa5e7181e1e32f3550f3257b93c17dfb37bed621a9c
    1.33.2: sha256:0fa15aca9b90fe7aef1ed3aad31edd1d9944a8c7aae34162963a6aaaf726e065
    1.33.1: sha256:10540261c311ae005b9af514d83c02694e12614406a8524fd2d0bad75296f70d
    1.33.0: sha256:ae5a4fc6d733fc28ff198e2d80334e21fcb5c34e76b411c50fff9cb25accf05a
    1.32.10: sha256:21cc3d98550d3a23052d649e77956f2557e7f6119ff1e27dc82b852d006136cd
    1.32.9: sha256:29037381c79152409adacee83448a2bdb67e113f003613663c7589286200ded8
    1.32.8: sha256:d5527714fac08eac4c1ddcbd8a3c6db35f3acd335d43360219d733273b672cce
    1.32.7: sha256:b862a8d550875924c8abed6c15ba22564f7e232c239aa6a2e88caf069a0ab548
    1.32.6: sha256:b045d4f8f96bf934c894f9704ab2931ffa3c6cf78a8d98e457482a6c455dab6d
    1.32.5: sha256:034753a2e308afeb4ce3cf332d38346c6e660252eac93b268fac0e112a56ff46
    1.32.4: sha256:91117b71eb2bb3dd79ec3ed444e058a347349108bf661838f53ee30d2a0ff168
    1.32.3: sha256:5c3c98e6e0fa35d209595037e05022597954b8d764482417a9588e15218f0fe2
    1.32.2: sha256:d74b659bbde5adf919529d079975900e51e10bc807f0fda9dc9f6bb07c4a3a7b
    1.32.1: sha256:8e6d0eeedd9f0b8b38d4f600ee167816f71cf4dacfa3d9a9bb6c3561cc884e95
    1.32.0: sha256:bda9b2324c96693b38c41ecea051bab4c7c434be5683050b5e19025b50dbc0bf
    1.31.14: sha256:e2842f132933b990a8cbc285be3a28ff1cd213fe1a3380e24e37b1d2ce5e0ca6
    1.31.13: sha256:37e8f83b7bc4cb1b6f49d99cb0d23c2c692f9782abc4f03aad37cc7bd504af68
    1.31.12: sha256:3dab6925a2beb59fbfa7df2897e001af95886145f556cafdbde8c4facd7ca516
    1.31.11: sha256:3a0e07fd72709736cd85ce64a2f5505b2bb085fe697417b96ff249febd5357b1
    1.31.10: sha256:bdb7b70e6f17e6a6700c275c0a3e3632252cf34bf482b6a9fb8448efe8a0e287
    1.31.9: sha256:2debf321e74f430c3832e2426766271f4d51e54927e6ad4be0235d31453dace6
    1.31.8: sha256:c071aa506071db5f03a03ea3f406b4250359b08b7ae10eeee3cfb3da05411925
    1.31.7: sha256:c6624e9e0bbf31334893f991f9a85c7018d8073c32147f421f6338bc92ac6f33
    1.31.6: sha256:79b2bae5f578bae643e44ae1a40c834221983ac8e695c82aad79f2dc96c50ada
    1.31.5: sha256:922a96405fdc3ae41e403565d06c5a6c3b733b0c3d0d1d61086b39c6760103d3
    1.31.4: sha256:fb6f02f3324a72307acc11998eb5b1c3778167ae165c98f9d49bd011498e72f8
    1.31.3: sha256:0ec590052f2d1cee158a789d705ca931cbc2556ceed364c4ad754fd36c61be28
    1.31.2: sha256:118e1b0e85357a81557f9264521c083708f295d7c5f954a4113500fd1afca8f8
    1.31.1: sha256:fbd98311e96b9dcdd73d1688760d410cc70aefce26272ff2f20eef51a7c0d1da
    1.31.0: sha256:b310da449a9d2f8b928cab5ca12a6772617ba421023894e061ca2647e6d9f1c3
  amd64:
    1.33.7: sha256:2cea40c8c6929330e799f8fc73233a4b61e63f208739669865e2a23a39c3a007
    1.33.6: sha256:10cd08fe1f9169fd7520123bcdfff87e37b8a4e21c39481faa382f00355b6973
    1.33.5: sha256:8f6106b970259486c5af5cbee404d4f23406d96d99dfb92a6965b299c2a4db0e
    1.33.4: sha256:109bd2607b054a477ede31c55ae814eae8e75543126dc4cea40b04424d843489
--
kubectl_checksums:
  arm:
    1.33.7: sha256:f6b9ac99f4efb406c5184d0a51d9ed896690c80155387007291309cbb8cdd847
    1.33.6: sha256:89bcef827ac8662781740d092cff410744c0653d828b68cc14051294fcd717e6
    1.33.5: sha256:5a3a416a85cfc9f7a348c0c0e6334b7449e00a57288ab5a57286ccf68a4d06af
    1.33.4: sha256:eefd3864ce5440e0ba648b12d53ccffaad97f1c049781b1aa21af6a5278f035f
    1.33.3: sha256:0124dba9e9091b872591cabcbaea7df07069cb132d38d95f3c7bc8d5b8b621a9
    1.33.2: sha256:f3992382aa0ea21f71a976b6fd6a213781c9b58be60c42013950110cf2184f2a
    1.33.1: sha256:6b1cd6e2bf05c6adaa76b952f9c4ea775f5255913974ccdb12145175d4809e93
    1.33.0: sha256:bbb4b4906d483f62b0fc3a0aea3ddac942820984679ad11635b81ee881d69ab3
    1.32.10: sha256:b42bc77586238b43b8c5cdd06086f1ab00190245dd8b66b28822785b177fbde4
    1.32.9: sha256:84629d460b60693ca954e148ce522defd34d18bc5c934836cfaf0268930713dd
    1.32.8: sha256:ed54b52631fdf5ecc4ddb12c47df481f84b5890683beaeaa55dc84e43d2cd023
    1.32.7: sha256:c5416b59afdf897c4fbf08867c8a32b635f83f26e40980d38233fad6b345e37c
    1.32.6: sha256:77fec65c6f08c28f8695de4db877d82d74c881ed3ed110ebfd88cbd4ee3d01dc
    1.32.5: sha256:7270e6ac4b82b5e4bd037dccae1631964634214baa66a9548deb5edd3f79de31
    1.32.4: sha256:bf28793213039690d018bbfa9bcfcfed76a9aa8e18dc299eced8709ca542fcdd
    1.32.3: sha256:f990c878e54e5fac82eac7398ef643acca9807838b19014f1816fa9255b2d3d9
    1.32.2: sha256:e1e6a2fd4571cd66c885aa42b290930660d34a7331ffb576fcab9fd1a0941a83
    1.32.1: sha256:8ccf69be2578d3a324e9fc7d4f3b29bc9743cc02d72f33ba2d0fe30389014bc8
    1.32.0: sha256:6b33ea8c80f785fb07be4d021301199ae9ee4f8d7ea037a8ae544d5a7514684e
    1.31.14: sha256:23860bd774ec2c2cb1f409581c236725673c55506409da846a651ec27c2ca15d
    1.31.13: sha256:875597876f9dcfb2b3197667c0fbb0691cbef3d9522de22875c1a5c02bc04de5
    1.31.12: sha256:8e430e7a192355a60e1398580a861b4724b286ed38ff52a156500d3fae90c583
    1.31.11: sha256:7768bb4e1b79ddac982968e47d9e25f357b7e9c0f08039134815a64062d5ea6f
    1.31.10: sha256:1f3f644609513ed0c6045638e60fc9e9fb5de39c375719601f565e6ad82b9b85
    1.31.9: sha256:54e560eb3ad4b2b0ae95d79d71b2816dfa154b33758e49f2583bec0980f19861
    1.31.8: sha256:65fdd04f5171e44620cc4e0b9e0763b1b3d10b2b15c1f7f99b549d36482015d4
    1.31.7: sha256:870d919f8ef5f5c608bd69c57893937910de6a8ed2c077fc4f0945375f61734d
    1.31.6: sha256:b370a552cd6c9bb5fc42e4e9031b74f35da332f27b585760bacb0d3189d8634d
    1.31.5: sha256:cbb4e470751ef8864ade9d008e848f691ac6cbdee320539797a68a5512b9f7f8
    1.31.4: sha256:055d1672f63fda86c6dfa5a2354d627f908f68bde6bf8394fdc9a99cadc4de19
    1.31.3: sha256:e0d00fbac98e67b774ff1ed9a0e6fc5be5c1f08cc69b0c8b483904ed15ad8c50
    1.31.2: sha256:f2a638bdaa4764e82259ed1548ce2c86056e33a3d09147f7f0c2d4ee5b5e300c
    1.31.1: sha256:51b178c9362a4fbe35644399f113d7f904d306261953a51c5c0a57676e209fa6
    1.31.0: sha256:a4d6292c88c199688a03ea211bea08c8ae29f1794f5deeeef46862088d124baa
  arm64:
    1.33.7: sha256:fa7ee98fdb6fba92ae05b5e0cde0abd5972b2d9a4a084f7052a1fd0dce6bc1de
    1.33.6: sha256:3ab32d945a67a6000ba332bf16382fc3646271da6b7d751608b320819e5b8f38
    1.33.5: sha256:6db7c5d846c3b3ddfd39f3137a93fe96af3938860eefdbf2429805ee1656e381
    1.33.4: sha256:76cd7a2aa59571519b68c3943521404cbce55dafb7d8866f8d0ea2995b396eef
--
kubeadm_checksums:
  arm64:
    1.33.7: sha256:b24eeeff288f9565e11a2527e5aed42c21386596110537adb805a5a2a7b3e9ce
    1.33.6: sha256:ef80c198ca15a0850660323655ebf5c32cc4ab00da7a5a59efe95e4bcf8503ab
    1.33.5: sha256:b1c00657649e35771569d095e531d826bd19baf57bcb53cccf3f91d7d60b7808
    1.33.4: sha256:ef471b454d68ee211e279ddeaebde6ee7a8e14b66ae58e0d0184e967c3595892
    1.33.3: sha256:bf8ed3bc3952e04f29863c6910ae84b359fe7ac1e642ed4d742ceb396e62c6f2
    1.33.2: sha256:21efc1ba54a1cf25ac68208b7dde2e67f6d0331259f432947d83e70b975ad4cc
    1.33.1: sha256:5b3e3a1e18d43522fdee0e15be13a42cee316e07ddcf47ef718104836edebb3e
    1.33.0: sha256:746c0ee45f4d32ec5046fb10d4354f145ba1ff0c997f9712d46036650ad26340
    1.32.10: sha256:a201f246be3d2c35ffa7fc51a1d2596797628f9b1455da52a246b42ce8e1f779
    1.32.9: sha256:377349141e865849355140c78063fa2b87443bf1aecb06319be4de4df8dbd918
    1.32.8: sha256:8dbd3fa2d94335d763b983caaf2798caae2d4183f6a95ebff28289f2e86edf68
    1.32.7: sha256:a2aad7f7b320c3c847dea84c08e977ba8b5c84d4b7102b46ffd09d41af6c4b51
    1.32.6: sha256:f786731c37ce6e89e6b71d5a7518e4d1c633337237e3803615056eb4640bfc8e
    1.32.5: sha256:2956c694ff2891acdc4690b807f87ab48419b4925d3fad2ac52ace2a1160bd17
    1.32.4: sha256:1b9d97b44758dc4da20d31e3b6d46f50af75ac48be887793e16797a43d9c30e7
    1.32.3: sha256:f9d007aaf1468ea862ef2a1a1a3f6f34cc57358742ceaff518e1533f5a794181
    1.32.2: sha256:fd8a8c1c41d719de703bf49c6f56692dd6477188d8f43dcb77019fd8bc30cbd3
    1.32.1: sha256:55a57145708aaa37f716f140ef774ca64b7088b6df5ee8eae182936ad6580328
    1.32.0: sha256:5da9746a449a3b8a8312b6dd8c48dcb861036cf394306cfbc66a298ba1e8fbde
    1.31.14: sha256:ff9d9351423fd9c7b40a39a9be11df077b1f5a40c85b70349ca0ce55cd4fd336
    1.31.13: sha256:30762e5a20eb8a4d52b278fe7d999fd76ab20b63b40cb1e60625bc73c6e11e96
    1.31.12: sha256:88fc31963e833d72d1e26159166591aea537d762debb5cc0f0d059fdc717b43b
    1.31.11: sha256:73dff62190cd26947a088ceb79d4d039a916091e0c80734e9ddd7b2e0b8efb8b
    1.31.10: sha256:01e627449b5f94bc068f7d0680a07abfd118cbf9805c7bce3aea31a46e4a16cc
    1.31.9: sha256:d8f5dbb17ce2dead6aedcc700e4293a9395e246079fcdc1772ab9e5cbfeca906
    1.31.8: sha256:d0d1a6634e397e4f14b1e5f9b4bd55758ea70bfc114728730d25d563952e453e
    1.31.7: sha256:3f95765db3b9ebb0cf2ff213ac3b42a831dd995a48d9a6b1d544137d3f2c3018
    1.31.6: sha256:03b6df27c630f6137be129d2cef49dc4da12077381af8d234a92e451ba2a16d2
    1.31.5: sha256:971904ff1ac2879d968cac1d4865b7c0ce0d9374506bd17bd0b123981803769b
    1.31.4: sha256:4598c2f0c69e60feb47a070376da358f16efe0e1403c6aca97fa8f7ab1d0e7c0
    1.31.3: sha256:8113900524bd1c8b3ce0b3ece0d37f96291cbf359946afae58a596319a5575c8
    1.31.2: sha256:0f9d231569b3195504f8458415e9b3080e23fb6a749fe7752abfc7a2884efadf
    1.31.1: sha256:66195cd53cda3c73c9ae5e49a1352c710c0ea9ce244bbdeb68b917d809f0ea78
    1.31.0: sha256:dbeb84862d844d58f67ad6be64021681a314cda162a04e6047f376f2a9ad0226
  amd64:
    1.33.7: sha256:c10813d54f58ef33bbe6675f3d39c8bd401867743ebc729afdd043265040c31d
    1.33.6: sha256:c1b84cb3482dd79e26629012f432541ccb505c17f5073aa1fdbca26b1e4909fd
    1.33.5: sha256:6761219749c6c67a56a5668dfe65d669e0c1f34d4b280b72de6d74d47c601f1e
    1.33.4: sha256:a109ebcb68e52d3dd605d92f92460c884dcc8b68aebe442404af19b6d9d778ec
```

이어서 배포한다!
- 아래처럼 반드시 ~/kubespray 디렉토리에서 ansible-playbook 를 실행하자.
```bash
# Deploy Kubespray with Ansible Playbook - run the playbook as root
# The option `--become` is required, as for example writing SSL keys in /etc/,
# installing packages and interacting with various systemd daemons.

# 배포 전, Task 목록 확인
ansible-playbook -i inventory/mycluster/inventory.ini -v cluster.yml -e kube_version="1.33.3" --list-tasks
# 생략...

# 정상 경우: 약 10분 이내 정도 소요됨.
[root@k8s-ctr kubespray]# ANSIBLE_FORCE_COLOR=true ansible-playbook -i inventory/mycluster/inventory.ini -v cluster.yml -e kube_version="1.33.3" | tee kubespray_install.log
Using /root/kubespray/ansible.cfg as config file
# ...
Saturday 31 January 2026  15:04:15 +0000 (0:00:00.032)       0:07:04.950 ****** 
=============================================================================== 
system_packages : Manage packages -------------------------------------- 23.22s
kubernetes/control-plane : Kubeadm | Initialize first control plane node (1st try) -- 10.85s
kubernetes-apps/node_feature_discovery : Node Feature Discovery | Create manifests -- 10.05s
etcd : Restart etcd ----------------------------------------------------- 8.14s
network_plugin/flannel : Flannel | Wait for flannel subnet.env file presence --- 7.31s
download : Download_file | Download item -------------------------------- 6.51s
download : Download_container | Download image if required -------------- 6.23s
container-engine/crictl : Download_file | Download item ----------------- 6.21s
container-engine/nerdctl : Download_file | Download item ---------------- 6.04s
download : Download_container | Download image if required -------------- 5.93s
kubernetes-apps/node_feature_discovery : Node Feature Discovery | Apply manifests --- 5.78s
container-engine/containerd : Download_file | Download item ------------- 5.73s
kubernetes-apps/metrics_server : Metrics Server | Create manifests ------ 5.72s
container-engine/runc : Download_file | Download item ------------------- 5.58s
kubernetes-apps/ansible : Kubernetes Apps | CoreDNS --------------------- 5.50s
download : Download_container | Download image if required -------------- 5.50s
etcd : Configure | Check if etcd cluster is healthy --------------------- 5.38s
kubernetes-apps/helm : Download_file | Download item -------------------- 5.20s
etcdctl_etcdutl : Download_file | Download item ------------------------- 5.00s
kubernetes-apps/helm : Extract_file | Unpacking archive ----------------- 4.72s

# 설치 확인 : /root/.kube/config
[root@k8s-ctr kubespray]# more kubespray_install.log
# ...

[root@k8s-ctr kubespray]# kubectl get node -v=6
I0131 15:06:58.947380   37755 loader.go:402] Config loaded from file:  /root/.kube/config
I0131 15:06:58.947925   37755 envvar.go:172] "Feature gate default state" feature="InformerResourceVersion" enabled=false
I0131 15:06:58.947948   37755 envvar.go:172] "Feature gate default state" feature="InOrderInformers" enabled=true
I0131 15:06:58.947954   37755 envvar.go:172] "Feature gate default state" feature="WatchListClient" enabled=false
I0131 15:06:58.947958   37755 envvar.go:172] "Feature gate default state" feature="ClientsAllowCBOR" enabled=false
I0131 15:06:58.947970   37755 envvar.go:172] "Feature gate default state" feature="ClientsPreferCBOR" enabled=false
I0131 15:06:58.959773   37755 round_trippers.go:632] "Response" verb="GET" url="https://127.0.0.1:6443/api/v1/nodes?limit=500" status="200 OK" milliseconds=8
NAME      STATUS   ROLES           AGE     VERSION
k8s-ctr   Ready    control-plane   4m40s   v1.33.3

[root@k8s-ctr kubespray]# cat /root/.kube/config | grep kube
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
- name: kubernetes-admin
```

## k8s 상태 확인
```bash
[root@k8s-ctr kubespray]# kubectl get node -owide
NAME      STATUS   ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                  CONTAINER-RUNTIME
k8s-ctr   Ready    control-plane   5m22s   v1.33.3   172.31.9.85   <none>        Rocky Linux 10.1 (Red Quartz)   6.12.0-124.28.1.el10_1.x86_64   containerd://2.1.5

[root@k8s-ctr kubespray]# kubectl get pod -A
NAMESPACE                NAME                                             READY   STATUS    RESTARTS   AGE
kube-system              coredns-5d784884df-p7ls4                         1/1     Running   0          4m37s
kube-system              dns-autoscaler-676999957f-62ghd                  1/1     Running   0          4m36s
kube-system              kube-apiserver-k8s-ctr                           1/1     Running   1          5m29s
kube-system              kube-controller-manager-k8s-ctr                  1/1     Running   2          5m29s
kube-system              kube-flannel-jzjqp                               1/1     Running   0          4m50s
kube-system              kube-proxy-kk2g5                                 1/1     Running   0          4m50s
kube-system              kube-scheduler-k8s-ctr                           1/1     Running   1          5m29s
kube-system              metrics-server-7cd7f9897-qrpz7                   1/1     Running   0          4m9s
node-feature-discovery   node-feature-discovery-gc-6c9b8f4657-2f88x       1/1     Running   0          3m49s
node-feature-discovery   node-feature-discovery-master-6989794b78-76svn   1/1     Running   0          3m49s
node-feature-discovery   node-feature-discovery-worker-pr6zc              1/1     Running   0          3m48s


# 기본 환경 정보 출력 저장
ip addr | tee -a ip_addr-2.txt 
ss -tnlp | tee -a ss-2.txt
df -hT | tee -a df-2.txt
findmnt | tee -a findmnt-2.txt
sysctl -a | tee -a sysctl-2.txt


# k8s 설치 후 비교 용도 파일 추가
vi -d ip_addr-1.txt ip_addr-2.txt
vi -d ss-1.txt ss-2.txt
vi -d df-1.txt df-2.txt
vi -d findmnt-1.txt findmnt-2.txt
vi -d sysctl-1.txt sysctl-2.txt
```

## 기타 편의성 세팅
```bash
# Source the completion
source <(kubectl completion bash)
source <(kubeadm completion bash)

# Alias kubectl to k
alias k=kubectl
complete -o default -F __start_kubectl k

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