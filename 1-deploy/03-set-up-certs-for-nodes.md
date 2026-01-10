# k8s 노드 용도의 인증서 초기 설정 진행

IP, Subnet 설정을 사전에 저장해둔다.

```bash
# Machine Database (서버 속성 저장 파일) : IPV4_ADDRESS FQDN HOSTNAME POD_SUBNET
## 참고) server(controlplane)는 kubelet 동작하지 않아서, 파드 네트워크 대역 설정 필요 없음
root@jumpbox:~/kubernetes-the-hard-way# cat <<EOF > machines.txt
172.31.5.196 server.kubernetes.local server
172.31.8.112 node-0.kubernetes.local node-0 10.200.0.0/24
172.31.15.209 node-1.kubernetes.local node-1 10.200.1.0/24
EOF

root@jumpbox:~/kubernetes-the-hard-way# cat machines.txt
172.31.5.196 server.kubernetes.local server
172.31.8.112 node-0.kubernetes.local node-0 10.200.0.0/24
172.31.15.209 node-1.kubernetes.local node-1 10.200.1.0/24

root@jumpbox:~/kubernetes-the-hard-way# while read IP FQDN HOST SUBNET; do
  echo "${IP} ${FQDN} ${HOST} ${SUBNET}"
done < machines.txt
172.31.5.196 server.kubernetes.local server 
172.31.8.112 node-0.kubernetes.local node-0 10.200.0.0/24
172.31.15.209 node-1.kubernetes.local node-1 10.200.1.0/24
```

## CA, TLS 인증서 생성

### ca.conf 확인

```bash
root@jumpbox:~/kubernetes-the-hard-way# cat ca.conf
[req]
distinguished_name = req_distinguished_name
prompt             = no
x509_extensions    = ca_x509_extensions

[ca_x509_extensions]
basicConstraints = CA:TRUE
keyUsage         = cRLSign, keyCertSign

[req_distinguished_name]
C   = US
ST  = Washington
L   = Seattle
CN  = CA

[admin]
distinguished_name = admin_distinguished_name
prompt             = no
req_extensions     = default_req_extensions

[admin_distinguished_name]
CN = admin
O  = system:masters

# Service Accounts
#
# The Kubernetes Controller Manager leverages a key pair to generate
# and sign service account tokens as described in the
# [managing service accounts](https://kubernetes.io/docs/admin/service-accounts-admin/)
# documentation.

[service-accounts]
distinguished_name = service-accounts_distinguished_name
prompt             = no
req_extensions     = default_req_extensions

[service-accounts_distinguished_name]
CN = service-accounts

# Worker Nodes
#
# Kubernetes uses a [special-purpose authorization mode](https://kubernetes.io/docs/admin/authorization/node/)
# called Node Authorizer, that specifically authorizes API requests made
# by [Kubelets](https://kubernetes.io/docs/concepts/overview/components/#kubelet).
# In order to be authorized by the Node Authorizer, Kubelets must use a credential
# that identifies them as being in the `system:nodes` group, with a username
# of `system:node:<nodeName>`.

[node-0]
distinguished_name = node-0_distinguished_name
prompt             = no
req_extensions     = node-0_req_extensions

[node-0_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Node-0 Certificate"
subjectAltName       = DNS:node-0, IP:127.0.0.1
subjectKeyIdentifier = hash

[node-0_distinguished_name]
CN = system:node:node-0
O  = system:nodes
C  = US
ST = Washington
L  = Seattle

[node-1]
distinguished_name = node-1_distinguished_name
prompt             = no
req_extensions     = node-1_req_extensions

[node-1_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Node-1 Certificate"
subjectAltName       = DNS:node-1, IP:127.0.0.1
subjectKeyIdentifier = hash

[node-1_distinguished_name]
CN = system:node:node-1
O  = system:nodes
C  = US
ST = Washington
L  = Seattle


# Kube Proxy Section
[kube-proxy]
distinguished_name = kube-proxy_distinguished_name
prompt             = no
req_extensions     = kube-proxy_req_extensions

[kube-proxy_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Kube Proxy Certificate"
subjectAltName       = DNS:kube-proxy, IP:127.0.0.1
subjectKeyIdentifier = hash

[kube-proxy_distinguished_name]
CN = system:kube-proxy
O  = system:node-proxier
C  = US
ST = Washington
L  = Seattle


# Controller Manager
[kube-controller-manager]
distinguished_name = kube-controller-manager_distinguished_name
prompt             = no
req_extensions     = kube-controller-manager_req_extensions

[kube-controller-manager_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Kube Controller Manager Certificate"
subjectAltName       = DNS:kube-controller-manager, IP:127.0.0.1
subjectKeyIdentifier = hash

[kube-controller-manager_distinguished_name]
CN = system:kube-controller-manager
O  = system:kube-controller-manager
C  = US
ST = Washington
L  = Seattle


# Scheduler
[kube-scheduler]
distinguished_name = kube-scheduler_distinguished_name
prompt             = no
req_extensions     = kube-scheduler_req_extensions

[kube-scheduler_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Kube Scheduler Certificate"
subjectAltName       = DNS:kube-scheduler, IP:127.0.0.1
subjectKeyIdentifier = hash

[kube-scheduler_distinguished_name]
CN = system:kube-scheduler
O  = system:system:kube-scheduler
C  = US
ST = Washington
L  = Seattle


# API Server
#
# The Kubernetes API server is automatically assigned the `kubernetes`
# internal dns name, which will be linked to the first IP address (`10.32.0.1`)
# from the address range (`10.32.0.0/24`) reserved for internal cluster
# services.

[kube-api-server]
distinguished_name = kube-api-server_distinguished_name
prompt             = no
req_extensions     = kube-api-server_req_extensions

[kube-api-server_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth, serverAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client, server
nsComment            = "Kube API Server Certificate"
subjectAltName       = @kube-api-server_alt_names
subjectKeyIdentifier = hash

[kube-api-server_alt_names]
IP.0  = 127.0.0.1
IP.1  = 10.32.0.1
DNS.0 = kubernetes
DNS.1 = kubernetes.default
DNS.2 = kubernetes.default.svc
DNS.3 = kubernetes.default.svc.cluster
DNS.4 = kubernetes.svc.cluster.local
DNS.5 = server.kubernetes.local
DNS.6 = api-server.kubernetes.local

[kube-api-server_distinguished_name]
CN = kubernetes
C  = US
ST = Washington
L  = Seattle


[default_req_extensions]
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Admin Client Certificate"
subjectKeyIdentifier = hash
```


### Certificate Authority 생성

