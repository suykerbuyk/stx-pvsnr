{% set stx_node_rack = salt['grains.get']('stx:node:rack') %}
{% set stx_image_src = salt['pillar.get']('stx_bci:cmu:image') %}
{% set stx_boot_disks = salt['stx_disk.by_criteria']('20', '150') %}
{% set stx_var_disks  = salt['stx_disk.by_criteria']('300', '7000') %}
{% set mnt_point1 = '/target_root' %}

{% if salt['grains.get']('stx_live_image') %}

include:
  - live_minion

wipe_disk:
  cmd.run:
    - name: /bin/stx-wipe-disk.sh
    - shell: /bin/bash
    - require:
      - sls: live_minion
    - unless:
      - file.file_exists /root/provisioning.done f

image_boot_disk:
  cmd.run:
    - name: /bin/stx-imager-cmu.sh /dev/{{stx_boot_disks["matching"][0]}} {{mnt_point1}} {{stx_image_src}}
    - shell: /bin/bash
    - require:
      - wipe_disk
    - unless:
      - file.access /root/provisioning.done f

mk_raid_disk:
  raid.present:
    - name: /dev/md0
    - level: 1
    - devices:
      - /dev/{{stx_var_disks['matching'][0]}}
      - /dev/{{stx_var_disks['matching'][1]}}
    - chunk: 256
    - run: True
    - require:
      - image_boot_disk
    - unless:
        - ls /dev/ | grep md0

label_raid_disk:
  module.run:
    - name: partition.mklabel
    - device: /dev/md0
    - label_type: gpt
    - require:
      - mk_raid_disk
    - unless:
      - fdisk -l /dev/md0 | grep 'Disk label type: dos'

make_swap_part:
  module.run:
    - name: partition.mkpartfs
    - device: /dev/md0
    - part_type: primary
    - fs_type: linux-swap
    - start: 0GB
    - end: 64GB
    - require:
      - label_raid_disk
    - unless:
      - file.is_blkdev /dev/md0p1

make_opt_part:
  module.run:
    - name: partition.mkpartfs
    - device: /dev/md0
    - part_type: primary
    - fs_type: ext2
    - start: 64GB
    - end: 100%
    - require:
      - label_raid_disk
      - make-swap-fs
    - unless:
      - file.is_blkdev /dev/md0p2

make_opt_fs:
  cmd.run:
    - name: 'mkfs.ext4 -U 8974698e-07c0-4e84-af44-55fc3d77fce8 -L opt /dev/md0p2'
    - require:
      - make_opt_part
    - unless:
      - disk.blkid /dev/md0p2 | grep ext

update_mdadm_conf:
  cmd.run:
    - name: 'mdadm --detail --scan /dev/md0 >{{mnt_point1}}/etc/mdadm.conf'
    - shell: /bin/bash
    - python_script: True
    - require:
      - mk_raid_disk

make-opt-mntpoint:
  cmd.run:
    - name: '[ -d {{mnt_point1}}/opt/seagate ] || mkdir -p {{mnt_point1}}/opt/seagate'

make_opt_fstab:
  file.append:
    - name: {{mnt_point1}}/etc/fstab
    - text:
      - UUID=8974698e-07c0-4e84-af44-55fc3d77fce8 /opt/seagate ext4 defaults 1 1

make-swap-fs:
  cmd.run:
    - name: 'mkswap -U d8e9f0b7-aa51-47eb-9ee2-af4007dc9872 -L swap /dev/md0p1'
    - require:
      - make_swap_part
    - unless:
      - disk.blkid /dev/md0p1 | grep swap

configure_repositories:
  file.recurse:
    - name: {{mnt_point1}}/etc/yum.repos.d
    - source: salt://files/etc/yum.repos.d
    - clean: True
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0644
    - keep_symlinks: False
    - include_empty: True
    - require:
      - image_boot_disk

import_rpm_keys:
  cmd.run:
    - name: rpm --import --root {{mnt_point1}}/ http://stx-prvsnr/vendor/centos/7.5.1804/RPM-GPG-KEY-CentOS-7
    - require:
      - configure_repositories
    - unless:
      - file.file_exists {{mnt_point1}}/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

update_packages:
  cmd.run:
    - name: /bin/yum install -y --installroot={{mnt_point1}}/ tmux screen nfs-utils dnsmasq darkhttpd salt-minion salt-ssh salt salt-master
    - require:
      - import_rpm_keys

purge_packages:
  cmd.run:
    - name: /bin/yum erase -y --installroot={{mnt_point1}}/ NetworkManager ; true
    - require:
      - update_packages

set_salt_dir_files:
  file.recurse:
    - name: {{mnt_point1}}/etc/salt
    - source: salt://build_cmu/files/etc/salt
    - clean: True
    - keep_source: False
    - dir_mode: 0755
    - file_mode: keep
    - keep_symlinks: False
    - include_empty: True
    - require:
      - update_packages

