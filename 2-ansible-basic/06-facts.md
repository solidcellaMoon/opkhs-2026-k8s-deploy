# Facts

Ansible Facts는 관리 대상 호스트에서 자동으로 수집되는 시스템 정보이다.
플레이북 실행 시 기본으로 수집되며, 조건 분기나 템플릿 렌더링에 활용된다.

## Fact 사용하기

플레이북을 작성한다.
```bash
# my-ansible/facts.yml
---
- hosts: db

  tasks:
  - name: Print all facts
    ansible.builtin.debug:
      var: ansible_facts
```

플레이북을 실행한다.
```bash
root@server:~/my-ansible# ansible-playbook facts.yml

PLAY [db] ******************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]

TASK [Print all facts] *****************************************************************
ok: [tnode3] => {
    "ansible_facts": {
        "all_ipv4_addresses": [
            "172.31.5.232"
        ],
        "all_ipv6_addresses": [
            "fe80::d0:f6ff:fe31:caa5"
        ],
        "ansible_local": {},
        "apparmor": {
            "status": "disabled"
        },
        "architecture": "x86_64",
        "bios_date": "10/16/2017",
        "bios_vendor": "Amazon EC2",
        "bios_version": "1.0",
        "board_asset_tag": "i-07367dc619f39a038",
        "board_name": "NA",
        "board_serial": "NA",
        "board_vendor": "Amazon EC2",
        "board_version": "NA",
        "chassis_asset_tag": "Amazon EC2",
        "chassis_serial": "NA",
        "chassis_vendor": "Amazon EC2",
        "chassis_version": "NA",
        "cmdline": {
            "BOOT_IMAGE": "(hd0,gpt3)/vmlinuz-5.14.0-570.17.1.el9_6.x86_64",
            "console": "ttyS0,115200n8",
            "crashkernel": "1G-4G:192M,4G-64G:256M,64G-:512M",
            "net.ifnames": "0",
            "no_timer_check": true,
            "nvme_core.io_timeout": "4294967295",
            "nvme_core.max_retries": "10",
            "root": "UUID=52ed443e-bcb6-4b82-be88-1526cd4bb5b7"
        },
        "date_time": {
            "date": "2026-01-17",
            "day": "17",
            "epoch": "1768669210",
            "epoch_int": "1768669210",
            "hour": "17",
            "iso8601": "2026-01-17T17:00:10Z",
            "iso8601_basic": "20260117T170010626984",
            "iso8601_basic_short": "20260117T170010",
            "iso8601_micro": "2026-01-17T17:00:10.626984Z",
            "minute": "00",
            "month": "01",
            "second": "10",
            "time": "17:00:10",
            "tz": "UTC",
            "tz_dst": "UTC",
            "tz_offset": "+0000",
            "weekday": "Saturday",
            "weekday_number": "6",
            "weeknumber": "02",
            "year": "2026"
        },
        "default_ipv4": {
            "address": "172.31.5.232",
            "alias": "eth0",
            "broadcast": "172.31.15.255",
            "gateway": "172.31.0.1",
            "interface": "eth0",
            "macaddress": "02:d0:f6:31:ca:a5",
            "mtu": 9001,
            "netmask": "255.255.240.0",
            "network": "172.31.0.0",
            "prefix": "20",
            "type": "ether"
        },
        "default_ipv6": {},
        "device_links": {
            "ids": {
                "nvme0n1": [
                    "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0",
                    "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0_1",
                    "nvme-nvme.1d0f-766f6c3035613232323334613139663064326330-416d617a6f6e20456c617374696320426c6f636b2053746f7265-00000001"
                ],
                "nvme0n1p1": [
                    "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0-part1",
                    "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0_1-part1",
                    "nvme-nvme.1d0f-766f6c3035613232323334613139663064326330-416d617a6f6e20456c617374696320426c6f636b2053746f7265-00000001-part1"
                ],
                "nvme0n1p2": [
                    "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0-part2",
                    "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0_1-part2",
                    "nvme-nvme.1d0f-766f6c3035613232323334613139663064326330-416d617a6f6e20456c617374696320426c6f636b2053746f7265-00000001-part2"
                ],
                "nvme0n1p3": [
                    "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0-part3",
                    "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0_1-part3",
                    "nvme-nvme.1d0f-766f6c3035613232323334613139663064326330-416d617a6f6e20456c617374696320426c6f636b2053746f7265-00000001-part3"
                ],
                "nvme0n1p4": [
                    "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0-part4",
                    "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0_1-part4",
                    "nvme-nvme.1d0f-766f6c3035613232323334613139663064326330-416d617a6f6e20456c617374696320426c6f636b2053746f7265-00000001-part4"
                ]
            },
            "labels": {
                "nvme0n1p2": [
                    "EFI"
                ],
                "nvme0n1p3": [
                    "BOOT"
                ],
                "nvme0n1p4": [
                    "rocky"
                ]
            },
            "masters": {},
            "uuids": {
                "nvme0n1p2": [
                    "B00E-7A0D"
                ],
                "nvme0n1p3": [
                    "5e1eda84-755d-434c-9560-fe2dc6ad4122"
                ],
                "nvme0n1p4": [
                    "52ed443e-bcb6-4b82-be88-1526cd4bb5b7"
                ]
            }
        },
        "devices": {
            "nvme0n1": {
                "holders": [],
                "host": "",
                "links": {
                    "ids": [
                        "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0",
                        "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0_1",
                        "nvme-nvme.1d0f-766f6c3035613232323334613139663064326330-416d617a6f6e20456c617374696320426c6f636b2053746f7265-00000001"
                    ],
                    "labels": [],
                    "masters": [],
                    "uuids": []
                },
                "model": "Amazon Elastic Block Store",
                "partitions": {
                    "nvme0n1p1": {
                        "holders": [],
                        "links": {
                            "ids": [
                                "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0-part1",
                                "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0_1-part1",
                                "nvme-nvme.1d0f-766f6c3035613232323334613139663064326330-416d617a6f6e20456c617374696320426c6f636b2053746f7265-00000001-part1"
                            ],
                            "labels": [],
                            "masters": [],
                            "uuids": []
                        },
                        "sectors": 4096,
                        "sectorsize": 512,
                        "size": "2.00 MB",
                        "start": "2048",
                        "uuid": null
                    },
                    "nvme0n1p2": {
                        "holders": [],
                        "links": {
                            "ids": [
                                "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0-part2",
                                "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0_1-part2",
                                "nvme-nvme.1d0f-766f6c3035613232323334613139663064326330-416d617a6f6e20456c617374696320426c6f636b2053746f7265-00000001-part2"
                            ],
                            "labels": [
                                "EFI"
                            ],
                            "masters": [],
                            "uuids": [
                                "B00E-7A0D"
                            ]
                        },
                        "sectors": 204800,
                        "sectorsize": 512,
                        "size": "100.00 MB",
                        "start": "6144",
                        "uuid": "B00E-7A0D"
                    },
                    "nvme0n1p3": {
                        "holders": [],
                        "links": {
                            "ids": [
                                "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0-part3",
                                "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0_1-part3",
                                "nvme-nvme.1d0f-766f6c3035613232323334613139663064326330-416d617a6f6e20456c617374696320426c6f636b2053746f7265-00000001-part3"
                            ],
                            "labels": [
                                "BOOT"
                            ],
                            "masters": [],
                            "uuids": [
                                "5e1eda84-755d-434c-9560-fe2dc6ad4122"
                            ]
                        },
                        "sectors": 2048000,
                        "sectorsize": 512,
                        "size": "1000.00 MB",
                        "start": "210944",
                        "uuid": "5e1eda84-755d-434c-9560-fe2dc6ad4122"
                    },
                    "nvme0n1p4": {
                        "holders": [],
                        "links": {
                            "ids": [
                                "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0-part4",
                                "nvme-Amazon_Elastic_Block_Store_vol05a22234a19f0d2c0_1-part4",
                                "nvme-nvme.1d0f-766f6c3035613232323334613139663064326330-416d617a6f6e20456c617374696320426c6f636b2053746f7265-00000001-part4"
                            ],
                            "labels": [
                                "rocky"
                            ],
                            "masters": [],
                            "uuids": [
                                "52ed443e-bcb6-4b82-be88-1526cd4bb5b7"
                            ]
                        },
                        "sectors": 123570143,
                        "sectorsize": 512,
                        "size": "58.92 GB",
                        "start": "2258944",
                        "uuid": "52ed443e-bcb6-4b82-be88-1526cd4bb5b7"
                    }
                },
                "removable": "0",
                "rotational": "0",
                "sas_address": null,
                "sas_device_handle": null,
                "scheduler_mode": "none",
                "sectors": 125829120,
                "sectorsize": "512",
                "serial": "vol05a22234a19f0d2c0",
                "size": "60.00 GB",
                "support_discard": "0",
                "vendor": null,
                "virtual": 1
            }
        },
        "distribution": "Rocky",
        "distribution_file_parsed": true,
        "distribution_file_path": "/etc/redhat-release",
        "distribution_file_variety": "RedHat",
        "distribution_major_version": "9",
        "distribution_release": "Blue Onyx",
        "distribution_version": "9.6",
        "dns": {
            "nameservers": [
                "172.31.0.2"
            ],
            "search": [
                "ap-northeast-2.compute.internal"
            ]
        },
        "domain": "",
        "effective_group_id": 0,
        "effective_user_id": 0,
        "env": {
            "BASH_FUNC_which%%": "() {  ( alias;\n eval ${which_declare} ) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot $@\n}",
            "DBUS_SESSION_BUS_ADDRESS": "unix:path=/run/user/0/bus",
            "DEBUGINFOD_IMA_CERT_PATH": "/etc/keys/ima:",
            "DEBUGINFOD_URLS": "https://debuginfod.rockylinux.org/ ",
            "HOME": "/root",
            "LANG": "en_US.UTF-8",
            "LESSOPEN": "||/usr/bin/lesspipe.sh %s",
            "LOGNAME": "root",
            "LS_COLORS": "rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=01;36:*.au=01;36:*.flac=01;36:*.m4a=01;36:*.mid=01;36:*.midi=01;36:*.mka=01;36:*.mp3=01;36:*.mpc=01;36:*.ogg=01;36:*.ra=01;36:*.wav=01;36:*.oga=01;36:*.opus=01;36:*.spx=01;36:*.xspf=01;36:",
            "MOTD_SHOWN": "pam",
            "PATH": "/root/.local/bin:/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin",
            "PWD": "/root",
            "SELINUX_LEVEL_REQUESTED": "",
            "SELINUX_ROLE_REQUESTED": "",
            "SELINUX_USE_CURRENT_RANGE": "",
            "SHELL": "/bin/bash",
            "SHLVL": "1",
            "SSH_CLIENT": "172.31.14.64 36428 22",
            "SSH_CONNECTION": "172.31.14.64 36428 172.31.5.232 22",
            "SSH_TTY": "/dev/pts/1",
            "TERM": "xterm-256color",
            "USER": "root",
            "XDG_RUNTIME_DIR": "/run/user/0",
            "XDG_SESSION_CLASS": "user",
            "XDG_SESSION_ID": "47",
            "XDG_SESSION_TYPE": "tty",
            "_": "/usr/bin/python3",
            "which_declare": "declare -f"
        },
        "eth0": {
            "active": true,
            "device": "eth0",
            "features": {
                "esp_hw_offload": "off [fixed]",
                "esp_tx_csum_hw_offload": "off [fixed]",
                "generic_receive_offload": "on",
                "generic_segmentation_offload": "on",
                "highdma": "on",
                "hsr_dup_offload": "off [fixed]",
                "hsr_fwd_offload": "off [fixed]",
                "hsr_tag_ins_offload": "off [fixed]",
                "hsr_tag_rm_offload": "off [fixed]",
                "hw_tc_offload": "off [fixed]",
                "l2_fwd_offload": "off [fixed]",
                "large_receive_offload": "off [fixed]",
                "loopback": "off [fixed]",
                "macsec_hw_offload": "off [fixed]",
                "ntuple_filters": "off [fixed]",
                "receive_hashing": "on",
                "rx_all": "off [fixed]",
                "rx_checksumming": "off [fixed]",
                "rx_fcs": "off [fixed]",
                "rx_gro_hw": "off [fixed]",
                "rx_gro_list": "off",
                "rx_udp_gro_forwarding": "off",
                "rx_udp_tunnel_port_offload": "off [fixed]",
                "rx_vlan_filter": "off [fixed]",
                "rx_vlan_offload": "off [fixed]",
                "rx_vlan_stag_filter": "off [fixed]",
                "rx_vlan_stag_hw_parse": "off [fixed]",
                "scatter_gather": "on",
                "tcp_segmentation_offload": "off",
                "tls_hw_record": "off [fixed]",
                "tls_hw_rx_offload": "off [fixed]",
                "tls_hw_tx_offload": "off [fixed]",
                "tx_checksum_fcoe_crc": "off [fixed]",
                "tx_checksum_ip_generic": "off [fixed]",
                "tx_checksum_ipv4": "on",
                "tx_checksum_ipv6": "off [fixed]",
                "tx_checksum_sctp": "off [fixed]",
                "tx_checksumming": "on",
                "tx_esp_segmentation": "off [fixed]",
                "tx_fcoe_segmentation": "off [fixed]",
                "tx_gre_csum_segmentation": "off [fixed]",
                "tx_gre_segmentation": "off [fixed]",
                "tx_gso_list": "off [fixed]",
                "tx_gso_partial": "off [fixed]",
                "tx_gso_robust": "off [fixed]",
                "tx_ipxip4_segmentation": "off [fixed]",
                "tx_ipxip6_segmentation": "off [fixed]",
                "tx_nocache_copy": "off",
                "tx_scatter_gather": "on",
                "tx_scatter_gather_fraglist": "off [fixed]",
                "tx_sctp_segmentation": "off [fixed]",
                "tx_tcp6_segmentation": "off [fixed]",
                "tx_tcp_ecn_segmentation": "off [fixed]",
                "tx_tcp_mangleid_segmentation": "off [fixed]",
                "tx_tcp_segmentation": "off [fixed]",
                "tx_tunnel_remcsum_segmentation": "off [fixed]",
                "tx_udp_segmentation": "off [fixed]",
                "tx_udp_tnl_csum_segmentation": "off [fixed]",
                "tx_udp_tnl_segmentation": "off [fixed]",
                "tx_vlan_offload": "off [fixed]",
                "tx_vlan_stag_hw_insert": "off [fixed]",
                "vlan_challenged": "off [fixed]"
            },
            "hw_timestamp_filters": [],
            "ipv4": {
                "address": "172.31.5.232",
                "broadcast": "172.31.15.255",
                "netmask": "255.255.240.0",
                "network": "172.31.0.0",
                "prefix": "20"
            },
            "ipv6": [
                {
                    "address": "fe80::d0:f6ff:fe31:caa5",
                    "prefix": "64",
                    "scope": "link"
                }
            ],
            "macaddress": "02:d0:f6:31:ca:a5",
            "module": "ena",
            "mtu": 9001,
            "pciid": "0000:00:05.0",
            "promisc": false,
            "timestamping": [],
            "type": "ether"
        },
        "fibre_channel_wwn": [],
        "fips": false,
        "flags": [
            "fpu",
            "vme",
            "de",
            "pse",
            "tsc",
            "msr",
            "pae",
            "mce",
            "cx8",
            "apic",
            "sep",
            "mtrr",
            "pge",
            "mca",
            "cmov",
            "pat",
            "pse36",
            "clflush",
            "mmx",
            "fxsr",
            "sse",
            "sse2",
            "ss",
            "ht",
            "syscall",
            "nx",
            "pdpe1gb",
            "rdtscp",
            "lm",
            "constant_tsc",
            "rep_good",
            "nopl",
            "xtopology",
            "nonstop_tsc",
            "cpuid",
            "tsc_known_freq",
            "pni",
            "pclmulqdq",
            "ssse3",
            "fma",
            "cx16",
            "pcid",
            "sse4_1",
            "sse4_2",
            "x2apic",
            "movbe",
            "popcnt",
            "tsc_deadline_timer",
            "aes",
            "xsave",
            "avx",
            "f16c",
            "rdrand",
            "hypervisor",
            "lahf_lm",
            "abm",
            "3dnowprefetch",
            "cpuid_fault",
            "pti",
            "fsgsbase",
            "tsc_adjust",
            "bmi1",
            "avx2",
            "smep",
            "bmi2",
            "erms",
            "invpcid",
            "mpx",
            "avx512f",
            "avx512dq",
            "rdseed",
            "adx",
            "smap",
            "clflushopt",
            "clwb",
            "avx512cd",
            "avx512bw",
            "avx512vl",
            "xsaveopt",
            "xsavec",
            "xgetbv1",
            "xsaves",
            "ida",
            "arat",
            "pku",
            "ospke"
        ],
        "form_factor": "Other",
        "fqdn": "tnode3",
        "gather_subset": [
            "all"
        ],
        "hostname": "tnode3",
        "hostnqn": "",
        "interfaces": [
            "lo",
            "eth0"
        ],
        "is_chroot": false,
        "iscsi_iqn": "",
        "kernel": "5.14.0-570.17.1.el9_6.x86_64",
        "kernel_version": "#1 SMP PREEMPT_DYNAMIC Fri May 23 22:47:01 UTC 2025",
        "lo": {
            "active": true,
            "device": "lo",
            "features": {
                "esp_hw_offload": "off [fixed]",
                "esp_tx_csum_hw_offload": "off [fixed]",
                "generic_receive_offload": "on",
                "generic_segmentation_offload": "on",
                "highdma": "on [fixed]",
                "hsr_dup_offload": "off [fixed]",
                "hsr_fwd_offload": "off [fixed]",
                "hsr_tag_ins_offload": "off [fixed]",
                "hsr_tag_rm_offload": "off [fixed]",
                "hw_tc_offload": "off [fixed]",
                "l2_fwd_offload": "off [fixed]",
                "large_receive_offload": "off [fixed]",
                "loopback": "on [fixed]",
                "macsec_hw_offload": "off [fixed]",
                "ntuple_filters": "off [fixed]",
                "receive_hashing": "off [fixed]",
                "rx_all": "off [fixed]",
                "rx_checksumming": "on [fixed]",
                "rx_fcs": "off [fixed]",
                "rx_gro_hw": "off [fixed]",
                "rx_gro_list": "off",
                "rx_udp_gro_forwarding": "off",
                "rx_udp_tunnel_port_offload": "off [fixed]",
                "rx_vlan_filter": "off [fixed]",
                "rx_vlan_offload": "off [fixed]",
                "rx_vlan_stag_filter": "off [fixed]",
                "rx_vlan_stag_hw_parse": "off [fixed]",
                "scatter_gather": "on",
                "tcp_segmentation_offload": "on",
                "tls_hw_record": "off [fixed]",
                "tls_hw_rx_offload": "off [fixed]",
                "tls_hw_tx_offload": "off [fixed]",
                "tx_checksum_fcoe_crc": "off [fixed]",
                "tx_checksum_ip_generic": "on [fixed]",
                "tx_checksum_ipv4": "off [fixed]",
                "tx_checksum_ipv6": "off [fixed]",
                "tx_checksum_sctp": "on [fixed]",
                "tx_checksumming": "on",
                "tx_esp_segmentation": "off [fixed]",
                "tx_fcoe_segmentation": "off [fixed]",
                "tx_gre_csum_segmentation": "off [fixed]",
                "tx_gre_segmentation": "off [fixed]",
                "tx_gso_list": "on",
                "tx_gso_partial": "off [fixed]",
                "tx_gso_robust": "off [fixed]",
                "tx_ipxip4_segmentation": "off [fixed]",
                "tx_ipxip6_segmentation": "off [fixed]",
                "tx_nocache_copy": "off [fixed]",
                "tx_scatter_gather": "on [fixed]",
                "tx_scatter_gather_fraglist": "on [fixed]",
                "tx_sctp_segmentation": "on",
                "tx_tcp6_segmentation": "on",
                "tx_tcp_ecn_segmentation": "on",
                "tx_tcp_mangleid_segmentation": "on",
                "tx_tcp_segmentation": "on",
                "tx_tunnel_remcsum_segmentation": "off [fixed]",
                "tx_udp_segmentation": "on",
                "tx_udp_tnl_csum_segmentation": "off [fixed]",
                "tx_udp_tnl_segmentation": "off [fixed]",
                "tx_vlan_offload": "off [fixed]",
                "tx_vlan_stag_hw_insert": "off [fixed]",
                "vlan_challenged": "on [fixed]"
            },
            "hw_timestamp_filters": [],
            "ipv4": {
                "address": "127.0.0.1",
                "broadcast": "",
                "netmask": "255.0.0.0",
                "network": "127.0.0.0",
                "prefix": "8"
            },
            "ipv6": [
                {
                    "address": "::1",
                    "prefix": "128",
                    "scope": "host"
                }
            ],
            "mtu": 65536,
            "promisc": false,
            "timestamping": [],
            "type": "loopback"
        },
        "loadavg": {
            "15m": 0.0,
            "1m": 0.0,
            "5m": 0.0
        },
        "locally_reachable_ips": {
            "ipv4": [
                "127.0.0.0/8",
                "127.0.0.1",
                "172.31.5.232"
            ],
            "ipv6": [
                "::1",
                "fe80::d0:f6ff:fe31:caa5"
            ]
        },
        "lsb": {},
        "lvm": "N/A",
        "machine": "x86_64",
        "machine_id": "ec2be459ebc37a286e24d0be08311049",
        "memfree_mb": 974,
        "memory_mb": {
            "nocache": {
                "free": 1428,
                "used": 285
            },
            "real": {
                "free": 974,
                "total": 1713,
                "used": 739
            },
            "swap": {
                "cached": 0,
                "free": 0,
                "total": 0,
                "used": 0
            }
        },
        "memtotal_mb": 1713,
        "module_setup": true,
        "mounts": [
            {
                "block_available": 15021208,
                "block_size": 4096,
                "block_total": 15429883,
                "block_used": 408675,
                "device": "/dev/nvme0n1p4",
                "dump": 0,
                "fstype": "xfs",
                "inode_available": 30852243,
                "inode_total": 30892528,
                "inode_used": 40285,
                "mount": "/",
                "options": "rw,seclabel,relatime,attr2,inode64,logbufs=8,logbsize=32k,noquota",
                "passno": 0,
                "size_available": 61526867968,
                "size_total": 63200800768,
                "uuid": "52ed443e-bcb6-4b82-be88-1526cd4bb5b7"
            },
            {
                "block_available": 172528,
                "block_size": 4096,
                "block_total": 239616,
                "block_used": 67088,
                "device": "/dev/nvme0n1p3",
                "dump": 0,
                "fstype": "xfs",
                "inode_available": 511635,
                "inode_total": 512000,
                "inode_used": 365,
                "mount": "/boot",
                "options": "rw,seclabel,relatime,attr2,inode64,logbufs=8,logbsize=32k,noquota",
                "passno": 0,
                "size_available": 706674688,
                "size_total": 981467136,
                "uuid": "5e1eda84-755d-434c-9560-fe2dc6ad4122"
            },
            {
                "block_available": 45826,
                "block_size": 2048,
                "block_total": 51091,
                "block_used": 5265,
                "device": "/dev/nvme0n1p2",
                "dump": 0,
                "fstype": "vfat",
                "inode_available": 0,
                "inode_total": 0,
                "inode_used": 0,
                "mount": "/boot/efi",
                "options": "rw,relatime,fmask=0077,dmask=0077,codepage=437,iocharset=ascii,shortname=winnt,errors=remount-ro",
                "passno": 0,
                "size_available": 93851648,
                "size_total": 104634368,
                "uuid": "B00E-7A0D"
            }
        ],
        "nodename": "tnode3",
        "os_family": "RedHat",
        "pkg_mgr": "dnf",
        "proc_cmdline": {
            "BOOT_IMAGE": "(hd0,gpt3)/vmlinuz-5.14.0-570.17.1.el9_6.x86_64",
            "console": "ttyS0,115200n8",
            "crashkernel": "1G-4G:192M,4G-64G:256M,64G-:512M",
            "net.ifnames": "0",
            "no_timer_check": true,
            "nvme_core.io_timeout": "4294967295",
            "nvme_core.max_retries": "10",
            "root": "UUID=52ed443e-bcb6-4b82-be88-1526cd4bb5b7"
        },
        "processor": [
            "0",
            "GenuineIntel",
            "Intel(R) Xeon(R) Platinum 8259CL CPU @ 2.50GHz",
            "1",
            "GenuineIntel",
            "Intel(R) Xeon(R) Platinum 8259CL CPU @ 2.50GHz"
        ],
        "processor_cores": 1,
        "processor_count": 1,
        "processor_nproc": 2,
        "processor_threads_per_core": 2,
        "processor_vcpus": 2,
        "product_name": "t3.small",
        "product_serial": "ec2be459-ebc3-7a28-6e24-d0be08311049",
        "product_uuid": "ec2be459-ebc3-7a28-6e24-d0be08311049",
        "product_version": "NA",
        "python": {
            "executable": "/usr/bin/python3",
            "has_sslcontext": true,
            "type": "cpython",
            "version": {
                "major": 3,
                "micro": 21,
                "minor": 9,
                "releaselevel": "final",
                "serial": 0
            },
            "version_info": [
                3,
                9,
                21,
                "final",
                0
            ]
        },
        "python_version": "3.9.21",
        "real_group_id": 0,
        "real_user_id": 0,
        "selinux": {
            "config_mode": "enforcing",
            "mode": "enforcing",
            "policyvers": 33,
            "status": "enabled",
            "type": "targeted"
        },
        "selinux_python_present": true,
        "service_mgr": "systemd",
        "ssh_host_key_ecdsa_public": "AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBINDQNqnGxpSremAMavD14MGAV+hE1QBTAJMH6XtAwaECT89Zvuh3uiYrjMD4fLHkX3cw91c5T5Nw30bS/Cq3QE=",
        "ssh_host_key_ecdsa_public_keytype": "ecdsa-sha2-nistp256",
        "ssh_host_key_ed25519_public": "AAAAC3NzaC1lZDI1NTE5AAAAIIbCFh4YQZUzIOMe+0vhZVt0CDZuDI0lWBSSi1BpyDKe",
        "ssh_host_key_ed25519_public_keytype": "ssh-ed25519",
        "ssh_host_key_rsa_public": "AAAAB3NzaC1yc2EAAAADAQABAAABgQCgXbF8ug0naWLkaHw4KWzCMSATRkP4Ls/AsdEXzRj6vSVP9kmE7p6OVEesaBJO/wD4M9OxNAJrUYo732Lk6OHQmBjil0UXgR76aq7v1hYbVRIUA6T0eH7S0jeBZZ2FU8zwGPuR/3On3POMcOaJH998HRzw0XXaW8elmLo9pYxZlcT/fNAO/sk2yIUt7trkMMNIT4p4baaNtumQd5Y7NiFG1kXBFx5k+PKPCGdIkVIsx5709S26S59MUpaPbxQs0fclEGIQ94q/0tWf2rFiEtqTCU5iftq/G6150A0AE4nTkaxPwnwzjWSbvUwpFGkXNUH6i8eFxInXyScHjYqPFiqjQ6CECVXoTEMPpnlWisnJHmLqcqvCv4/Hsd3N4CcFKjbhKwbjDgLbh/L944U8mSH8K064i02PdsmrWE+BSqZOjnvyU25bjTw3atCtBMOr/jErw0dXTOp1Xz7VTsYznahWzWTfJ1UTrQPLtjHIbTetq1VYzUjnq8/mdEvmnnBW5hs=",
        "ssh_host_key_rsa_public_keytype": "ssh-rsa",
        "swapfree_mb": 0,
        "swaptotal_mb": 0,
        "system": "Linux",
        "system_capabilities": [],
        "system_capabilities_enforced": "False",
        "system_vendor": "Amazon EC2",
        "systemd": {
            "features": "+PAM +AUDIT +SELINUX -APPARMOR +IMA +SMACK +SECCOMP +GCRYPT +GNUTLS +OPENSSL +ACL +BLKID +CURL +ELFUTILS +FIDO2 +IDN2 -IDN -IPTC +KMOD +LIBCRYPTSETUP +LIBFDISK +PCRE2 -PWQUALITY +P11KIT -QRENCODE +TPM2 +BZIP2 +LZ4 +XZ +ZLIB +ZSTD -BPF_FRAMEWORK +XKBCOMMON +UTMP +SYSVINIT default-hierarchy=unified",
            "version": 252
        },
        "uptime_seconds": 13744,
        "user_dir": "/root",
        "user_gecos": "root",
        "user_gid": 0,
        "user_id": "root",
        "user_shell": "/bin/bash",
        "user_uid": 0,
        "userspace_architecture": "x86_64",
        "userspace_bits": "64",
        "virtualization_role": "guest",
        "virtualization_tech_guest": [
            "kvm"
        ],
        "virtualization_tech_host": [],
        "virtualization_type": "kvm"
    }
}

PLAY RECAP *****************************************************************************
tnode3                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```

## Fact를 통해 수집된 변수 중 특정 값만 추출

플레이북을 작성한다.

```bash
# my-ansible/facts1.yml
---
- hosts: db

  tasks:
  - name: Print all facts
    ansible.builtin.debug:
      msg: >
        The default IPv4 address of {{ ansible_facts.hostname }}
        is {{ ansible_facts.default_ipv4.address }}
```

플레이북을 실행한다.
```bash
root@server:~/my-ansible# ansible-playbook facts1.yml

PLAY [db] ******************************************************************************

TASK [Gathering Facts] *****************************************************************
ok: [tnode3]

TASK [Print all facts] *****************************************************************
ok: [tnode3] => {
    "msg": "The default IPv4 address of tnode3 is 172.31.5.232\n"
}

PLAY RECAP *****************************************************************************
tnode3                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```