```bash
# Generate the CA configuration file, certificate, and private key

# Root CA 개인키 생성 : ca.key
root@jumpbox:~/kubernetes-the-hard-way# openssl genrsa -out ca.key 4096
root@jumpbox:~/kubernetes-the-hard-way# ls -l ca.key 
-rw------- 1 root root 3272 Jan 10 12:07 ca.key

root@jumpbox:~/kubernetes-the-hard-way# cat ca.key
-----BEGIN PRIVATE KEY-----
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
P+L9jpMS9hk/6kIshoFd0bXw7z9CdA==
-----END PRIVATE KEY-----

# 개인키 구조 확인
root@jumpbox:~/kubernetes-the-hard-way# openssl rsa -in ca.key -text -noout
Private-Key: (4096 bit, 2 primes)
modulus:
    00:bc:44:55:1b:2e:ee:6c:48:8e:26:f7:20:57:2d:
    91:9d:4e:bc:2e:6b:85:21:1f:3a:5f:55:6d:47:73:
    cd:6a:20:d7:b9:96:18:fa:9f:7c:47:3b:91:f1:be:
    3a:33:02:b5:a7:02:30:e9:5a:c8:f5:ee:f6:77:5d:
    a5:e1:0a:cc:76:b4:ee:b3:53:1f:e5:e6:44:d2:ae:
    7b:cc:e6:03:b4:6f:d4:f4:b1:b1:0e:eb:f7:6e:4e:
    66:f1:c8:19:c4:8f:0b:18:9e:10:9b:a9:fa:59:17:
    54:d1:75:25:1c:0a:bb:b3:95:ab:8e:75:d1:ce:17:
    df:42:99:e9:dd:f1:8d:a4:8d:e4:43:79:93:60:6a:
    f0:5a:56:3a:50:3e:33:f5:8c:76:aa:45:86:b5:a7:
    45:c1:45:16:5a:5c:40:f6:21:45:65:06:8a:bb:c5:
    4e:9f:11:df:16:2a:c9:d0:99:60:8b:42:22:eb:66:
    b1:af:08:8d:60:df:b2:9c:67:03:77:9d:b3:5c:de:
    96:0a:cb:08:8d:de:96:a4:5a:11:b3:59:9d:72:83:
    ee:a9:e1:bc:a4:93:26:0d:97:ae:f5:1e:c1:d7:80:
    a1:00:8c:e8:3a:91:23:70:2c:77:77:be:7b:9e:7b:
    a0:1c:a6:24:2c:f6:51:d4:0b:87:d0:32:5b:c7:f9:
    cf:bf:03:95:7b:13:d3:25:49:ed:bb:2d:5f:ce:e9:
    36:cd:92:32:2c:3d:06:90:a7:96:b0:4f:3a:91:10:
    ed:12:9a:e5:e0:93:2b:88:2b:f5:e4:1b:8e:43:8e:
    3e:52:bb:19:9c:5a:42:a6:41:ce:99:d0:fb:43:8c:
    38:65:eb:22:c3:03:e9:5e:7b:f1:7f:84:a1:72:1c:
    e9:aa:9a:52:71:6a:eb:41:89:f3:e3:cb:a2:24:3e:
    3d:10:64:b6:b4:3e:c0:83:0a:15:44:22:21:b3:10:
    ed:8d:76:fc:3d:11:7a:50:89:00:40:17:89:c6:13:
    9a:a4:34:c6:29:bd:f7:04:0f:01:38:f5:2b:97:59:
    76:9a:c8:9c:68:fb:2a:72:4d:ef:5d:82:59:6c:36:
    07:fa:d6:4b:67:aa:98:82:1d:5f:c4:f3:fe:22:15:
    ec:d7:37:a7:ca:bc:1b:5a:47:ba:cb:83:e5:d0:64:
    56:5f:e1:aa:34:cf:c2:59:15:f0:69:4d:26:55:20:
    e8:a5:f4:68:a0:42:70:f3:a9:91:99:53:bd:f9:c1:
    7c:3d:84:4a:9a:15:ce:59:66:8b:ea:ac:18:48:27:
    ff:9e:fe:ba:46:ee:1c:be:25:39:4e:85:a5:e9:5b:
    a0:1b:d6:2f:98:ad:e5:ae:95:da:2a:1f:14:80:71:
    46:cf:4f
publicExponent: 65537 (0x10001)
privateExponent:
    0b:25:de:06:e9:5f:d8:d8:45:ad:42:53:8f:40:a0:
    2f:63:c0:24:dc:dd:04:8f:12:d2:73:a9:30:37:f2:
    8b:e6:e7:49:e7:fc:bb:ff:c1:9e:28:da:da:d3:b1:
    77:df:cb:33:2e:75:5d:a6:b0:8b:a4:db:6c:9f:5b:
    a3:d8:68:84:5c:46:5e:26:a7:ec:37:17:10:2f:f6:
    1e:0b:3e:0b:95:d6:52:fe:f5:45:b5:97:45:d8:2d:
    4f:02:7d:9e:c9:51:96:38:40:87:81:d3:29:d4:b0:
    83:0e:a0:0f:3f:06:1f:a6:2c:83:17:b0:40:0c:8d:
    d3:25:c6:01:61:bc:f4:bc:d4:d8:0c:aa:3b:65:59:
    ac:ca:64:fd:92:11:5a:e8:37:06:9c:c3:53:47:aa:
    61:12:b4:36:24:36:fc:86:ba:7d:e1:9b:49:6f:1a:
    2e:b5:22:33:ef:d3:5a:1f:70:3b:64:19:29:3d:ea:
    d0:e5:d2:be:a5:15:b0:73:db:c8:08:cb:31:79:44:
    ad:32:ef:38:bc:b0:c8:33:ef:cf:0c:ee:be:74:82:
    d2:05:b9:e3:e2:35:63:4c:a8:b6:d4:5c:14:ba:05:
    ce:95:de:bd:1e:67:03:77:69:43:95:40:96:01:2a:
    ae:9c:ef:e6:1c:57:d0:14:8c:0a:e4:a5:d1:50:eb:
    8a:2c:02:61:b5:c6:8f:ef:f7:c3:d9:02:1c:d4:84:
    32:42:4e:4b:79:87:8a:21:4b:8b:78:1b:7d:45:f4:
    eb:bb:64:92:90:d4:b7:ef:3e:17:4a:f8:89:1e:c5:
    90:dc:3c:6d:42:b2:a1:ae:4f:84:5a:9e:95:ff:14:
    74:2d:21:c9:53:43:74:85:eb:6e:be:1d:39:de:41:
    53:04:80:78:05:81:39:b9:dd:89:52:7c:ed:42:12:
    a3:c0:74:47:a2:14:1e:06:5e:de:42:dc:02:71:c8:
    76:6e:79:5c:1a:8b:53:78:61:02:ad:27:8d:26:ef:
    07:58:09:43:e4:b4:d4:65:5f:7f:42:8f:83:2d:63:
    51:f3:fc:f2:69:65:42:6f:66:97:50:66:d2:10:8b:
    bb:8f:94:4b:cc:18:0e:93:2f:67:b3:00:ae:50:8c:
    08:6d:49:cd:95:7d:cf:81:77:d2:36:00:67:de:b8:
    86:fd:4e:d8:9d:d8:65:87:5e:7e:18:ef:c8:8c:f8:
    f8:53:74:63:69:52:c7:fb:c8:24:32:7d:3d:9c:1a:
    f0:b9:50:b4:2c:85:f7:d3:da:57:bd:d4:f2:0a:1c:
    46:bf:f6:cd:51:28:57:3d:d2:84:44:dc:b2:3e:38:
    f1:05:4d:4a:0a:a6:54:17:ef:3b:16:2d:45:9d:66:
    ee:41
prime1:
    00:df:d9:b3:64:0e:34:b5:b1:5d:03:e2:17:3e:61:
    3f:a9:d1:89:63:c2:03:6e:e3:b0:ff:00:a7:68:e2:
    86:11:6d:ad:15:dc:85:8c:76:3f:f7:ef:e8:fb:09:
    af:3d:bd:f2:d3:83:23:30:71:47:e6:c1:28:57:87:
    08:83:83:f1:65:53:4d:fe:9e:c5:15:89:65:3d:d8:
    e8:a6:69:3e:e9:43:1d:f9:d3:1e:3c:95:aa:fc:15:
    b3:a7:81:fd:4b:15:49:83:bc:dd:40:58:a5:8f:60:
    4c:15:ca:e4:23:19:b8:e8:62:36:43:7e:d8:19:72:
    aa:f6:6a:d8:b4:e2:0b:3a:2c:5f:0e:bb:22:22:23:
    38:31:27:d7:da:93:ca:ac:2d:fe:1b:24:2a:22:46:
    7b:c7:56:6b:ca:29:95:52:14:58:47:df:a3:16:4a:
    a4:1c:00:86:ee:1d:0d:b6:c2:29:75:40:66:dd:a8:
    9e:2b:61:aa:ba:27:ff:bc:df:31:c2:0b:76:5a:5e:
    bb:73:c2:7d:90:e1:dd:dd:62:fa:23:df:7f:a4:6c:
    40:67:9b:a7:10:3b:3e:7a:bf:dc:bd:4d:b0:1c:30:
    9c:ce:2d:18:38:4c:d7:58:c0:15:e2:4d:37:87:a9:
    dd:b0:b7:42:77:0a:44:74:59:78:9a:9c:06:d4:70:
    56:91
prime2:
    00:d7:4e:55:e7:40:a0:75:78:69:31:95:f5:db:0e:
    1a:8f:fc:dc:e9:84:57:dd:3e:b6:11:5c:85:55:64:
    76:43:58:ef:5c:a2:bd:3a:2b:84:c1:99:f3:2e:cd:
    0c:91:5f:14:ef:a4:f7:c4:e4:fe:90:f9:e6:95:db:
    26:53:a8:11:73:86:06:b9:39:9d:e0:b1:67:b8:b9:
    af:0d:ac:1e:ce:45:fc:37:d2:ce:9d:e5:a8:3f:ea:
    e7:33:27:9a:6e:13:f9:a2:b2:57:33:15:88:9d:b9:
    ec:70:61:11:f4:b4:31:e1:52:80:57:0a:4b:2e:15:
    43:ac:59:e9:f3:87:54:f4:10:39:81:8b:90:e8:43:
    60:59:b1:a0:7f:4b:db:b3:fb:98:e7:e1:7d:ee:14:
    58:5b:cc:14:b2:ec:ca:b7:76:28:4d:73:af:13:01:
    59:6a:0d:5e:ad:9e:f9:b6:cb:17:9f:bc:33:9f:31:
    50:ea:e4:89:6c:4e:59:e4:20:61:7e:23:9c:a0:2d:
    4c:97:4b:7b:76:2c:cb:64:78:db:f7:ca:10:79:d2:
    3b:5e:78:24:3d:ae:9c:d8:91:31:96:86:58:f4:7a:
    a5:06:e3:a5:e5:27:e0:69:3a:c3:f5:a7:a6:c5:cf:
    80:e3:d5:59:de:58:f7:fd:22:07:23:9b:19:9b:4e:
    77:df
exponent1:
    00:c5:92:0c:be:2b:b7:a4:01:b6:19:fe:4c:0b:97:
    a3:ac:0b:af:9a:67:9b:c6:1c:9a:94:87:0c:3b:0b:
    6b:cf:28:21:13:61:7e:51:b9:f0:bd:b1:76:cd:52:
    ff:e3:9b:aa:1d:ba:e9:ad:10:de:a8:31:25:9d:13:
    26:95:85:37:e2:f9:82:a6:4f:95:9d:6b:95:fa:df:
    5e:7f:b9:f6:77:c4:f0:49:16:67:e2:8b:2a:cd:b1:
    8d:ce:33:71:ce:fa:2b:d7:65:33:56:5e:a7:49:83:
    71:c3:ee:3e:2b:28:c1:c6:01:20:e9:b3:a3:a1:da:
    4e:40:8d:8f:55:1f:09:4f:bf:e7:ea:45:8a:5b:dc:
    ff:f4:8a:b8:fe:47:61:23:54:b8:a9:55:e3:06:3b:
    75:76:3b:b5:89:49:e8:6b:f8:5e:ee:98:d9:05:8c:
    bd:89:a5:81:71:da:1c:c7:88:59:35:0e:b1:7b:c4:
    1e:4e:25:b6:9c:f5:3e:c7:81:ab:16:1c:2d:ca:97:
    40:15:6c:bc:8c:ca:7d:9a:af:88:1d:6f:5e:e6:4d:
    51:0e:e1:17:b3:c0:c6:65:6a:bf:b6:29:42:5d:af:
    1e:46:ef:10:28:68:d1:cc:98:44:f8:66:b4:b3:3d:
    5e:d8:60:f6:fd:c0:07:29:35:ea:b7:73:2c:a8:05:
    ba:b1
exponent2:
    57:1a:f8:22:10:c1:5a:05:16:f9:da:a3:96:b6:04:
    05:10:d6:07:1b:65:b8:ba:b0:4a:21:d6:47:8f:d7:
    50:b3:e0:52:e7:fc:0a:56:a4:e4:f6:75:ae:0f:82:
    f0:25:39:81:22:8a:a2:fb:ca:09:b9:30:92:9c:10:
    cb:73:89:6b:e5:63:3e:f8:92:68:df:1d:09:5d:05:
    f7:50:15:3e:7a:8d:e9:bf:bd:9b:9f:d8:0b:d3:eb:
    29:84:f2:33:6a:9d:6a:37:20:94:28:38:17:27:ab:
    02:64:23:31:8e:dd:47:3d:6b:72:cb:55:53:15:83:
    45:6d:32:fb:35:5b:27:4a:91:19:59:ef:8c:28:06:
    09:03:95:dd:2a:41:7e:75:61:8d:1e:6b:26:30:d0:
    f6:82:80:35:4b:1b:50:51:db:48:4a:6f:20:0f:41:
    af:68:2d:4f:ac:ab:76:4a:80:0a:3d:c7:dc:b5:c4:
    f8:e2:f0:be:02:8c:d7:80:4a:31:10:13:43:b2:4f:
    f4:3d:b3:7b:41:f0:1f:7b:cd:f2:57:ab:86:bd:89:
    0b:55:2b:c4:50:aa:5f:eb:8d:d6:4a:10:1f:08:a7:
    4f:3c:36:57:99:64:6e:ee:39:6d:5f:20:57:92:f5:
    a0:37:26:9e:8f:fb:f4:4b:19:fc:4b:b9:76:5d:ae:
    9d
coefficient:
    72:6e:e9:90:ce:fb:bf:0e:70:02:d9:bc:75:ac:26:
    bf:70:9e:16:a2:31:a0:10:c9:f3:ff:5d:1a:a6:7b:
    9a:38:2e:51:49:44:43:92:26:9f:c9:51:e9:21:a7:
    c6:fe:18:d8:3b:15:e0:09:23:a3:1a:49:51:79:f1:
    ce:a5:9f:c8:47:89:54:81:32:3e:c8:a7:e7:ba:a8:
    17:a4:36:b0:0e:b7:3f:d1:c3:c0:9c:ac:d7:a0:8c:
    ea:c7:e8:dd:ca:eb:50:c2:7e:35:0f:1e:b5:77:d6:
    61:31:0d:5e:de:17:08:2a:90:75:4a:34:9f:19:c1:
    d2:95:59:a8:1f:c1:c7:08:b7:37:46:4d:2b:d9:ab:
    6b:4a:f7:3c:6d:3f:70:b4:43:b0:f2:a3:e5:2d:fc:
    54:9f:05:27:07:7e:2d:fd:1b:8a:49:6a:2d:ae:c4:
    4b:3f:e3:41:87:6b:df:da:15:7d:f4:63:c0:4a:23:
    2e:1a:d9:aa:10:79:4a:f5:68:1e:61:55:37:9f:7c:
    48:91:77:c6:ab:75:ba:7b:53:02:f8:61:65:e1:33:
    b2:e5:eb:bf:87:16:47:dd:a5:db:cd:46:59:6d:cc:
    b4:ed:d5:d5:31:23:27:31:4b:3f:e2:fd:8e:93:12:
    f6:19:3f:ea:42:2c:86:81:5d:d1:b5:f0:ef:3f:42:
    74


# Root CA 인증서 생성 : ca.crt
## -x509 : CSR을 만들지 않고 바로 인증서(X.509) 생성, 즉, Self-Signed Certificate
## -noenc : 개인키를 암호화하지 않음, 즉, CA 키(ca.key)에 패스프레이즈 없음
## -config ca.conf : 인증서 세부 정보는 설정 파일에서 읽음 , [req] 섹션 사용됨 - DN 정보 → [req_distinguished_name] , CA 확장 → [ca_x509_extensions]

root@jumpbox:~/kubernetes-the-hard-way# openssl req -x509 -new -sha512 -noenc \
  -key ca.key -days 3653 \
  -config ca.conf \
  -out ca.crt

root@jumpbox:~/kubernetes-the-hard-way# ls -l ca.crt
-rw-r--r-- 1 root root 1899 Jan 10 12:08 ca.crt

# ca.conf 관련 내용
root@jumpbox:~/kubernetes-the-hard-way# cat ca.conf | grep -C 9 "ca_x509_extensions"
[req]
distinguished_name = req_distinguished_name
prompt             = no
x509_extensions    = ca_x509_extensions

[ca_x509_extensions]
basicConstraints = CA:TRUE # 이 인증서는 CA 역할 가능
keyUsage         = cRLSign, keyCertSign # cRLSign: 인증서 폐기 목록(CRL) 서명 가능, keyCertSign: 다른 인증서를 서명할 수 있음

[req_distinguished_name]
C   = US
ST  = Washington
L   = Seattle
CN  = CA

root@jumpbox:~/kubernetes-the-hard-way# cat ca.crt
-----BEGIN CERTIFICATE-----
MIIFTDCCAzSgAwIBAgIUHFcNvixknFyAFmy3NwUfDLkfhxswDQYJKoZIhvcNAQEN
BQAwQTELMAkGA1UEBhMCVVMxEzARBgNVBAgMCldhc2hpbmd0b24xEDAOBgNVBAcM
B1NlYXR0bGUxCzAJBgNVBAMMAkNBMB4XDTI2MDExMDEyMDgwNVoXDTM2MDExMTEy
MDgwNVowQTELMAkGA1UEBhMCVVMxEzARBgNVBAgMCldhc2hpbmd0b24xEDAOBgNV
BAcMB1NlYXR0bGUxCzAJBgNVBAMMAkNBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
MIICCgKCAgEAvERVGy7ubEiOJvcgVy2RnU68LmuFIR86X1VtR3PNaiDXuZYY+p98
RzuR8b46MwK1pwIw6VrI9e72d12l4QrMdrTus1Mf5eZE0q57zOYDtG/U9LGxDuv3
bk5m8cgZxI8LGJ4Qm6n6WRdU0XUlHAq7s5WrjnXRzhffQpnp3fGNpI3kQ3mTYGrw
WlY6UD4z9Yx2qkWGtadFwUUWWlxA9iFFZQaKu8VOnxHfFirJ0Jlgi0Ii62axrwiN
YN+ynGcDd52zXN6WCssIjd6WpFoRs1mdcoPuqeG8pJMmDZeu9R7B14ChAIzoOpEj
cCx3d757nnugHKYkLPZR1AuH0DJbx/nPvwOVexPTJUntuy1fzuk2zZIyLD0GkKeW
sE86kRDtEprl4JMriCv15BuOQ44+UrsZnFpCpkHOmdD7Q4w4ZesiwwPpXnvxf4Sh
chzpqppScWrrQYnz48uiJD49EGS2tD7AgwoVRCIhsxDtjXb8PRF6UIkAQBeJxhOa
pDTGKb33BA8BOPUrl1l2msicaPsqck3vXYJZbDYH+tZLZ6qYgh1fxPP+IhXs1zen
yrwbWke6y4Pl0GRWX+GqNM/CWRXwaU0mVSDopfRooEJw86mRmVO9+cF8PYRKmhXO
WWaL6qwYSCf/nv66Ru4cviU5ToWl6VugG9YvmK3lrpXaKh8UgHFGz08CAwEAAaM8
MDowDAYDVR0TBAUwAwEB/zALBgNVHQ8EBAMCAQYwHQYDVR0OBBYEFGdoiUBnqWqc
o/NEVr9aJ1eY/9UAMA0GCSqGSIb3DQEBDQUAA4ICAQAuRi3XMZdrrSpu4PE1Sk7V
peSi4uPDTJN6W7rBXYCDUVVR3C61VmJX1WhfwHyFLWX+BJErdc0uGMcDD/j07TaC
Hr02cjiJcHOnH+veUGevW6dZylvMzuE+ielOMYD7zoqK96l0Y1ySOTD7sXPTZoOp
4KGZl1y7vfI2iu2GqWeP8AAptBnIcEK9o9GFPrha7npM/Q8Ih4vB4qLF/DTCCFa1
4Lj9bWugtMFBmewObstZxzKsSUzAJvMLWkLaSKuzBZWeYpVyn/4J+Jdfy0Irmm9v
iPL7J7Hvvc2NdQi+MiqM4fBhnMJCRA10EzmbOX1RSzoCUNy2pXhbgdl1L+hDFmrA
ovcMgXn71IRU7GExTm6Q4mGfDdzn6YDC46GtAF5YVQhTX5WAcWPH2KS5PJyRobdM
lfZxLw+HkQ6vt3iYhYqCF3ESI27hQj1PAzyOajiYyDlcDEQEP+Xk7lKCittQcLCK
eyBqbW3DbemLgGUkgVqdL+is7tUGzF8e4kRx6dKfL67/W+G9oArf11x0L3S0XHrn
YQDMzkWCXrft4MRzWjyidCaBwVTcHwYz74gVT1B3ZXEbbBjfAKtTTUmpExjqns9q
mQ39/WNrlNY7MxXbNbEWI+Nz++KbgzqE6HgmK7Hl1smI0MONZba6DCSsDx0oVO22
2X/SUI2Nm5+TwedDUQrKEQ==
-----END CERTIFICATE-----

# 인증서 전체 내용 확인
root@jumpbox:~/kubernetes-the-hard-way# openssl x509 -in ca.crt -text -noout
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            1c:57:0d:be:2c:64:9c:5c:80:16:6c:b7:37:05:1f:0c:b9:1f:87:1b
        Signature Algorithm: sha512WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:08:05 2026 GMT
            Not After : Jan 11 12:08:05 2036 GMT
        Subject: C=US, ST=Washington, L=Seattle, CN=CA
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:bc:44:55:1b:2e:ee:6c:48:8e:26:f7:20:57:2d:
                    91:9d:4e:bc:2e:6b:85:21:1f:3a:5f:55:6d:47:73:
                    cd:6a:20:d7:b9:96:18:fa:9f:7c:47:3b:91:f1:be:
                    3a:33:02:b5:a7:02:30:e9:5a:c8:f5:ee:f6:77:5d:
                    a5:e1:0a:cc:76:b4:ee:b3:53:1f:e5:e6:44:d2:ae:
                    7b:cc:e6:03:b4:6f:d4:f4:b1:b1:0e:eb:f7:6e:4e:
                    66:f1:c8:19:c4:8f:0b:18:9e:10:9b:a9:fa:59:17:
                    54:d1:75:25:1c:0a:bb:b3:95:ab:8e:75:d1:ce:17:
                    df:42:99:e9:dd:f1:8d:a4:8d:e4:43:79:93:60:6a:
                    f0:5a:56:3a:50:3e:33:f5:8c:76:aa:45:86:b5:a7:
                    45:c1:45:16:5a:5c:40:f6:21:45:65:06:8a:bb:c5:
                    4e:9f:11:df:16:2a:c9:d0:99:60:8b:42:22:eb:66:
                    b1:af:08:8d:60:df:b2:9c:67:03:77:9d:b3:5c:de:
                    96:0a:cb:08:8d:de:96:a4:5a:11:b3:59:9d:72:83:
                    ee:a9:e1:bc:a4:93:26:0d:97:ae:f5:1e:c1:d7:80:
                    a1:00:8c:e8:3a:91:23:70:2c:77:77:be:7b:9e:7b:
                    a0:1c:a6:24:2c:f6:51:d4:0b:87:d0:32:5b:c7:f9:
                    cf:bf:03:95:7b:13:d3:25:49:ed:bb:2d:5f:ce:e9:
                    36:cd:92:32:2c:3d:06:90:a7:96:b0:4f:3a:91:10:
                    ed:12:9a:e5:e0:93:2b:88:2b:f5:e4:1b:8e:43:8e:
                    3e:52:bb:19:9c:5a:42:a6:41:ce:99:d0:fb:43:8c:
                    38:65:eb:22:c3:03:e9:5e:7b:f1:7f:84:a1:72:1c:
                    e9:aa:9a:52:71:6a:eb:41:89:f3:e3:cb:a2:24:3e:
                    3d:10:64:b6:b4:3e:c0:83:0a:15:44:22:21:b3:10:
                    ed:8d:76:fc:3d:11:7a:50:89:00:40:17:89:c6:13:
                    9a:a4:34:c6:29:bd:f7:04:0f:01:38:f5:2b:97:59:
                    76:9a:c8:9c:68:fb:2a:72:4d:ef:5d:82:59:6c:36:
                    07:fa:d6:4b:67:aa:98:82:1d:5f:c4:f3:fe:22:15:
                    ec:d7:37:a7:ca:bc:1b:5a:47:ba:cb:83:e5:d0:64:
                    56:5f:e1:aa:34:cf:c2:59:15:f0:69:4d:26:55:20:
                    e8:a5:f4:68:a0:42:70:f3:a9:91:99:53:bd:f9:c1:
                    7c:3d:84:4a:9a:15:ce:59:66:8b:ea:ac:18:48:27:
                    ff:9e:fe:ba:46:ee:1c:be:25:39:4e:85:a5:e9:5b:
                    a0:1b:d6:2f:98:ad:e5:ae:95:da:2a:1f:14:80:71:
                    46:cf:4f
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:TRUE
            X509v3 Key Usage: 
                Certificate Sign, CRL Sign
            X509v3 Subject Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha512WithRSAEncryption
    Signature Value:
        2e:46:2d:d7:31:97:6b:ad:2a:6e:e0:f1:35:4a:4e:d5:a5:e4:
        a2:e2:e3:c3:4c:93:7a:5b:ba:c1:5d:80:83:51:55:51:dc:2e:
        b5:56:62:57:d5:68:5f:c0:7c:85:2d:65:fe:04:91:2b:75:cd:
        2e:18:c7:03:0f:f8:f4:ed:36:82:1e:bd:36:72:38:89:70:73:
        a7:1f:eb:de:50:67:af:5b:a7:59:ca:5b:cc:ce:e1:3e:89:e9:
        4e:31:80:fb:ce:8a:8a:f7:a9:74:63:5c:92:39:30:fb:b1:73:
        d3:66:83:a9:e0:a1:99:97:5c:bb:bd:f2:36:8a:ed:86:a9:67:
        8f:f0:00:29:b4:19:c8:70:42:bd:a3:d1:85:3e:b8:5a:ee:7a:
        4c:fd:0f:08:87:8b:c1:e2:a2:c5:fc:34:c2:08:56:b5:e0:b8:
        fd:6d:6b:a0:b4:c1:41:99:ec:0e:6e:cb:59:c7:32:ac:49:4c:
        c0:26:f3:0b:5a:42:da:48:ab:b3:05:95:9e:62:95:72:9f:fe:
        09:f8:97:5f:cb:42:2b:9a:6f:6f:88:f2:fb:27:b1:ef:bd:cd:
        8d:75:08:be:32:2a:8c:e1:f0:61:9c:c2:42:44:0d:74:13:39:
        9b:39:7d:51:4b:3a:02:50:dc:b6:a5:78:5b:81:d9:75:2f:e8:
        43:16:6a:c0:a2:f7:0c:81:79:fb:d4:84:54:ec:61:31:4e:6e:
        90:e2:61:9f:0d:dc:e7:e9:80:c2:e3:a1:ad:00:5e:58:55:08:
        53:5f:95:80:71:63:c7:d8:a4:b9:3c:9c:91:a1:b7:4c:95:f6:
        71:2f:0f:87:91:0e:af:b7:78:98:85:8a:82:17:71:12:23:6e:
        e1:42:3d:4f:03:3c:8e:6a:38:98:c8:39:5c:0c:44:04:3f:e5:
        e4:ee:52:82:8a:db:50:70:b0:8a:7b:20:6a:6d:6d:c3:6d:e9:
        8b:80:65:24:81:5a:9d:2f:e8:ac:ee:d5:06:cc:5f:1e:e2:44:
        71:e9:d2:9f:2f:ae:ff:5b:e1:bd:a0:0a:df:d7:5c:74:2f:74:
        b4:5c:7a:e7:61:00:cc:ce:45:82:5e:b7:ed:e0:c4:73:5a:3c:
        a2:74:26:81:c1:54:dc:1f:06:33:ef:88:15:4f:50:77:65:71:
        1b:6c:18:df:00:ab:53:4d:49:a9:13:18:ea:9e:cf:6a:99:0d:
        fd:fd:63:6b:94:d6:3b:33:15:db:35:b1:16:23:e3:73:fb:e2:
        9b:83:3a:84:e8:78:26:2b:b1:e5:d6:c9:88:d0:c3:8d:65:b6:
        ba:0c:24:ac:0f:1d:28:54:ed:b6:d9:7f:d2:50:8d:8d:9b:9f:
        93:c1:e7:43:51:0a:ca:11
```

