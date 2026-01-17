# Ansible 조건문

Ansible 조건문은 `when`을 사용해 특정 조건에서만 작업을 실행하도록 제어한다.

Facts, 변수, 이전 작업의 결과 등을 활용할 수 있다.

## 기본 when

플레이북을 작성한다.
```bash
# ~/my-ansible/when_task.yml
---
- hosts: localhost
  vars:
    run_my_task: true

  tasks:
  - name: echo message
    ansible.builtin.shell: "echo test"
    when: run_my_task
    register: result

  - name: Show result
    ansible.builtin.debug:
      var: result
```

플레이북을 실행한다.
```bash
root@server:~/my-ansible# ansible-playbook when_task.yml

PLAY [localhost] ***********************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [localhost]

TASK [echo message] ********************************************************************
changed: [localhost]

TASK [Show result] *********************************************************************
ok: [localhost] => {
    "result": {
        "changed": true,
        "cmd": "echo test",
        "delta": "0:00:00.003453",
        "end": "2026-01-17 17:41:23.639788",
        "failed": false,
        "msg": "",
        "rc": 0,
        "start": "2026-01-17 17:41:23.636335",
        "stderr": "",
        "stderr_lines": [],
        "stdout": "test",
        "stdout_lines": [
            "test"
        ]
    }
}

PLAY RECAP *****************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

run_my_task 값을 false 수정 후 실행 확인한다.
```bash
root@server:~/my-ansible# cat when_task.yml 
---
- hosts: localhost
  vars:
    run_my_task: false

  tasks:
  - name: echo message
    ansible.builtin.shell: "echo test"
    when: run_my_task
    register: result

  - name: Show result
    ansible.builtin.debug:
      var: result

root@server:~/my-ansible# ansible-playbook when_task.yml

PLAY [localhost] ***********************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [localhost]

TASK [echo message] ********************************************************************
skipping: [localhost]

TASK [Show result] *********************************************************************
ok: [localhost] => {
    "result": {
        "changed": false,
        "false_condition": "run_my_task",
        "skip_reason": "Conditional result was False",
        "skipped": true
    }
}

PLAY RECAP *****************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0 
```