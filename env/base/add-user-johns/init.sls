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

mk-local-bin:
    module.run:
    - name: file.mkdir
    - dir_path: /home/johns/bin
    - user: johns
    - group: johns
    - mode: 0755
    - require:
        - add-user-johns

add-bin-tm:
    file.managed:
    - name: /home/johns/tm
    - source: salt://add-user-johns/files/tm
    - user: johns
    - group: johns
    - mode: 0755
    - require:
        - mk-local-bin
