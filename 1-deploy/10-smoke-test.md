# 10. Smoke Test

## Data Encryption
```bash
# Create a generic secret
root@jumpbox:~/kubernetes-the-hard-way# kubectl create secret generic kubernetes-the-hard-way --from-literal="mykey=mydata"
secret/kubernetes-the-hard-way created

# 확인
root@jumpbox:~/kubernetes-the-hard-way# kubectl get secret kubernetes-the-hard-way
NAME                      TYPE     DATA   AGE
kubernetes-the-hard-way   Opaque   1      14s

root@jumpbox:~/kubernetes-the-hard-way# kubectl get secret kubernetes-the-hard-way -o yaml
apiVersion: v1
data:
  mykey: bXlkYXRh
kind: Secret
metadata:
  creationTimestamp: "2026-01-10T14:14:09Z"
  name: kubernetes-the-hard-way
  namespace: default
  resourceVersion: "5439"
  uid: 7d80f9b4-b106-494b-8088-35a56b08e222
type: Opaque

root@jumpbox:~/kubernetes-the-hard-way# kubectl get secret kubernetes-the-hard-way -o jsonpath='{.data.mykey}' ; echo
bXlkYXRh

root@jumpbox:~/kubernetes-the-hard-way# kubectl get secret kubernetes-the-hard-way -o jsonpath='{.data.mykey}' | base64 -d ; echo
mydata

# Print a hexdump of the kubernetes-the-hard-way secret stored in etcd
## etcdctl get … : etcd 내부 key 직접 조회, kubernetes API 우회(매우 강력한 접근)
## Secret 리소스의 etcd 실제 저장 경로: /registry/<resource>/<namespace>/<name> -> /registry/secrets/default/kubernetes-the-hard-way

# Kubernetes Secret이 etcd에 AES-CBC 방식으로 정상 암호화되어 저장되고 있음을 증명하는 출력
# k8s:enc	: Kubernetes 암호화 포맷
# aescbc	: 암호화 알고리즘 (AES-CBC)
# v1	    : encryption provider 버전
# key1	  : 사용된 encryption key 이름
# 이후 데이터는 암호화된 데이터

root@jumpbox:~/kubernetes-the-hard-way# ssh root@server \
    'etcdctl get /registry/secrets/default/kubernetes-the-hard-way | hexdump -C'
root@server's password: 
00000000  2f 72 65 67 69 73 74 72  79 2f 73 65 63 72 65 74  |/registry/secret| # etcd key 이름은 항상 평문 : 어떤 리소스인지 식별 가능
00000010  73 2f 64 65 66 61 75 6c  74 2f 6b 75 62 65 72 6e  |s/default/kubern|
00000020  65 74 65 73 2d 74 68 65  2d 68 61 72 64 2d 77 61  |etes-the-hard-wa|
00000030  79 0a 6b 38 73 3a 65 6e  63 3a 61 65 73 63 62 63  |y.k8s:enc:aescbc|
00000040  3a 76 31 3a 6b 65 79 31  3a d2 1c 01 d7 80 7a 8b  |:v1:key1:.....z.|
00000050  ed a9 90 e5 9a 31 e2 c2  f4 c0 3e c4 08 5d af 4e  |.....1....>..].N|
00000060  2b b3 2c 02 26 56 e0 e3  b2 54 87 38 3d d0 49 61  |+.,.&V...T.8=.Ia|
00000070  72 9c 2c a4 8c 98 d3 da  0d 34 2b c7 13 18 b8 26  |r.,......4+....&|
00000080  ca 04 44 1d 4e d5 d5 8d  78 85 6f 20 bb 65 8d 19  |..D.N...x.o .e..|
00000090  ee 57 10 3d 07 fa 41 23  b6 d3 97 98 f0 64 ec e8  |.W.=..A#.....d..|
000000a0  0c 1f 68 a0 a8 ef d6 b3  86 7b df 41 23 09 4e f3  |..h......{.A#.N.|
000000b0  6c 4a c9 9b 21 76 67 49  5c 9b 67 6a ac 63 e1 73  |lJ..!vgI\.gj.c.s|
000000c0  fe 82 f3 f5 10 88 5b 89  06 66 2e 7a d3 b3 c8 7c  |......[..f.z...||
000000d0  d4 7b 69 d7 1d d9 a4 05  45 45 26 49 6a ec ad 6c  |.{i.....EE&Ij..l|
000000e0  74 a5 45 6a 9f 76 f3 f9  0d 55 21 84 a5 61 df da  |t.Ej.v...U!..a..|
000000f0  73 98 41 f9 38 df 36 99  67 09 2f 7b 3f 54 92 b3  |s.A.8.6.g./{?T..|
00000100  da 71 79 ec d9 58 6f 83  37 24 b5 c5 6e 8f 64 c4  |.qy..Xo.7$..n.d.|
00000110  bf 40 94 50 3d d4 51 a6  8d 8e 27 f0 80 1e 4c 9f  |.@.P=.Q...'...L.|
00000120  a8 ba 20 6f 55 e6 2d 2c  e6 71 23 58 83 a2 fe c3  |.. oU.-,.q#X....|
00000130  db 1e 1a 1f f1 7a d5 bd  43 a4 4d 94 98 8f b5 c8  |.....z..C.M.....|
00000140  64 4c de bf cc 04 63 74  8e 93 e1 73 fc 65 88 d0  |dL....ct...s.e..|
00000150  e1 24 f8 4c 1f d9 24 7c  3a 0a                    |.$.L..$|:.|
0000015a
```

