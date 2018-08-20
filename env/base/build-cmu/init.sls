include:
    - config-live

image-disk:
    cmd.run:
    - name: /bin/stx-imager.sh /dev/sda http://stx-prvsnr/sage/images/sage-CentOS-7.5.x86_64-7.5.0_3-k3.10.0.txz
    - shell: /bin/bash
    - require:
        - sls: config-live
    - unless:
        - File.access /root/provisioning.done f 

sync-etc-yum.repos.d:
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
        - image-disk

import-rpm-keys:
    cmd.run:
    - name: rpm --import --root /part1/ http://stx-prvsnr/vendor/centos/7.5.1804/RPM-GPG-KEY-CentOS-7
    - require:
        - sync-etc-yum.repos.d
    - unless:
        - test -f /part1/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

update-packages:
    cmd.run:
    - name: /bin/yum install -y --installroot=/part1/ tmux nfs-utils dnsmasq darkhttpd salt-minion salt-ssh salt 
    - require:
        - import-rpm-keys

sync-etc-salt:
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
        - update-packages

sync-bin:
    file.recurse:
    - name: /part1/bin
    - source: salt://build-cmu/files/cmu-h1/bin
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0755
    - keep_symlinks: False
    - include_empty: True
    - require:
        - update-packages

sync-network-ifcfg:
    file.recurse:
    - name: /part1/etc/sysconfig/network-scripts
    - source: salt://build-cmu/files/cmu-h1/etc/sysconfig/network-scripts
    - keep_source: False
    - dir_mode: 0644
    - file_mode: 0644
    - clean: False
    - keep_symlinks: False
    - include_empty: True
    - require:
        - update-packages

sync-root-ssh:
    file.recurse:
    - name: /part1/root/.ssh
    - source: salt://build-cmu/files/cmu-h1/root/ssh
    - keep_source: False
    - dir_mode: 0700
    - file_mode: 0600
    - user: root
    - group: root
    - clean: True
    - keep_symlinks: False
    - include_empty: True
    - require:
        - update-packages

sync-etc-ssh:
    file.recurse:
    - name: /part1/etc/ssh
    - source: salt://build-cmu/files/cmu-h1/etc/ssh
    - keep_source: False
    - dir_mode: 0755
    - file_mode: keep
    - user: root
    - group: root
    - clean: True
    - keep_symlinks: False
    - include_empty: True
    - require:
        - update-packages

set-etc-dnsmasq.conf:
    file.managed:
    - name: /part1/etc/dnsmasq.conf
    - source: salt://build-cmu/files/cmu-h1/etc/dnsmasq.conf
    - mode: 0644
    - user: root
    - group: root
    - require:
        - update-packages

set-etc-sysconfig-darkhttpd:
    file.managed:
    - name: /part1/etc/sysconfig/darkhttpd
    - source: salt://build-cmu/files/cmu-h1/etc/sysconfig/darkhttpd
    - mode: 0644
    - user: root
    - group: root
    - require:
        - update-packages

set-etc-hosts:
    file.managed:
    - name: /part1/etc/hosts
    - source: salt://build-cmu/files/cmu-h1/etc/hosts
    - mode: 0644
    - user: root
    - group: root

set-etc-hosts.dnsmasq:
    file.managed:
    - name: /part1/etc/hosts.dnsmasq
    - source: salt://build-cmu/files/cmu-h1/etc/hosts.dnsmasq
    - mode: 0644
    - user: root
    - group: root

set-hostname:
    file.managed:
    - name: /part1/etc/hostname
    - mode: 0644
    - contents: cmu-h1

set-minion_id:
    file.managed:
    - name: /part1/etc/salt/minion_id
    - mode: 0644
    - contents:
        cmu-h1
    - require:
        - update-packages

/dev/md127:
    raid.present:
    - level: 1
    - devices:
        - /dev/sdd
        - /dev/sde
    - chunk: 256
    - run: True
    - unless:
        - ls /dev/ | grep md127

label-raid-disk:
    module.run:
    - name: partition.mklabel
    - device: /dev/md127
    - label_type: msdos
    - require:
        - /dev/md127
    - unless:
        - fdisk -l /dev/md127 | grep 'Disk label type: dos'

make-swap-part:
    module.run:
    - name: partition.mkpartfs
    - device: /dev/md127
    - part_type: primary
    - fs_type: linux-swap
    - start: 0GB
    - end: 64GB
    - require:
        - label-raid-disk
    - unless:
        - file.is_blkdev /dev/md127p1


make-swap-fs:
    cmd.run:
    - name: 'mkswap -U d8e9f0b7-aa51-47eb-9ee2-af4007dc9872 -L swap /dev/md127p1'
    - require:
        - make-swap-part
    - unless:
        - disk.blkid /dev/md127p1 | grep swap

make-swap-fstab:
    file.append:
    - name: /part1/etc/fstab
    - text:
        - UUID=d8e9f0b7-aa51-47eb-9ee2-af4007dc9872 none swap sw 0 0

make-opt-part:
    module.run:
    - name: partition.mkpartfs
    - device: /dev/md127
    - part_type: primary
    - fs_type: ext2
    - start: 64GB
    - end: 100%
    - require:
        - label-raid-disk
        - make-swap-fs
    - unless:
        - file.is_blkdev /dev/md127p2

make-opt-fs:
    cmd.run:
    - name: 'mkfs.ext4 -U 8974698e-07c0-4e84-af44-55fc3d77fce8 -L opt /dev/md127p2'
    - require:
        - make-opt-part
    - unless:
        - disk.blkid /dev/md127p2 | grep ext

make-opt-mntpoint:
    cmd.run:
    - name: '[ -d /part1/opt/seagate ] || mkdir -p /part1/opt/seagate'

make-opt-fstab:
    file.append:
    - name: /part1/etc/fstab
    - text:
        - UUID=8974698e-07c0-4e84-af44-55fc3d77fce8 /opt/seagate ext4 defaults 1 1

nfs-enable-service:
    cmd.run:
    - name: systemctl --root=/part1 enable nfs
    - unless:
        - file.access /etc/systemd/system/multi-user.target.wants/nfs-server.service f

nfs-add-mount-dir:
    cmd.run:
    - name: '[ -d /part1/prvsnr ] || mkdir /part1/prvsnr'

nfs-add-fstab:
    file.append:
    - name: /part1/etc/fstab
    - text:
        - '# stx-prvsnr.mero.colo.seagate.com:/prvsnr /prvsnr nfs4 defaults 0 0'
    - require:
        - make-opt-fstab

darkhttp-enable-service:
    cmd.run:
    - name: systemctl --root=/part1 enable darkhttpd
    - unless:
        - file.access /etc/systemd/system/multi-user.target.wants/darkhttpd.service f

dnsmasq-enable-service:
    cmd.run:
    - name: systemctl --root=/part1 enable dnsmasq
    - unless:
        - file.access /etc/systemd/system/multi-user.target.wants/dnsmasq.service f
