#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

for UUID in $( virsh list --state-running --uuid ); do
    all_disks_hash_xml=$( virsh dumpxml $UUID |
                          grep -oP "/kvm-disks/images/.*?qcow2" |
                          sort -V | uniq | md5sum | grep -oE '^[^ ]+' )
    all_disks_hash_apparmor=$( cat /etc/apparmor.d/libvirt/libvirt-${UUID}.files |
                               grep -oP "/kvm-disks/images/.*?qcow2" |
                               sort -V | uniq | md5sum | grep -oE '^[^ ]+' )

    if [[ "$all_disks_hash_xml" != "$all_disks_hash_apparmor" ]]; then
        echo $UUID differs
    else
        echo $UUID is ok
    fi
done
