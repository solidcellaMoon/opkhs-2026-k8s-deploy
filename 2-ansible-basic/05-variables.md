# Variables

- Ansible 변수는 플레이북과 인벤토리에서 재사용 가능한 값을 정의해 환경별 설정을 분리하고, 작업을 반복 없이 관리하기 위한 기능이다.
- 변수는 YAML로 정의하며 Jinja2 템플릿 문법으로 참조한다.

아래와 같은 우선순위를 갖는다.
```
추가변수(실행 시 파라미터) > 플레이 변수 > 호스트 변수 > 그룹 변수
```

## 그룹 변수
- 인벤토리에 정의된 호스트 그룹에 적용하는 변수

```bash
root@server:~/my-ansible# cat inventory 
[web]
tnode1 ansible_python_interpreter=/usr/bin/python3
tnode2 ansible_python_interpreter=/usr/bin/python3

[db]
tnode3 ansible_python_interpreter=/usr/bin/python3

[all:children]
web
db

[all:vars]
user=ansible
```

플레이북을 작성한다.
```bash
# my-ansible/create-user.yml
---
- hosts: all
  tasks:
  - name: Create User {{ user }}
    ansible.builtin.user:
      name: "{{ user }}"
      state: present
```

플레이북을 실행한다.
```bash
root@server:~/my-ansible# ansible-playbook create-user.yml

PLAY [all] *****************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]
ok: [tnode1]
ok: [tnode2]

TASK [Create User ansible] *************************************************************
changed: [tnode1]
changed: [tnode2]
changed: [tnode3]

PLAY RECAP *****************************************************************************
tnode1                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode2                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode3                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  

# 유저 생성 확인!
root@tnode1:~# cat /etc/passwd | grep ansible
ansible:x:1002:1002::/home/ansible:/bin/sh

# 멱등성 확인을 위해 한번 더 실행
root@server:~/my-ansible# ansible-playbook create-user.yml

PLAY [all] *****************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]
ok: [tnode1]
ok: [tnode2]

TASK [Create User ansible] *************************************************************
ok: [tnode1]
ok: [tnode2]
ok: [tnode3]

PLAY RECAP *****************************************************************************
tnode1                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode2                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode3                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   


# 똑같음
root@tnode1:~# cat /etc/passwd | grep ansible
ansible:x:1002:1002::/home/ansible:/bin/sh

# 유저를 지워본다.
root@tnode1:~# userdel -r ansible
userdel: ansible mail spool (/var/mail/ansible) not found
root@tnode1:~# tail -n 2 /etc/passwd
ubuntu:x:1000:1000:Ubuntu:/home/ubuntu:/bin/bash
labadmin:x:1001:1001::/home/labadmin:/bin/bash

# 다시 플레이북을 돌린다.
root@server:~/my-ansible# ansible-playbook create-user.yml

PLAY [all] *****************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]
ok: [tnode1]
ok: [tnode2]

TASK [Create User ansible] *************************************************************
ok: [tnode2]
ok: [tnode3]
changed: [tnode1]

PLAY RECAP *****************************************************************************
tnode1                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode2                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode3                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

# 다시 유저가 생성되어 있음. (멱등성 확인)
root@tnode1:~# tail -n 2 /etc/passwd
labadmin:x:1001:1001::/home/labadmin:/bin/bash
ansible:x:1002:1002::/home/ansible:/bin/sh
```

## 호스트 변수
- 말 그대로 해당 호스트에서만 사용할 수 있음

```bash
root@server:~/my-ansible# cat inventory 
[web]
tnode1 ansible_python_interpreter=/usr/bin/python3
tnode2 ansible_python_interpreter=/usr/bin/python3

[db]
tnode3 ansible_python_interpreter=/usr/bin/python3 user=ansible1

[all:children]
web
db

[all:vars]
user=ansible
```

플레이북을 작성한다.
```bash
# my-ansible/create-user1.yml
---
- hosts: db
  tasks:
  - name: Create User {{ user }}
    ansible.builtin.user:
      name: "{{ user }}"
      state: present
```

플레이북을 실행한다.
```bash
# 사전 확인
[root@tnode3 ~]# tail -n 3 /etc/passwd
rocky:x:1000:1000:rocky Cloud User:/home/rocky:/bin/bash
labadmin:x:1001:1001::/home/labadmin:/bin/bash
ansible:x:1002:1002::/home/ansible:/bin/bash

# 플레이북 실행.
root@server:~/my-ansible# ansible-playbook create-user1.yml

PLAY [db] ******************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]

TASK [Create User ansible1] ************************************************************
changed: [tnode3]

PLAY RECAP *****************************************************************************
tnode3                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

# 변경 확인
[root@tnode3 ~]# tail -n 3 /etc/passwd
labadmin:x:1001:1001::/home/labadmin:/bin/bash
ansible:x:1002:1002::/home/ansible:/bin/bash
ansible1:x:1003:1003::/home/ansible1:/bin/bash
```

