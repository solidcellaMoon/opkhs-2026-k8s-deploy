# 9. pod 대역 통신을 위한 네트워크 라우팅 설정

node-0/1에 PodCIDR과 통신을 위한 OS 커널에 (수동) 라우팅 설정

| 항목               | 네트워크 대역 or IP     |
| ---------------- | ----------------- |
| clusterCIDR      | 10.200.0.0/16     |
| → node-0 PodCIDR | **10.200.0.0/24** |
| → node-1 PodCIDR | **10.200.1.0/24** |
| ServiceCIDR      | 10.32.0.0/24      |
| → api clusterIP  | 10.32.0.1         |

```bash
# The Routing Table
# In this section you will gather the information required to create routes in the kubernetes-the-hard-way VPC network.

# Print the internal IP address and Pod CIDR range for each worker instance:

root@jumpbox:~/kubernetes-the-hard-way# SERVER_IP=$(grep server machines.txt | cut -d " " -f 1)
root@jumpbox:~/kubernetes-the-hard-way# NODE_0_IP=$(grep node-0 machines.txt | cut -d " " -f 1)
root@jumpbox:~/kubernetes-the-hard-way# NODE_0_SUBNET=$(grep node-0 machines.txt | cut -d " " -f 4)
root@jumpbox:~/kubernetes-the-hard-way# NODE_1_IP=$(grep node-1 machines.txt | cut -d " " -f 1)
root@jumpbox:~/kubernetes-the-hard-way# NODE_1_SUBNET=$(grep node-1 machines.txt | cut -d " " -f 4)


root@jumpbox:~/kubernetes-the-hard-way# echo $SERVER_IP $NODE_0_IP $NODE_0_SUBNET $NODE_1_IP $NODE_1_SUBNET
172.31.5.196 172.31.8.112 10.200.0.0/24 172.31.15.209 10.200.1.0/24


root@jumpbox:~/kubernetes-the-hard-way# ssh server ip -c route
root@server's password: 
default via 172.31.0.1 dev ens5 proto dhcp src 172.31.5.196 metric 100 
172.31.0.0/20 dev ens5 proto kernel scope link src 172.31.5.196 metric 100 
172.31.0.1 dev ens5 proto dhcp scope link src 172.31.5.196 metric 100 
172.31.0.2 dev ens5 proto dhcp scope link src 172.31.5.196 metric 100 



root@jumpbox:~/kubernetes-the-hard-way# ssh root@server <<EOF
  ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
  ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF
Pseudo-terminal will not be allocated because stdin is not a terminal.


root@jumpbox:~/kubernetes-the-hard-way# ssh server ip -c route
root@server's password: 
default via 172.31.0.1 dev ens5 proto dhcp src 172.31.5.196 metric 100 
10.200.0.0/24 via 172.31.8.112 dev ens5 
10.200.1.0/24 via 172.31.15.209 dev ens5 
172.31.0.0/20 dev ens5 proto kernel scope link src 172.31.5.196 metric 100 
172.31.0.1 dev ens5 proto dhcp scope link src 172.31.5.196 metric 100 
172.31.0.2 dev ens5 proto dhcp scope link src 172.31.5.196 metric 100 





root@jumpbox:~/kubernetes-the-hard-way# ssh node-0 ip -c route
root@node-0's password: 
default via 172.31.0.1 dev ens5 proto dhcp src 172.31.8.112 metric 100 
172.31.0.0/20 dev ens5 proto kernel scope link src 172.31.8.112 metric 100 
172.31.0.1 dev ens5 proto dhcp scope link src 172.31.8.112 metric 100 
172.31.0.2 dev ens5 proto dhcp scope link src 172.31.8.112 metric 100

root@jumpbox:~/kubernetes-the-hard-way# ssh root@node-0 <<EOF
  ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF
Pseudo-terminal will not be allocated because stdin is not a terminal.

root@jumpbox:~/kubernetes-the-hard-way# ssh node-0 ip -c route
root@node-0's password: 
default via 172.31.0.1 dev ens5 proto dhcp src 172.31.8.112 metric 100 
10.200.1.0/24 via 172.31.15.209 dev ens5 
172.31.0.0/20 dev ens5 proto kernel scope link src 172.31.8.112 metric 100 
172.31.0.1 dev ens5 proto dhcp scope link src 172.31.8.112 metric 100 
172.31.0.2 dev ens5 proto dhcp scope link src 172.31.8.112 metric 100 




root@jumpbox:~/kubernetes-the-hard-way# ssh node-1 ip -c route
root@node-1's password: 
default via 172.31.0.1 dev ens5 proto dhcp src 172.31.15.209 metric 100 
172.31.0.0/20 dev ens5 proto kernel scope link src 172.31.15.209 metric 100 
172.31.0.1 dev ens5 proto dhcp scope link src 172.31.15.209 metric 100 
172.31.0.2 dev ens5 proto dhcp scope link src 172.31.15.209 metric 100


root@jumpbox:~/kubernetes-the-hard-way# ssh root@node-1 <<EOF
  ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
EOF
Pseudo-terminal will not be allocated because stdin is not a terminal.


root@jumpbox:~/kubernetes-the-hard-way# ssh node-1 ip -c route
root@node-1's password: 
default via 172.31.0.1 dev ens5 proto dhcp src 172.31.15.209 metric 100 
10.200.0.0/24 via 172.31.8.112 dev ens5 
172.31.0.0/20 dev ens5 proto kernel scope link src 172.31.15.209 metric 100 
172.31.0.1 dev ens5 proto dhcp scope link src 172.31.15.209 metric 100 
172.31.0.2 dev ens5 proto dhcp scope link src 172.31.15.209 metric 100 
```