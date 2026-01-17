# Playbook 기본

## 플레이북 환경 설정
- 앤서블 작업 디렉토리에 `ansible.cfg` 파일을 생성하면, 다양한 앤서블 설정을 적용할 수 있다.
- 앤서블 환경 설정 파일에는 각 섹션에 key-value 쌍으로 정의된 설정이 포함되며, 여러 개의 섹션으로 구성된다.
- 섹션 제목은 대괄호로 묶여 있으며, 기본적인 실행을 위해 다음 예제와 같이 `[defaults]`와 `[privilege_escalation]` 두 개의 섹션으로 구성한다.

```bash
[defaults]
inventory = ./inventory
remote_user = root
ask_pass = false

[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_ask_pass = false
```

앤서블은 리눅스에서 기본적으로 SSH를 통해 Managed Node에 연결한다.

### `[defaults]` 섹션
앤서블 작업을 위한 기본값 설정
- Managed Node에 연결하는 방법을 제어하는 가장 중요한 매개 변수가 설정된다.
- 별도로 설정되어 있지 않다면, 앤서블은 실행 시 **로컬 사용자와 같은 사용자 이름**을 사용하여 관리 호스트에 연결한다.
- 이때, 다른 사용자를 지정하려면 `remote_user` 매개 변수를 사용하면 된다.

| 매개 변수       | 설명                                                                         |
| ----------- | -------------------------------------------------------------------------- |
| inventory   | 인벤토리 파일의 경로를 지정함.                                                          |
| remote_user | 앤서블이 관리 호스트에 연결할 때 사용하는 사용자 이름을 지정함. 이때, 사용자 이름을 지정하지 않으면 현재 사용자 이름으로 지정됨. |
| ask_pass    | SSH 암호를 묻는 메시지 표시 여부를 지정함. SSH 공개 키 인증을 사용하는 경우 기본값은 false임.               |


### `[privilege_escalation]` 섹션

보안/감사로 인해 원격 호스트에 권한 없는 사용자 연결 후 관리 액세스 권한을 에스컬레이션하여 루트 사용자로 가져올 때

| 매개 변수           | 설명                                                                                                                                                 |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| become          | 기본적으로 권한 에스컬레이션을 활성화할 때 사용하며, 연결 후 관리 호스트에서 자동으로 사용자를 전환할지 여부를 지정함.  <br>일반적으로 root로 전환되며, 플레이북에서도 지정할 수 있음.                                       |
| become_method   | 권한을 에스컬레이션하는 사용자 전환 방식을 의미함. 일반적으로 기본값은 sudo를 사용하며, su는 옵션으로 설정할 수 있음.                                                                             |
| become_user     | 관리 호스트에서 전환할 사용자를 지정함. 일반적으로 기본값은 root임.                                                                                                           |
| become_ask_pass | become_method 매개 변수에 대한 암호를 묻는 메시지 표시 여부를 지정함. 기본값은 false임.  <br>권한을 에스컬레이션하기 위해 사용자가 암호를 입력해야 하는 경우, 구성 파일에 become_ask_pass = true 매개 변수를 설정하면 됨. |

---

이제 실습을 위한 설정을 이어서 진행해본다.
```bash
root@server:~/my-ansible# cat <<EOT > ansible.cfg
[defaults]
inventory = ./inventory
remote_user = root
ask_pass = false

[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_ask_pass = false
EOT

root@server:~/my-ansible# cat ansible.cfg 
[defaults]
inventory = ./inventory
remote_user = root
ask_pass = false

[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_ask_pass = false
```

## ad hoc commands

### ping 모듈
- ping 모듈을 이용하여 web 그룹의 호스트로 정상 연결(pong반환)이면 ‘SUCCESS’ 출력 (icmp ping 아니며, python 테스트 모듈)
  
