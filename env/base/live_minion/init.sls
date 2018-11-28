# Update the Live Minion Image with the site data and requirements.

sync_salt_all:
  module.run:
    - name: saltutil.sync_all
    - refresh: True

cp_termsize:
  file.managed:
    - name: /bin/termsize
    - source: salt://files/bin/termsize
    - user: root
    - group: root
    - mode: 755
    - require:
      - sync_salt_all

cp_stx_imager_cmu:
  file.managed:
    - name: /bin/stx-imager-cmu.sh
    - source: salt://files/bin/stx-imager-cmu.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - cp_termsize

cp_stx_imager_ssu:
  file.managed:
    - name: /bin/stx-imager-ssu.sh
    - source: salt://files/bin/stx-imager-ssu.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - cp_stx_imager_cmu

cp_stx_imager_blade:
  file.managed:
    - name: /bin/stx-imager-blade.sh
    - source: salt://files/bin/stx-imager-blade.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - cp_stx_imager_ssu

cp_stx_imager_generic:
  file.managed:
    - name: /bin/stx-imager-generic.sh
    - source: salt://files/bin/stx-imager-generic.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - cp_stx_imager_blade

cp_stx_wipe_disk:
  file.managed:
    - name: /bin/stx-wipe-disk.sh
    - source: salt://files/bin/stx-wipe-disk.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - cp_stx_imager_generic

config_local_repos:
  file.recurse:
    - name: /etc/yum.repos.d/
    - source: salt://files/etc/yum.repos.d
    - clean: True
    - keep_source: False
    - dir_mode: 0755
    - file_mode: 0644
    - keep_symlinks: False
    - include_empty: True
    - require:
      - cp_stx_wipe_disk

live_minion_done:
  cmd.run:
    - name: "date >/root/live_minion.done"
    - mode: 0644
    - require:
      - config_local_repos
    - unless:
      - test -f /root/live_minion.done
