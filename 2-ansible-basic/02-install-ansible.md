# Ansible 설치

```bash
# 작업 기본 디렉토리 확인
root@server:~# whoami
root
root@server:~# pwd
/root

# 파이썬 버전 확인
root@server:~# python3 --version
Python 3.12.3

# 설치
root@server:~# apt install software-properties-common -y
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
software-properties-common is already the newest version (0.99.49.3).
software-properties-common set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 86 not upgraded.

root@server:~# add-apt-repository --yes --update ppa:ansible/ansible
Repository: 'Types: deb
URIs: https://ppa.launchpadcontent.net/ansible/ansible/ubuntu/
Suites: noble
Components: main
'
Description:
Ansible is a radically simple IT automation platform that makes your applications and systems easier to deploy. Avoid writing scripts or custom code to deploy and update your applications— automate in a language that approaches plain English, using SSH, with no agents to install on remote systems.

http://ansible.com/

If you face any issues while installing Ansible PPA, file an issue here:
https://github.com/ansible-community/ppa/issues
More info: https://launchpad.net/~ansible/+archive/ubuntu/ansible
Adding repository.
Hit:1 http://ap-northeast-2.ec2.archive.ubuntu.com/ubuntu noble InRelease
Hit:2 http://ap-northeast-2.ec2.archive.ubuntu.com/ubuntu noble-updates InRelease                              
Hit:3 http://ap-northeast-2.ec2.archive.ubuntu.com/ubuntu noble-backports InRelease                            
Get:4 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]                                      
Get:5 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble InRelease [17.8 kB]
Get:6 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble/main amd64 Packages [772 B]
Get:7 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble/main Translation-en [472 B]
Get:8 http://security.ubuntu.com/ubuntu noble-security/main amd64 Components [21.6 kB]
Get:9 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Components [71.4 kB]
Get:10 http://security.ubuntu.com/ubuntu noble-security/restricted amd64 Components [212 B]
Get:11 http://security.ubuntu.com/ubuntu noble-security/multiverse amd64 Components [212 B]
Fetched 239 kB in 2s (105 kB/s)                                        
Reading package lists... Done

root@server:~# apt install ansible -y
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  ansible-core python3-kerberos python3-nacl python3-ntlm-auth python3-paramiko python3-requests-ntlm python3-resolvelib python3-winrm
Suggested packages:
  python-nacl-doc python3-gssapi python3-invoke
The following NEW packages will be installed:
  ansible ansible-core python3-kerberos python3-nacl python3-ntlm-auth python3-paramiko python3-requests-ntlm python3-resolvelib python3-winrm
0 upgraded, 9 newly installed, 0 to remove and 86 not upgraded.
Need to get 20.8 MB of archives.
After this operation, 231 MB of additional disk space will be used.
Get:1 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble/main amd64 ansible-core all 2.19.5-1ppa~noble [1134 kB]
Get:2 http://ap-northeast-2.ec2.archive.ubuntu.com/ubuntu noble/universe amd64 python3-resolvelib all 1.0.1-1 [25.7 kB]
Get:3 http://ap-northeast-2.ec2.archive.ubuntu.com/ubuntu noble/universe amd64 python3-kerberos amd64 1.1.14-3.1build9 [21.2 kB]
Get:4 http://ap-northeast-2.ec2.archive.ubuntu.com/ubuntu noble/main amd64 python3-nacl amd64 1.5.0-4build1 [57.9 kB]
Get:5 http://ap-northeast-2.ec2.archive.ubuntu.com/ubuntu noble/universe amd64 python3-ntlm-auth all 1.5.0-1 [21.3 kB]
Get:6 http://ap-northeast-2.ec2.archive.ubuntu.com/ubuntu noble-updates/main amd64 python3-paramiko all 2.12.0-2ubuntu4.1 [137 kB]
Get:7 http://ap-northeast-2.ec2.archive.ubuntu.com/ubuntu noble/universe amd64 python3-requests-ntlm all 1.1.0-3 [6308 B]
Get:8 http://ap-northeast-2.ec2.archive.ubuntu.com/ubuntu noble/universe amd64 python3-winrm all 0.4.3-2 [31.9 kB]
Get:9 https://ppa.launchpadcontent.net/ansible/ansible/ubuntu noble/main amd64 ansible all 12.3.0-1ppa~noble [19.4 MB]
Fetched 20.8 MB in 1min 17s (270 kB/s)                                                                                                                            
Selecting previously unselected package python3-resolvelib.
(Reading database ... 71822 files and directories currently installed.)
Preparing to unpack .../0-python3-resolvelib_1.0.1-1_all.deb ...
Unpacking python3-resolvelib (1.0.1-1) ...
Selecting previously unselected package ansible-core.
Preparing to unpack .../1-ansible-core_2.19.5-1ppa~noble_all.deb ...
Unpacking ansible-core (2.19.5-1ppa~noble) ...
Selecting previously unselected package ansible.
Preparing to unpack .../2-ansible_12.3.0-1ppa~noble_all.deb ...
Unpacking ansible (12.3.0-1ppa~noble) ...
Selecting previously unselected package python3-kerberos.
Preparing to unpack .../3-python3-kerberos_1.1.14-3.1build9_amd64.deb ...
Unpacking python3-kerberos (1.1.14-3.1build9) ...
Selecting previously unselected package python3-nacl.
Preparing to unpack .../4-python3-nacl_1.5.0-4build1_amd64.deb ...
Unpacking python3-nacl (1.5.0-4build1) ...
Selecting previously unselected package python3-ntlm-auth.
Preparing to unpack .../5-python3-ntlm-auth_1.5.0-1_all.deb ...
Unpacking python3-ntlm-auth (1.5.0-1) ...
Selecting previously unselected package python3-paramiko.
Preparing to unpack .../6-python3-paramiko_2.12.0-2ubuntu4.1_all.deb ...
Unpacking python3-paramiko (2.12.0-2ubuntu4.1) ...
Selecting previously unselected package python3-requests-ntlm.
Preparing to unpack .../7-python3-requests-ntlm_1.1.0-3_all.deb ...
Unpacking python3-requests-ntlm (1.1.0-3) ...
Selecting previously unselected package python3-winrm.
Preparing to unpack .../8-python3-winrm_0.4.3-2_all.deb ...
Unpacking python3-winrm (0.4.3-2) ...
Setting up python3-ntlm-auth (1.5.0-1) ...
Setting up python3-resolvelib (1.0.1-1) ...
Setting up python3-kerberos (1.1.14-3.1build9) ...
Setting up ansible-core (2.19.5-1ppa~noble) ...
Setting up ansible (12.3.0-1ppa~noble) ...
Setting up python3-nacl (1.5.0-4build1) ...
Setting up python3-requests-ntlm (1.1.0-3) ...
Setting up python3-winrm (0.4.3-2) ...
Setting up python3-paramiko (2.12.0-2ubuntu4.1) ...
Processing triggers for man-db (2.12.0-4build2) ...
Scanning processes...                                                                                                                                              
Scanning linux images...                                                                                                                                           

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
```

