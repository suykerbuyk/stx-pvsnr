node:
  00_50_cc_7a_3e_09:
    - rack: h02
    - role: cmu
    - hostname: cmu-h02
    - ext_p1:    '00:50:cc:7a:3e:07'
    - ext_p2:    '00:50:cc:7a:3e:08'
    - int_p1:    '00:50:cc:7a:3e:0b'
    - int_p2:    '00:50:cc:7a:3e:0c'
    - mgmt0_ip:  '172.16.12.41'
    - data0_ip:  '172.19.12.41'
    - ipmi_port: '00:50:cc:7a:3e:09'
    - ipmi:      '10.230.166.53'

  00_50_cc_79_bd_f9:
    - rack: h02
    - role: ssu
    - hostname: ssu1-h02
    - mgmt_port1: '00:50:cc:79:bd:f7'
    - mgmt_port2: '00:50:cc:79:bd:f8'
    - ipmi_port:  '00:50:cc:79:bd:f9'
    - data_port1: '00:50:cc:79:bd:fb'
    - data_port2: '00:50:cc:79:bd:fc'
    - data0:      '172.19.12.1'
    - mgmt0:      '172.16.12.1'
    - ipmi:       '172.16.12.101'

  00_50_cc_79_bd_d5:
    - rack: h02
    - role: ssu
    - hostname: ssu2-h02
    - mgmt_port1: '00:50:cc:79:bd:d3'
    - mgmt_port2: '00:50:cc:79:bd:d4'
    - ipmi_port:  '00:50:cc:79:bd:d5'
    - data_port1: '00:50:cc:79:bd:d7'
    - data_port2: '00:50:cc:79:bd:d8'
    - data0:      '172.19.12.2'
    - mgmt0:      '172.16.12.2'
    - ipmi:       '172.16.12.102'

  00_50_cc_79_bd_ff:
    - rack: h02
    - role: ssu
    - hostname: ssu3-h02
    - mgmt_port1: '00:50:cc:79:bd:fd'
    - mgmt_port2: '00:50:cc:79:bd:fe'
    - ipmi_port:  '00:50:cc:79:bd:ff'
    - data_port1: '00:50:cc:79:be:01'
    - data_port2: '00:50:cc:79:be:02'
    - data0:      '172.19.12.3'
    - mgmt0:      '172.16.12.3'
    - ipmi:       '172.16.12.103'

  00_50_cc_79_bd_c3:
    - rack: h02
    - role: ssu
    - hostname: ssu4-h02
    - mgmt_port1: '00:50:cc:79:bd:c1'
    - mgmt_port2: '00:50:cc:79:bd:c2'
    - ipmi_port:  '00:50:cc:79:bd:c3'
    - data_port1: '00:50:cc:79:bd:c5'
    - data_port2: '00:50:cc:79:bd:c6'
    - data0:      '172.19.12.4'
    - mgmt0:      '172.16.12.4'
    - ipmi:       '172.16.12.104'

  00_50_cc_79_bd_bd:
    - rack: h02
    - role: ssu
    - hostname: ssu5-h02
    - mgmt_port1: '00:50:cc:79:bd:bb'
    - mgmt_port2: '00:50:cc:79:bd:bc'
    - ipmi_port:  '00:50:cc:79:bd:bd'
    - data_port1: '00:50:cc:79:bd:bf'
    - data_port2: '00:50:cc:79:bd:c0'
    - data0:      '172.19.12.5'
    - ipmi:       '172.16.12.105'
    - mgmt0:      '172.16.12.5'

  00_50_cc_79_bd_db:
    - rack: h02
    - role: ssu
    - hostname: ssu6-h02
    - mgmt_port1: '00:50:cc:79:bd:d9'
    - mgmt_port2: '00:50:cc:79:bd:da'
    - ipmi_port:  '00:50:CC:79:bd:db'
    - data_port1: '00:50:cc:79:bd:dd'
    - data_port2: '00:50:cc:79:bd:de'
    - data0:      '172.19.12.6'
    - mgmt0:      '172.16.12.6'
    - ipmi:       '172.16.12.106'

  # Hermi02 S3 Server nodes 
  00_1e_67_68_cd_16:
    - rack: h02
    - role: s3_server
    - hostname: qb01n1-h02
    - mgmt_port1: '00:1e:67:68:cd:14'
    - mgmt_port2: '00:1e:67:68:cd:15'
    - data_port1: '00:1e:67:68:cd:15'
    - data0:      '172.19.12.8'
    - mgmt0:      '172.16.12.8'
    - ipmi:       '172.16.12.128'

  00_1e_67_68_e1_0e:
    - rack: h02
    - role: s3_server
    - hostname: qb01n2-h02
    - mgmt_port1: '00:1e:67:68:e1:0c'
    - mgmt_port2: '00:1e:67:68:e1:0d'
    - data_port1: '00:1e:67:68:cd:15'
    - data0:      '172.19.12.9'
    - mgmt0:      '172.16.12.9'
    - ipmi:       '172.16.12.129'

  00_1e_67_68_d7_7e:
    - rack: h02
    - role: s3_server
    - hostname: qb01n3-h02
    - mgmt_port1: '00:1e:67:68:d7:7c'
    - mgmt_port2: '00:1e:67:68:d7:7d'
    - data_port1: '00:1e:67:68:d7:81'
    - data0:      '172.19.12.10'
    - mgmt0:      '172.16.12.10'
    - ipmi:       '172.16.12.130'

  00_1e_67_68_dc_56:
    - rack: h02
    - role: s3_server
    - hostname: qb01n4-h02
    - mgmt_port1: '00:1e:67:68:dc:54'
    - mgmt_port2: '00:1e:67:68:dc:55'
    - data_port1: '00:1e:67:68:dc:59'
    - data0:      '172.19.12.11'
    - mgmt0:      '172.16.12.11'
    - ipmi:       '172.16.12.131'


