# Ansible Roles

Ansible Role은 플레이북을 기능 단위로 구조화하기 위한 표준 디렉토리 규칙이다. 역할별로 변수, 태스크, 핸들러, 템플릿 등을 분리해 재사용성과 유지보수성을 높인다.

- 플레이북에서 전달된 **변수**를 사용. 변수 미설정 시 기본값을 롤의 해당 변수에 설정하기도 한다.
- **콘텐츠**를 **그룹화**하여 코드를 다른 사용자와 쉽게 공유할 수 있다.
- 웹 서버, 데이터베이스 서버 또는 깃(Git) 리포지터리와 같은 **시스템** 유형의 **필수 요소**를 **정의**할 수 있다.
- 대규모 프로젝트를 쉽게 관리할 수 있다.
- 다른 사용자와 **동시**에 **개발**할 수 있다.
- 잘 작성한 롤은 앤서블 **갤럭시**를 통해 **공유**하거나 다른 사람이 공유한 롤을 가져올 수도 있다.


## 기본 디렉토리 구조
```
roles/
  web/
    tasks/
      main.yml
    handlers/
      main.yml
    templates/
      nginx.conf.j2
    files/
      index.html
    vars/
      main.yml
    defaults/
      main.yml
    meta/
      main.yml
```

| **하위 디렉토리** | **기능**                                                                                                          |
| ----------- | --------------------------------------------------------------------------------------------------------------- |
| defaults    | 이 디렉토리의 main.yml 파일에는 롤이 사용될 때 덮어쓸 수 있는 롤 변수의 기본값이 포함되어 있습니다.  <br>이러한 변수는 우선순위가 낮으며 플레이에서 변경할 수 있습니다.          |
| files       | 이 디렉토리에는 롤 작업에서 참조한 정적 파일이 있습니다.                                                                                |
| handlers    | 이 디렉토리의 main.yml 파일에는 롤의 핸들러 정의가 포함되어 있습니다.                                                                     |
| meta        | 이 디렉토리의 main.yml 파일에는 작성자, 라이센스, 플랫폼 및 옵션, 롤 종속성을 포함한 롤에 대한 정보가 들어 있습니다.                                        |
| tasks       | 이 디렉토리의 main.yml 파일에는 롤의 작업 정의가 포함되어 있습니다.                                                                      |
| templates   | 이 디렉토리에는 롤 작업에서 참조할 Jinja2 템플릿이 있습니다.                                                                           |
| tests       | 이 디렉토리에는 롤을 테스트하는 데 사용할 수 있는 인벤토리와 test.yml 플레이북이 포함될 수 있습니다.                                                   |
| vars        | 이 디렉토리의 main.yml 파일은 롤의 변수 값을 정의합니다. 종종 이러한 변수는 롤 내에서 내부 목적으로 사용됩니다.  <br>또한 우선순위가 높으며, 플레이북에서 사용될 때 변경되지 않습니다. |


## Role 생성 방법
```bash
# 서브 명령어 확인 : init 롤 생성 서브 명령어
root@server:~/my-ansible# ansible-galaxy role -h
usage: ansible-galaxy role [-h] ROLE_ACTION ...

positional arguments:
  ROLE_ACTION
    init       Initialize new role with the base structure of a role.
    remove     Delete roles from roles_path.
    delete     Removes the role from Galaxy. It does not remove or alter the actual
               GitHub repository.
    list       Show the name and version of each role installed in the roles_path.
    search     Search the Galaxy database by tags, platforms, author and multiple
               keywords.
    import     Import a role into a galaxy server
    setup      Manage the integration between Galaxy and the given source.
    info       View more details about a specific role.
    install    Install role(s) from file(s), URL(s) or Ansible Galaxy

options:
  -h, --help   show this help message and exit
ansible-galaxy role init roles/web


# 롤 생성
root@server:~/my-ansible# ansible-galaxy role init my-role
- Role my-role was created successfully


root@server:~/my-ansible# tree ./my-role/
./my-role/
├── README.md
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

9 directories, 8 files
```