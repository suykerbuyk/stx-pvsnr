import_rpm_keys:
  cmd.run:
    - name: rpm --import  http://stx-prvsnr/vendor/centos/7.5.1804/RPM-GPG-KEY-CentOS-7
    - require:
      - configure_repositories
    - unless:
      - test -f /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

configure_repositories:
  file.recurse:
    - name: /etc/yum.repos.d
    - source: salt://files/etc/yum.repos.d
    - clean: True
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0644
    - keep_symlinks: False
    - include_empty: True