### Client, Server 인증서 생성 : admin

```bash
# Create Client and Server Certificates : admin
root@jumpbox:~/kubernetes-the-hard-way# openssl genrsa -out admin.key 4096

root@jumpbox:~/kubernetes-the-hard-way# ls -l admin.key
-rw------- 1 root root 3272 Jan 10 12:09 admin.key

# ca.conf 에 admin 섹션
root@jumpbox:~/kubernetes-the-hard-way# cat ca.conf | grep -A 3 "\[admin"
[admin]
distinguished_name = admin_distinguished_name
prompt             = no
req_extensions     = default_req_extensions
--
[admin_distinguished_name]
CN = admin
O  = system:masters

root@jumpbox:~/kubernetes-the-hard-way# cat ca.conf | grep -A 7 "\[default_req_extensions\]"
[default_req_extensions] # 공통 CSR 확장
basicConstraints     = CA:FALSE
extendedKeyUsage     = clientAuth
keyUsage             = critical, digitalSignature, keyEncipherment
nsCertType           = client
nsComment            = "Admin Client Certificate"
subjectKeyIdentifier = hash

# csr 파일 생성 : admin.key 개인키를 사용해 'CN=admin, O=system:masters'인 Kubernetes 관리자용 클라이언트 인증서 요청(admin.csr) 생성
root@jumpbox:~/kubernetes-the-hard-way# openssl req -new -key admin.key -sha256 \
  -config ca.conf -section admin \
  -out admin.csr

root@jumpbox:~/kubernetes-the-hard-way# ls -l admin.csr
-rw-r--r-- 1 root root 1830 Jan 10 12:10 admin.csr

# CSR 전체 내용 확인
root@jumpbox:~/kubernetes-the-hard-way# openssl req -in admin.csr -text -noout
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: CN=admin, O=system:masters
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:b3:7d:fb:20:b1:a8:9e:28:44:d7:fe:75:44:b6:
                    d8:bc:2a:f3:88:cd:ab:4d:09:e6:73:62:cf:57:f8:
                    1b:e7:07:1b:5a:04:7c:fd:42:24:55:a5:02:f1:73:
                    17:44:31:5e:e3:0d:68:87:3a:65:57:0a:c7:79:3f:
                    56:04:69:c5:7e:3e:0b:a3:da:93:e1:3f:c3:c6:28:
                    ff:17:98:6d:56:b8:1a:a7:55:16:18:99:71:2e:f3:
                    75:0f:38:15:2f:92:95:ac:08:53:82:b3:41:d3:ed:
                    c4:51:bc:ca:6d:b5:f4:07:54:fc:8b:e2:c9:26:f0:
                    c8:6f:99:b7:70:ac:c3:61:60:df:1b:4a:5b:87:b4:
                    8d:c4:b8:ae:32:d1:4d:4c:87:8c:e9:0e:fd:75:b0:
                    3e:29:c7:a1:75:8e:c8:10:0f:d1:ea:a3:5f:b1:f7:
                    a9:36:5e:5a:2f:09:d2:ca:5a:9b:9b:41:b5:a9:b8:
                    a9:a8:3f:4a:9d:dd:43:99:2d:bb:a3:05:87:a0:0e:
                    d8:c6:67:4b:f9:3a:0c:eb:ef:e2:8b:1e:6f:b1:18:
                    51:f6:92:b3:5d:79:79:52:92:13:88:a3:a2:90:0e:
                    65:50:96:ab:85:e9:e2:fe:cc:fe:4c:5b:99:f2:ec:
                    b6:8d:19:3a:75:7d:c1:8a:c1:20:20:c6:eb:14:b7:
                    f7:b7:46:58:29:b9:44:c9:37:b3:42:18:fc:3c:1d:
                    e7:d1:82:e4:d0:0b:fb:c8:0f:6c:9c:51:49:39:a0:
                    77:dc:77:15:be:3b:c1:68:3a:4d:29:bd:97:4d:51:
                    c2:22:6a:d6:ae:aa:6a:ab:13:15:10:89:8e:75:f5:
                    43:7a:59:81:52:aa:47:81:58:0b:bd:8b:f0:d0:09:
                    72:30:c9:c5:c0:e9:8f:4a:e1:0b:6b:1d:ef:b6:0b:
                    ce:a2:65:74:74:ff:a4:9b:01:5a:2d:65:01:17:54:
                    45:b9:a5:82:76:f8:42:62:cb:06:32:c7:47:a8:5f:
                    52:1c:e9:15:9b:70:14:d7:47:f0:8e:f2:57:89:ba:
                    95:d8:b1:05:e8:68:49:8c:07:75:4f:64:c0:83:12:
                    0d:a3:f9:f2:b2:ff:e5:8e:8b:d7:4f:27:d1:a7:2a:
                    2e:fa:cf:dc:df:6c:1b:cd:6a:fc:62:db:46:1a:e6:
                    c0:78:3b:9b:02:d5:64:12:7c:a6:17:2d:69:7a:e5:
                    38:ff:bb:c4:b6:38:78:3e:52:63:c9:e8:af:0d:81:
                    f2:eb:9c:e9:de:14:ed:f7:cb:e7:7d:96:f3:bd:b0:
                    1c:26:70:e3:a1:f5:e3:2d:3b:db:c1:73:d8:4e:e4:
                    0b:98:be:c5:eb:8e:a6:58:f3:aa:45:de:7f:90:77:
                    52:f4:fd
                Exponent: 65537 (0x10001)
        Attributes:
            Requested Extensions:
                X509v3 Basic Constraints: 
                    CA:FALSE
                X509v3 Extended Key Usage: 
                    TLS Web Client Authentication
                X509v3 Key Usage: critical
                    Digital Signature, Key Encipherment
                Netscape Cert Type: 
                    SSL Client
                Netscape Comment: 
                    Admin Client Certificate
                X509v3 Subject Key Identifier: 
                    2C:00:5F:51:EC:63:EA:F3:8D:A3:7F:E7:67:98:99:72:94:79:B7:11
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        5f:56:7d:6c:77:ef:5b:6b:fe:e6:64:7e:a2:0a:fb:e0:c6:7d:
        40:d3:5b:99:57:fd:b5:6e:55:0f:5b:f7:36:b9:54:bd:6f:09:
        b7:c5:e0:ab:35:32:58:a0:3a:55:ef:12:87:fc:15:10:f3:6a:
        cc:f4:91:b8:00:14:5a:e3:5b:74:85:57:a5:fa:0b:31:b9:99:
        6b:2f:ac:8b:c2:4c:d0:2a:44:f3:c2:a0:89:d4:e6:50:39:72:
        52:7a:41:b8:65:69:03:2b:0c:f7:ca:1d:6b:be:16:b4:5b:24:
        dd:41:fa:1d:a6:71:54:26:4f:0b:1e:47:a0:e6:ec:74:e4:a4:
        0c:59:80:7e:19:27:b3:6e:d0:ab:0e:d3:74:91:be:06:18:0c:
        ab:ed:2c:2a:ba:16:43:c7:26:70:3a:7d:0c:17:f2:3d:cc:c1:
        9d:94:e2:3d:fc:2e:3a:7d:6d:6f:95:aa:a5:ab:94:fe:5a:32:
        28:44:ac:9e:0d:f4:38:2a:9d:35:e0:02:b9:3b:74:51:fb:b4:
        91:70:ad:58:61:6f:a6:b2:86:c2:b1:20:1c:d9:28:da:dc:8b:
        ef:1e:3a:39:9a:f6:2c:e8:a6:59:75:d1:4e:79:d6:61:71:94:
        f9:00:74:f2:41:91:b3:eb:dd:f6:2e:34:1d:e7:ca:50:db:f4:
        35:32:03:92:e7:0f:47:26:d8:b6:a7:6d:d8:9c:6d:09:ff:7c:
        af:01:d7:e9:cd:58:87:67:ac:09:cc:8d:4d:09:b7:8e:79:1a:
        fa:41:fc:44:d0:83:f5:dc:3a:d8:30:80:c3:47:07:a4:fc:db:
        78:28:f0:a6:d9:38:ac:66:aa:dd:c3:55:4c:1f:a2:90:fe:3e:
        44:1a:b3:1b:a9:b4:99:f3:80:e5:fa:4e:8f:97:d4:a6:d7:e5:
        89:2f:f4:7b:94:23:ab:a4:3d:ed:b7:a8:12:31:39:9e:2b:f4:
        00:8a:d1:1b:97:3e:f6:d6:64:ac:00:fd:b5:77:24:d3:d3:1e:
        fa:2e:2a:65:99:b9:cf:de:00:c6:c6:69:36:44:2f:1b:d2:b2:
        56:52:31:f3:c7:00:2a:c5:2b:20:a4:ca:b8:2f:b0:8c:84:97:
        11:62:dc:72:2d:ff:fd:1e:4f:ce:2a:29:15:37:ec:d9:0f:0e:
        0d:61:02:06:32:86:44:5d:52:5c:b1:72:3f:fd:3b:ac:95:0a:
        8d:cf:89:63:88:54:1a:50:5b:56:18:6b:be:c7:e6:5b:28:3d:
        92:52:b3:be:b1:ea:f7:bd:d2:7d:bc:ed:12:1e:3f:f7:e1:52:
        5b:5a:9b:37:3e:7e:00:59:1d:66:6f:38:e7:14:37:92:81:86:
        c5:01:59:75:e0:52:55:c7


# ca에 csr 요청을 통한 crt 파일 생성
## -req : CSR를 입력으로 받아 인증서를 생성, self-signed 아님, CA가 서명하는 방식
## -days 3653 : 인증서 유효기간 3653일 (약 10년)
## -copy_extensions copyall : CSR에 포함된 모든 X.509 extensions를 인증서로 복사
## -CAcreateserial : CA 시리얼 번호 파일 자동 생성, 다음 인증서 발급 시 재사용, 기본 생성 파일(ca.srl)
root@jumpbox:~/kubernetes-the-hard-way# openssl x509 -req -days 3653 -in admin.csr \
  -copy_extensions copyall \
  -sha256 -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out admin.crt
Certificate request self-signature ok
subject=CN=admin, O=system:masters

root@jumpbox:~/kubernetes-the-hard-way# ls -l admin.crt
-rw-r--r-- 1 root root 2021 Jan 10 12:11 admin.crt


root@jumpbox:~/kubernetes-the-hard-way# openssl x509 -in admin.crt -text -noout | grep -C 10 "Issuer"
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:8d
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:11:07 2026 GMT
            Not After : Jan 11 12:11:07 2036 GMT
        Subject: CN=admin, O=system:masters # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:b3:7d:fb:20:b1:a8:9e:28:44:d7:fe:75:44:b6:
                    d8:bc:2a:f3:88:cd:ab:4d:09:e6:73:62:cf:57:f8:


root@jumpbox:~/kubernetes-the-hard-way# openssl x509 -in admin.crt -text -noout | grep -C 10 "X509v3 extensions"
                    95:d8:b1:05:e8:68:49:8c:07:75:4f:64:c0:83:12:
                    0d:a3:f9:f2:b2:ff:e5:8e:8b:d7:4f:27:d1:a7:2a:
                    2e:fa:cf:dc:df:6c:1b:cd:6a:fc:62:db:46:1a:e6:
                    c0:78:3b:9b:02:d5:64:12:7c:a6:17:2d:69:7a:e5:
                    38:ff:bb:c4:b6:38:78:3e:52:63:c9:e8:af:0d:81:
                    f2:eb:9c:e9:de:14:ed:f7:cb:e7:7d:96:f3:bd:b0:
                    1c:26:70:e3:a1:f5:e3:2d:3b:db:c1:73:d8:4e:e4:
                    0b:98:be:c5:eb:8e:a6:58:f3:aa:45:de:7f:90:77:
                    52:f4:fd
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE # 👀
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication # 👀
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Admin Client Certificate
```