```bash
#
root@server:~/my-ansible# ansible -m ping web
[WARNING]: Host 'tnode1' is using the discovered Python interpreter at '/usr/bin/python3.12', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.19/reference_appendices/interpreter_discovery.html for more information.
tnode1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.12"
    },
    "changed": false,
    "ping": "pong"
}
[WARNING]: Host 'tnode2' is using the discovered Python interpreter at '/usr/bin/python3.12', but future installation of another Python interpreter could cause a different interpreter to be discovered. See https://docs.ansible.com/ansible-core/2.19/reference_appendices/interpreter_discovery.html for more information.
tnode2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.12"
    },
    "changed": false,
    "ping": "pong"
}

# ⬆️ Ansible이 '지금은 잘 동작하지만 미래에 예기치 않게 Python 인터프리터가 바뀔 수 있다'는 점을 알려주는 예방용 경고
# 암묵적 Python 자동 선택을 지양하고, 명시적 설정을 권장 : 기본값(ansible_python_interpreter=auto)

---

# inventory 그룹 구성
root@server:~/my-ansible# cat <<EOT > inventory
[web]
tnode1 ansible_python_interpreter=/usr/bin/python3
tnode2 ansible_python_interpreter=/usr/bin/python3

[db]
tnode3 ansible_python_interpreter=/usr/bin/python3

[all:children]
web
db
EOT

root@server:~/my-ansible# ansible-inventory -i ./inventory --list | jq
{
  "_meta": {
    "hostvars": {
      "tnode1": {
        "ansible_python_interpreter": "/usr/bin/python3"
      },
      "tnode2": {
        "ansible_python_interpreter": "/usr/bin/python3"
      },
      "tnode3": {
        "ansible_python_interpreter": "/usr/bin/python3"
      }
    },
    "profile": "inventory_legacy"
  },
  "all": {
    "children": [
      "ungrouped",
      "web",
      "db"
    ]
  },
  "db": {
    "hosts": [
      "tnode3"
    ]
  },
  "web": {
    "hosts": [
      "tnode1",
      "tnode2"
    ]
  }
}

#
root@server:~/my-ansible# ansible -m ping web
tnode1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
tnode2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

#
root@server:~/my-ansible# ansible -m ping db
tnode3 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

옵션 설정으로 암호 입력 후 실행 확인

```bash
# 암호 입력 후 실행
root@server:~/my-ansible# ansible -m ping --ask-pass web
SSH password: 
tnode1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
tnode2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

다른 사용자 계정으로 실행 확인
```bash
# root 계정 대신 labadmin 계정으로 실행

root@server:~/my-ansible# ansible -m ping web -u labadmin
[ERROR]: Task failed: Missing sudo password
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

tnode1 | FAILED! => {
    "changed": false,
    "msg": "Task failed: Missing sudo password"
}
tnode2 | FAILED! => {
    "changed": false,
    "msg": "Task failed: Missing sudo password"
}

root@server:~/my-ansible# ansible -m ping web -u labadmin --ask-pass
SSH password: 
[ERROR]: Task failed: Missing sudo password
Origin: <adhoc 'ping' task>

{'action': 'ping', 'args': {}, 'timeout': 0, 'async_val': 0, 'poll': 15}

tnode1 | FAILED! => {
    "changed": false,
    "msg": "Task failed: Missing sudo password"
}
tnode2 | FAILED! => {
    "changed": false,
    "msg": "Task failed: Missing sudo password"
}
```

실패하는 이유는?
- Ansible이 sudo(become)를 사용하도록 설정되어 있는데, sudo 비밀번호를 못 받아서.
- ping 모듈 자체는 sudo가 필요 없는데도 `become=true`가 설정돼 있으면 sudo로 올리려다가 Missing sudo password가 난다.


