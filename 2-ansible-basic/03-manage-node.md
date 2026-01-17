# Managed Node 관리

## 인벤토리를 통한 Managed Node 선정

IP를 이용한 인벤토리 파일을 생성한다.
```bash
root@server:~/my-ansible# cat <<EOT > inventory
172.31.3.86
172.31.3.42
172.31.5.232
EOT

# inventory 검증 : -i 특정 인벤토리 지정
root@server:~/my-ansible# ansible-inventory -i ./inventory --list | jq
{
  "_meta": {
    "hostvars": {},
    "profile": "inventory_legacy"
  },
  "all": {
    "children": [
      "ungrouped"
    ]
  },
  "ungrouped": {
    "hosts": [
      "172.31.3.86",
      "172.31.3.42",
      "172.31.5.232"
    ]
  }
```

호스트명을 이용한 인벤토리 파일을 생성한다.
```bash
# /etc/hosts 파일 확인
root@server:~/my-ansible# cat /etc/hosts
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
172.31.14.64 server
172.31.3.86 tnode1
172.31.3.42 tnode2
172.31.5.232 tnode3

# inventory 파일 생성
root@server:~/my-ansible# cat <<EOT > inventory
tnode1
tnode2
tnode3
EOT

# inventory 검증
root@server:~/my-ansible# ansible-inventory -i ./inventory --list | jq
{
  "_meta": {
    "hostvars": {},
    "profile": "inventory_legacy"
  },
  "all": {
    "children": [
      "ungrouped"
    ]
  },
  "ungrouped": {
    "hosts": [
      "tnode1",
      "tnode2",
      "tnode3"
    ]
  }
}
```

## 역할에 따른 호스트 그룹 설정
호스트별로 Role(역할)을 주고, 롤별로 특정 작업을 수행하는 경우가 종종 발생.
```bash
# 참고
root@server:~/my-ansible# cat /etc/ansible/hosts
# This is the default ansible 'hosts' file.
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/ip can be a member of multiple groups

# Ex 1: Ungrouped hosts, specify before any group headers:

## green.example.com
## blue.example.com
## 192.168.100.1
## 192.168.100.10

# Ex 2: A collection of hosts belonging to the 'webservers' group:

## [webservers]
## alpha.example.org
## beta.example.org
## 192.168.1.100
## 192.168.1.110

# If you have multiple hosts following a pattern, you can specify
# them like this:

## www[001:006].example.com

# You can also use ranges for multiple hosts: 

## db-[99:101]-node.example.com

# Ex 3: A collection of database servers in the 'dbservers' group:

## [dbservers]
##
## db01.intranet.mydomain.net
## db02.intranet.mydomain.net
## 10.25.1.56
## 10.25.1.57


# Ex4: Multiple hosts arranged into groups such as 'Debian' and 'openSUSE':

## [Debian]
## alpha.example.org
## beta.example.org

## [openSUSE]
## green.example.com
## blue.example.com
```

그룹별 호스트를 지정해보자.
- 앤서블 플레이북 실행 시, 그룹별로 작업을 처리할 수 있음.
- 그룹명은 대괄호(`[]`) 내에 작성하고, 해당 그룹에 속하는 호스트명이나 IP를 한 줄에 하나씩 나열한다.
- 
```bash
# EXAMPLE: 총 2개의 그룹!
[webservers]
web1.example.com
web2.example.com
192.0.2.42

[db-servers]
db01.example.com
db02.example.com
```

중첩 그룹 정의도 가능하다.
- 앤서블 인벤토리는 호스트 그룹에 기존에 정의한 호스트 그룹을 포함할 수도 있다.
- 이 경우, 호스트 그룹 이름 생성 시 `:children` 이라는 접미사를 추가하면 된다.
- 아래는 webservers 및 db-servers 그룹의 모든 호스트를 포함하는 datacenter 그룹을 생성하는 예시이다.

```bash
# webservers, db-servers는 datacenter 안에 포함된다.
[webservers]
web1.example.com
web2.example.com
192.0.2.42

[db-servers]
db01.example.com
db02.example.com

[datacenter:children]
webservers
dbservers
```

범위 사용을 통한 호스트 정의 간소화
- 인벤토리의 호스트명 또는 IP 주소를 설정할 때, 범위를 지정하여 호스트 인벤토리를 간소화할 수 있다.
- 숫자/영문자로 범위 지정 가능하며, 대괄호 사이에 시작 구문과 종료 구문을 포함한다.

```
[start:end]
```


예시1
- webservers는 web1, web2에 해당하는 플레이북 작업이 실행된다.
- db-servers는 db01, db02에 해당하는 플레이북 작업이 실행된다.
```bash
[webservers]
web[1:2].example.com

[db-servers]
db[01:02].example.com
```

