add-user-johns:
    user.present:
    - name: johns
    - groups:
        - wheel
    - shell: /bin/bash
    - createhome: True

copy-bashrc:
    file.managed:
    - name: /home/johns/.gitconfig
    - source: salt://add-user-johns/files/gitconfig
    - user: johns
    - group: johns
    - mode: 0644
    - require:
        - add-user-johns
    - unless:
        - file.access /home/johns/.gitconfig f

/home/johns/.bashrc:
    file.line:
    - after: "# User specific aliases and functions"
    - content: "unset PROMPT_COMMAND"
    - mode: ensure
    - require:
        - add-user-johns

add-tmux-conf:
    file.managed:
    - name: /home/johns/.tmux.conf
    - source: salt://add-user-johns/files/tmux.conf
    - user: johns
    - group: johns
    - mode: 0644
    - require:
        - add-user-johns
    - unless:
        - file.access /home/johns/.tmux.conf f

mk-local-bin:
    module.run:
    - name: file.mkdir
    - dir_path: /home/johns/bin
    - user: johns
    - group: johns
    - mode: 0755
    - require:
        - add-user-johns
    - unless:
        - file.directory_exists /home/johns/bin

add-bin-tm:
    file.managed:
    - name: /home/johns/bin/tm
    - source: salt://add-user-johns/files/tm
    - user: johns
    - group: johns
    - mode: 0755
    - require:
        - mk-local-bin
    - unless:
        - file.access /home/johns/bin/tm f

mk-user-ssh:
    module.run:
    - name: file.mkdir
    - dir_path: /home/johns/.ssh
    - user: johns
    - group: johns
    - mode: 0700
    - require:
        - add-user-johns
    - unless:
        - file.directory_exists /home/johns/.ssh

add-user-ssh-config:
    file.managed:
    - name: /home/johns/.ssh/config
    - source: salt://add-user-johns/files/ssh/config
    - user: johns
    - group: johns
    - mode: 0600
    - require:
        - mk-user-ssh
    - unless:
        - file.access /home/johns/.ssh/config.conf f

add-user-ssh-id_rsa:
    file.managed:
    - name: /home/johns/.ssh/id_rsa
    - source: salt://add-user-johns/files/ssh/id_rsa
    - user: johns
    - group: johns
    - mode: 0600
    - require:
        - mk-user-ssh
    - unless:
        - file.access /home/johns/.ssh/id_rsa f

add-user-ssh-id_rsa_pub:
    file.managed:
    - name: /home/johns/.ssh/id_rsa.pub
    - source: salt://add-user-johns/files/ssh/id_rsa.pub
    - user: johns
    - group: johns
    - mode: 0600
    - require:
        - mk-user-ssh
    - unless:
        - file.access /home/johns/.ssh/id_rsa.pub f

add-user-ssh-authorized_keys:
    file.managed:
    - name: /home/johns/.ssh/authorized_keys
    - source: salt://add-user-johns/files/ssh/authorized_keys
    - user: johns
    - group: johns
    - mode: 0600
    - require:
        - mk-user-ssh
    - unless:
        - file.access /home/johns/.ssh/authorized_keys f

