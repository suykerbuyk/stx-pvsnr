sync-custom-modules:
    module.run:
        - name: saltutil.sync_all
        - refresh: True

live-sync-termsize:
    file.managed:
        - name: /bin/termsize
        - source: salt://files/bin/termsize
        - user: root
        - group: root
        - mode: 755

live-sync-stx-cmu-imager:
    file.managed:
        - name: /bin/stx-imager-cmu.sh
        - source: salt://files/bin/stx-imager-cmu.sh
        - user: root
        - group: root
        - mode: 755

live-sync-stx-ssu-imager:
    file.managed:
        - name: /bin/stx-imager-ssu.sh
        - source: salt://files/bin/stx-imager-ssu.sh
        - user: root
        - group: root
        - mode: 755

live-sync-stx-blade-imager:
    file.managed:
        - name: /bin/stx-imager-blade.sh
        - source: salt://files/bin/stx-imager-blade.sh
        - user: root
        - group: root
        - mode: 755

live-sync-stx-wipe-disk:
    file.managed:
        - name: /bin/stx-wipe-disk.sh
        - source: salt://files/bin/stx-wipe-disk.sh
        - user: root
        - group: root
        - mode: 755

live-etc-yum.repos.d:
    file.recurse:
        - name: /etc/yum.repos.d
        - source: salt://files/etc/yum.repos.d
        - clean: True
        - keep_source: False
        - dir_mode: 0755
        - file_mode: 0644
        - keep_symlinks: False
        - include_empty: True
