# admin 및 원격 접속을 위한 kubeconfig 파일 구성
- kubectl을 k8s 노드 서버가 아닌, 다른 원격지에서 수행할 수 있도록 kubeconfig 파일을 구성한다.
- 이번 실습에서는 jumpbox 서버에서 구성한다.

```bash
# The Admin Kubernetes Configuration File

# You should be able to ping server.kubernetes.local based on the /etc/hosts DNS entry from a previous lab.
root@jumpbox:~/kubernetes-the-hard-way# curl -s --cacert ca.crt https://server.kubernetes.local:6443/version | jq
{
  "major": "1",
  "minor": "32",
  "gitVersion": "v1.32.3",
  "gitCommit": "32cc146f75aad04beaaa245a7157eb35063a9f99",
  "gitTreeState": "clean",
  "buildDate": "2025-03-11T19:52:21Z",
  "goVersion": "go1.23.6",
  "compiler": "gc",
  "platform": "linux/amd64"
}

# Generate a kubeconfig file suitable for authenticating as the admin user:
root@jumpbox:~/kubernetes-the-hard-way# kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --server=https://server.kubernetes.local:6443
Cluster "kubernetes-the-hard-way" set.

root@jumpbox:~/kubernetes-the-hard-way# kubectl config set-credentials admin \
  --client-certificate=admin.crt \
  --client-key=admin.key
User "admin" set.

root@jumpbox:~/kubernetes-the-hard-way# kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin
Context "kubernetes-the-hard-way" created.

root@jumpbox:~/kubernetes-the-hard-way# kubectl config use-context kubernetes-the-hard-way
Switched to context "kubernetes-the-hard-way".

# 위 명령어를 실행한 결과 kubectl 명령줄 도구에서 사용하는 기본 위치 ~/.kube/config에 kubectl 파일이 생성됩니다. 
# 이는 또한 구성을 지정하지 않고도 kubectl 명령어를 실행할 수 있음을 의미합니다.

# Check the version of the remote Kubernetes cluster:
root@jumpbox:~/kubernetes-the-hard-way# kubectl version
Client Version: v1.32.3
Kustomize Version: v5.5.0
Server Version: v1.32.3

# List the nodes in the remote Kubernetes cluster
root@jumpbox:~/kubernetes-the-hard-way# kubectl get nodes -v=6
I0110 14:01:47.436246    2780 loader.go:402] Config loaded from file:  /root/.kube/config
I0110 14:01:47.437132    2780 envvar.go:172] "Feature gate default state" feature="ClientsAllowCBOR" enabled=false
I0110 14:01:47.437157    2780 envvar.go:172] "Feature gate default state" feature="ClientsPreferCBOR" enabled=false
I0110 14:01:47.437165    2780 envvar.go:172] "Feature gate default state" feature="InformerResourceVersion" enabled=false
I0110 14:01:47.437308    2780 envvar.go:172] "Feature gate default state" feature="WatchListClient" enabled=false
I0110 14:01:47.437213    2780 cert_rotation.go:140] Starting client certificate rotation controller
I0110 14:01:47.461469    2780 round_trippers.go:560] GET https://server.kubernetes.local:6443/api?timeout=32s 200 OK in 23 milliseconds
I0110 14:01:47.464078    2780 round_trippers.go:560] GET https://server.kubernetes.local:6443/apis?timeout=32s 200 OK in 1 milliseconds
I0110 14:01:47.476697    2780 round_trippers.go:560] GET https://server.kubernetes.local:6443/api/v1/nodes?limit=500 200 OK in 2 milliseconds
NAME     STATUS   ROLES    AGE     VERSION
node-0   Ready    <none>   13m     v1.32.3
node-1   Ready    <none>   4m24s   v1.32.3


root@jumpbox:~/kubernetes-the-hard-way# cat /root/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZURENDQXpTZ0F3SUJBZ0lVSEZjTnZpeGtuRnlBRm15M053VWZETGtmaHhzd0RRWUpLb1pJaHZjTkFRRU4KQlFBd1FURUxNQWtHQTFVRUJoTUNWVk14RXpBUkJnTlZCQWdNQ2xkaGMyaHBibWQwYjI0eEVEQU9CZ05WQkFjTQpCMU5sWVhSMGJHVXhDekFKQmdOVkJBTU1Ba05CTUI0WERUSTJNREV4TURFeU1EZ3dOVm9YRFRNMk1ERXhNVEV5Ck1EZ3dOVm93UVRFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ01DbGRoYzJocGJtZDBiMjR4RURBT0JnTlYKQkFjTUIxTmxZWFIwYkdVeEN6QUpCZ05WQkFNTUFrTkJNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QQpNSUlDQ2dLQ0FnRUF2RVJWR3k3dWJFaU9KdmNnVnkyUm5VNjhMbXVGSVI4NlgxVnRSM1BOYWlEWHVaWVkrcDk4ClJ6dVI4YjQ2TXdLMXB3SXc2VnJJOWU3MmQxMmw0UXJNZHJUdXMxTWY1ZVpFMHE1N3pPWUR0Ry9VOUxHeER1djMKYms1bThjZ1p4SThMR0o0UW02bjZXUmRVMFhVbEhBcTdzNVdyam5YUnpoZmZRcG5wM2ZHTnBJM2tRM21UWUdydwpXbFk2VUQ0ejlZeDJxa1dHdGFkRndVVVdXbHhBOWlGRlpRYUt1OFZPbnhIZkZpckowSmxnaTBJaTYyYXhyd2lOCllOK3luR2NEZDUyelhONldDc3NJamQ2V3BGb1JzMW1kY29QdXFlRzhwSk1tRFpldTlSN0IxNENoQUl6b09wRWoKY0N4M2Q3NTdubnVnSEtZa0xQWlIxQXVIMERKYngvblB2d09WZXhQVEpVbnR1eTFmenVrMnpaSXlMRDBHa0tlVwpzRTg2a1JEdEVwcmw0Sk1yaUN2MTVCdU9RNDQrVXJzWm5GcENwa0hPbWREN1E0dzRaZXNpd3dQcFhudnhmNFNoCmNoenBxcHBTY1dyclFZbno0OHVpSkQ0OUVHUzJ0RDdBZ3dvVlJDSWhzeER0alhiOFBSRjZVSWtBUUJlSnhoT2EKcERUR0tiMzNCQThCT1BVcmwxbDJtc2ljYVBzcWNrM3ZYWUpaYkRZSCt0WkxaNnFZZ2gxZnhQUCtJaFhzMXplbgp5cndiV2tlNnk0UGwwR1JXWCtHcU5NL0NXUlh3YVUwbVZTRG9wZlJvb0VKdzg2bVJtVk85K2NGOFBZUkttaFhPCldXYUw2cXdZU0NmL252NjZSdTRjdmlVNVRvV2w2VnVnRzlZdm1LM2xycFhhS2g4VWdIRkd6MDhDQXdFQUFhTTgKTURvd0RBWURWUjBUQkFVd0F3RUIvekFMQmdOVkhROEVCQU1DQVFZd0hRWURWUjBPQkJZRUZHZG9pVUJucVdxYwpvL05FVnI5YUoxZVkvOVVBTUEwR0NTcUdTSWIzRFFFQkRRVUFBNElDQVFBdVJpM1hNWmRyclNwdTRQRTFTazdWCnBlU2k0dVBEVEpONlc3ckJYWUNEVVZWUjNDNjFWbUpYMVdoZndIeUZMV1grQkpFcmRjMHVHTWNERC9qMDdUYUMKSHIwMmNqaUpjSE9uSCt2ZVVHZXZXNmRaeWx2TXp1RStpZWxPTVlEN3pvcUs5NmwwWTF5U09URDdzWFBUWm9PcAo0S0dabDF5N3ZmSTJpdTJHcVdlUDhBQXB0Qm5JY0VLOW85R0ZQcmhhN25wTS9ROEloNHZCNHFMRi9EVENDRmExCjRMajliV3VndE1GQm1ld09ic3RaeHpLc1NVekFKdk1MV2tMYVNLdXpCWldlWXBWeW4vNEorSmRmeTBJcm1tOXYKaVBMN0o3SHZ2YzJOZFFpK01pcU00ZkJobk1KQ1JBMTBFem1iT1gxUlN6b0NVTnkycFhoYmdkbDFMK2hERm1yQQpvdmNNZ1huNzFJUlU3R0V4VG02UTRtR2ZEZHpuNllEQzQ2R3RBRjVZVlFoVFg1V0FjV1BIMktTNVBKeVJvYmRNCmxmWnhMdytIa1E2dnQzaVloWXFDRjNFU0kyN2hRajFQQXp5T2FqaVl5RGxjREVRRVArWGs3bEtDaXR0UWNMQ0sKZXlCcWJXM0RiZW1MZ0dVa2dWcWRMK2lzN3RVR3pGOGU0a1J4NmRLZkw2Ny9XK0c5b0FyZjExeDBMM1MwWEhybgpZUURNemtXQ1hyZnQ0TVJ6V2p5aWRDYUJ3VlRjSHdZejc0Z1ZUMUIzWlhFYmJCamZBS3RUVFVtcEV4anFuczlxCm1RMzkvV05ybE5ZN014WGJOYkVXSStOeisrS2JnenFFNkhnbUs3SGwxc21JME1PTlpiYTZEQ1NzRHgwb1ZPMjIKMlgvU1VJMk5tNStUd2VkRFVRcktFUT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://server.kubernetes.local:6443
  name: kubernetes-the-hard-way
contexts:
- context:
    cluster: kubernetes-the-hard-way
    user: admin
  name: kubernetes-the-hard-way
current-context: kubernetes-the-hard-way
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate: /root/kubernetes-the-hard-way/admin.crt
    client-key: /root/kubernetes-the-hard-way/admin.key
```