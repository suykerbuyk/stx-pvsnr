sync-custom-modules:
    module.run:
        - name: saltutil.sync_modules
        - refresh: True

live-sync-termsize:
    file.managed:
        - name: /bin/termsize
        - source: salt://files/bin/termsize
        - user: root
        - group: root
        - mode: 755

live-sync-stx-imager:
    file.managed:
        - name: /bin/stx-imager.sh
        - source: salt://files/bin/stx-imager-cmu.sh
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
