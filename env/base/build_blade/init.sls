include:
  - live_minion

wipe_disk:
  cmd.run:
    - name: /bin/stx-wipe-disk.sh
    - shell: /bin/bash
    - require:
      - sls: live_minion

image_disk:
  cmd.run:
    - name: /bin/stx-imager-blade.sh /dev/sda  http://stx-prvsnr/sage/images/sage-CentOS-7.5.x86_64-7.5.0_3-k3.10.0.txz
    - shell: /bin/bash
    - require:
      - wipe_disk
    - unless:
      - file.access /root/provisioning.done f 

sync_etc_yum.repos.d:
  file.recurse:
    - name: /part1/etc/yum.repos.d
    - source: salt://files/etc/yum.repos.d
    - clean: True
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0644
    - keep_symlinks: False
    - include_empty: True
    - require:
      - image_disk

import_rpm_keys:
  cmd.run:
    - name: rpm --import --root /part1/ http://stx-prvsnr/vendor/centos/7.5.1804/RPM-GPG-KEY-CentOS-7
    - require:
      - sync_etc_yum.repos.d
    - unless:
      - test -f /part1/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

update_packages:
  cmd.run:
    - name: /bin/yum install -y --installroot=/part1/ salt-minion 
    - require:
      - import_rpm_keys

sync_etc_salt:
  file.recurse:
    - name: /part1/etc/salt
    - source: salt://build_blade/files/etc/salt
    - clean: True
    - keep_source: False
    - dir_mode: 0755
    - file_mode: keep
    - keep_symlinks: False
    - include_empty: True
    - require:
        - update_packages

sync_bin:
  file.recurse:
    - name: /part1/bin
    - source: salt://build_blade/files/bin
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0755
    - keep_symlinks: False
    - include_empty: True
    - require:
        - update_packages

sync_network:
  file.recurse:
    - name: /part1/etc/sysconfig/
    - source: salt://build_blade/files/etc/sysconfig
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0755
    - keep_symlinks: False
    - include_empty: True
    - require:
      - update_packages

sync_root_ssh:
  file.recurse:
    - name: /part1/root/.ssh
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

sync_etc_ssh:
  file.recurse:
    - name: /part1/etc/ssh
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

salt-minion_enable_service:
  cmd.run:
    - name: systemctl --root=/part1 enable salt-minion
    - unless:
      - file.access /etc/systemd/system/multi-user.target.wants/salt-minion.service f
