# k8s 암호화 설정

```bash
# Generate an encryption key
root@jumpbox:~/kubernetes-the-hard-way# export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
root@jumpbox:~/kubernetes-the-hard-way# echo $ENCRYPTION_KEY
gKosSfT9sRCaYxhkBv0VrVJrD/m6dAUnjCxL6WjIBAM=

# The Encryption Config File

# Create the encryption-config.yaml encryption config file
# (참고) 실제 etcd 값에 기록되는 헤더 : k8s:enc:aescbc:v1:key1:<ciphertext>

root@jumpbox:~/kubernetes-the-hard-way# cat configs/encryption-config.yaml
kind: EncryptionConfiguration           # kube-apiserver가 etcd에 저장할 리소스를 어떻게 암호화할지 정의
apiVersion: apiserver.config.k8s.io/v1  # --encryption-provider-config 플래그로 참조
resources:
  - resources:
      - secrets                         # 암호화 대상 Kubernetes 리소스 : 여기서는 Secret 리소스만 암호화
    providers:                          # 지원 providers(위 부터 적용됨) : identity, aescbc, aesgcm, kms v2, secretbox
      - aescbc:                         # etcd에 저장될 Secret을 AES-CBC 방식으로 암호화
          keys:
            - name: key1                # 키 식별자 (etcd 데이터에 기록됨)
              secret: ${ENCRYPTION_KEY}
      - identity: {}                    # 암호화하지 않음 (Plaintext), 주로 하위 호환성 / 점진적 암호화 목적

root@jumpbox:~/kubernetes-the-hard-way# envsubst < configs/encryption-config.yaml > encryption-config.yaml


root@jumpbox:~/kubernetes-the-hard-way# cat encryption-config.yaml
kind: EncryptionConfiguration
apiVersion: apiserver.config.k8s.io/v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: gKosSfT9sRCaYxhkBv0VrVJrD/m6dAUnjCxL6WjIBAM=
      - identity: {}


# Copy the encryption-config.yaml encryption config file to each controller instance:
root@jumpbox:~/kubernetes-the-hard-way# scp encryption-config.yaml root@server:~/
root@server's password: 
encryption-config.yaml                                    100%  271   387.7KB/s   00:00    

root@jumpbox:~/kubernetes-the-hard-way# ssh server ls -l /root/encryption-config.yaml
root@server's password: 
-rw-r--r-- 1 root root 271 Jan 10 12:43 /root/encryption-config.yaml
```