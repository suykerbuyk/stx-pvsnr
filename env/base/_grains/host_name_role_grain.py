#!/usr/bin/python
# vim: fenc=utf-8:ts=4:sw=4:sta:noet:sts=4:fdm=marker:ai

import socket
import logging
log = logging.getLogger(__name__)

def host_name_role():

	hostname = socket.gethostname().lower()
    log.debug("host-name-rolegrain hostname: " + hostname)

    if "ssu" in hostname:
        return {'host_name_role':'ssu'}
    elif "cmu" in hostname:
        return {'host_name_role':'cmu'}
    elif "s3" in hostname:
        return {'host_name_role':'s3'}
    elif "stx-prvsnr" in hostname:
        return {'host_name_role':'stx-prvsnr'}
    else:
        return {'host_name_role':'n/a'}



if __name__ == "__main__":
    print host_name_role()
