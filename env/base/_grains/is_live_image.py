#!/usr/bin/python
# vim: fenc=utf-8:ts=4:sw=4:sta:noet:sts=4:fdm=marker:ai

import logging
import re

# Import salt libs
#import salt.utils.files
#import salt.utils.path
#import salt.utils.platform

# Solve the Chicken and egg problem where grains need to run before any
# of the modules are loaded and are generally available for any usage.
import salt.modules.cmdmod

__salt__ = {
	'cmd.run': salt.modules.cmdmod._run_quiet,
	'cmd.run_all': salt.modules.cmdmod._run_all_quiet
}

log = logging.getLogger(__name__)

def is_live_image():
	'''
	Sets stx_live_image to 'True' if we've booted to a live image.
	Sets stx_live_image to 'False' otherwise.
	'''
	if 'rootflags=loop' in open('/proc/cmdline').read():
		return {'stx_live_image' : True}
	else:
		return {'stx_live_image' : False}
	return {'stx_live_image': None}


if __name__ == "__main__":
    a = is_live_image()
	print a