```bash
# ansible.cfg에서 privilege_escalation 모두 제거
root@server:~/my-ansible# cat ansible.cfg
[defaults]
inventory = ./inventory
remote_user = root
ask_pass = false

#[privilege_escalation]
#become = true
#become_method = sudo
#become_user = root
#become_ask_pass = false

# 다시 시도해본다.
root@server:~/my-ansible# ansible -m ping web -u labadmin
tnode1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
tnode2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

root@server:~/my-ansible# ansible -m ping web -u labadmin --ask-pass
SSH password: 
tnode1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
tnode2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

root@server:~/my-ansible# ansible -m ping web -u labadmin -k -e ansible_become=false
SSH password: 
tnode1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
tnode2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

root@server:~/my-ansible# ansible -m ping db -u labadmin --ask-pass
SSH password: 
tnode3 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

## shell 모듈
노드들에 명령 구문을 전달하고 해당 결과를 반환하는 모듈이다.

```bash
#
root@server:~/my-ansible# ansible -m shell -a uptime db
tnode3 | CHANGED | rc=0 >>
 14:15:05 up  1:03,  1 user,  load average: 0.00, 0.00, 0.00

#
root@server:~/my-ansible# ansible -m shell -a "free -h" web
tnode1 | CHANGED | rc=0 >>
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       374Mi       1.0Gi       2.7Mi       681Mi       1.5Gi
Swap:             0B          0B          0B
tnode2 | CHANGED | rc=0 >>
               total        used        free      shared  buff/cache   available
Mem:           1.9Gi       372Mi       1.0Gi       2.7Mi       704Mi       1.5Gi
Swap:             0B          0B          0B


#
root@server:~/my-ansible# ansible -m shell -a "tail -n 3 /etc/passwd" all
tnode1 | CHANGED | rc=0 >>
_chrony:x:110:112:Chrony daemon,,,:/var/lib/chrony:/usr/sbin/nologin
ubuntu:x:1000:1000:Ubuntu:/home/ubuntu:/bin/bash
labadmin:x:1001:1001::/home/labadmin:/bin/bash
tnode2 | CHANGED | rc=0 >>
_chrony:x:110:112:Chrony daemon,,,:/var/lib/chrony:/usr/sbin/nologin
ubuntu:x:1000:1000:Ubuntu:/home/ubuntu:/bin/bash
labadmin:x:1001:1001::/home/labadmin:/bin/bash
tnode3 | CHANGED | rc=0 >>
chrony:x:995:995:chrony system user:/var/lib/chrony:/sbin/nologin
rocky:x:1000:1000:rocky Cloud User:/home/rocky:/bin/bash
labadmin:x:1001:1001::/home/labadmin:/bin/bash
```

## 플레이북 작성
- 플레이북은 YAML 포맷으로 작성된 텍스트 파일이며, 일반적으로 `.yml` 확장자를 사용하여 저장.
- 플레이북은 대상 호스트나 호스트 집합에 수행할 작업을 정의하고 이를 실행한다. 이때 특정 작업 단위를 수행하기 위해 모듈을 적용한다.

용어
- Playbook
    - A list of plays that define the order in which Ansible performs operations, from top to bottom, to achieve an overall goal.
- Play
    - An ordered list of tasks that maps to managed nodes in an inventory.
- Task
    - A reference to a single module that defines the operations that Ansible performs.
- Module
    - A unit of code or binary that Ansible runs on managed nodes.
    - Ansible modules are grouped in collections with a [Fully Qualified Collection Name (FQCN)](https://docs.ansible.com/projects/ansible/latest/reference_appendices/glossary.html#term-Fully-Qualified-Collection-Name-FQCN) for each module.


### 1. debug 모듈을 이용하여 문자열 출력

플레이북 2개를 작성한다.
- my-ansible/first-playbook.yml
- my-ansible/first-playbook-with-error.yml

```bash
# my-ansible/first-playbook.yml
---
- hosts: all
  tasks:
    - name: Print message
      debug:
        msg: Hello CloudNet@ Ansible Study
```

```bash
# my-ansible/first-playbook-with-error.yml
---
- hosts: all
  tasks:
    - name: Print message
      debug:
      msg: Hello CloudNet@ Ansible Study