set_minion_file:
  file.managed:
    - name: {{mnt_point1}}/etc/salt/minion
    - source: /etc/salt/minion
    - mode: 0644
    - require:
      - update_packages

set_minion_id:
  file.managed:
    - name: {{mnt_point1}}/etc/salt/minion_id
    - mode: 0644
    - source: /etc/salt/minion_id
    - require:
      - update_packages

set_minion_grain_file:
  file.managed:
    - name: {{mnt_point1}}/etc/salt/grains
    - mode: 0644
    - source: /etc/salt/grains
    - require:
      - update_packages

set_bin_files:
  file.recurse:
    - name: {{mnt_point1}}/bin
    - source: salt://build_cmu/files/bin
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0755
    - keep_symlinks: False
    - include_empty: True
    - require:
      - update_packages

set_mlx4_conf:
  file.managed:
    - name: {{mnt_point1}}/etc/rdma/mlx4.conf
    - contents:
      - '0000:0c:00.0 eth eth'

set_network_file:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network
    - file_mode: 0755
    - require:
      - update_packages
    - contents:
      - SEARCH=mero.colo.seagate.com
      - NETWORKING=yes
      - NETWORKING_IPV6=no
      - GATEWAY=10.230.160.1
      - GATEWAYDEV=p2p1

set_bonding_config:
  file.managed:
    - name: {{mnt_point1}}/etc/modprobe.d/bonding.conf
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - 'options bonding max_bonds=0'

set_network_mgmt_ext:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-p2p1
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Ethernet
      - DEVICE=p2p1
      - PROXY_METHOD=none
      - BROWSER_ONLY=no
      - BOOTPROTO=dhcp
      - DEFROUTE=yes
      - IPV4_FAILURE_FATAL=no
      - IPV6INIT=no
      - IPV6_AUTOCONF=yes
      - IPV6_DEFROUTE=yes
      - IPV6_FAILURE_FATAL=no
      - IPV6_ADDR_GEN_MODE=stable-privacy
      - ONBOOT=yes
      - NM_CONTROLLED=no

set_network_int_p1:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-enp12s0
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Ethernet
      - NAME=enp12s0
      - BOOTPROTO=none
      - USRCTL=no
      - DEVICE=enp12s0
      - ONBOOT=yes
      - MASTER=bond0
      - MTU=9000
      - NM_CONTROLLED=no

set_network_int_p2:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-enp12s0d1
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Ethernet
      - NAME=enp12s0d1
      - BOOTPROTO=none
      - USRCTL=no
      - DEVICE=enp12s0d1
      - ONBOOT=yes
      - MASTER=bond0
      - SLAVE=yes
      - MTU=9000
      - NM_CONTROLLED=no

set_network_int_bond0:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-bond0
    - file_mode: 0755
    - require:
      - set_network_int_p1
      - set_network_int_p2
    - contents:
      - DEVICE=bond0
      - 'BONDING_OPTS="mode=4 miimon=100 lacp_rate=1"'
      - TYPE=Bond
      - BONDING_MASTER=yes
      - BOOTPROTO=none
      - DEFROUTE=yes
      - IPV4_FAILURE_FATAL=no
      - IPV6INIT=no
      - NAME=bond0
      - ONBOOT=yes
      - SLAVE=yes
      - MTU=9000
      - NM_CONTROLLED=no

set_network_int_bond0_2:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-bond0.2
    - file_mode: 0755
    - require:
      - set_network_int_bond0
    - contents:
      - DEVICE=bond0.2
      - IPADDR=172.16.10.41
      - NETMASK=255.255.0.0
      - DEFROUTE=yes
      - ONBOOT=yes
      - BOOTPROTO=yes
      - VLAN=yes

set_network_int_bond0_3:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-bond0.3
    - file_mode: 0755
    - require:
      - set_network_int_bond0
    - contents:
      - DEVICE=bond0.3
      - IPADDR=172.19.10.41
      - NETMASK=255.255.0.0
      - DEFROUTE=yes
      - ONBOOT=yes
      - BOOTPROTO=yes
      - VLAN=yes

rm_ifcfg_lan0:
  file.absent:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-lan0

rm_ifcfg_eth0:
  file.absent:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-eth0

rm_ifcfg_eth1:
  file.absent:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-eth1

rm_ifcfg_eth2:
  file.absent:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-eth2

rm_ifcfg_eth3:
  file.absent:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-eth3

set_root_ssh_dir_files:
  file.recurse:
    - name: {{mnt_point1}}/root/.ssh
    - source: salt://build_cmu/files/root/ssh
    - keep_source: False
    - dir_mode: 0700
    - file_mode: 0600
    - user: root
    - group: root
    - clean: True
    - keep_symlinks: False
    - include_empty: True
    - require:
      - update_packages