### Client, Server 인증서 생성: 나머지 전부

```bash
# ca.conf 수정
root@jumpbox:~/kubernetes-the-hard-way# cat ca.conf | grep system:kube-scheduler
CN = system:kube-scheduler
O  = system:system:kube-scheduler

root@jumpbox:~/kubernetes-the-hard-way# sed -i 's/system:system:kube-scheduler/system:kube-scheduler/' ca.conf

root@jumpbox:~/kubernetes-the-hard-way# cat ca.conf | grep system:kube-scheduler
CN = system:kube-scheduler
O  = system:kube-scheduler

# 변수 지정
root@jumpbox:~/kubernetes-the-hard-way# certs=(
  "node-0" "node-1"
  "kube-proxy" "kube-scheduler"
  "kube-controller-manager"
  "kube-api-server"
  "service-accounts"
)

root@jumpbox:~/kubernetes-the-hard-way# echo ${certs[*]}
node-0 node-1 kube-proxy kube-scheduler kube-controller-manager kube-api-server service-accounts

# 개인키 생성, csr 생성, 인증서 생성
root@jumpbox:~/kubernetes-the-hard-way# for i in ${certs[*]}; do
  openssl genrsa -out "${i}.key" 4096

  openssl req -new -key "${i}.key" -sha256 \
    -config "ca.conf" -section ${i} \
    -out "${i}.csr"

  openssl x509 -req -days 3653 -in "${i}.csr" \
    -copy_extensions copyall \
    -sha256 -CA "ca.crt" \
    -CAkey "ca.key" \
    -CAcreateserial \
    -out "${i}.crt"
done
Certificate request self-signature ok
subject=CN=system:node:node-0, O=system:nodes, C=US, ST=Washington, L=Seattle
Certificate request self-signature ok
subject=CN=system:node:node-1, O=system:nodes, C=US, ST=Washington, L=Seattle
Certificate request self-signature ok
subject=CN=system:kube-proxy, O=system:node-proxier, C=US, ST=Washington, L=Seattle
Certificate request self-signature ok
subject=CN=system:kube-scheduler, O=system:kube-scheduler, C=US, ST=Washington, L=Seattle
Certificate request self-signature ok
subject=CN=system:kube-controller-manager, O=system:kube-controller-manager, C=US, ST=Washington, L=Seattle
Certificate request self-signature ok
subject=CN=kubernetes, C=US, ST=Washington, L=Seattle
Certificate request self-signature ok
subject=CN=service-accounts

root@jumpbox:~/kubernetes-the-hard-way# ls -1 *.crt *.key *.csr
admin.crt
admin.csr
admin.key
ca.crt
ca.key
kube-api-server.crt
kube-api-server.csr
kube-api-server.key
kube-controller-manager.crt
kube-controller-manager.csr
kube-controller-manager.key
kube-proxy.crt
kube-proxy.csr
kube-proxy.key
kube-scheduler.crt
kube-scheduler.csr
kube-scheduler.key
node-0.crt
node-0.csr
node-0.key
node-1.crt
node-1.csr
node-1.key
service-accounts.crt
service-accounts.csr
service-accounts.key
```

