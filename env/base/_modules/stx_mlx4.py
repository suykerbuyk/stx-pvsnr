#!/usr/bin/python
# vim: fenc=utf-8:ts=4:sw=4:sta:noet:sts=4:fdm=marker:ai

import logging, os, fnmatch

port_file_list = []

def port_files():
	'''
	returns a list of port device control files
	'''
	if len(port_file_list) > 0:
		return port_file_list

	directory = '/sys/devices/'
	pattern = 'mlx4_port[1-2]'
	for root, dirs, files in os.walk(directory):
		for basename in files:
			if fnmatch.fnmatch(basename, pattern):
				port_device_file = os.path.join(root,basename)
				port_file_list.append(port_device_file)
	return port_file_list

def pci_slots():
	'''
	returns a list of the pci slots appropriate for rdma.conf
	'''
	slots = set()
	for port_file in port_files():
		slot = os.path.basename(
			os.path.dirname(
			os.path.dirname(port_file)))
		slots.add(slot)
	return list(slots)

def set_eth_mode():
	'''
	Configures all Mellanox ports for ethernet
	'''
	for port_file in port_files():
		with open(port_file,'w') as ctrl:
			ctrl.write('eth\n')
	return True

def set_ib_mode():
	'''
	Configues all Mellanox ports for IB
	'''
	for port_file in port_files():
		with open(port_file,'w') as ctrl:
			ctrl.write('ib\n')
	return True

def gen_rdma_conf_as_eth(rdma_dir='/etc/rdma/', rdma_file='mlx4.conf'):
	'''
	Generates an rdma.conf file at the directory specified
	Default location /etc/rdma/
	All dirs will be created if they don't exists.
	'''
	if not os.path.exists(rdma_dir):
		os.makedirs(rdma_dir)
	with open(rdma_dir + rdma_file, 'w') as rdma_fhandle:
		for slot in pci_slots():
			rdma_fhandle.write(slot + '   eth eth \n')
	return True

def present():
	if len(port_files()) > 0:
		return True
	return False

if __name__ == "__main__":
	print port_files()
	print pci_slots()
	set_eth_mode
	gen_rdma_conf_as_eth

