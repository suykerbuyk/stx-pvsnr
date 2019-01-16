{% set stx_node_rack = salt['grains.get']('stx:node:rack') %}
{% set stx_image_src = salt['pillar.get']('stx_bci:ssu:image') %}
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
      - file.access /root/provisioning.done f

image_boot_disk:
  cmd.run:
    - name: /bin/stx-imager-ssu.sh /dev/{{stx_boot_disks["matching"][0]}} {{mnt_point1}} {{stx_image_src}}
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
      - /dev/md0
    - unless:
      - fdisk -l /dev/md0 | grep 'Disk label type: gpt'

make_swap_part:
  module.run:
    - name: partition.mkpartfs
    - device: /dev/md0
    - part_type: primary
    - fs_type: linux-swap
    - start: 0GB
    - end: 50%
    - require:
      - label_raid_disk
    - unless:
      - file.is_blkdev /dev/md0p1

make_swap_fs:
  cmd.run:
    - name: 'mkswap -U d8e9f0b7-aa51-47eb-9ee2-af4007dc9872 -L swap /dev/md0p1'
    - require:
      - make_swap_part
    - unless:
      - disk.blkid /dev/md0p1 | grep swap

make_swap_fstab:
  file.append:
    - name: {{mnt_point1}}/etc/fstab
    - text:
      - UUID=d8e9f0b7-aa51-47eb-9ee2-af4007dc9872 none swap sw 0 0
    - require:
      - make_swap_fs

make_opt_part:
  module.run:
    - name: partition.mkpartfs
    - device: /dev/md0
    - part_type: primary
    - fs_type: ext2
    - start: 50%
    - end: 100%
    - require:
      - label_raid_disk
      - make_swap_fs
    - unless:
      - file.is_blkdev /dev/md0p2

make_opt_fs:
  cmd.run:
    - name: 'mkfs.ext4 -U 8974698e-07c0-4e84-af44-55fc3d77fce8 -L opt /dev/md0p2'
    - require:
      - make_opt_part
    - unless:
      - disk.blkid /dev/md0p2 | grep ext

make_opt_mntpoint:
  cmd.run:
    - name: '[ -d {{mnt_point1}}/var/mero ] || mkdir -p {{mnt_point1}}/var/mero'
    - require:
      - make_opt_fs

make_opt_fstab:
  file.append:
    - name: {{mnt_point1}}/etc/fstab
    - text:
      - UUID=8974698e-07c0-4e84-af44-55fc3d77fce8 /var/mero ext4 defaults 1 1
    - require:
      - make_opt_mntpoint

update_mdadm_conf:
  cmd.run:
    - name: 'mdadm --detail --scan /dev/md0 >{{mnt_point1}}/etc/mdadm.conf'
    - shell: /bin/bash
    - python_script: True
    - require:
      - /dev/md0

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
    - source: salt://build_ssu/files/etc/salt
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
    - source: salt://build_ssu/files/bin
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
    - file_mode: 0644
    - require:
      - update_packages
    - contents:
      - NETWORKING=yes
      - NETWORKING_IPV6=no

set_bonding_config:
  file.managed:
    - name: {{mnt_point1}}/etc/modprobe.d/bonding.conf
    - file_mode: 0644
    - require:
      - set_network_file
    - contents:
      - 'options bonding max_bonds=0'

set_network_mgmt_port1:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-p2p1
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Ethernet
      - DEVICE=p2p1
      - BOOTPROTO=none
      - MASTER=mgmt0
      - SLAVE=yes
      - NAME=p2p1
      - NM_CONTROLLED=no
      - USRCTL=no
      - ONBOOT=yes
      - MTU=1500

set_network_mgmt_port2:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-p3p1
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Ethernet
      - DEVICE=p3p1
      - BOOTPROTO=none
      - MASTER=mgmt0
      - SLAVE=yes
      - NAME=p3p1
      - NM_CONTROLLED=no
      - USRCTL=no
      - ONBOOT=yes
      - MTU=1500

set_network_mgmt0:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-mgmt0
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Bond
      - DEVICE=mgmt0
      - NAME=mgmt0
      - BOOTPROTO=dhcp
      - ONBOOT=yes
      - DEFROUTE=yes
      - BONDING_MASTER=yes
      - BONDING_OPTS="mode=active-backup primary=p2p1 miimon=100"
      - NM_CONTROLLED=no
      - USRCTL=no
      - ONBOOT=yes
      - MTU=1500

set_network_data_port1:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-enp12s0
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Ethernet
      - DEVICE=enp12s0
      - BOOTPROTO=none
      - MASTER=data0
      - SLAVE=yes
      - NAME=enp12s0
      - NM_CONTROLLED=no
      - USRCTL=no
      - ONBOOT=yes
      - MTU=9000

set_network_data_port2:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-enp12s0d1
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Ethernet
      - DEVICE=enp12s0d1
      - BOOTPROTO=none
      - MASTER=data0
      - SLAVE=yes
      - NAME=enp12s0d1
      - NM_CONTROLLED=no
      - USRCTL=no
      - ONBOOT=yes
      - MTU=9000

set_network_data0:
  file.managed:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts/ifcfg-data0
    - file_mode: 0755
    - require:
      - set_network_file
    - contents:
      - TYPE=Bond
      - DEVICE=data0
      - NAME=data0
      - BOOTPROTO=dhcp
      - ONBOOT=yes
      - BONDING_MASTER=yes
      - BONDING_OPTS="miimon=100 mode=802.3ad lacp_rate=1 xmit_hash_policy=1"
      - NM_CONTROLLED=no
      - USRCTL=no
      - ONBOOT=yes
      - MTU=9000

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
    - source: salt://build_ssu/files/root/ssh
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
    - source: salt://build_ssu/files/etc/ssh
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
