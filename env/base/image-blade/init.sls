sync-termsize:
   file.managed:
   - name: /bin/termsize
   - source: salt://files/util/termsize
   - user: root
   - group: root
   - mode: 755

sync-stx-imager:
   file.managed:
   - name: /bin/stx-imager.sh
   - source: salt://files/util/stx-imager.sh
   - user: root
   - group: root
   - mode: 755
   - require:
     - file: sync-termsize

image-disk:
  cmd.run:
  - name: /bin/stx-imager.sh /dev/sda http://stx-prvsnr/sage/images/sage-CentOS-7.5.x86_64-7.5.0_3-k3.10.0.txz
  - shell: /bin/bash
  - python_shell: True
  - require:
    - file: sync-stx-imager
    - file: sync-termsize
  - unless:
    - file.access /root/provisioning.done f 

