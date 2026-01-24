# x509-certificate-exporter에 대해서

k8s 인증서 만료기간 모니터링을 위해 x509-certificate-exporter를 사용해보자.
- x509-certificate-exporter: https://github.com/enix/x509-certificate-exporter
  - Grafana Dashboard ID: 13922
- cert-exporter: https://github.com/joe-elliott/cert-exporter


## install
- values 파일 주요 내용
    - 데몬셋 2종류 배포 : 컨트롤 플레인 노드들 수집(cp), 워커 노드들 수집(nodes)
    - 수집 종류 : 인증서(crt) 파일, kubeconfig 파일 → 직접 파일 위치 설정
    - 프로메테우스 알람 설정 활성화 : warning Days Left(28 일), critical Days Left(14일)
    - 그라파나 대시보드 추가 활성화

```bash
# w1/w2 에 node label 설정
[root@k8s-ctr ~]# k label node k8s-w1 worker="true" --overwrite
node/k8s-w1 labeled

[root@k8s-ctr ~]# k label node k8s-w2 worker="true" --overwrite
node/k8s-w2 labeled

[root@k8s-ctr ~]# k get nodes -l worker=true
NAME     STATUS   ROLES    AGE   VERSION
k8s-w1   Ready    <none>   24m   v1.32.11
k8s-w2   Ready    <none>   21m   v1.32.11

# values 파일 작성
cat << EOF > cert-export-values.yaml
# -- hostPaths Exporter
hostPathsExporter:
  hostPathVolumeType: Directory

  daemonSets:
    cp:
      nodeSelector:
        node-role.kubernetes.io/control-plane: ""
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/control-plane
        operator: Exists
      watchFiles:
      - /var/lib/kubelet/pki/kubelet-client-current.pem
      - /var/lib/kubelet/pki/kubelet.crt
      - /etc/kubernetes/pki/apiserver.crt
      - /etc/kubernetes/pki/apiserver-etcd-client.crt
      - /etc/kubernetes/pki/apiserver-kubelet-client.crt
      - /etc/kubernetes/pki/ca.crt
      - /etc/kubernetes/pki/front-proxy-ca.crt
      - /etc/kubernetes/pki/front-proxy-client.crt
      - /etc/kubernetes/pki/etcd/ca.crt
      - /etc/kubernetes/pki/etcd/healthcheck-client.crt
      - /etc/kubernetes/pki/etcd/peer.crt
      - /etc/kubernetes/pki/etcd/server.crt
      watchKubeconfFiles:
      - /etc/kubernetes/admin.conf
      - /etc/kubernetes/controller-manager.conf
      - /etc/kubernetes/scheduler.conf

    nodes:
      nodeSelector:
        worker: "true"
      watchFiles:
      - /var/lib/kubelet/pki/kubelet-client-current.pem
      - /etc/kubernetes/pki/ca.crt

prometheusServiceMonitor:
  create: true
  scrapeInterval: 15s
  scrapeTimeout: 10s
  extraLabels:
    release: kube-prometheus-stack

prometheusRules:
  create: true
  warningDaysLeft: 28
  criticalDaysLeft: 14
  extraLabels:
    release: kube-prometheus-stack

grafana:
  createDashboard: true
secretsExporter:
  enabled: false
EOF

# helm chart 설치
helm repo add enix https://charts.enix.io
helm install x509-certificate-exporter enix/x509-certificate-exporter -n monitoring --values cert-export-values.yaml

# 설치 확인
[root@k8s-ctr ~]# helm list -n monitoring
NAME                            NAMESPACE       REVISION        UPDATED                                  STATUS          CHART                            APP VERSION
kube-prometheus-stack           monitoring      1               2026-01-24 14:21:49.701991854 +0000 UTC  deployed        kube-prometheus-stack-80.13.3    v0.87.1    
x509-certificate-exporter       monitoring      1               2026-01-24 14:37:37.571818467 +0000 UTC  deployed        x509-certificate-exporter-3.19.1 3.19.1 

## x509 대시보드 추가 : grafana sidecar 컨테이너가 configmap 확인 후 추가
[root@k8s-ctr ~]# k get cm -n monitoring x509-certificate-exporter-dashboard
NAME                                  DATA   AGE
x509-certificate-exporter-dashboard   1      46s

[root@k8s-ctr ~]# k get cm -n monitoring x509-certificate-exporter-dashboard -o yaml | grep -C 5 "13922"
        ]
      },
      "description": "Unified dashboard for checking certificates expiration: Kubernetes Secrets, certificate files on nodes, or on any server.",
      "editable": true,
      "fiscalYearStartMonth": 0,
      "gnetId": 13922,
      "graphTooltip": 0,
      "id": null,
      "links": [],
      "panels": [
        {

# 데몬셋 확인 : cp, nodes 각각
[root@k8s-ctr ~]# k get ds -n monitoring -l app.kubernetes.io/instance=x509-certificate-exporter
NAME                              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                            AGE
x509-certificate-exporter-cp      1         1         1       1            1           node-role.kubernetes.io/control-plane=   119s
x509-certificate-exporter-nodes   2         2         2       2            2           worker=true                              119s

# 파드 정보 확인 : IP 확인
[root@k8s-ctr ~]# k get pod -n monitoring -l app.kubernetes.io/instance=x509-certificate-exporter -owide
NAME                                    READY   STATUS    RESTARTS   AGE     IP           NODE      NOMINATED NODE   READINESS GATES
x509-certificate-exporter-cp-4c2hs      1/1     Running   0          2m18s   10.244.0.4   k8s-ctr   <none>           <none>
x509-certificate-exporter-nodes-8zz8m   1/1     Running   0          2m18s   10.244.1.8   k8s-w1    <none>           <none>
x509-certificate-exporter-nodes-fms4n   1/1     Running   0          2m18s   10.244.3.4   k8s-w2    <none>           <none>

# 프로메테우스 서비스모니터 수집을 위한 Service(ClusterIP) 정보 확인
[root@k8s-ctr ~]# k get svc,ep -n monitoring x509-certificate-exporter
NAME                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/x509-certificate-exporter   ClusterIP   10.96.228.222   <none>        9793/TCP   2m36s

NAME                                  ENDPOINTS                                         AGE
endpoints/x509-certificate-exporter   10.244.0.4:9793,10.244.1.8:9793,10.244.3.4:9793   2m36s

# 컨트롤플레인 노드에 배포된 'x509 익스포터' 파드에 메트릭 호출 확인
[root@k8s-ctr ~]# curl -s 10.244.0.4:9793/metrics | grep '^x509' | head -n 3
x509_cert_expired{filename="apiserver-etcd-client.crt",filepath="/etc/kubernetes/pki/apiserver-etcd-client.crt",issuer_CN="etcd-ca",serial_number="1002621958514806630",subject_CN="kube-apiserver-etcd-client"} 0
x509_cert_expired{filename="apiserver.crt",filepath="/etc/kubernetes/pki/apiserver.crt",issuer_CN="kubernetes",serial_number="4640757581642793600",subject_CN="kube-apiserver"} 0
x509_cert_expired{filename="ca.crt",filepath="/etc/kubernetes/pki/ca.crt",issuer_CN="kubernetes",serial_number="8646541998922360003",subject_CN="kubernetes"} 0

# 워커 노드에 배포된 'x509 익스포터' 파드에 메트릭 호출 확인
[root@k8s-ctr ~]# curl -s 10.244.1.8:9793/metrics | grep '^x509' | head -n 3
x509_cert_expired{filename="ca.crt",filepath="/etc/kubernetes/pki/ca.crt",issuer_CN="kubernetes",serial_number="8646541998922360003",subject_CN="kubernetes"} 0
x509_cert_expired{filename="kubelet-client-current.pem",filepath="/var/lib/kubelet/pki/kubelet-client-current.pem",issuer_CN="kubernetes",serial_number="130088106758482436399647409980572724693",subject_CN="system:node:k8s-w1",subject_O="system:nodes"} 0
x509_cert_not_after{filename="ca.crt",filepath="/etc/kubernetes/pki/ca.crt",issuer_CN="kubernetes",serial_number="8646541998922360003",subject_CN="kubernetes"} 2.08462204e+09
```

