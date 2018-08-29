include:
    - live_minion

image_disk:
    cmd.run:
    - name: /bin/stx-imager-cmu.sh /dev/sda http://stx-prvsnr/sage/images/sage-CentOS-7.5.x86_64-7.5.0_3-k3.10.0.txz
    - shell: /bin/bash
    - require:
        _ sls: config_live
    - unless:
        - File.access /root/provisioning.done f 

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
        _ sync_etc_yum.repos.d
    - unless:
        - test -f /part1/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

update_packages:
    cmd.run:
    - name: /bin/yum install -y --installroot=/part1/ tmux nfs-utils dnsmasq darkhttpd salt-minion salt-ssh salt salt-master
    - require:
        - import_rpm_keys

sync_etc_salt:
    file.recurse:
    - name: /part1/etc/salt
    - source: salt://build-cmu/files/cmu-h1/etc/salt
    - clean: True
    - keep_source: False
    - dir_mode: 0755
    - file_mode: keep
    - keep_symlinks: False
    - include_empty: True
    - require:
        _ update_packages

sync_bin:
    file.recurse:
    - name: /part1/bin
    - source: salt://build-cmu/files/bin
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0755
    - keep_symlinks: False
    - include_empty: True
    - require:
        - update_packages

sync_network_ifcfg:
    file.recurse:
    - name: /part1/etc/sysconfig/network-scripts
    - source: salt://build-cmu/files/etc/sysconfig/network-scripts
    - keep_source: False
    - dir_mode: 0644
    - file_mode: 0644
    - clean: False
    - keep_symlinks: False
    - include_empty: True
    - require:
        - update_packages

sync_root_ssh:
    file.recurse:
    - name: /part1/root/.ssh
    - source: salt://build-cmu/files/root/ssh
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
    - source: salt://build-cmu/files/etc/ssh
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

set_etc_dnsmasq.conf:
    file.managed:
    - name: /part1/etc/dnsmasq.conf
    - source: salt://build-cmu/files/etc/dnsmasq.conf
    - mode: 0644
    - user: root
    - group: root
    - require:
        - update_packages

set_etc_sysconfig_darkhttpd:
    file.managed:
    - name: /part1/etc/sysconfig/darkhttpd
    - source: salt://build-cmu/files/etc/sysconfig/darkhttpd
    - mode: 0644
    - user: root
    - group: root
    - require:
        - update_packages

set_etc_hosts:
    file.managed:
    - name: /part1/etc/hosts
    - source: salt://build-cmu/files/etc/hosts
    - mode: 0644
    - user: root
    - group: root

set_etc_hosts.dnsmasq:
    file.managed:
    - name: /part1/etc/hosts.dnsmasq
    - source: salt://build-cmu/files/etc/hosts.dnsmasq
    - mode: 0644
    - user: root
    - group: root

set_hostname:
    file.managed:
    - name: /part1/etc/hostname
    - mode: 0644
    - contents: cmu-h1

set_bonding_max:
    file.managed:
    - name: /part1/etc/modprobe.d/bonding.conf
    - mode: 0644
    - contents: options bonding max_bonds=0

set_minion_id:
    file.managed:
    - name: /part1/etc/salt/minion_id
    - mode: 0644
    - contents:
        cmu-h1
    - require:
        - update_packages

/dev/md0:
    raid.present:
    - level: 1
    - devices:
        - /dev/sdd
        - /dev/sde
    - chunk: 256
    - run: True
    - unless:
        - ls /dev/ | grep md0

update_mdadm_conf:
    cmd.run:
    - name: 'mdadm --detail --scan /dev/md0 >/part1/etc/mdadm.conf'
    - shell: /bin/bash
    - python_script: True
    - require:
        - /dev/md0

label_raid_disk:
    module.run:
    - name: partition.mklabel
    - device: /dev/md0
    - label_type: msdos
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
    - name: /part1/etc/fstab
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
    - name: '[ -d /part1/opt/seagate ] || mkdir -p /part1/opt/seagate'

make_opt_fstab:
    file.append:
    - name: /part1/etc/fstab
    - text:
        - UUID=8974698e-07c0-4e84-af44-55fc3d77fce8 /opt/seagate ext4 defaults 1 1

nfs_add_mount_dir:
    cmd.run:
    - name: '[ -d /part1/prvsnr ] || mkdir /part1/prvsnr'

nfs_add_fstab:
    file.append:
    - name: /part1/etc/fstab
    - text:
        - 'stx-prvsnr.mero.colo.seagate.com:/prvsnr /prvsnr nfs4 defaults 0 0'
    - require:
        - make_opt_fstab

darkhttp_enable_service:
    cmd.run:
    - name: systemctl --root=/part1 enable darkhttpd
    - unless:
        - file.access /etc/systemd/system/multi-user.target.wants/darkhttpd.service f

nfs_enable_service:
    cmd.run:
    - name: systemctl --root=/part1 enable nfs
    - unless:
        - file.access /etc/systemd/system/multi-user.target.wants/nfs-server.service f


dnsmasq_enable_service:
    cmd.run:
    - name: systemctl --root=/part1 enable dnsmasq
    - unless:
        - file.access /etc/systemd/system/multi-user.target.wants/dnsmasq.service f

salt_master_enable_service:
    cmd.run:
    - name: systemctl --root=/part1 enable salt-master
    - unless:
        - file.access /etc/systemd/system/multi-user.target.wants/salt-master.service f
