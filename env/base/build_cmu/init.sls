{% set stx_node_rack = salt['grains.get']('stx:node:rack') %}
{% set stx_image_src = salt['pillar.get']('stx_bci:cmu:image') %}
{% set stx_boot_disks = salt['stx_disk.by_criteria']('20', '150') %}
{% set stx_var_disks  = salt['stx_disk.by_criteria']('300', '7000') %}
{% set mnt_point1 = '/target_root' %}

include:
  - live_minion

wipe_disk:
  cmd.run:
    - name: /bin/stx-wipe-disk.sh
    - shell: /bin/bash
    - require:
      - sls: live_minion
    - unless:
      - File.access /root/provisioning.done f 

image_boot_disk:
  cmd.run:
    - name: /bin/stx-imager-cmu.sh /dev/{{stx_boot_disks["matching"][0]}} {{stx_image_src}}
    - shell: /bin/bash
    - require:
      - wipe_disk
    - unless:
      - File.access /root/provisioning.done f 

{{mnt_point1}}/etc/yum.repos.d:
  file.recurse:
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
      - sync_etc_yum.repos.d
    - unless:
      - test -f {{mnt_point1}}/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

update_packages:
  cmd.run:
    - name: /bin/yum install -y --installroot={{mnt_point1}}/ tmux nfs-utils dnsmasq darkhttpd salt-minion salt-ssh salt salt-master
    - require:
      - import_rpm_keys

purge_packages:
  cmd.run:
    - name: /bin/yum erase -y --installroot={{mnt_point1}}/ NetworkManager ; true
    - require:
      - update_packages

{{mnt_point1}}/etc/salt/:
  file.recurse:
    - source: salt://build_cmu/files/etc/salt/
    - clean: True
    - keep_source: False
    - dir_mode: 0755
    - file_mode: keep
    - keep_symlinks: False
    - include_empty: True
    - require:
      - update_packages

{{mnt_point1}}/etc/salt/minion:
  file.managed:
    - source: /etc/salt/minion
    - mode: 0644
    - require:
      - update_packages

{{mnt_point1}}/etc/salt/minion_id:
  file.managed:
    - mode: 0644
    - source: /etc/salt/minion_id
    - require:
      - update_packages

{{mnt_point1}}/etc/salt/grains:
  file.managed:
    - mode: 0644
    - source: /etc/salt/grains
    - require:
      - update_packages

{{mnt_point1}}/bin/:
  file.recurse:
    - source: salt://build_cmu/files/bin/
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0755
    - keep_symlinks: False
    - include_empty: True
    - require:
      - update_packages

{{mnt_point1}}/etc/sysconfig/:
  file.recurse:
    - source: salt://build_cmu/files/etc/sysconfig/
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0755
    - keep_symlinks: False
    - include_empty: True
    - require:
      - update_packages

{{mnt_point1}}/root/.ssh/:
  file.recurse:
    - source: salt://build_cmu/files/root/ssh/
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

{{mnt_point1}}/etc/ssh/:
  file.recurse:
    - source: salt://build_cmu/files/etc/ssh/
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

{{mnt_point1}}/etc/hostname:
  file.managed:
    - mode: 0644
    - source: /etc/hostname

/dev/md0:
  raid.present:
    - level: 1
    - devices:
      - /dev/{{stx_var_disks['matching'][0]}}
      - /dev/{{stx_var_disks['matching'][1]}}
    - chunk: 256
    - run: True
    - unless:
        - ls /dev/ | grep md0

update_mdadm_conf:
  cmd.run:
    - name: 'mdadm --detail --scan /dev/md0 >{{mnt_point1}}/etc/mdadm.conf'
    - shell: /bin/bash
    - python_script: True
    - require:
      - /dev/md0

label_raid_disk:
  module.run:
    - name: partition.mklabel
    - device: /dev/md0
    - label_type: gpt
    - require:
      - /dev/md0
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

make-swap-fs:
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

make-opt-mntpoint:
  cmd.run:
    - name: '[ -d {{mnt_point1}}/opt/seagate ] || mkdir -p {{mnt_point1}}/opt/seagate'

make_opt_fstab:
  file.append:
    - name: {{mnt_point1}}/etc/fstab
    - text:
      - UUID=8974698e-07c0-4e84-af44-55fc3d77fce8 /opt/seagate ext4 defaults 1 1

salt_minion_enable_service:
  cmd.run:
    - name: systemctl --root={{mnt_point1}} enable salt-minion
    - unless:
      - file.access /etc/systemd/system/multi-user.target.wants/salt-minion.service f

salt_disable_firewalld:
    cmd.run:
    - name: systemctl --root={{mnt_point1}} disable firewalld
    - unless:

{{mnt_point1}}/etc/modprobe.d/bonding.conf:
  file.managed:
    - mode: 0644
    - contents: options bonding max_bonds=0

{{mnt_point1}}/etc/dnsmasq.conf:
  file.managed:
    - source: salt://build_cmu/files/etc/dnsmasq.conf.{{stx_node_rack}}
    - mode: 0644
    - user: root
    - group: root
    - require:
        - update_packages

{{mnt_point1}}/etc/sysconfig/darkhttpd:
  file.managed:
    - source: salt://build_cmu/files/etc/sysconfig/darkhttpd
    - mode: 0644
    - user: root
    - group: root
    - require:
        - update_packages

{{mnt_point1}}/etc/hosts:
  file.managed:
    - source: salt://build_cmu/files/etc/hosts.{{stx_node_rack}}
    - mode: 0644
    - user: root
    - group: root
    - template: jinja
    - context:
      rack: {{ stx_node_rack }}

{{mnt_point1}}/etc/hosts.dnsmasq:
  file.managed:
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