## Deployments , Port Forwarding , Log, Exec, Service(NodePort)

### Deployments
```bash
# Create a deployment for the nginx web server:
root@jumpbox:~/kubernetes-the-hard-way# kubectl get pod
No resources found in default namespace.

root@jumpbox:~/kubernetes-the-hard-way# kubectl create deployment nginx --image=nginx:latest
deployment.apps/nginx created

root@jumpbox:~/kubernetes-the-hard-way# kubectl scale deployment nginx --replicas=2
deployment.apps/nginx scaled

root@jumpbox:~/kubernetes-the-hard-way# kubectl get pod -owide
NAME                     READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
nginx-54c98b4f84-554rr   1/1     Running   0          19s   10.200.0.2   node-0   <none>           <none>
nginx-54c98b4f84-p92fd   1/1     Running   0          11s   10.200.1.2   node-1   <none>           <none>


root@jumpbox:~/kubernetes-the-hard-way# ssh node-0 crictl ps
time="2026-01-10T14:18:18Z" level=warning msg="Config \"/etc/crictl.yaml\" does not exist, trying next: \"/usr/local/bin/crictl.yaml\""
time="2026-01-10T14:18:18Z" level=warning msg="runtime connect using default endpoints: [unix:///run/containerd/containerd.sock unix:///run/crio/crio.sock unix:///var/run/cri-dockerd.sock]. As the default settings are now deprecated, you should set the endpoint instead."
time="2026-01-10T14:18:18Z" level=warning msg="Image connect using default endpoints: [unix:///run/containerd/containerd.sock unix:///run/crio/crio.sock unix:///var/run/cri-dockerd.sock]. As the default settings are now deprecated, you should set the endpoint instead."
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD                      NAMESPACE
8c836a704b7ba       2e97da2b9cb35       27 seconds ago      Running             nginx               0                   97559162e52ed       nginx-54c98b4f84-554rr   default


root@jumpbox:~/kubernetes-the-hard-way# ssh node-1 crictl ps
time="2026-01-10T14:18:56Z" level=warning msg="Config \"/etc/crictl.yaml\" does not exist, trying next: \"/usr/local/bin/crictl.yaml\""
time="2026-01-10T14:18:56Z" level=warning msg="runtime connect using default endpoints: [unix:///run/containerd/containerd.sock unix:///run/crio/crio.sock unix:///var/run/cri-dockerd.sock]. As the default settings are now deprecated, you should set the endpoint instead."
time="2026-01-10T14:18:56Z" level=warning msg="Image connect using default endpoints: [unix:///run/containerd/containerd.sock unix:///run/crio/crio.sock unix:///var/run/cri-dockerd.sock]. As the default settings are now deprecated, you should set the endpoint instead."
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD                      NAMESPACE
00354e7b921e2       2e97da2b9cb35       57 seconds ago      Running             nginx               0                   71075a3afbd6b       nginx-54c98b4f84-p92fd   default


root@jumpbox:~/kubernetes-the-hard-way# ssh node-0 pstree -ap
systemd,1
  |-agetty,755 -o -- \\u --noreset --noclear - linux
  |-agetty,756 -o -- \\u --noreset --noclear --keep-baud 115200,57600,38400,9600 - vt220
  |-amazon-ssm-agen,1378
  |   |-ssm-agent-worke,1472
  |   |   |-{ssm-agent-worke},1473
  |   |   |-{ssm-agent-worke},1474
  |   |   |-{ssm-agent-worke},1475
  |   |   |-{ssm-agent-worke},1476
  |   |   |-{ssm-agent-worke},1477
  |   |   |-{ssm-agent-worke},1478
  |   |   |-{ssm-agent-worke},1479
  |   |   |-{ssm-agent-worke},1480
  |   |   |-{ssm-agent-worke},1483
  |   |   `-{ssm-agent-worke},1491
  |   |-{amazon-ssm-agen},1379
  |   |-{amazon-ssm-agen},1380
  |   |-{amazon-ssm-agen},1381
  |   |-{amazon-ssm-agen},1382
  |   |-{amazon-ssm-agen},1384
  |   |-{amazon-ssm-agen},1416
  |   |-{amazon-ssm-agen},1417
  |   `-{amazon-ssm-agen},2313
  |-containerd,2753
  |   |-{containerd},2764
  |   |-{containerd},2766
  |   |-{containerd},2767
  |   |-{containerd},2768
  |   |-{containerd},2770
  |   |-{containerd},2798
  |   |-{containerd},3626
  |   `-{containerd},3704
  |-containerd-shim,3666 -namespace k8s.io -id 97559162e52edec2b334f1f4d0d12bf09cd08bb694df065906a337e79f8a1eeb -address/ru
  |   |-nginx,3719
  |   |   |-nginx,3754
  |   |   `-nginx,3755
  |   |-pause,3689
  |   |-{containerd-shim},3667
  |   |-{containerd-shim},3668
  |   |-{containerd-shim},3669
  |   |-{containerd-shim},3670
  |   |-{containerd-shim},3671
  |   |-{containerd-shim},3672
  |   |-{containerd-shim},3673
  |   |-{containerd-shim},3674
  |   |-{containerd-shim},3675
  |   |-{containerd-shim},3703
  |   `-{containerd-shim},3764
  |-dbus-daemon,735 --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
  |-kube-proxy,2751 --config=/var/lib/kube-proxy/kube-proxy-config.yaml
  |   |-{kube-proxy},2755
  |   |-{kube-proxy},2756
  |   |-{kube-proxy},2757
  |   `-{kube-proxy},2759
  |-kubelet,3265 --config=/var/lib/kubelet/kubelet-config.yaml --kubeconfig=/var/lib/kubelet/kubeconfig --v=2
  |   |-{kubelet},3266
  |   |-{kubelet},3267
  |   |-{kubelet},3268
  |   |-{kubelet},3269
  |   |-{kubelet},3271
  |   |-{kubelet},3274
  |   |-{kubelet},3275
  |   |-{kubelet},3290
  |   `-{kubelet},3300
  |-polkitd,794 --no-debug --log-level=notice
  |   |-{polkitd},799
  |   |-{polkitd},800
  |   `-{polkitd},801
  |-sshd,1291
  |   `-sshd-session,3805
  |       `-sshd-session,3826
  |           `-pstree,3827 -ap
  |-systemd,3811 --user
  |   `-(sd-pam),3813
  |-systemd-journal,307
  |-systemd-logind,743
  |-systemd-network,674
  |-systemd-resolve,358
  |-systemd-timesyn,359
  |   `-{systemd-timesyn},369
  |-systemd-udevd,368
  `-unattended-upgr,782 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal


root@jumpbox:~/kubernetes-the-hard-way# ssh node-1 pstree -ap
systemd,1
  |-agetty,761 -o -- \\u --noreset --noclear - linux
  |-agetty,763 -o -- \\u --noreset --noclear --keep-baud 115200,57600,38400,9600 - vt220
  |-amazon-ssm-agen,1377
  |   |-ssm-agent-worke,1471
  |   |   |-{ssm-agent-worke},1472
  |   |   |-{ssm-agent-worke},1473
  |   |   |-{ssm-agent-worke},1474
  |   |   |-{ssm-agent-worke},1475
  |   |   |-{ssm-agent-worke},1476
  |   |   |-{ssm-agent-worke},1477
  |   |   |-{ssm-agent-worke},1478
  |   |   |-{ssm-agent-worke},1479
  |   |   |-{ssm-agent-worke},1480
  |   |   `-{ssm-agent-worke},1481
  |   |-{amazon-ssm-agen},1378
  |   |-{amazon-ssm-agen},1379
  |   |-{amazon-ssm-agen},1380
  |   |-{amazon-ssm-agen},1381
  |   |-{amazon-ssm-agen},1383
  |   |-{amazon-ssm-agen},1448
  |   |-{amazon-ssm-agen},1449
  |   `-{amazon-ssm-agen},1992
  |-containerd,2762
  |   |-{containerd},2770
  |   |-{containerd},2771
  |   |-{containerd},2772
  |   |-{containerd},2773
  |   |-{containerd},2780
  |   |-{containerd},2969
  |   |-{containerd},3202
  |   |-{containerd},3281
  |   `-{containerd},3284
  |-containerd-shim,3241 -namespace k8s.io -id 71075a3afbd6b302dfb93d9201b14c2aa3bf6707388d6f4e2d9bb576df0fb207 -address/ru
  |   |-nginx,3298
  |   |   |-nginx,3332
  |   |   `-nginx,3333
  |   |-pause,3267
  |   |-{containerd-shim},3242
  |   |-{containerd-shim},3243
  |   |-{containerd-shim},3244
  |   |-{containerd-shim},3245
  |   |-{containerd-shim},3246
  |   |-{containerd-shim},3247
  |   |-{containerd-shim},3248
  |   |-{containerd-shim},3249
  |   |-{containerd-shim},3250
  |   |-{containerd-shim},3251
  |   `-{containerd-shim},3335
  |-dbus-daemon,735 --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
  |-kube-proxy,2759 --config=/var/lib/kube-proxy/kube-proxy-config.yaml
  |   |-{kube-proxy},2763
  |   |-{kube-proxy},2764
  |   |-{kube-proxy},2765
  |   |-{kube-proxy},2768
  |   `-{kube-proxy},2831
  |-kubelet,2766 --config=/var/lib/kubelet/kubelet-config.yaml --kubeconfig=/var/lib/kubelet/kubeconfig --v=2
  |   |-{kubelet},2774
  |   |-{kubelet},2775
  |   |-{kubelet},2776
  |   |-{kubelet},2777
  |   |-{kubelet},2779
  |   |-{kubelet},2791
  |   |-{kubelet},2795
  |   |-{kubelet},2801
  |   |-{kubelet},2804
  |   |-{kubelet},2807
  |   `-{kubelet},2812
  |-polkitd,796 --no-debug --log-level=notice
  |   |-{polkitd},800
  |   |-{polkitd},801
  |   `-{polkitd},802
  |-sshd,1290
  |   `-sshd-session,3382
  |       `-sshd-session,3403
  |           `-pstree,3404 -ap
  |-systemd,3388 --user
  |   `-(sd-pam),3390
  |-systemd-journal,307
  |-systemd-logind,742
  |-systemd-network,674
  |-systemd-resolve,358
  |-systemd-timesyn,359
  |   |-{systemd-timesyn},370
  |   `-{systemd-timesyn},492
  |-systemd-udevd,368
  `-unattended-upgr,791 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal


root@jumpbox:~/kubernetes-the-hard-way# ssh node-0 brctl show
bridge name     bridge id               STP enabled     interfaces
cni0            8000.96fe03b893a7       no              veth05676363

root@jumpbox:~/kubernetes-the-hard-way# ssh node-1 brctl show
bridge name     bridge id               STP enabled     interfaces
cni0            8000.daab517ccb79       no              veth53358c14



# 파드 별 veth 인터페이스 생성 확인
root@jumpbox:~/kubernetes-the-hard-way# ssh node-0 ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP group default qlen 1000
    link/ether 02:8e:7c:9a:5d:49 brd ff:ff:ff:ff:ff:ff
    altname enp0s5
    altname enx028e7c9a5d49
    inet 172.31.8.112/20 metric 100 brd 172.31.15.255 scope global dynamic ens5
       valid_lft 3481sec preferred_lft 3481sec
    inet6 fe80::8e:7cff:fe9a:5d49/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
3: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 96:fe:03:b8:93:a7 brd ff:ff:ff:ff:ff:ff
    inet 10.200.0.1/24 brd 10.200.0.255 scope global cni0
       valid_lft forever preferred_lft forever
    inet6 fe80::94fe:3ff:feb8:93a7/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
4: veth05676363@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cni0 state UP group default qlen 1000
    link/ether e2:36:3f:8c:25:bd brd ff:ff:ff:ff:ff:ff link-netns cni-649028bf-5f52-ba31-229e-13bcf269d36d
    inet6 fe80::e036:3fff:fe8c:25bd/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever


root@jumpbox:~/kubernetes-the-hard-way# ssh node-1 ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP group default qlen 1000
    link/ether 02:59:31:bd:1f:11 brd ff:ff:ff:ff:ff:ff
    altname enp0s5
    altname enx025931bd1f11
    inet 172.31.15.209/20 metric 100 brd 172.31.15.255 scope global dynamic ens5
       valid_lft 3453sec preferred_lft 3453sec
    inet6 fe80::59:31ff:febd:1f11/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
3: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether da:ab:51:7c:cb:79 brd ff:ff:ff:ff:ff:ff
    inet 10.200.1.1/24 brd 10.200.1.255 scope global cni0
       valid_lft forever preferred_lft forever
    inet6 fe80::d8ab:51ff:fe7c:cb79/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
4: veth53358c14@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cni0 state UP group default qlen 1000
    link/ether 82:23:de:28:e8:1f brd ff:ff:ff:ff:ff:ff link-netns cni-834fff8a-34fb-a069-aa4d-ab3441082a37
    inet6 fe80::8023:deff:fe28:e81f/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever



# server 노드에서 파드 IP로 호출 확인
root@jumpbox:~/kubernetes-the-hard-way# ssh server curl -s 10.200.1.2 | grep title
root@server's password: 
<title>Welcome to nginx!</title>

root@jumpbox:~/kubernetes-the-hard-way# ssh server curl -s 10.200.0.2 | grep title
root@server's password: 
<title>Welcome to nginx!</title>
```