set_etc_ssh_dir_files:
  file.recurse:
    - name: {{mnt_point1}}/etc/ssh/
    - source: salt://build_cmu/files/etc/ssh
    - keep_source: False
    - dir_mode: 0755
    - file_mode: keep
    - user: root
    - group: root
    - clean: True
    - keep_symlinks: False
    - include_empty: True
    - require:
      - update_packages

set_etc_host_name:
  file.managed:
    - name: {{mnt_point1}}/etc/hostname
    - source: /etc/hostname
    - user: root
    - group: root

make_swap_fstab:
  file.append:
    - name: {{mnt_point1}}/etc/fstab
    - text:
      - UUID=d8e9f0b7-aa51-47eb-9ee2-af4007dc9872 none swap sw 0 0

set_nic_bios_dev_name_grub:
  file.replace:
    - name: {{mnt_point1}}/etc/grub2.cfg
    - pattern: 'biosdevname=0'
    - repl: 'biosdevname=1'
    - append_if_not_found: False
    - prepend_if_not_found: False
    - ignore_if_missing: True

set_nic_bios_dev_name_boot:
  file.replace:
    - name: {{mnt_point1}}/boot/grub2/grub.cfg
    - pattern: 'biosdevname=0'
    - repl: 'biosdevname=1'
    - append_if_not_found: False
    - prepend_if_not_found: False
    - ignore_if_missing: True

set_nic_net_if_name_grub:
  file.replace:
    - name: {{mnt_point1}}/etc/grub2.cfg
    - pattern: 'net.ifnames=0'
    - repl: 'net.ifnames=1'
    - append_if_not_found: False
    - prepend_if_not_found: False
    - ignore_if_missing: True

set_nic_net_if_name_boot:
  file.replace:
    - name: {{mnt_point1}}/boot/grub2/grub.cfg
    - pattern: 'net.ifnames=0'
    - repl: 'net.ifnames=1'
    - append_if_not_found: False
    - prepend_if_not_found: False
    - ignore_if_missing: True

salt_minion_enable_service:
  cmd.run:
    - name: systemctl --root={{mnt_point1}} enable salt-minion
    - unless:
      - file.access /etc/systemd/system/multi-user.target.wants/salt-minion.service f

salt_disable_firewalld:
    cmd.run:
    - name: systemctl --root={{mnt_point1}} disable firewalld

set_dnsmasq_conf:
  file.managed:
    - name: {{mnt_point1}}/etc/dnsmasq.conf
    - source: salt://build_cmu/files/etc/dnsmasq.conf.{{stx_node_rack}}
    - mode: 0644
    - user: root
    - group: root
    - require:
        - update_packages

set_darkhttpd_config:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/darkhttpd
    - mode: 0644
    - user: root
    - group: root
    - require:
      - update_packages
    - contents:
      - 'DARKHTTPD_ROOT="/prvsnr"'
      - 'DARKHTTPD_FLAGS="--log /var/log/darkhttpd.log --uid root --gid root --addr 172.16.10.41"'
      - 'MIMETYPES="--mimetypes /etc/mime.types"'

set_etc_hosts_file:
  file.managed:
    - name: {{mnt_point1}}/etc/hosts
    - source: salt://build_cmu/files/etc/hosts.{{stx_node_rack}}
    - mode: 0644
    - user: root
    - group: root
    - template: jinja
    - context:
      rack: {{ stx_node_rack }}

set_hosts_dnsmasq_file:
  file.managed:
    - name: {{mnt_point1}}/etc/hosts.dnsmasq
    - source: salt://build_cmu/files/etc/hosts.dnsmasq.{{stx_node_rack}}
    - mode: 0644
    - user: root
    - group: root

nfs_add_mount_dir:
  cmd.run:
    - name: '[ -d {{mnt_point1}}/prvsnr ] || mkdir {{mnt_point1}}/prvsnr'

nfs_add_fstab:
  file.append:
    - name: {{mnt_point1}}/etc/fstab
    - text:
      - 'stx-prvsnr.mero.colo.seagate.com:/prvsnr /prvsnr nfs4 defaults 0 0'
    - require:
      - make_opt_fstab

darkhttp_enable_service:
  cmd.run:
    - name: systemctl --root={{mnt_point1}} enable darkhttpd
    - unless:
      - file.access /etc/systemd/system/multi-user.target.wants/darkhttpd.service f

nfs_enable_service:
  cmd.run:
    - name: systemctl --root={{mnt_point1}} enable nfs
    - unless:
      - file.access /etc/systemd/system/multi-user.target.wants/nfs-server.service f


dnsmasq_enable_service:
  cmd.run:
    - name: systemctl --root={{mnt_point1}} enable dnsmasq
    - unless:
      - file.access /etc/systemd/system/multi-user.target.wants/dnsmasq.service f

salt_master_enable_service:
  cmd.run:
    - name: systemctl --root={{mnt_point1}} enable salt-master
    - unless:
      - file.access /etc/systemd/system/multi-user.target.wants/salt-master.service f

{% endif %} # if stx_live_minion
