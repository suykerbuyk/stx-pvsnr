node:
  # UDX Nodes
  00_50_cc_79_92_d3:
    - rack: m02
    - hostname: udxcloud1-1
    - role: generic

  00_50_cc_79_93_15:
    - rack: m02
    - hostname: edxedge1-1
    - role: generic

  00_50_cc_7a_7e_4d:
    - rack: m02
    - hostname: udxedge1-2
    - role: generic
    - mgmt_port1: '68:05:ca:3d:83:74'
    - mgmt_port2: '00:50:cc:7a:7e:4b'
    - mgmt_port3: '00:50:cc:7a:7e:4c'
    - data_port1: '00:50:cc:7a:7e:50'
    - data0:      '172.19.3.74'
    - mgmt0:      '10.230.163.89'
    - ipmi:       '10.230.163.91'

  00_50_cc_79_db_0f:
    - rack: m02
    - role: generic
    - hostname: udx-03
    - mgmt_ports:
      - port1: 00:50:cc:79:db:0d
      - port2: 00:50:cc:79:db:0e
    - data_ports:
      - port1: 00:50:cc:79:db:12
    - ipmi_ports:
      - port1: 00:50:cc:79:db:0f
    - ipmi_ip:
      - 10.230.161.161

  00_50_cc_79_6f_1b:
    - rack: m02
    - role: generic
    - hostname: udx-03
    - mgmt_ports:
      - port1: 00:50:cc:79:6f:19
      - port2: 00:50:cc:79:6f:1a
    - 
