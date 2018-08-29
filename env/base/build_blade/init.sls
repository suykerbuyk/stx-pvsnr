sync_termsize:
   file.managed:
   - name: /bin/termsize
   - source: salt://files/bin/termsize
   - user: root
   - group: root
   - mode: 755

sync_stx_imager:
   file.managed:
   - name: /bin/stx-imager-blade.sh
   - source: salt://files/bin/stx-imager-blade.sh
   - user: root
   - group: root
   - mode: 755
   - require:
     - file: sync_termsize

image_disk:
  cmd.run:
  - name: /bin/stx-imager-blade.sh /dev/sda http://stx-prvsnr/sage/images/sage-CentOS-7.5.x86_64-7.5.0_3-k3.10.0.txz
  - shell: /bin/bash
  - python_shell: True
  - require:
    - file: sync_stx_imager
    - file: sync_termsize
  - unless:
    - file.access /root/provisioning.done f 