### Port Forwarding
```bash
# Retrieve the full name of the nginx pod:
root@jumpbox:~/kubernetes-the-hard-way# POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
root@jumpbox:~/kubernetes-the-hard-way# echo $POD_NAME
nginx-54c98b4f84-554rr


# Forward port 8080 on your local machine to port 80 of the nginx pod:
root@jumpbox:~# kubectl port-forward $POD_NAME 8080:80 &
ps -ef | grep kubectl
[1] 3150
root        3150    3078  0 14:29 pts/4    00:00:00 kubectl port-forward nginx-54c98b4f84-554rr 8080:80
root        3152    3078  0 14:29 pts/4    00:00:00 grep kubectl
root@jumpbox:~# Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080


# In a new terminal make an HTTP request using the forwarding address:
root@jumpbox:~# curl --head http://127.0.0.1:8080
HTTP/1.1 200 OK
Server: nginx/1.29.4
Date: Sat, 10 Jan 2026 14:29:46 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 09 Dec 2025 18:28:10 GMT
Connection: keep-alive
ETag: "69386a3a-267"
Accept-Ranges: bytes


root@jumpbox:~# kubectl port-forward $POD_NAME 8080:80 &
ps -ef | grep kubectl
[1] 3150
root        3150    3078  0 14:29 pts/4    00:00:00 kubectl port-forward nginx-54c98b4f84-554rr 8080:80
root        3152    3078  0 14:29 pts/4    00:00:00 grep kubectl
root@jumpbox:~# Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080 # 👀
Handling connection for 8080 # 👀
Handling connection for 8080 # 👀
```

