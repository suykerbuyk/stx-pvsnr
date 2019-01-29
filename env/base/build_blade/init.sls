{% set stx_node_rack = salt['grains.get']('stx:node:rack') %}
{% set stx_image_src = salt['pillar.get']('stx_bci:blade:image') %}
{% set stx_boot_disks = salt['stx_disk.by_criteria']('100', '900') %}
# {% set stx_var_disks  = salt['stx_disk.by_criteria']('300', '7000') %}
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
      - file.access /root/provisioning.done f

image_boot_disk:
  cmd.run:
    - name: /bin/stx-imager-blade.sh /dev/{{stx_boot_disks["matching"][0]}} {{mnt_point1}} {{stx_image_src}}
    - shell: /bin/bash
    - require:
      - wipe_disk
    - unless:
      - file.access /root/provisioning.done f

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
      - test -f {{mnt_point1}}/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

update_packages:
  cmd.run:
    - name: /bin/yum install -y --installroot={{mnt_point1}}/ tmux screen salt-minion
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
    - source: salt://build_blade/files/etc/salt
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
      - set_salt_dir_files

set_minion_id:
  file.managed:
    - name: {{mnt_point1}}/etc/salt/minion_id
    - mode: 0644
    - source: /etc/salt/minion_id
    - require:
      - set_minion_file

set_minion_grain_file:
  file.managed:
    - name: {{mnt_point1}}/etc/salt/grains
    - mode: 0644
    - source: /etc/salt/grains
    - require:
      - set_minion_id

set_bin_files:
  file.recurse:
    - name: {{mnt_point1}}/bin
    - source: salt://build_blade/files/bin
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
      - '0000:01:00.0 eth'
      - '0000:02:00.0 eth eth'

set_network_file:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network
    - file_mode: 0644
    - require:
      - update_packages
      - set_mlx4_conf
    - contents:
      - SEARCH=mero.colo.seagate.com
      - NETWORKING=yes
      - NETWORKING_IPV6=no
      - GATEWAY=10.230.160.1
      - GATEWAYDEV=enp5s0f0

set_network_mgmt_port1:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-enp5s0f0
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Ethernet
      - DEVICE=enp5s0f0
      - NAME=enp5s0f0
      - BOOTPROTO=dhcp
      - DEFROUTE=yes
      - IPV4_FAILURE_FATAL=no
      - MTU=1500
      - NM_CONTROLLED=no
      - ONBOOT=yes

set_network_mgmt_port2:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-enp5s0f1
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Ethernet
      - DEVICE=enp5s0f1
      - NAME=enp5s0f1
      - BOOTPROTO=dhcp
      - DEFROUTE=no
      - IPV4_FAILURE_FATAL=no
      - MTU=1500
      - NM_CONTROLLED=no
      - ONBOOT=yes

set_network_data_port1:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-p1p1
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Ethernet
      - DEVICE=p1p1
      - NAME=p1p1
      - BOOTPROTO=dhcp
      - DEFROUTE=no
      - IPV4_FAILURE_FATAL=no
      - MTU=9000
      - NM_CONTROLLED=no
      - ONBOOT=yes

set_network_data_port2:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-em1
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Ethernet
      - DEVICE=em1
      - NAME=em1
      - BOOTPROTO=dhcp
      - DEFROUTE=no
      - IPV4_FAILURE_FATAL=no
      - MTU=9000
      - NM_CONTROLLED=no
      - ONBOOT=yes

set_network_data_port3:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-em2
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Ethernet
      - DEVICE=em2
      - NAME=em2
      - BOOTPROTO=dhcp
      - DEFROUTE=no
      - IPV4_FAILURE_FATAL=no
      - MTU=9000
      - NM_CONTROLLED=no
      - ONBOOT=yes

rm_ifcfg_lan0:
  file.absent:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-lan0

set_root_ssh_dir_files:
  file.recurse:
    - name: {{mnt_point1}}/root/.ssh
    - source: salt://build_blade/files/root/ssh
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
    - source: salt://build_blade/files/etc/ssh
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
      - file.access {{mnt_point1}}/etc/systemd/system/multi-user.target.wants/salt-minion.service f

salt_disable_firewalld:
    cmd.run:
    - name: systemctl --root={{mnt_point1}} disable firewalld

{% endif %} # if stx_live_minion