```

플레이북 문법 체크 옵션도 자체로 제공한다.
```bash
# 문법 체크 : 문법 오류 확인
root@server:~/my-ansible# ansible-playbook --syntax-check first-playbook.yml

playbook: first-playbook.yml

# debug:, msg: 사이 indent가 틀렸음.
root@server:~/my-ansible# ansible-playbook --syntax-check first-playbook-with-error.yml
[ERROR]: conflicting action statements: debug, msg
Origin: /root/my-ansible/first-playbook-with-error.yml:4:7

2 - hosts: all
3   tasks:
4     - name: Print message
        ^ column 7
```

플레이북 실행
- 플레이북을 실행할 때는 ansible-playbook 명령어를 사용한다.
- 환경 설정 파일인 ansible.cfg가 존재하는 디렉토리 내에서 실행할 경우에는 ansible-playbook 명령어와 함께 실행하고자 하는 플레이북 파일명을 입력하면 된다.

```bash
root@server:~/my-ansible# ansible-playbook first-playbook.yml

PLAY [all] *****************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]
ok: [tnode1]
ok: [tnode2]

TASK [Print message] *******************************************************************
ok: [tnode1] => {
    "msg": "Hello CloudNet@ Ansible Study"
}
ok: [tnode2] => {
    "msg": "Hello CloudNet@ Ansible Study"
}
ok: [tnode3] => {
    "msg": "Hello CloudNet@ Ansible Study"
}

PLAY RECAP *****************************************************************************
tnode1                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode2                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode3                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


```

### 2. 서비스 재시작하는 플레이북 작성

플레이북 1개를 작성한다.
- my-ansible/restart-service.yml

```bash
# my-ansible/restart-service.yml
---
- hosts: all
  tasks:
    - name: Restart sshd service
      ansible.builtin.service:
        name: ssh # sshd
        state: restarted
```

---
**state**: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html#parameter-state
- **started** : `Start service httpd, if not started`
- **stooped** : `Stop service httpd, if started`
- **restarted** : `Restart service httpd, in all cases`
- **reloaded** : `Reload service httpd, in all cases`

---

플레이북을 실행해보자.
```bash
# (신규터미널) 모니터링 : 서비스 재시작 실행 여부 확인
ssh tnode1 tail -f /var/log/syslog

# 실행 전 check 옵션으로 플레이북의 실행 상태를 미리 점검 가능 : 출력 중 changed=1 확인
root@server:~/my-ansible# ansible-playbook --check restart-service.yml

PLAY [all] *****************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]
ok: [tnode1]
ok: [tnode2]

TASK [Restart sshd service] ************************************************************
[ERROR]: Task failed: Module failed: Could not find the requested service ssh: host
Origin: /root/my-ansible/restart-service.yml:4:7

2 - hosts: all
3   tasks:
4     - name: Restart sshd service
        ^ column 7

fatal: [tnode3]: FAILED! => {"changed": false, "msg": "Could not find the requested service ssh: host"}
changed: [tnode2]
changed: [tnode1]

PLAY RECAP *****************************************************************************
tnode1                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode2                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode3                     : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   


# 플레이북 실제 실행
root@server:~/my-ansible# ansible-playbook restart-service.yml

PLAY [all] *****************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]
ok: [tnode1]
ok: [tnode2]

TASK [Restart sshd service] ************************************************************
[ERROR]: Task failed: Module failed: Could not find the requested service ssh: host
Origin: /root/my-ansible/restart-service.yml:4:7

2 - hosts: all
3   tasks:
4     - name: Restart sshd service
        ^ column 7

fatal: [tnode3]: FAILED! => {"changed": false, "msg": "Could not find the requested service ssh: host"}
changed: [tnode1]
changed: [tnode2]