### Log
```bash
# Print the nginx pod logs
root@jumpbox:~# kubectl logs $POD_NAME
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/01/10 14:17:51 [notice] 1#1: using the "epoll" event method
2026/01/10 14:17:51 [notice] 1#1: nginx/1.29.4
2026/01/10 14:17:51 [notice] 1#1: built by gcc 14.2.0 (Debian 14.2.0-19) 
2026/01/10 14:17:51 [notice] 1#1: OS: Linux 6.12.48+deb13-cloud-amd64
2026/01/10 14:17:51 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2026/01/10 14:17:51 [notice] 1#1: start worker processes
2026/01/10 14:17:51 [notice] 1#1: start worker process 29
2026/01/10 14:17:51 [notice] 1#1: start worker process 30
127.0.0.1 - - [10/Jan/2026:14:29:35 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:29:38 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:29:39 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:29:46 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"

root@jumpbox:~# curl --head http://127.0.0.1:8080
HTTP/1.1 200 OK
Server: nginx/1.29.4
Date: Sat, 10 Jan 2026 14:32:14 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 09 Dec 2025 18:28:10 GMT
Connection: keep-alive
ETag: "69386a3a-267"
Accept-Ranges: bytes


root@jumpbox:~# kubectl logs $POD_NAME
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/01/10 14:17:51 [notice] 1#1: using the "epoll" event method
2026/01/10 14:17:51 [notice] 1#1: nginx/1.29.4
2026/01/10 14:17:51 [notice] 1#1: built by gcc 14.2.0 (Debian 14.2.0-19) 
2026/01/10 14:17:51 [notice] 1#1: OS: Linux 6.12.48+deb13-cloud-amd64
2026/01/10 14:17:51 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2026/01/10 14:17:51 [notice] 1#1: start worker processes
2026/01/10 14:17:51 [notice] 1#1: start worker process 29
2026/01/10 14:17:51 [notice] 1#1: start worker process 30
127.0.0.1 - - [10/Jan/2026:14:29:35 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:29:38 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:29:39 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:29:46 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-"
127.0.0.1 - - [10/Jan/2026:14:32:08 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.14.1" "-" # 👀


# 확인 후 port-forward Killed
root@jumpbox:~# kill -9 $(pgrep kubectl)
root@jumpbox:~# 
[1]+  Killed                  kubectl port-forward $POD_NAME 8080:80
```

