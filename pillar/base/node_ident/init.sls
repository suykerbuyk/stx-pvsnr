node:
  # infrastructure nodes
  00_1e_67_68_df_7e:
    - hostname: stx-prvsnr
    - role: prvsnr

  # #############
  # Hermi 01 rack
  00_50_cc_7a_80_e1:
    - hostname: cmu-h1
    - role: cmu

  00_50_cc_79_b2_53:
    - hostname: ssu2-h1
    - role: ssu

  # #############
  # Hermi 02 rack
  00_50_cc_7a_3e_09:
    - rack: h2
    - role: cmu
    - hostname: cmu-h2
    - ext_p1:    '00:50:cc:7a:3e:07'
    - ext_p2:    '00:50:cc:7a:3e:08'
    - int_p1:    '00:50:cc:7a:3e:0b'
    - int_p2:    '00:50:cc:7a:3e:0c'
    - mgmt0_ip:  '172.16.12.41'
    - data0_ip:  '172.19.12.41'
    - ipmi_port: '00:50:cc:7a:3e:09'
    - ipmi:      '10.230.166.53'

  00_50_cc_79_bd_f9:
    - rack: h2
    - role: ssu
    - hostname: ssu1-h2
    - mgmt_port1: '00:50:cc:79:bd:f7'
    - mgmt_port2: '00:50:cc:79:bd:f8'
    - ipmi_port:  '00:50:cc:79:bd:f9'
    - data_port1: '00:50:cc:79:bd:fb'
    - data_port2: '00:50:cc:79:bd:fc'
    - data0:      '172.19.12.1'
    - mgmt0:      '172.16.12.1'
    - ipmi:       '172.16.12.101'

  00_50_cc_79_bd_d5:
    - rack: h2
    - role: ssu
    - hostname: ssu2-h2
    - mgmt_port1: '00:50:cc:79:bd:d3'
    - mgmt_port2: '00:50:cc:79:bd:d4'
    - ipmi_port:  '00:50:cc:79:bd:d5'
    - data_port1: '00:50:cc:79:bd:d7'
    - data_port2: '00:50:cc:79:bd:d8'
    - data0:      '172.19.12.2'
    - mgmt0:      '172.16.12.2'
    - ipmi:       '172.16.12.102'

  00_50_cc_79_bd_ff:
    - rack: h2
    - role: ssu
    - hostname: ssu3-h2
    - mgmt_port1: '00:50:cc:79:bd:fd'
    - mgmt_port2: '00:50:cc:79:bd:fe'
    - ipmi_port:  '00:50:cc:79:bd:ff'
    - data_port1: '00:50:cc:79:be:01'
    - data_port2: '00:50:cc:79:be:02'
    - data0:      '172.19.12.3'
    - mgmt0:      '172.16.12.3'
    - ipmi:       '172.16.12.103'

  00_50_cc_79_bd_c3:
    - rack: h2
    - role: ssu
    - hostname: ssu4-h2
    - mgmt_port1: '00:50:cc:79:bd:c1'
    - mgmt_port2: '00:50:cc:79:bd:c2'
    - ipmi_port:  '00:50:cc:79:bd:c3'
    - data_port1: '00:50:cc:79:bd:c5'
    - data_port2: '00:50:cc:79:bd:c6'
    - data0:      '172.19.12.4'
    - mgmt0:      '172.16.12.4'
    - ipmi:       '172.16.12.104'

  00_50_cc_79_bd_bd:
    - rack: h2
    - role: ssu
    - hostname: ssu5-h2
    - mgmt_port1: '00:50:cc:79:bd:bb'
    - mgmt_port2: '00:50:cc:79:bd:bc'
    - ipmi_port:  '00:50:cc:79:bd:bd'
    - data_port1: '00:50:cc:79:bd:bf'
    - data_port2: '00:50:cc:79:bd:c0'
    - data0:      '172.19.12.5'
    - ipmi:       '172.16.12.105'
    - mgmt0:      '172.16.12.5'

  00_50_cc_79_bd_db:
    - rack: h2
    - role: ssu
    - hostname: ssu6-h2
    - mgmt_port1: '00:50:cc:79:bd:d9'
    - mgmt_port2: '00:50:cc:79:bd:da'
    - ipmi_port:  '00:50:CC:79:bd:db'
    - data_port1: '00:50:cc:79:bd:dd'
    - data_port2: '00:50:cc:79:bd:de'
    - data0:      '172.19.12.6'
    - mgmt0:      '172.16.12.6'
    - ipmi:       '172.16.12.106'

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
    - role: s3_client
    - mgmt0: '00:1e:67:68:d6:c4'
    - data0: 'e4:1d:2d:6f:0c:41'

  00_1e_67_68_c8_ae:
    - rack: m06
    - hostname: qb03n4-m06
    - role: s3_client
    - mgmt0: '00:1e:67:68:c8:ac'
    - data0: 'e4:1d:2d:6f:8a:b2'

  00_50_cc_79_92_d3:
    - rack: m02
    - hostname: edxCloud1-1
    - role: edge

  00_50_cc_79_93_15:
    - rack: m02
    - hostname: edxedge1-1
    - role: edge

# mero06 SSUs
  00_50_cc_7a_6a_df:
    - rack: m09
    - hostname: ssu1-m09
    - role: generic
