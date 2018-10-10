#!/usr/bin/python
# vim: fenc=utf-8:ts=4:sw=4:sta:noet:sts=4:fdm=marker:ai

import logging, os, fnmatch

mlx_port_file_list = []

def _port_files():
	'''
	returns a list of port device control files
	'''
	if len(mlx_port_file_list) > 0:
		return mlx_port_file_list

	directory = '/sys/devices/'
	pattern = 'mlx4_port[1-2]'
	for root, dirs, files in os.walk(directory):
		for basename in files:
			if fnmatch.fnmatch(basename, pattern):
				port_device_file = os.path.join(root,basename)
				mlx_port_file_list.append(port_device_file)
	return mlx_port_file_list

def _pci_slots():
	'''
	returns a list of the pci slots appropriate for rdma.conf
	'''
	slots = set()
	for port_file in _port_files():
		slot = os.path.basename(
			os.path.dirname(
			os.path.dirname(port_file)))
		slots.add(slot)
	return list(slots)

def check_for_mellanox():
	if len(_port_files()) > 0:
		return {'mlx_present', True}
	else:
		return {'mlx_present', False}


if __name__ == "__main__":
    print check_for_mellanox()