node-0 인증서 확인
```bash
root@jumpbox:~/kubernetes-the-hard-way# openssl x509 -in node-0.crt -text -noout | grep -C 10 node-0
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:8e
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:12 2026 GMT
            Not After : Jan 11 12:13:12 2036 GMT
        Subject: CN=system:node:node-0, O=system:nodes, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:8c:40:e8:76:2b:16:c5:6d:88:fb:63:bf:08:a7:
                    06:87:78:b8:a4:54:88:7d:03:a3:3a:01:c8:07:c3:
                    14:bb:76:c2:27:bb:2e:0d:76:29:4b:de:fa:5e:d4:
                    99:ca:83:f0:02:e1:1f:51:34:7b:6e:87:c4:f0:60:
                    46:f3:2a:fa:96:f9:a7:f6:f6:86:35:4f:63:e9:99:
                    53:38:8d:63:4b:83:d6:04:49:6b:6f:19:97:2e:09:
--
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication # 👀
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Node-0 Certificate
            X509v3 Subject Alternative Name: 
                DNS:node-0, IP Address:127.0.0.1 # 👀
            X509v3 Subject Key Identifier: 
                EC:85:76:8D:8B:31:08:45:7F:E1:BF:8C:56:0C:13:43:5D:97:72:59
            X509v3 Authority Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        a2:a0:97:96:b4:f5:5e:af:e2:2c:87:05:21:3c:15:65:09:9a:
        d8:70:ff:cd:a8:32:df:9c:87:21:e0:ed:e3:66:0a:7c:9a:0e:
        0e:38:93:ba:8b:6f:b6:21:5b:5b:15:f5:4e:a4:ae:48:74:af:
        27:ee:1f:1c:6e:7d:3d:08:6f:d1:be:10:23:3b:94:2b:d2:f6:
```

