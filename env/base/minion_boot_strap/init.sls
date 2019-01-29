{% set port1_mac_safe = salt['grains.get']('bmc_network:port1_mac_safe') %}
{% set node_role = salt['pillar.get'] ('node:%s:role' | format(port1_mac_safe)) %}
{% set node_name = salt['pillar.get'] ('node:%s:hostname' | format(port1_mac_safe)) %}
{% set node_rack = salt['pillar.get'] ('node:%s:rack' | format(port1_mac_safe)) %}

{% if node_name == '' %}
{{ raise('node_name pillar data not found for bmc port1 mac address {0}'.format(port1_mac_safe)) }}
{% endif %}

{% if node_role == '' %}
{{ raise('node_role pillar data not found for bmc port1 mac address {0}'.format(port1_mac_safe)) }}
{% endif %}

{% if node_rack == '' %}
{{ raise('node_rack pillar data not found for bmc port1 mac address {0}'.format(port1_mac_safe)) }}
{% endif %}

/etc/salt/hostname:
  file.managed:
    - contents: {{ node_name }}

set_system_host_name:
  cmd.run:
    - name: 'hostnamectl set-hostname {{node_name}}'
    - require:
      - /etc/salt/hostname

salt-minion:
  service:
    - pkg.installed: []
    - running
    - enable: True
    - full_restart: True
    - require:
      - set_system_host_name
    - watch:
      - file: /etc/salt/grains
      - file: /etc/salt/minion_id

/etc/salt/minion_id:
  file.managed:
    - contents: {{ node_name }}

/etc/salt/grains:
  file.managed:
    - contents: |
        stx:
          node:
            - role: {{node_role}}
            - name: {{node_name}}
            - rack: {{node_rack}}
            - bmc_mac: {{port1_mac_safe}}

config_mellanox:
  cmd.run:
    - name: 'for x in $(find /sys/devices/ -name mlx4_port?); do echo $x; echo "eth" >$x; done'

