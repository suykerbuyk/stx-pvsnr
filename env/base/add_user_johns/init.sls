add_user_johns:
    user.present:
    - name: johns
    - groups:
        - wheel
    - shell: /bin/bash
    - createhome: True
    - password: $1$xd3Jjbbl$daitEGGRJFgr292j0KbH91

copy_bashrc:
    file.managed:
    - name: /home/johns/.gitconfig
    - source: salt://add_user_johns/files/gitconfig
    - user: johns
    - group: johns
    - mode: 0644
    - require:
        - add_user_johns
    - unless:
        - file.access /home/johns/.gitconfig f

/home/johns/.bashrc:
    file.line:
    - after: "# User specific aliases and functions"
    - content: "unset PROMPT_COMMAND"
    - mode: ensure
    - require:
        - add_user_johns

add_tmux_conf:
    file.managed:
    - name: /home/johns/.tmux.conf
    - source: salt://add_user_johns/files/tmux.conf
    - user: johns
    - group: johns
    - mode: 0644
    - require:
        - add_user_johns
    - unless:
        - file.access /home/johns/.tmux.conf f

mk_local_bin:
    module.run:
    - name: file.mkdir
    - dir_path: /home/johns/bin
    - user: johns
    - group: johns
    - mode: 0755
    - require:
        - add_user_johns
    - unless:
        - file.directory_exists /home/johns/bin

add_bin_tm:
    file.managed:
    - name: /home/johns/bin/tm
    - source: salt://add_user_johns/files/tm
    - user: johns
    - group: johns
    - mode: 0755
    - require:
        - mk_local_bin
    - unless:
        - file.access /home/johns/bin/tm f

mk_user_ssh:
    module.run:
    - name: file.mkdir
    - dir_path: /home/johns/.ssh
    - user: johns
    - group: johns
    - mode: 0700
    - require:
        - add_user_johns
    - unless:
        - file.directory_exists /home/johns/.ssh

add_user_ssh_config:
    file.managed:
    - name: /home/johns/.ssh/config
    - source: salt://add_user_johns/files/ssh/config
    - user: johns
    - group: johns
    - mode: 0600
    - require:
        - mk_user_ssh
    - unless:
        - file.access /home/johns/.ssh/config.conf f

add_user_ssh_id_rsa:
    file.managed:
    - name: /home/johns/.ssh/id_rsa
    - source: salt://add_user_johns/files/ssh/id_rsa
    - user: johns
    - group: johns
    - mode: 0600
    - require:
        - mk_user_ssh
    - unless:
        - file.access /home/johns/.ssh/id_rsa f

add_user_ssh_id_rsa_pub:
    file.managed:
    - name: /home/johns/.ssh/id_rsa.pub
    - source: salt://add_user_johns/files/ssh/id_rsa.pub
    - user: johns
    - group: johns
    - mode: 0600
    - require:
        - mk_user_ssh
    - unless:
        - file.access /home/johns/.ssh/id_rsa.pub f

add_user_ssh_authorized_keys:
    file.managed:
    - name: /home/johns/.ssh/authorized_keys
    - source: salt://add_user_johns/files/ssh/authorized_keys
    - user: johns
    - group: johns
    - mode: 0600
    - require:
        - mk_user_ssh
    - unless:
        - file.access /home/johns/.ssh/authorized_keys f