node-1 인증서 확인
```bash
root@jumpbox:~/kubernetes-the-hard-way# openssl x509 -in node-1.crt -text -noout | grep -C 10 node-1
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:8f
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:12 2026 GMT
            Not After : Jan 11 12:13:12 2036 GMT
        Subject: CN=system:node:node-1, O=system:nodes, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:c6:dc:d5:82:79:ee:aa:66:b1:02:f9:fd:92:f9:
                    5e:1f:06:0c:f5:32:38:4f:f5:8a:80:32:73:2e:55:
                    11:2f:c4:cf:85:c8:a7:d3:45:4d:8f:58:ac:56:ca:
                    75:3b:9c:1a:07:5d:f4:f8:3d:d8:c1:43:e8:0f:ef:
                    1e:60:d5:12:7a:f9:1e:49:98:eb:5c:09:dc:a3:39:
                    89:df:55:9a:37:5e:cd:cb:c5:74:2a:ea:6e:ad:a0:
--
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication # 👀
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Node-1 Certificate
            X509v3 Subject Alternative Name: 
                DNS:node-1, IP Address:127.0.0.1 # 👀
            X509v3 Subject Key Identifier: 
                65:84:F6:F5:CA:06:10:B8:CC:E8:A8:D9:69:0A:3D:3B:2A:85:70:9D
            X509v3 Authority Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        b8:18:95:cb:b3:4d:df:0c:c9:f4:a4:97:ef:75:04:86:22:38:
        ea:eb:45:21:e5:81:6c:ae:f1:4b:4d:79:09:8c:97:5f:54:ad:
        d7:95:eb:25:a6:0a:b1:2e:50:50:31:6d:89:5d:49:cb:b0:12:
        94:69:cf:9a:06:29:72:7f:a4:96:37:71:d0:a0:cc:ee:58:a5:
```