PLAY RECAP *****************************************************************************
tnode1                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode2                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode3                     : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
```

로그는 아래와 같음.
```bash
root@server:~# ssh tnode1 tail -f /var/log/syslog
2026-01-17T14:25:06.741884+00:00 ip-172-31-3-86 systemd[4206]: Listening on pk-debconf-helper.socket - debconf communication socket.
2026-01-17T14:25:06.741921+00:00 ip-172-31-3-86 systemd[4206]: Listening on snapd.session-agent.socket - REST API socket for snapd user session agent.
2026-01-17T14:25:06.753350+00:00 ip-172-31-3-86 systemd[4206]: Listening on dbus.socket - D-Bus User Message Bus Socket.
2026-01-17T14:25:06.769321+00:00 ip-172-31-3-86 systemd[4206]: Listening on gpg-agent-ssh.socket - GnuPG cryptographic agent (ssh-agent emulation).
2026-01-17T14:25:06.769409+00:00 ip-172-31-3-86 systemd[4206]: Reached target sockets.target - Sockets.
2026-01-17T14:25:06.769450+00:00 ip-172-31-3-86 systemd[4206]: Reached target basic.target - Basic System.
2026-01-17T14:25:06.769487+00:00 ip-172-31-3-86 systemd[4206]: Reached target default.target - Main User Target.
2026-01-17T14:25:06.769616+00:00 ip-172-31-3-86 systemd[4206]: Startup finished in 122ms.
2026-01-17T14:25:06.769809+00:00 ip-172-31-3-86 systemd[1]: Started user@0.service - User Manager for UID 0.
2026-01-17T14:25:06.771379+00:00 ip-172-31-3-86 systemd[1]: Started session-48.scope - Session 48 of User root.

# 실행 전 check 옵션으로 플레이북의 실행 상태를 미리 점검 가능 : 출력 중 changed=1 확인
2026-01-17T14:25:34.914509+00:00 ip-172-31-3-86 systemd[1]: Started session-50.scope - Session 50 of User root.
2026-01-17T14:25:35.790989+00:00 ip-172-31-3-86 python3[4336]: ansible-ansible.legacy.setup Invoked with gather_subset=['all'] gather_timeout=10 filter=[] fact_path=/etc/ansible/facts.d
2026-01-17T14:25:37.462953+00:00 ip-172-31-3-86 python3[4430]: ansible-ansible.legacy.systemd Invoked with name=ssh state=restarted daemon_reload=False daemon_reexec=False scope=system no_block=False enabled=None force=None masked=None
2026-01-17T14:25:46.183989+00:00 ip-172-31-3-86 systemd[1]: fwupd.service: Deactivated successfully.
2026-01-17T14:25:46.187743+00:00 ip-172-31-3-86 systemd[1]: fwupd.service: Consumed 1.568s CPU time.


# 플레이북 실제 실행
2026-01-17T14:26:37.204418+00:00 ip-172-31-3-86 systemd[1]: session-50.scope: Deactivated successfully.
2026-01-17T14:26:37.204520+00:00 ip-172-31-3-86 systemd[1]: session-50.scope: Consumed 1.323s CPU time.
2026-01-17T14:26:49.150607+00:00 ip-172-31-3-86 systemd[1]: Started session-51.scope - Session 51 of User root.
2026-01-17T14:26:50.175493+00:00 ip-172-31-3-86 python3[4512]: ansible-ansible.legacy.setup Invoked with gather_subset=['all'] gather_timeout=10 filter=[] fact_path=/etc/ansible/facts.d
2026-01-17T14:26:51.690057+00:00 ip-172-31-3-86 python3[4607]: ansible-ansible.legacy.systemd Invoked with name=ssh state=restarted daemon_reload=False daemon_reexec=False scope=system no_block=False enabled=None force=None masked=None
2026-01-17T14:26:51.712666+00:00 ip-172-31-3-86 systemd[1]: Stopping ssh.service - OpenBSD Secure Shell server...
2026-01-17T14:26:51.713587+00:00 ip-172-31-3-86 systemd[1]: ssh.service: Deactivated successfully.
2026-01-17T14:26:51.713833+00:00 ip-172-31-3-86 systemd[1]: Stopped ssh.service - OpenBSD Secure Shell server.
2026-01-17T14:26:51.713948+00:00 ip-172-31-3-86 systemd[1]: ssh.service: Consumed 2.248s CPU time, 22.8M memory peak, 0B memory swap peak.
2026-01-17T14:26:51.721546+00:00 ip-172-31-3-86 systemd[1]: Starting ssh.service - OpenBSD Secure Shell server...
2026-01-17T14:26:51.746913+00:00 ip-172-31-3-86 systemd[1]: Started ssh.service - OpenBSD Secure Shell server.
#  완료...
```

Managed Node의 OS별로 조건을 분리해보자.
```bash
# Before
root@server:~/my-ansible# cat restart-service.yml 
---
- hosts: all
  tasks:
    - name: Restart sshd service
      ansible.builtin.service:
        name: ssh # sshd
        state: restarted

