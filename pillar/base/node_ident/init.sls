node:
  # infrastructure nodes
  00_1e_67_68_df_7e:
    - hostname: stx-prvsnr
    - role: prvsnr
    - mgmt_port1: '00:1e:67:68:df:7c'
    - mgmt_port2: '00:1e:67:68:df:7d'
    - data_port1: 'e4:1d:2d:78:23:c1'
    - data_port2: 'e4:1d:2d:78:23:c2'
    - mgmt0_ip:   '10.230.161.52'
    - data0_ip:   '172.19.1.212'

  # #############
  # Hermi 01 rack
  00_50_cc_7a_80_e1:
    - rack: h01
    - role: cmu
    - hostname: cmu-h01
    - ext_p1:    '00:50:cc:7a:80:df'
    - ext_p2:    '00:50:cc:7a:80:e0'
    - int_p1:    '00:50:cc:7a:80:e3'
    - int_p2:    '00:50:cc:7a:80:e4'
    - mgmt0_ip:  '172.16.1.41'
    - data0_ip:  '172.19.1.41'
    - ipmi_port: '00:50:cc:7a:80:e1'
    - ipmi:      '10.230.164.193'

  00_50_cc_79_b3_31:
    - rack: h01
    - role: ssu
    - hostname: ssu1-h01
    - mgmt_port1: '00:50:cc:79:b3:2f'
    - mgmt_port2: '00:50:cc:79:b3:30'
    - ipmi_port:  '00:50:cc:79:b3:31'
    - data_port1: '00:50:cc:79:b3:33'
    - data_port2: '00:50:cc:79:b3:34'
    - data0:      '172.19.1.1'
    - mgmt0:      '172.16.1.1'
    - ipmi:       '172.16.1.101'

  00_50_cc_79_b2_53:
    - rack: h01
    - role: ssu
    - hostname: ssu2-h01
    - mgmt_port1: '00:50:cc:79:b2:51'
    - mgmt_port2: '00:50:cc:79:b2:52'
    - ipmi_port:  '00:50:cc:79:b2:53'
    - data_port1: '00:50:cc:79:b2:55'
    - data_port2: '00:50:cc:79:b2:56'
    - data0:      '172.19.1.2'
    - mgmt0:      '172.16.1.2'
    - ipmi:       '172.16.1.102'

  00_50_cc_79_f5_85:
    - rack: h01
    - role: ssu
    - hostname: ssu3-h01
    - mgmt_port1: '00:50:cc:79:f5:83'
    - mgmt_port2: '00:50:cc:79:f5:84'
    - ipmi_port:  '00:50:cc:79:f5:85'
    - data_port1: '00:50:cc:79:f5:87'
    - data_port2: '00:50:cc:79:f5:88'
    - data0:      '172.19.1.3'
    - mgmt0:      '172.16.1.3'
    - ipmi:       '172.16.1.103'

  00_50_cc_79_b9_6d:
    - rack: h01
    - role: ssu
    - hostname: ssu4-h01
    - mgmt_port1: '00:50:cc:79:b9:6b'
    - mgmt_port2: '00:50:cc:79:b9:6c'
    - ipmi_port:  '00:50:cc:79:b9:6d'
    - data_port1: '00:50:cc:79:b9:6f'
    - data_port2: '00:50:cc:79:b9:70'
    - data0:      '172.19.1.4'
    - mgmt0:      '172.16.1.4'
    - ipmi:       '172.16.1.104'

  00_50_cc_79_be_2f:
    - rack: h01
    - role: ssu
    - hostname: ssu5-h01
    - mgmt_port1: '00:50:cc:79:be:2d'
    - mgmt_port2: '00:50:cc:79:be:2e'
    - ipmi_port:  '00:50:cc:79:be:2f'
    - data_port1: '00:50:cc:79:be:31'
    - data_port2: '00:50:cc:79:be:32'
    - data0:      '172.19.1.5'
    - mgmt0:      '172.16.1.5'
    - ipmi:       '172.16.1.105'

  00_50_cc_79_b2_5f:
    - rack: h01
    - role: ssu
    - hostname: ssu6-h01
    - mgmt_port1: '00:50:cc:79:b2:5d'
    - mgmt_port2: '00:50:cc:79:b2:5e'
    - ipmi_port:  '00:50:cc:79:b2:5f'
    - data_port1: '00:50:cc:79:b2:61'
    - data_port2: '00:50:cc:79:b2:62'
    - data0:      '172.19.1.6'
    - mgmt0:      '172.16.1.6'
    - ipmi:       '172.16.1.106'

  00_50_cc_7a_49_3d:
    - rack: h01
    - role: ssu
    - hostname: ssu7-h01
    - mgmt_port1: '00:50:cc:7a:49:3b'
    - mgmt_port2: '00:50:cc:7a:49:3c'
    - ipmi_port:  '00:50:cc:7a:49:3d'
    - data_port1: '00:50:cc:7a:49:3f'
    - data_port2: '00:50:cc:7a:49:40'
    - data0:      '172.19.1.7'
    - mgmt0:      '172.16.1.7'
    - ipmi:       '172.16.1.107'

  # #############
  # Hermi 02 rack
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

  # #############
  # Mero 10 rack
  00_50_cc_7a_5f_e1:
    - rack: m10
    - role: cmu
    - hostname: cmu-m10
    - mgmt_ports:
      - port1: 00:50:cc:7a:5f:e1
      - port2: 68:05:ca:3a:f0:0a
    - data_ports:
      - port1: 00:50:cc:7a:5f:e3
      - port2: 00:50:cc:7a:5f:e4
    - ipmi_ports:
      - port1: 00:50:cc:7a:5f:e1

  # #############
  # Mero 09 rack
  00_50_cc_7a_6a_df:
    - rack: m09
    - role: cmu
    - hostname: cmu-m09
    - mgmt_port1: '68:05:ca:3c:f0:d7'
    - mgmt_port2: '00:50:cc:7a:6a:dd'
    - mgmt_port3: '00:50:cc:7a:6a:de'
    - mgmt_port4: '00:50:cc:7a:6a:e1'
    - data_port1: '00:50:cc:7a:6a:e2'
    - mgmt0_ip:   '10.230.165.191'
    - data0_ip:   ''
    - ipmi_port:  '00:50:cc:7a:6a:df'
    - ipmi:       '10.230.165.188'

  00_50_cc_79_f5_43:
    - rack: m09
    - role: ssu
    - hostname: ssu1-m09
    - mgmt_port1: '00:50:cc:79:f5:41'
    - mgmt_port2: '00:50:cc:79:f5:42'
    - data_port1: '00:50:cc:79:f5:45'
    - data_port2: '00:50:cc:79:f5:46'
    - mgmt0_ip:   '172.16.2.1'
    - data0_ip:   '172.19.2.1'
    - ipmi:       '172.16.2.101'

  # #############
  # mero06 clients
  00_1e_67_68_cc_0e:
    - rack: m06
    - hostname: qb01n3-m06
    - role: s3_client

  00_1e_67_68_d7_ce:
    - rack: m06
    - hostname: qb01n4-m06
    - role: s3_client

  00_1e_67_66_d9_52:
    - rack: m06
    - hostname: qb02n1-m06
    - role: s3_client

  00_1e_67_66_df_a2:
    - rack: m06
    - hostname: qb02n2-m06
    - role: s3_client

  00_1e_67_66_e8_4a:
    - rack: m06
    - hostname: qb02n3-m06
    - role: s3_client

  00_1e_67_66_f0_ba:
    - rack: m06
    - hostname: qb02n4-m06
    - role: s3_client

  00_1e_67_68_d6_c6:
    - rack: m06
    - hostname: qb03n1-m06
    - role: generic
    - mgmt0: '00:1e:67:68:d6:c4'
    - data0: 'e4:1d:2d:6f:0c:41'

  00_1e_67_68_d7_fe:
    - rack: m06
    - hostname: qb03n2-m06
    - role: generic
    - mgmt0: 00:1e:67:68:d7:fc
    - data0: e4:1d:2d:6f:0c:91

  00_1e_67_68_de_16:
    - rack: m06
    - hostname: qb03n3-m06
    - role: generic
    - mgmt0: 00:1e:67:68:de:14
    - data0: e4:1d:2d:6f:8e:c1

  00_1e_67_68_c8_ae:
    - rack: m06
    - hostname: qb03n4-m06
    - role: generic
    - mgmt0: 00:1e:67:68:c8:ac
    - data0: e4:1d:2d:6f:8a:b1

  00_1e_67_68_cc_56:
    - rack: m06
    - hostname: qb04n1-m06
    - role: generic
    - mgmt0: '00:1e:67:68:cc:54'

  00_1e_67_68_df_ac:
    - rack: m06
    - hostname: qb05n1-m06
    - role: generic
    - mgmt0: '00:1e:67:68:df:ac'

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