kube-proxy 인증서 확인
```bash
root@jumpbox:~/kubernetes-the-hard-way# openssl x509 -in kube-proxy.crt -text -noout | grep -C 10 kube-proxy
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:90
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:13 2026 GMT
            Not After : Jan 11 12:13:13 2036 GMT
        Subject: CN=system:kube-proxy, O=system:node-proxier, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:ab:8b:e6:c7:24:7c:f6:12:a4:3d:7a:bc:13:59:
                    9b:92:1f:4f:16:58:b2:f4:26:0d:0b:fb:19:31:6b:
                    6a:90:7d:f4:11:94:4f:fd:55:18:31:e9:8a:b6:11:
                    a3:cd:ff:1a:c0:52:d9:de:18:b3:9c:0b:36:fe:45:
                    14:57:14:80:27:71:3d:06:b8:d9:71:7d:c7:85:15:
                    fd:b4:b9:3b:4a:35:d4:d5:ae:64:36:97:9f:68:ef:
--
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Kube Proxy Certificate
            X509v3 Subject Alternative Name: 
                DNS:kube-proxy, IP Address:127.0.0.1 # 👀
            X509v3 Subject Key Identifier: 
                40:A5:30:79:02:40:53:7E:E4:1B:5F:20:87:0B:7E:BD:17:51:F4:19
            X509v3 Authority Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        35:51:ba:c3:c0:74:52:b4:ee:5f:57:b4:18:38:b5:8b:fa:e3:
        46:fb:5e:2f:a9:01:dd:1b:84:c3:69:7d:58:ba:0e:cb:93:9e:
        c4:98:29:15:1f:f7:c6:f3:0d:cb:4a:91:4f:68:46:30:b0:d6:
        6c:25:7f:06:d7:40:4f:d2:c1:2d:42:ec:0d:4f:04:c3:30:a2:
```


kube-scheduler 인증서 확인
```bash
root@jumpbox:~/kubernetes-the-hard-way# openssl x509 -in kube-scheduler.crt -text -noout | grep -C 10 kube-scheduler
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:91
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:14 2026 GMT
            Not After : Jan 11 12:13:14 2036 GMT
        Subject: CN=system:kube-scheduler, O=system:kube-scheduler, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:b3:90:03:69:1d:bc:55:ab:e3:4c:54:cb:f3:26:
                    7d:89:d0:fc:5d:6b:da:32:78:8c:f0:dd:02:cd:5c:
                    47:ee:cc:72:00:20:aa:78:30:ef:fa:60:13:8a:f8:
                    5f:59:2d:4b:7e:37:db:b5:a8:c4:8f:62:85:b2:2f:
                    65:f8:08:ce:d9:cb:03:77:5f:b5:cc:2a:35:1f:7f:
                    70:53:18:56:f6:a0:51:61:56:7e:51:c5:b9:77:96:
--
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Kube Scheduler Certificate
            X509v3 Subject Alternative Name: 
                DNS:kube-scheduler, IP Address:127.0.0.1 # 👀
            X509v3 Subject Key Identifier: 
                4C:7D:D9:3B:7A:50:D6:64:85:4F:BE:5D:92:13:2E:52:C8:46:39:AA
            X509v3 Authority Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        b7:38:60:ad:3f:fe:83:8e:88:ea:45:2f:d5:20:e9:8b:ce:60:
        ea:c7:8b:3b:1b:40:89:e7:88:f7:ef:65:fe:ca:78:ab:59:73:
        1b:8e:fc:c2:35:39:2c:b8:56:a2:95:48:a7:01:c4:9a:57:77:
        13:e1:d5:d0:2f:b8:51:96:05:95:99:a0:3b:c8:e9:2e:87:f7:

```


