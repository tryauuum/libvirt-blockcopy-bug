#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

if (( "$#" != 1 )); then
    echo "usage: $0 DOMID"
    exit 1
fi

DOMID="$1"
SNAPPATH="/kvm-disks/snapshots/${DOMID}.snap"
# cringe way to get path to current disk image
DISKPATH=$( virsh dumpxml --domain ${DOMID} |
            grep -m1 -oP 'source file=.\K.*qcow2' )
# check if successful
stat $DISKPATH &>/dev/null
NEWDISKPATH="/kvm-disks/images/${DOMID}_$( date +%s ).qcow2"

virsh snapshot-create-as --domain $DOMID --name temporary-after-migration \
    --disk-only --atomic--no-metadata \
    --diskspec vda,file=$SNAPPATH
qemu-img convert -f qcow2 -O qcow2 -o preallocation=metadata \
    $DISKPATH $NEWDISKPATH

virsh blockcopy --domain $DOMID --path vda --dest $NEWDISKPATH \
    --shallow --reuse-external --transient-job --pivot

# remove unused files
virsh vol-delete ${SNAPPATH} || rm -v ${SNAPPATH}
virsh vol-delete ${DISKPATH} || rm -v ${DISKPATH}