예시2
```bash
# IP 범위 설정 : 192.168.4.0 ~ 192.168.4.255 사이의 IP 범위를 표현
[defaults]
192.168.4.[0:255]

# 호스트명 범위 설정 : com01.example.com ~ com20.example.com 의 범위를 표현
[compute]
com[01:20].example.com

# DNS 범위 설정 : a.dns.example.com , b.dns.example.com , c.dns.example.com 을 의미함
[dns]
[a:c].dns.example.com

# IPv6 범위 설정 : 2001:db08::a ~ 2001:db08::f 사이의 IPv6 범위를 표현
[ipv6]
2001:db8::[a:f]
```

## 실습을 위한 앤서블 설정
```bash
# inventory 그룹 구성
root@server:~/my-ansible# cat <<EOT > inventory
[web]
tnode1
tnode2

[db]
tnode3

[all:children]
web
db
EOT

# inventory 검증
root@server:~/my-ansible# ansible-inventory -i ./inventory --list | jq
{
  "_meta": {
    "hostvars": {},
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

root@server:~/my-ansible# ansible-inventory -i ./inventory --graph
@all:
  |--@ungrouped:
  |--@web:
  |  |--tnode1
  |  |--tnode2
  |--@db:
  |  |--tnode3
```

현재 디렉토리 내에 ansible.cfg 라는 앤서블 환경 설정 파일을 구성 시, -i 옵션을 사용하지 않아도 ansible.cfg 설정 파일에 정의된 인벤토리의 호스트 정보를 확인할 수 있다.
```bash
# ansible.cfg 파일 생성
root@server:~/my-ansible# cat <<EOT > ansible.cfg
[defaults]
inventory = ./inventory
EOT

# inventory 목록 확인
root@server:~/my-ansible# ansible-inventory --list | jq
{
  "_meta": {
    "hostvars": {},
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

# ansible config 적용 우선 순위 확인
root@server:~/my-ansible# echo $ANSIBLE_CONFIG

# kubespary 실행 시, 디렉터리 위치 고정 이유
root@server:~/my-ansible# cat $PWD/ansible.cfg
[defaults]
inventory = ./inventory

root@server:~/my-ansible# ls ~/.ansible.cfg
ls: cannot access '/root/.ansible.cfg': No such file or directory

root@server:~/my-ansible# tree ~/.ansible
/root/.ansible
└── tmp

2 directories, 0 files

root@server:~/my-ansible# cat /etc/ansible/ansible.cfg
# Since Ansible 2.12 (core):
# To generate an example config file (a "disabled" one with all default settings, commented out):
#               $ ansible-config init --disabled > ansible.cfg
#
# Also you can now have a more complete file by including existing plugins:
# ansible-config init --disabled -t all > ansible.cfg

# For previous versions of Ansible you can check for examples in the 'stable' branches of each version
# Note that this file was always incomplete  and lagging changes to configuration settings

# for example, for 2.9: https://github.com/ansible/ansible/blob/stable-2.9/examples/ansible.cfg

#

root@server:~/my-ansible# ansible-config dump
ACTION_WARNINGS(default) = True
AGNOSTIC_BECOME_PROMPT(default) = True
ALLOW_BROKEN_CONDITIONALS(default) = False
ALLOW_EMBEDDED_TEMPLATES(default) = True
ANSIBLE_CONNECTION_PATH(default) = None
ANSIBLE_COW_ACCEPTLIST(default) = ['bud-frogs', 'bunny', 'cheese', 'daemon', 'default',>
ANSIBLE_COW_PATH(default) = None
ANSIBLE_COW_SELECTION(default) = default
ANSIBLE_FORCE_COLOR(default) = False
ANSIBLE_HOME(default) = /root/.ansible
ANSIBLE_NOCOLOR(default) = False
ANSIBLE_NOCOWS(default) = False
ANSIBLE_PIPELINING(default) = False
ANY_ERRORS_FATAL(default) = False
BECOME_ALLOW_SAME_USER(default) = False
BECOME_PASSWORD_FILE(default) = None
...

root@server:~/my-ansible# ansible-config list
ACTION_WARNINGS:
  default: true
  description:
  - By default, Ansible will issue a warning when received from a task action (module
    or action plugin).
  - These warnings can be silenced by adjusting this setting to False.
  env:
  - name: ANSIBLE_ACTION_WARNINGS
  ini:
  - key: action_warnings
    section: defaults
  name: Toggle action warnings
  type: boolean
  version_added: '2.5'
AGNOSTIC_BECOME_PROMPT:
  default: true
  description: Display an agnostic become prompt instead of displaying a prompt contain>
    the command line supplied become method.
  env:
  - name: ANSIBLE_AGNOSTIC_BECOME_PROMPT
  ini:
  - key: agnostic_become_prompt
    section: privilege_escalation
  name: Display an agnostic become prompt
  type: boolean
  version_added: '2.5'
  yaml:
    key: privilege_escalation.agnostic_become_prompt
...
```

Ansible Config 적용 우선순위
1. `ANSIBLE_CONFIG`
2. `ansible.cfg` in current directory
3. `~/.ansible.cfg` in home directory
4. `/etc/ansible/ansible.cfg`