kube-controller-manager 인증서 확인
```bash
root@jumpbox:~/kubernetes-the-hard-way# openssl x509 -in kube-controller-manager.crt -text -noout | grep -C 10 kube-controller-manager
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:92
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:15 2026 GMT
            Not After : Jan 11 12:13:15 2036 GMT
        Subject: CN=system:kube-controller-manager, O=system:kube-controller-manager, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:a7:10:2f:bd:61:38:78:d7:0a:d7:8f:c1:04:b2:
                    e6:9c:bf:26:a8:98:da:8b:2e:63:c9:79:64:a0:61:
                    bf:9c:ff:b6:2f:c4:e5:52:93:e0:c3:c1:a6:70:3c:
                    8c:42:be:7c:2f:a5:fe:cb:1c:3e:01:da:c4:65:ff:
                    96:48:fa:7f:91:63:e6:53:74:77:30:28:a3:b6:3e:
                    1c:44:cd:63:ea:2b:8a:97:12:54:b4:de:d7:69:b0:
--
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client
            Netscape Comment: 
                Kube Controller Manager Certificate
            X509v3 Subject Alternative Name: 
                DNS:kube-controller-manager, IP Address:127.0.0.1 # 👀
            X509v3 Subject Key Identifier: 
                13:A6:2E:13:A7:65:DF:6F:B5:D0:55:77:88:65:1B:02:A7:DA:5F:4D
            X509v3 Authority Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        6b:1b:ae:6d:96:d1:bb:67:67:fa:ab:c8:9c:ad:68:80:17:31:
        29:b9:f0:0a:ae:73:5b:db:76:1a:1a:09:02:cb:35:b9:f4:bf:
        57:29:1e:a6:3c:5b:fc:1f:e9:6d:67:96:c5:b7:cd:94:00:7e:
        4f:77:55:cf:36:02:b7:6f:4e:b7:8c:46:e5:15:d6:7f:70:65:
```


kube-api-server 인증서 확인
```bash
root@jumpbox:~/kubernetes-the-hard-way# openssl x509 -in kube-api-server.crt -text -noout | grep -C 10 kubernetes
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:93
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:15 2026 GMT
            Not After : Jan 11 12:13:15 2036 GMT
        Subject: CN=kubernetes, C=US, ST=Washington, L=Seattle # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:e8:84:0c:6e:f2:0a:a4:c8:b5:21:e9:10:8a:84:
                    f0:ae:6a:11:fb:7b:cb:f8:1c:da:7f:87:98:1f:b4:
                    8f:07:f2:1b:1b:f0:1c:0e:01:f6:47:b1:2b:8e:64:
                    9f:e3:b5:cc:fe:bc:ef:0d:e6:e1:80:09:26:b6:ae:
                    eb:d6:85:e6:8e:f5:f3:32:46:22:aa:23:c6:83:6a:
                    c6:26:ef:7f:25:d1:12:be:ae:db:dd:1a:4a:b2:44:
--
                CA:FALSE
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication, TLS Web Server Authentication
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Netscape Cert Type: 
                SSL Client, SSL Server # 👀
            Netscape Comment: 
                Kube API Server Certificate
            X509v3 Subject Alternative Name: # 👀
                IP Address:127.0.0.1, IP Address:10.32.0.1, DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster, DNS:kubernetes.svc.cluster.local, DNS:server.kubernetes.local, DNS:api-server.kubernetes.local
            X509v3 Subject Key Identifier: 
                44:D0:C1:CF:43:54:C6:64:33:7E:24:F8:4B:D2:82:C5:DA:CC:3F:4B
            X509v3 Authority Key Identifier: 
                67:68:89:40:67:A9:6A:9C:A3:F3:44:56:BF:5A:27:57:98:FF:D5:00
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        21:43:a7:c2:19:ba:10:0f:10:48:0b:18:8b:fc:e7:a2:5c:a6:
        33:83:27:3f:80:17:a7:8e:71:1c:8e:f3:06:3c:47:83:1c:a7:
        51:79:02:12:68:22:c2:c4:0f:6f:35:c7:5d:d8:91:b4:89:b9:
        25:41:cb:d8:34:20:d2:12:59:7a:de:1f:e8:1a:6e:1d:cc:d6:
```

service-accounts 인증서 확인
```bash
root@jumpbox:~/kubernetes-the-hard-way# openssl x509 -in service-accounts.crt -text -noout | grep -C 10 service-accounts
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            65:a8:39:c3:df:6a:08:6a:c2:66:bd:1c:5c:ee:48:c4:5b:5e:4d:94
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Washington, L=Seattle, CN=CA
        Validity
            Not Before: Jan 10 12:13:16 2026 GMT
            Not After : Jan 11 12:13:16 2036 GMT
        Subject: CN=service-accounts # 👀
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:d1:a1:ba:d6:6f:5a:e3:b5:e7:15:ec:5a:31:54:
                    97:dd:12:63:84:54:dd:b2:dd:5c:87:51:39:bf:7a:
                    ac:b9:ff:c5:a7:a0:06:22:f2:9b:67:ca:61:98:f6:
                    d7:67:6d:f3:d9:b8:00:ce:1e:67:a5:eb:94:7b:af:
                    46:8d:1b:92:ed:ef:fe:20:c8:1f:39:d0:e5:f1:ac:
                    f1:7f:a9:81:ab:9a:28:bf:23:16:fc:9a:40:b5:04:
```

## 각 EC2마다 필요한 인증서들을 전송

### jumpbox EC2 -> node-0, node-1 EC2

```bash
root@jumpbox:~/kubernetes-the-hard-way# for host in node-0 node-1; do
  ssh root@${host} mkdir /var/lib/kubelet/

  scp ca.crt root@${host}:/var/lib/kubelet/

  scp ${host}.crt \
    root@${host}:/var/lib/kubelet/kubelet.crt

  scp ${host}.key \
    root@${host}:/var/lib/kubelet/kubelet.key
done

ca.crt                                                    100% 1899     3.5MB/s   00:00    
node-0.crt                                                100% 2147     5.3MB/s   00:00    
node-0.key                                                100% 3272     7.4MB/s   00:00    
ca.crt                                                    100% 1899     4.5MB/s   00:00    
node-1.crt                                                100% 2147     3.9MB/s   00:00    
node-1.key                                                100% 3272     4.1MB/s   00:00

# 확인
root@jumpbox:~/kubernetes-the-hard-way# ssh node-0 ls -l /var/lib/kubelet
total 12
-rw-r--r-- 1 root root 1899 Jan 10 12:20 ca.crt
-rw-r--r-- 1 root root 2147 Jan 10 12:20 kubelet.crt
-rw------- 1 root root 3272 Jan 10 12:20 kubelet.key

root@jumpbox:~/kubernetes-the-hard-way# ssh node-1 ls -l /var/lib/kubelet
total 12
-rw-r--r-- 1 root root 1899 Jan 10 12:20 ca.crt
-rw-r--r-- 1 root root 2147 Jan 10 12:20 kubelet.crt
-rw------- 1 root root 3272 Jan 10 12:20 kubelet.key
```

### jumpbox EC2 -> server EC2

```bash
root@jumpbox:~/kubernetes-the-hard-way# scp \
  ca.key ca.crt \
  kube-api-server.key kube-api-server.crt \
  service-accounts.key service-accounts.crt \
  root@server:~/
ca.key                                                    100% 3272     4.2MB/s   00:00    
ca.crt                                                    100% 1899     2.4MB/s   00:00    
kube-api-server.key                                       100% 3272     6.1MB/s   00:00    
kube-api-server.crt                                       100% 2354     4.0MB/s   00:00    
service-accounts.key                                      100% 3272     5.4MB/s   00:00    
service-accounts.crt                                      100% 2004     3.7MB/s   00:00 

# 확인
root@jumpbox:~/kubernetes-the-hard-way# ssh server ls -l /root
total 24
-rw-r--r-- 1 root root 1899 Jan 10 12:24 ca.crt
-rw------- 1 root root 3272 Jan 10 12:24 ca.key
-rw-r--r-- 1 root root 2354 Jan 10 12:24 kube-api-server.crt
-rw------- 1 root root 3272 Jan 10 12:24 kube-api-server.key
-rw-r--r-- 1 root root 2004 Jan 10 12:24 service-accounts.crt
-rw------- 1 root root 3272 Jan 10 12:24 service-accounts.key
```

