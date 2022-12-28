#!/usr/bin/env python
from __future__ import print_function
from collections import OrderedDict, namedtuple
import os
from typing import Dict, Any
import glob
import re


def cpuinfo():
    """ Return the information in /proc/cpuinfo
    as a dictionary in the following format:
    cpu_info['proc0']={...}
    cpu_info['proc1']={...}

    """

    cpu_info = OrderedDict()
    procinfo = OrderedDict()

    nprocs = 0
    with open('/proc/cpuinfo') as f:
        for line in f:
            if not line.strip():
                # end of one processor
                cpu_info['proc%s' % nprocs] = procinfo
                nprocs = nprocs + 1
                # Reset
                procinfo = OrderedDict()
            else:
                if len(line.split(':')) == 2:
                    procinfo[line.split(':')[0].strip()] = line.split(':')[1].strip()
                else:
                    procinfo[line.split(':')[0].strip()] = ''

    return cpu_info


def process_list():
    pid_s = []
    for subdir in os.listdir('/proc'):
        if subdir.isdigit():
            pid_s.append(subdir)

    return pid_s


def netdevs():
    """RX and TX bytes for each of the network devices"""
    with open('/proc/net/dev') as f:
        net_dump = f.readlines()
    device_data: Dict[Any, Any] = {}
    data = namedtuple('data', ['rx', 'tx'])
    for line in net_dump[2:]:
        line = line.split(':')
        if line[0].strip() != 'lo':
            device_data[line[0].strip()] = data(float(line[1].split()[0]) / (1024.0 * 1024.0),
                                                float(line[1].split()[8]) / (1024.0 * 1024.0))
    return device_data


def size(device):
    nr_sectors = open(device + '/size').read().rstrip('\n')
    sect_size = open(device + '/queue/hw_sector_size').read().rstrip('\n')

    # The sect_size is in bytes, so we convert it to GiB and then send it back
    return (float(nr_sectors) * float(sect_size)) / (1024.0 * 1024.0 * 1024.0)


# Add any other device pattern to read from
dev_pattern = ['sd.*', 'mmcblk*']


def detect_devs():
    for device in glob.glob('/sys/block/*'):
        for pattern in dev_pattern:
            if re.compile(pattern).match(os.path.basename(device)):
                print('Device:: {0}, Size:: {1} GiB'.format(device, size(device)))


mem_bytes = os.sysconf('SC_PAGE_SIZE') * os.sysconf('SC_PHYS_PAGES')  # e.g. 4015976448
mem_gib = mem_bytes/(1024.**3)  # e.g. 3.74


if __name__ == '__main__':
    cpuinfo = cpuinfo()
    print("CPU:")
    for processor in cpuinfo.keys():
        print("\t" + cpuinfo[processor]['model name'])
    print("RAM:")
    print(mem_gib)  # total physical memory available
    print("LAN:")
    netdevs = netdevs()
    for dev in netdevs.keys():
        print("\t" + '{0}: {1} MiB {2} MiB'.format(dev, netdevs[dev].rx, netdevs[dev].tx))
    print(" \nProcesses:")
    pids = process_list()
    print("\t" + 'Total count:: {0}'.format(len(pids)) + "\n")
    print("Block devices:")
    detect_devs()
