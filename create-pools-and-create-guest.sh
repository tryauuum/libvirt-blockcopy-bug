#!/bin/bash

set -o errexit
set -o nounset

for POOL in 'images' 'snapshots'; do
    mkdir -p /kvm-disks/${POOL} &>/dev/null
    virsh pool-define-as --name ${POOL} --type dir --target /kvm-disks/${POOL}
    virsh pool-start ${POOL}
    virsh pool-autostart ${POOL}
done

qemu-img create -f qcow2 -o preallocation=metadata \
  /kvm-disks/images/guest.qcow2 10M

cat > guest.xml << EOF
<domain type='qemu'>
  <name>guest</name>
  <memory>4194</memory>
  <currentMemory>4194</currentMemory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64' machine='q35'>hvm</type>
    <boot dev='hd'/>
  </os>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/kvm-disks/images/guest.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <controller type='usb' index='0' model='qemu-xhci' ports='15'/>
    <interface type='user'>
      <mac address='52:54:00:09:a4:37'/>
      <model type='virtio'/>
    </interface>
    <console type='pty'/>
    <channel type='unix'>
      <source mode='bind'/>
      <target type='virtio' name='org.qemu.guest_agent.0'/>
    </channel>
  </devices>
</domain>
EOF

virsh define guest.xml
virsh start guest
