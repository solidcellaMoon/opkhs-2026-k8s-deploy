# Ansible 핸들러 및 작업 실패 처리

Ansible 핸들러는 특정 작업이 변경을 일으켰을 때만 실행되는 후속 작업이다. 서비스 재시작, 설정 리로드처럼 변경 시점에만 수행해야 하는 작업에 사용한다. 실패 처리 옵션은 작업 실패를 무시하거나, 조건적으로 복구 절차를 실행하는 데 활용한다.

## 핸들러 기본 사용법

플레이북을 생성한다.
- rsyslog 재시작 태스크가 실행되면 notify 키워드를 통해 print msg라는 핸들러 호출. 핸들러는 handlers 키워드로 시작함.
```bash
# ~/my-ansible/handler-sample.yml
---
- hosts: tnode2
  tasks:
    - name: restart rsyslog
      ansible.builtin.service:
        name: "rsyslog"
        state: restarted
      notify:
        - print msg

  handlers:
    - name: print msg
      ansible.builtin.debug:
        msg: "rsyslog is restarted"
```

플레이북을 실행한다.
- tnode2 노드에 rsyslog 서비스를 재시작하고, print msg라는 핸들러를 호출해 “rsyslog..” 메시지를 출력
```bash
root@server:~/my-ansible# ansible-playbook handler-sample.yml

PLAY [tnode2] **************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode2]

TASK [restart rsyslog] *****************************************************************
changed: [tnode2]

RUNNING HANDLER [print msg] ************************************************************
ok: [tnode2] => {
    "msg": "rsyslog is restarted"
}

PLAY RECAP *****************************************************************************
tnode2                     : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```
