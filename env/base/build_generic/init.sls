{% set stx_node_rack = salt['grains.get']('stx:node:rack') %}
{% set stx_image_src = salt['pillar.get']('stx_bci:generic:image') %}
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
    - name: /bin/stx-imager-generic.sh /dev/{{stx_boot_disks["matching"][0]}} {{mnt_point1}} {{stx_image_src}}
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
    - name: /bin/yum install -y --installroot={{mnt_point1}}/ tmux salt-minion
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
    - source: salt://build_generic/files/bin
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0755
    - keep_symlinks: False
    - include_empty: True
    - require:
      - update_packages

set_network_script_files:
  file.recurse:
    - name: {{mnt_point1}}/etc/sysconfig/network-scripts
    - source: salt://build_blade/files/etc/sysconfig/network-scripts
    - keep_source: False
    - dir_mode: 0644
    - file_mode: 0644
    - clean: False
    - keep_symlinks: False
    - include_empty: True
    - require:
      - update_packages

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

salt_minion_enable_service:
  cmd.run:
    - name: systemctl --root={{mnt_point1}} enable salt-minion
    - unless:
      - file.access /etc/systemd/system/multi-user.target.wants/salt-minion.service f

set_bonding_config:
  file.managed:
    - name: {{mnt_point1}}/etc/modprobe.d/bonding.conf
    - mode: 0644
    - contents: options bonding max_bonds=0

{% endif %} # if stx_live_minion
