# monitoring 세팅

k8s 클러스터에 대한 기본적인 모니터링 스택을 배포해본다.

## metrics-server
```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server --set 'args[0]=--kubelet-insecure-tls' -n kube-system

# 확인
[root@k8s-ctr ~]# kubectl top node
NAME      CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
k8s-ctr   130m         3%       765Mi           4%          
k8s-w1    20m          1%       290Mi           8%          
k8s-w2    26m          1%       327Mi           9%   

[root@k8s-ctr ~]# kubectl top pod -A --sort-by='cpu'
NAMESPACE      NAME                              CPU(cores)   MEMORY(bytes)   
kube-system    kube-apiserver-k8s-ctr            29m          205Mi           
kube-system    etcd-k8s-ctr                      14m          35Mi            
kube-system    kube-controller-manager-k8s-ctr   10m          49Mi            
kube-flannel   kube-flannel-ds-vkgb7             8m           13Mi            
kube-system    kube-scheduler-k8s-ctr            6m           23Mi            
kube-flannel   kube-flannel-ds-8mxwr             6m           13Mi            
kube-flannel   kube-flannel-ds-9fj94             5m           13Mi            
kube-system    metrics-server-5dd7b49d79-gg6hh   3m           15Mi            
kube-system    coredns-668d6bf9bc-m9wgw          1m           16Mi            
kube-system    kube-proxy-qtfn5                  1m           14Mi            
kube-system    kube-proxy-wvktp                  1m           17Mi            
kube-system    kube-proxy-9mmtj                  1m           16Mi            
kube-system    coredns-668d6bf9bc-s2444          1m           16Mi            

[root@k8s-ctr ~]# kubectl top pod -A --sort-by='memory'
NAMESPACE      NAME                              CPU(cores)   MEMORY(bytes)   
kube-system    kube-apiserver-k8s-ctr            27m          205Mi           
kube-system    kube-controller-manager-k8s-ctr   10m          49Mi            
kube-system    etcd-k8s-ctr                      13m          35Mi            
kube-system    kube-scheduler-k8s-ctr            6m           23Mi            
kube-system    kube-proxy-wvktp                  1m           17Mi            
kube-system    kube-proxy-9mmtj                  1m           16Mi            
kube-system    coredns-668d6bf9bc-s2444          2m           16Mi            
kube-system    coredns-668d6bf9bc-m9wgw          1m           16Mi            
kube-system    metrics-server-5dd7b49d79-gg6hh   3m           15Mi            
kube-system    kube-proxy-qtfn5                  1m           14Mi            
kube-flannel   kube-flannel-ds-8mxwr             6m           13Mi            
kube-flannel   kube-flannel-ds-9fj94             6m           13Mi            
kube-flannel   kube-flannel-ds-vkgb7             6m           13Mi 
```

## kube-prometheus-stack
```bash
# repo 추가
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# 파라미터 파일 생성
cat <<EOT > monitor-values.yaml
prometheus:
  prometheusSpec:
    scrapeInterval: "20s"
    evaluationInterval: "20s"
    externalLabels:
      cluster: "myk8s-cluster"
  service:
    type: NodePort
    nodePort: 30001

grafana:
  defaultDashboardsTimezone: Asia/Seoul
  adminPassword: prom-operator
  service:
    type: NodePort
    nodePort: 30002

alertmanager:
  enabled: true
defaultRules:
  create: true

kubeProxy:
  enabled: false
prometheus-windows-exporter:
  prometheus:
    monitor:
      enabled: false
EOT

# 배포
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 80.13.3 \
-f monitor-values.yaml --create-namespace --namespace monitoring

...
NAME: kube-prometheus-stack
LAST DEPLOYED: Sat Jan 24 14:21:49 2026
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=kube-prometheus-stack"

Get Grafana 'admin' user password by running:

  kubectl --namespace monitoring get secrets kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

Access Grafana local instance:

  export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=kube-prometheus-stack" -oname)
  kubectl --namespace monitoring port-forward $POD_NAME 3000

Get your grafana admin user password by running:

  kubectl get secret --namespace monitoring -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo


Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.


# 각각 웹 접속 실행 : NodePort 접속
open http://{k8s-ctr_public_ip}:30001 # prometheus
open http://{k8s-ctr_public_ip}:30002 # grafana : 접속 계정 admin / prom-operator
```

Grafana에서 대시보드 추가
- Dashboard → New → Import → 15661, 15757 입력 후 Load ⇒ 데이터소스(Prometheus 선택) 후 Import 클릭


## control plane 컴포넌트 메트릭 수집 설정
- kube-controller-manager, etcd, kube-scheduler

```bash
# kube-controller-manager
[root@k8s-ctr ~]# sed -i 's|--bind-address=127.0.0.1|--bind-address=0.0.0.0|g' /etc/kubernetes/manifests/kube-controller-manager.yaml

[root@k8s-ctr ~]# cat /etc/kubernetes/manifests/kube-controller-manager.yaml | grep bind-address
    - --bind-address=0.0.0.0

# kube-scheduler
[root@k8s-ctr ~]# sed -i 's|--bind-address=127.0.0.1|--bind-address=0.0.0.0|g' /etc/kubernetes/manifests/kube-scheduler.yaml

[root@k8s-ctr ~]# cat /etc/kubernetes/manifests/kube-scheduler.yaml | grep bind-address
    - --bind-address=0.0.0.0

# etcd metrics-url(http) 127.0.0.1 에 172.31.7.91 추가
[root@k8s-ctr ~]# sed -i 's|--listen-metrics-urls=http://127.0.0.1:2381|--listen-metrics-urls=http://127.0.0.1:2381,http://172.31.7.91:2381|g' /etc/kubernetes/manifests/etcd.yaml

[root@k8s-ctr ~]# cat /etc/kubernetes/manifests/etcd.yaml | grep listen-metrics-urls
    - --listen-metrics-urls=http://127.0.0.1:2381,http://172.31.7.91:2381
```

이후 그라파나에서 etcd 대시보드를 보면 메트릭이 표시된다.