## 플레이 변수
- 플레이북 내에서 선언되는 변수, 별도 파일 분리

플레이북을 작성한다.
```bash
# my-ansible/create-user2.yml
---
- hosts: all
  vars:
    user: ansible2

  tasks:
  - name: Create User {{ user }}
    ansible.builtin.user:
      name: "{{ user }}"
      state: present
```

플레이북을 실행한다.
```bash
# 사전 확인
[root@tnode3 ~]# tail -n 3 /etc/passwd
labadmin:x:1001:1001::/home/labadmin:/bin/bash
ansible:x:1002:1002::/home/ansible:/bin/bash
ansible1:x:1003:1003::/home/ansible1:/bin/bash

# 인벤토리 확인
root@server:~/my-ansible# cat inventory
[web]
tnode1 ansible_python_interpreter=/usr/bin/python3
tnode2 ansible_python_interpreter=/usr/bin/python3

[db]
tnode3 ansible_python_interpreter=/usr/bin/python3 user=ansible1

[all:children]
web
db

[all:vars]
user=ansible


# 플레이북 실행
root@server:~/my-ansible# ansible-playbook create-user2.yml

PLAY [all] *****************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]
ok: [tnode1]
ok: [tnode2]

TASK [Create User ansible2] ************************************************************
changed: [tnode1]
changed: [tnode3]
changed: [tnode2]

PLAY RECAP *****************************************************************************
tnode1                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode2                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
tnode3                     : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

# 확인
root@server:~/my-ansible# for i in {1..3}; do echo ">> tnode$i <<"; ssh tnode$i tail -n 3 /etc/passwd; echo; done
>> tnode1 <<
labadmin:x:1001:1001::/home/labadmin:/bin/bash
ansible:x:1002:1002::/home/ansible:/bin/sh
ansible2:x:1003:1003::/home/ansible2:/bin/sh

>> tnode2 <<
labadmin:x:1001:1001::/home/labadmin:/bin/bash
ansible:x:1002:1002::/home/ansible:/bin/sh
ansible2:x:1003:1003::/home/ansible2:/bin/sh

>> tnode3 <<
ansible:x:1002:1002::/home/ansible:/bin/bash
ansible1:x:1003:1003::/home/ansible1:/bin/bash
ansible2:x:1004:1004::/home/ansible2:/bin/bash
```

## 추가 변수
- 외부에서 ansible-playbook를 실행 할 때 함께 파라미터로 넘겨주는 변수를 의미. 앞에 변수 중 우선순위가 가장 높음.

```bash
# my-ansible/create-user3.yml
---
- hosts: all
  vars_files:
    - vars/users.yml

  tasks:
  - name: Create User {{ user }}
    ansible.builtin.user:
      name: "{{ user }}"
      state: present
---
ansible-playbook -e user=ansible4 create-user3.yml
```

## 작업 변수
- 플레이북의 수행 결과를 저장. 특정 작업 수행 후 그 결과를 후속 작업에서 사용할 때 주로 사용됨.

플레이북을 작성한다.
```bash
# my-ansible/create-user4.yml
---
- hosts: db
  tasks:
  - name: Create User {{ user }}
    ansible.builtin.user:
      name: "{{ user }}"
      state: present
    register: result
  
  - ansible.builtin.debug:
      var: result
```

플레이북을 실행한다.
- 여기서, 맨 아래의 ok=3는 총 3개의 TASK가 정상 실행되었다는 의미이다.
```bash
root@server:~/my-ansible# ansible-playbook -e user=ansible5 create-user4.yml

PLAY [db] ******************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]

TASK [Create User ansible5] ************************************************************
changed: [tnode3]

TASK [ansible.builtin.debug] ***********************************************************
ok: [tnode3] => {
    "result": {
        "changed": true,
        "comment": "",
        "create_home": true,
        "failed": false,
        "group": 1005,
        "home": "/home/ansible5",
        "name": "ansible5",
        "shell": "/bin/bash",
        "state": "present",
        "system": false,
        "uid": 1005
    }
}

PLAY RECAP *****************************************************************************
tnode3                     : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```