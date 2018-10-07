{% set port1_mac_safe = salt['grains.get']('bmc_network:port1_mac_safe') %}
{% set node_role = salt['pillar.get'] ('node:%s:role' | format(port1_mac_safe)) %}
{% set node_name = salt['pillar.get'] ('node:%s:hostname' | format(port1_mac_safe)) %}

{% if node_name == '' %}
{{ raise('node_name pillar data not found for bmc port1 mac address {0}'.format(port1_mac_safe)) }}
{% endif %}

{% if node_role == '' %}
{{ raise('node_role pillar data not found for bmc port1 mac address {0}'.format(port1_mac_safe)) }}
{% endif %}

get_stx_node_role:
  grains.present:
    - value: {{ node_role }}

get_stx_host_name:
  grains.present:
    - value: {{ node_name }}

set_minion_id:
  file.managed:
     - name: /etc/salt/minion_id
     - contents: {{ node_name }}
     - require:
       - get_stx_node_role
       - get_stx_host_name


set_system_host_name:
  cmd.run:
    - name: 'hostnamectl set-hostname {{node_name}}'
    - require:
      - set_minion_id

restart_salt_minion:
  cmd.run:
    - name: 'systemctl restart salt-minion'
    - require:
      - set_system_host_name

{#% endif %#}
