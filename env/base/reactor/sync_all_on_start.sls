sync_all_on_start:
  local.saltutil.sync_all:
    - tgt: {{ data['id'] }}