# After
root@server:~/my-ansible# cat restart-service.yml 
- hosts: all
  tasks:
    - name: Restart SSH on Debian
      ansible.builtin.service:
        name: ssh
        state: restarted
      when: ansible_facts['os_family'] == 'Debian'

    - name: Restart SSH on RedHat
      ansible.builtin.service:
        name: sshd
        state: restarted
      when: ansible_facts['os_family'] == 'RedHat'


# you can see the ‘raw’ information for any host in your inventory by running this ad-hoc ansible command at the command line:
root@server:~/my-ansible# ansible tnode1 -m ansible.builtin.setup | grep -iE 'os_family|ansible_distribution'
        "ansible_distribution": "Ubuntu",
        "ansible_distribution_file_parsed": true,
        "ansible_distribution_file_path": "/etc/os-release",
        "ansible_distribution_file_variety": "Debian",
        "ansible_distribution_major_version": "24",
        "ansible_distribution_release": "noble",
        "ansible_distribution_version": "24.04",
        "ansible_os_family": "Debian",

root@server:~/my-ansible# ansible tnode3 -m ansible.builtin.setup | grep -iE 'os_family|ansible_distribution'
        "ansible_distribution": "Rocky",
        "ansible_distribution_file_parsed": true,
        "ansible_distribution_file_path": "/etc/redhat-release",
        "ansible_distribution_file_variety": "RedHat",
        "ansible_distribution_major_version": "9",
        "ansible_distribution_release": "Blue Onyx",
        "ansible_distribution_version": "9.6",
        "ansible_os_family": "RedHat",


# 실행 전 check 옵션으로 플레이북의 실행 상태를 미리 점검
root@server:~/my-ansible# ansible-playbook --check restart-service.yml

PLAY [all] *****************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]
ok: [tnode1]
ok: [tnode2]

TASK [Restart SSH on Debian] ***********************************************************
skipping: [tnode3]
changed: [tnode1]
changed: [tnode2]

TASK [Restart SSH on RedHat] ***********************************************************
skipping: [tnode1]
skipping: [tnode2]
changed: [tnode3]

PLAY RECAP *****************************************************************************
tnode1                     : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
tnode2                     : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
tnode3                     : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   


# 플레이북 실제 실행
root@server:~/my-ansible# ansible-playbook restart-service.yml  

PLAY [all] *****************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]
ok: [tnode1]
ok: [tnode2]

TASK [Restart SSH on Debian] ***********************************************************
skipping: [tnode3]
changed: [tnode1]
changed: [tnode2]

TASK [Restart SSH on RedHat] ***********************************************************
skipping: [tnode1]
skipping: [tnode2]
changed: [tnode3]

PLAY RECAP *****************************************************************************
tnode1                     : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
tnode2                     : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
tnode3                     : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

```

Ubuntu도 os_family는 Debian으로 출력된다.
- https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_conditionals.html#ansible-facts-os-family