설치 완료!

```bash
# check
root@server:~# ansible --version
ansible [core 2.19.5]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.12.3 (main, Aug 14 2025, 17:47:21) [GCC 13.3.0] (/usr/bin/python3)
  jinja version = 3.1.2
  pyyaml version = 6.0.1 (with libyaml v0.2.5)

root@server:~# cat /etc/ansible/ansible.cfg
# Since Ansible 2.12 (core):
# To generate an example config file (a "disabled" one with all default settings, commented out):
#               $ ansible-config init --disabled > ansible.cfg
#
# Also you can now have a more complete file by including existing plugins:
# ansible-config init --disabled -t all > ansible.cfg

# For previous versions of Ansible you can check for examples in the 'stable' branches of each version
# Note that this file was always incomplete  and lagging changes to configuration settings

# for example, for 2.9: https://github.com/ansible/ansible/blob/stable-2.9/examples/ansible.cfg

root@server:~# ansible-config list
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
  description: Display an agnostic become prompt instead of displaying a prompt containing
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
ALLOW_BROKEN_CONDITIONALS:
  default: false
  description:
  - When enabled, this option allows conditionals with non-boolean results to be used.
  - A deprecation warning will be emitted in these cases.
  - By default, non-boolean conditionals result in an error.
  - Such results often indicate unintentional use of templates where they are not
    supported, resulting in a conditional that is always true.
  - When this option is enabled, conditional expressions which are a literal ``None``
    or empty string will evaluate as true for backwards compatibility.
  env:
  - name: ANSIBLE_ALLOW_BROKEN_CONDITIONALS
  ini:
  - key: allow_broken_conditionals
    section: defaults
  name: Allow broken conditionals
  type: boolean
  version_added: '2.19'
...


# 작업 디렉터리 생성
root@server:~# mkdir my-ansible && cd my-ansible
root@server:~/my-ansible# 
```


