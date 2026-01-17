# Ansible 반복문

Ansible 반복문은 동일한 작업을 여러 항목에 대해 반복 실행할 때 사용한다.

## 기본 loop
- 특정 항목에 대한 작업을 반복: item 변수, 변수 목록 지정
- loop 키워드를 작업에 추가하면 작업을 반복해야 하는 항목의 목록을 값으로 사용. 그리고 해당하는 값을 사용하려면 item 변수를 사용.

플레이북을 작성한다.
```bash
# ~/my-ansible/check-services.yml
---
- hosts: all
  tasks:
    - name: Check sshd state on Debian
      ansible.builtin.service:
        name: ssh
        state: started
      when: ansible_facts['os_family'] == 'Debian'

    - name: Check sshd state on RedHat
      ansible.builtin.service:
        name: sshd
        state: started
      when: ansible_facts['os_family'] == 'RedHat'


    - name: Check rsyslog state
      ansible.builtin.service:
        name: rsyslog
        state: started
```

플레이북을 실행한다.
```bash
# 프로세스 동작 확인
root@server:~/my-ansible# ansible -m shell -a "pstree |grep rsyslog" all
tnode1 | CHANGED | rc=0 >>
        |-rsyslogd---3*[{rsyslogd}]
tnode2 | CHANGED | rc=0 >>
        |-rsyslogd---3*[{rsyslogd}]
tnode3 | CHANGED | rc=0 >>
        |-rsyslogd---2*[{rsyslogd}]

root@server:~/my-ansible# ansible -m shell -a "pstree |grep sshd" all
tnode1 | CHANGED | rc=0 >>
        |-sshd---sshd---sh---python3---sh-+-grep
tnode2 | CHANGED | rc=0 >>
        |-sshd---sshd---sh---python3---sh-+-grep
tnode3 | CHANGED | rc=0 >>
        |-sshd---sshd---sshd---sh---python3---sh-+-grep

# 실행
root@server:~/my-ansible# ansible-playbook check-services.yml

PLAY [all] *****************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]
ok: [tnode1]
ok: [tnode2]

TASK [Check sshd state on Debian] ******************************************************
skipping: [tnode3]
ok: [tnode1]
ok: [tnode2]

TASK [Check sshd state on RedHat] ******************************************************
skipping: [tnode1]
skipping: [tnode2]
ok: [tnode3]

TASK [Check rsyslog state] *************************************************************
ok: [tnode1]
ok: [tnode2]
ok: [tnode3]

PLAY RECAP *****************************************************************************
tnode1                     : ok=3    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
tnode2                     : ok=3    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
tnode3                     : ok=3    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
```