### Exec
```bash
# Print the nginx version by executing the nginx -v command in the nginx container:
root@jumpbox:~# kubectl exec -ti $POD_NAME -- nginx -v
nginx version: nginx/1.29.4
```

### Service

```bash
# Expose the nginx deployment using a NodePort service:
root@jumpbox:~# kubectl expose deployment nginx --port=80 --target-port=80 --type=NodePort
service/nginx exposed


# 확인
root@jumpbox:~# kubectl get service,ep nginx
NAME            TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
service/nginx   NodePort   10.32.0.175   <none>        80:30159/TCP   7s

NAME              ENDPOINTS                     AGE
endpoints/nginx   10.200.0.2:80,10.200.1.2:80   7s


# Retrieve the node port assigned to the nginx service:
root@jumpbox:~# NODE_PORT=$(kubectl get svc nginx --output=jsonpath='{range .spec.ports[0]}{.nodePort}')
root@jumpbox:~# echo $NODE_PORT
30159


# Make an HTTP request using the IP address and the nginx node port:
root@jumpbox:~# curl -s -I http://node-0:${NODE_PORT}
HTTP/1.1 200 OK
Server: nginx/1.29.4
Date: Sat, 10 Jan 2026 14:38:24 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 09 Dec 2025 18:28:10 GMT
Connection: keep-alive
ETag: "69386a3a-267"
Accept-Ranges: bytes

root@jumpbox:~# curl -s -I http://node-1:${NODE_PORT}
HTTP/1.1 200 OK
Server: nginx/1.29.4
Date: Sat, 10 Jan 2026 14:38:30 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 09 Dec 2025 18:28:10 GMT
Connection: keep-alive
ETag: "69386a3a-267"
Accept-Ranges: bytes
```

## 실습 완료 후 서버 삭제
```bash
❯ terraform destroy
```