## ssh 인증 구성

```bash
root@server:~/my-ansible# ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
Generating public/private rsa key pair.
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:KsWG18bQ7oYqJPwWNUpaWaf9Qsqde7y9AMRU7zLXnYs root@server
The key's randomart image is:
+---[RSA 3072]----+
|       ...       |
|     .oo  .      |
|    o =o.  .     |
|   + *.B  . . . .|
|. + = X.So o . o |
|.o.o * O..+   . .|
| o. o o *.   E . |
|  .o o o oo      |
|  ...   ...o.    |
+----[SHA256]-----+
```

공개 키를 관리 노드에 복사

```bash
# 공개 키를 관리 노드에 복사
root@server:~/my-ansible# for i in {1..3}; do sshpass -p 'qwe123' ssh-copy-id -o StrictHostKeyChecking=no root@tnode$i; done
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh -o 'StrictHostKeyChecking=no' 'root@tnode1'"
and check to make sure that only the key(s) you wanted were added.

/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh -o 'StrictHostKeyChecking=no' 'root@tnode2'"
and check to make sure that only the key(s) you wanted were added.

/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh -o 'StrictHostKeyChecking=no' 'root@tnode3'"
and check to make sure that only the key(s) you wanted were added.

# 복사 확인
root@server:~/my-ansible# for i in {1..3}; do echo ">> tnode$i <<"; ssh tnode$i cat ~/.ssh/authorized_keys; echo; done
>> tnode1 <<
no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo 'Please login as the user \"ubuntu\" rather than the user \"root\".';echo;sleep 10;exit 142" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDvJpkqheVrTwdFah7fHs8wEGi695ctVC8i8pyE5wrcGwlVB08CClUnS4pqDlEu9afNd+6tfWzTPPyld/UX6hg4jskRCMJ5H50ow3m8dJF+UG5ZKh+UsFoNye5OAcHtELo/7hQGfjuSW8nZmhsMvQ5M7BmVfqk+LxS6GXOHc8zNBJPW6Qh/Iy+z7/bpMOAyk8Z+Y/0FrXiiib1vOL7PSY0T3liG62RafgO7KmcUQvfJmfGN79bHa8CAUNTVHm9NTKwbGWFxPYCrdyUTBUkI1fQAQVG2JZITZKEy15BD/pJ/pm8g6NTvfxMBP0w5a/WUg5BqzEOW70EX3FlovYtOpjYZ my-access-key
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6ZEyYKCx1c+GS7aSuFovl02ROiFgQzU9ZlRHpvtDe6xbKmSQFQwO6hYRmIBwa8en58jdC/W74NFUX7GTub0ffUs4r1LSE0SEjC3ylu77nmY/sIiYMs3tW0quVkxXa2jagT77R+yKTw6+G/8sjo6/N8Lb12HbjYA18k07CQZgSBivQGS34CP2mfq8ab0FsiwT8PW0+FZ4FTimGYvaw76qOIS1h33P5mp7u+f7SFjnpne1Gjch0TIUbfSoqKmgRc5a2ccBjwbFIg0TEMqzXavoGIXbHoxELlPSZdWqi7T42oWlvIP+9TBP9JrQwemMgCIUbGPAjFGIHh4lydpqopqHVDcc78z+rs4d1aNLTlFBPu2PMU4sIZHh6CXkoLJaopTe1lQ+QJAdMmE10RzqYou2f0KHz9zOuS4fFhI7QiKEHl8PA1d4lEbfZEXVsV+WhpTSdS6uvaMeyoBlrpW+0C27cYOOYPAJgrsVW3IXobcK/Z7MSI1kt+oULqidPL1JM/O0= root@server

>> tnode2 <<
no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo 'Please login as the user \"ubuntu\" rather than the user \"root\".';echo;sleep 10;exit 142" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDvJpkqheVrTwdFah7fHs8wEGi695ctVC8i8pyE5wrcGwlVB08CClUnS4pqDlEu9afNd+6tfWzTPPyld/UX6hg4jskRCMJ5H50ow3m8dJF+UG5ZKh+UsFoNye5OAcHtELo/7hQGfjuSW8nZmhsMvQ5M7BmVfqk+LxS6GXOHc8zNBJPW6Qh/Iy+z7/bpMOAyk8Z+Y/0FrXiiib1vOL7PSY0T3liG62RafgO7KmcUQvfJmfGN79bHa8CAUNTVHm9NTKwbGWFxPYCrdyUTBUkI1fQAQVG2JZITZKEy15BD/pJ/pm8g6NTvfxMBP0w5a/WUg5BqzEOW70EX3FlovYtOpjYZ my-access-key
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6ZEyYKCx1c+GS7aSuFovl02ROiFgQzU9ZlRHpvtDe6xbKmSQFQwO6hYRmIBwa8en58jdC/W74NFUX7GTub0ffUs4r1LSE0SEjC3ylu77nmY/sIiYMs3tW0quVkxXa2jagT77R+yKTw6+G/8sjo6/N8Lb12HbjYA18k07CQZgSBivQGS34CP2mfq8ab0FsiwT8PW0+FZ4FTimGYvaw76qOIS1h33P5mp7u+f7SFjnpne1Gjch0TIUbfSoqKmgRc5a2ccBjwbFIg0TEMqzXavoGIXbHoxELlPSZdWqi7T42oWlvIP+9TBP9JrQwemMgCIUbGPAjFGIHh4lydpqopqHVDcc78z+rs4d1aNLTlFBPu2PMU4sIZHh6CXkoLJaopTe1lQ+QJAdMmE10RzqYou2f0KHz9zOuS4fFhI7QiKEHl8PA1d4lEbfZEXVsV+WhpTSdS6uvaMeyoBlrpW+0C27cYOOYPAJgrsVW3IXobcK/Z7MSI1kt+oULqidPL1JM/O0= root@server

>> tnode3 <<
no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo 'Please login as the user \"rocky\" rather than the user \"root\".';echo;sleep 10;exit 142" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDvJpkqheVrTwdFah7fHs8wEGi695ctVC8i8pyE5wrcGwlVB08CClUnS4pqDlEu9afNd+6tfWzTPPyld/UX6hg4jskRCMJ5H50ow3m8dJF+UG5ZKh+UsFoNye5OAcHtELo/7hQGfjuSW8nZmhsMvQ5M7BmVfqk+LxS6GXOHc8zNBJPW6Qh/Iy+z7/bpMOAyk8Z+Y/0FrXiiib1vOL7PSY0T3liG62RafgO7KmcUQvfJmfGN79bHa8CAUNTVHm9NTKwbGWFxPYCrdyUTBUkI1fQAQVG2JZITZKEy15BD/pJ/pm8g6NTvfxMBP0w5a/WUg5BqzEOW70EX3FlovYtOpjYZ my-access-key
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6ZEyYKCx1c+GS7aSuFovl02ROiFgQzU9ZlRHpvtDe6xbKmSQFQwO6hYRmIBwa8en58jdC/W74NFUX7GTub0ffUs4r1LSE0SEjC3ylu77nmY/sIiYMs3tW0quVkxXa2jagT77R+yKTw6+G/8sjo6/N8Lb12HbjYA18k07CQZgSBivQGS34CP2mfq8ab0FsiwT8PW0+FZ4FTimGYvaw76qOIS1h33P5mp7u+f7SFjnpne1Gjch0TIUbfSoqKmgRc5a2ccBjwbFIg0TEMqzXavoGIXbHoxELlPSZdWqi7T42oWlvIP+9TBP9JrQwemMgCIUbGPAjFGIHh4lydpqopqHVDcc78z+rs4d1aNLTlFBPu2PMU4sIZHh6CXkoLJaopTe1lQ+QJAdMmE10RzqYou2f0KHz9zOuS4fFhI7QiKEHl8PA1d4lEbfZEXVsV+WhpTSdS6uvaMeyoBlrpW+0C27cYOOYPAJgrsVW3IXobcK/Z7MSI1kt+oULqidPL1JM/O0= root@server

# ssh 접속 테스트
root@server:~/my-ansible# for i in {1..3}; do echo ">> tnode$i <<"; ssh tnode$i hostname; echo; done
>> tnode1 <<
tnode1

>> tnode2 <<
tnode2

>> tnode3 <<
tnode3



# python 정보 확인
root@server:~/my-ansible# for i in {1..3}; do echo ">> tnode$i <<"; ssh tnode$i python3 -V; echo; done
>> tnode1 <<
Python 3.12.3

>> tnode2 <<
Python 3.12.3

>> tnode3 <<
Python 3.9.21
```