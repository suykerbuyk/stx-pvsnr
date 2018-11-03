{% set stx_bci_url='http://stx-prvsnr/sage/images' %}
{% set stx_bci_default_img='sage-CentOS-7.5.x86_64-7.5.0_3-k3.10.0.txz' %}

stx_bci:
  cmu:
    - image: '{{stx_bci_url}}/{{stx_bci_default_img}}'
  ssu:
    - image: '{{stx_bci_url}}/{{stx_bci_default_img}}'
  s3_client:
    - image: '{{stx_bci_url}}/{{stx_bci_default_img}}'
  s3_server:
    - image: '{{stx_bci_url}}/{{stx_bci_default_img}}'
  blade:
    - image: '{{stx_bci_url}}/{{stx_bci_default_img}}'
  generic:
    - image: '{{stx_bci_url}}/{{stx_bci_default_img}}'
