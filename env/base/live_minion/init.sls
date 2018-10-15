# Update the Live Minion Image with the site data and requirements.

sync_salt_all:
  module.run:
    - name: saltutil.sync_all
    - refresh: True

/bin/termsize:
  file.managed:
    - source: salt://files/bin/termsize
    - user: root
    - group: root
    - mode: 755

/bin/stx-imager-cmu.sh:
  file.managed:
    - source: salt://files/bin/stx-imager-cmu.sh
    - user: root
    - group: root
    - mode: 755

/bin/stx-imager-ssu.sh:
  file.managed:
    - source: salt://files/bin/stx-imager-ssu.sh
    - user: root
    - group: root
    - mode: 755

/bin/stx-imager-blade.sh:
  file.managed:
    - source: salt://files/bin/stx-imager-blade.sh
    - user: root
    - group: root
    - mode: 755

/bin/stx-imager-generic.sh:
  file.managed:
    - source: salt://files/bin/stx-imager-generic.sh
    - user: root
    - group: root
    - mode: 755

/bin/stx-wipe-disk.sh:
  file.managed:
    - source: salt://files/bin/stx-wipe-disk.sh
    - user: root
    - group: root
    - mode: 755

/etc/yum.repos.d:
  file.recurse:
    - source: salt://files/etc/yum.repos.d
    - clean: True
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0644
    - keep_symlinks: False
    - include_empty: True
