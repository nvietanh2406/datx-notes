# I. Make VM on tpcom

properties:
    - CD/DVD drive: pfSense-CE-2.6.0-RELEASE-amd64.iso
    - guest os customization : enable
    - NIC
        E1000E  |  Direct-Network | Static - Manual | 103.141.177.61 | WAN
        VMXNET3 |  Management     | Static - Manual | 10.48.9.250    | mngt
        VMXNET3 |  Production     | Static - Manual | 10.48.16.250   | prodnet
    - CPU: 2 
    - MEM : 4GB
    - Virtual CPU hot add : enable
    - Memory hot add : enable
    - add new HDD : vSAN Enterprise Plus, NVME
    - Power on: uncheck

## install via shell 
accept -> install pfsen -> auto bios -> fished

goto tpcom -> eject media of vm -> reboot 

## config set interface wan