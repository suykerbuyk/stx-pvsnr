#!/usr/bin/python
# vim: fenc=utf-8:ts=4:sw=4:sta:noet:sts=4:fdm=marker:ai

import logging, os

opts = salt.config.minion_config('/etc/salt/minion')
opts['grains'] = {}
__salt__ = salt.loader.minion_mods(opts, whitelist=['stx_mlx4'])

log = logging.getLogger(__name__)

def check_for_mellanox():
	if __salt__['stx_mlx4.present']():
		return {'has_mlx4', 'True'}
	else:
		return {'has_mlx4', 'False'}


if __name__ == "__main__":
    print check_for_mellanox()
