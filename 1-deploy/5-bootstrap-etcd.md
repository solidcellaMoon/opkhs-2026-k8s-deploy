# 5. etcd 구동

## Prerequisites
- hostname 변경 : controller -> server
- http 평문 통신
```bash
# Each etcd member must have a unique name within an etcd cluster. 
# Set the etcd name to match the hostname of the current compute instance:
root@jumpbox:~/kubernetes-the-hard-way# cat units/etcd.service | grep controller
  --name controller \
  --initial-cluster controller=http://127.0.0.1:2380 \

# 변경 후 확인
root@jumpbox:~/kubernetes-the-hard-way# cat units/etcd.service | grep server
  --name server \
  --initial-cluster server=http://127.0.0.1:2380 \

# Copy etcd binaries and systemd unit files to the server machine
root@jumpbox:~/kubernetes-the-hard-way# scp \
  downloads/controller/etcd \
  downloads/client/etcdctl \
  units/etcd.service \
  root@server:~/
etcd                                                      100%   24MB  98.1MB/s   00:00    
etcdctl                                                   100%   16MB 281.7MB/s   00:00    
etcd.service                                              100%  564     1.0MB/s   00:00    
```

## etcd 구동

```bash
# Install the etcd Binaries
# Extract and install the etcd server and the etcdctl command line utility
root@server:~# pwd
/root
root@server:~# ls
admin.kubeconfig        etcd.service                        kube-scheduler.kubeconfig
ca.crt                  etcdctl                             service-accounts.crt
ca.key                  kube-api-server.crt                 service-accounts.key
encryption-config.yaml  kube-api-server.key
etcd                    kube-controller-manager.kubeconfig


root@server:~# mv etcd etcdctl /usr/local/bin/


# Configure the etcd Server
root@server:~# mkdir -p /etc/etcd /var/lib/etcd
root@server:~# chmod 700 /var/lib/etcd
root@server:~# cp ca.crt kube-api-server.key kube-api-server.crt /etc/etcd/

# Create the etcd.service systemd unit file:
root@server:~# mv etcd.service /etc/systemd/system/

root@server:~# tree /etc/systemd/system/
/etc/systemd/system/
├── cloud-config.target.wants
│   └── cloud-init-hotplugd.socket -> /usr/lib/systemd/system/cloud-init-hotplugd.socket
├── cloud-init.target.wants
│   ├── cloud-config.service -> /usr/lib/systemd/system/cloud-config.service
│   ├── cloud-final.service -> /usr/lib/systemd/system/cloud-final.service
│   ├── cloud-init-local.service -> /usr/lib/systemd/system/cloud-init-local.service
│   ├── cloud-init-main.service -> /usr/lib/systemd/system/cloud-init-main.service
│   └── cloud-init-network.service -> /usr/lib/systemd/system/cloud-init-network.service
├── dbus-org.freedesktop.network1.service -> /usr/lib/systemd/system/systemd-networkd.service
├── dbus-org.freedesktop.resolve1.service -> /usr/lib/systemd/system/systemd-resolved.service
├── dbus-org.freedesktop.timesync1.service -> /usr/lib/systemd/system/systemd-timesyncd.service
├── etcd.service
├── getty.target.wants
│   └── getty@tty1.service -> /usr/lib/systemd/system/getty@.service
├── hibernate.target.wants
│   └── grub-common.service -> /usr/lib/systemd/system/grub-common.service
├── hybrid-sleep.target.wants
│   └── grub-common.service -> /usr/lib/systemd/system/grub-common.service
├── multi-user.target.wants
│   ├── amazon-ssm-agent.service -> /usr/lib/systemd/system/amazon-ssm-agent.service
│   ├── e2scrub_reap.service -> /usr/lib/systemd/system/e2scrub_reap.service
│   ├── grub-common.service -> /usr/lib/systemd/system/grub-common.service
│   ├── remote-fs.target -> /usr/lib/systemd/system/remote-fs.target
│   ├── ssh.service -> /usr/lib/systemd/system/ssh.service
│   ├── systemd-networkd.service -> /usr/lib/systemd/system/systemd-networkd.service
│   └── unattended-upgrades.service -> /usr/lib/systemd/system/unattended-upgrades.service
├── network-online.target.wants
│   └── systemd-networkd-wait-online.service -> /usr/lib/systemd/system/systemd-networkd-wait-online.service
├── sockets.target.wants
│   ├── systemd-networkd.socket -> /usr/lib/systemd/system/systemd-networkd.socket
│   └── uuidd.socket -> /usr/lib/systemd/system/uuidd.socket
├── ssh.service.wants
│   └── sshd-keygen.service -> /usr/lib/systemd/system/sshd-keygen.service
├── ssh.socket.wants
│   └── sshd-keygen.service -> /usr/lib/systemd/system/sshd-keygen.service
├── sshd.service -> /usr/lib/systemd/system/ssh.service
├── sshd.service.wants
│   └── sshd-keygen.service -> /usr/lib/systemd/system/sshd-keygen.service
├── sshd@.service.wants
│   └── sshd-keygen.service -> /usr/lib/systemd/system/sshd-keygen.service
├── suspend-then-hibernate.target.wants
│   └── grub-common.service -> /usr/lib/systemd/system/grub-common.service
├── suspend.target.wants
│   └── grub-common.service -> /usr/lib/systemd/system/grub-common.service
├── sysinit.target.wants
│   ├── systemd-network-generator.service -> /usr/lib/systemd/system/systemd-network-generator.service
│   ├── systemd-pstore.service -> /usr/lib/systemd/system/systemd-pstore.service
│   ├── systemd-resolved.service -> /usr/lib/systemd/system/systemd-resolved.service
│   └── systemd-timesyncd.service -> /usr/lib/systemd/system/systemd-timesyncd.service
└── timers.target.wants
    ├── apt-daily-upgrade.timer -> /lib/systemd/system/apt-daily-upgrade.timer
    ├── apt-daily.timer -> /lib/systemd/system/apt-daily.timer
    ├── dpkg-db-backup.timer -> /lib/systemd/system/dpkg-db-backup.timer
    ├── e2scrub_all.timer -> /usr/lib/systemd/system/e2scrub_all.timer
    ├── fstrim.timer -> /lib/systemd/system/fstrim.timer
    └── man-db.timer -> /usr/lib/systemd/system/man-db.timer

17 directories, 40 files


# Start the etcd Server
root@server:~# systemctl daemon-reload
root@server:~# systemctl enable etcd
Created symlink '/etc/systemd/system/multi-user.target.wants/etcd.service' → '/etc/systemd/system/etcd.service'.
root@server:~# systemctl start etcd


# 확인
root@server:~# systemctl status etcd --no-pager
● etcd.service - etcd
     Loaded: loaded (/etc/systemd/system/etcd.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-01-10 12:50:00 UTC; 19s ago
 Invocation: bc1409d11da148168bb57df79594a7c8
       Docs: https://github.com/etcd-io/etcd
   Main PID: 2486 (etcd)
      Tasks: 7 (limit: 2293)
     Memory: 11.7M (peak: 12.9M)
        CPU: 156ms
     CGroup: /system.slice/etcd.service
             └─2486 /usr/local/bin/etcd --name server --initial-advertise-peer-urls http://…

Jan 10 12:50:00 server etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…mon"}
Jan 10 12:50:00 server etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…mon"}
Jan 10 12:50:00 server systemd[1]: Started etcd.service - etcd.
Jan 10 12:50:00 server etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…ING"}
Jan 10 12:50:00 server etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…3.6"}
Jan 10 12:50:00 server etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…3.6"}
Jan 10 12:50:00 server etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…3.6"}
Jan 10 12:50:00 server etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…5.0"}
Jan 10 12:50:00 server etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…6.0"}
Jan 10 12:50:00 server etcd[2486]: {"level":"info","ts":"2026-01-10T12:50:00.…379"}
Hint: Some lines were ellipsized, use -l to show in full.

root@server:~# ss -tnlp | grep etcd
LISTEN 0      4096       127.0.0.1:2380      0.0.0.0:*    users:(("etcd",pid=2486,fd=3))           
LISTEN 0      4096       127.0.0.1:2379      0.0.0.0:*    users:(("etcd",pid=2486,fd=6))    

# List the etcd cluster members
root@server:~# etcdctl member list
6702b0a34e2cfd39, started, server, http://127.0.0.1:2380, http://127.0.0.1:2379, false


root@server:~# etcdctl member list -w table
+------------------+---------+--------+-----------------------+-----------------------+------------+
|        ID        | STATUS  |  NAME  |      PEER ADDRS       |     CLIENT ADDRS      | IS LEARNER |
+------------------+---------+--------+-----------------------+-----------------------+------------+
| 6702b0a34e2cfd39 | started | server | http://127.0.0.1:2380 | http://127.0.0.1:2379 |      false |
+------------------+---------+--------+-----------------------+-----------------------+------------+


root@server:~# etcdctl endpoint status -w table
+----------------+------------------+------------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+
|    ENDPOINT    |        ID        |  VERSION   | STORAGE VERSION | DB SIZE | IN USE | PERCENTAGE NOT IN USE | QUOTA | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS | DOWNGRADE TARGET VERSION | DOWNGRADE ENABLED |
+----------------+------------------+------------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+
| 127.0.0.1:2379 | 6702b0a34e2cfd39 | 3.6.0-rc.3 |           3.6.0 |   20 kB |  16 kB |                   20% |   0 B |      true |      false |         2 |          4 |                  4 |        |                          |             false |
+----------------+------------------+------------+-----------------+---------+--------+-----------------------+-------+-----------+------------+-----------+------------+--------------------+--------+--------------------------+-------------------+

root@server:~# exit
```