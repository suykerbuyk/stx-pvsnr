sync_grains:
  local.saltutil.sync_modules:
    - tgt: {{ data['id'] }}
