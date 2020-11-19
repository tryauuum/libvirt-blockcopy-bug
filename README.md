```
### create pools and simple domain
# ./create-pools-and-create-guest.sh
Pool images defined

Pool images started

Pool images marked as autostarted

Pool snapshots defined

Pool snapshots started

Pool snapshots marked as autostarted

Formatting '/kvm-disks/images/guest.qcow2', fmt=qcow2 size=10485760 cluster_size=65536 preallocation=metadata lazy_refcounts=off refcount_bits=16
Domain guest defined from guest.xml

Domain guest started

### reproduce bug
# ./reproduce-bug.sh guest
+ ((  1 != 1  ))
+ DOMID=guest
+ SNAPPATH=/kvm-disks/snapshots/guest.snap
++ virsh dumpxml --domain guest
++ grep -m1 -oP 'source file=.\K.*qcow2'
+ DISKPATH=/kvm-disks/images/guest.qcow2
+ stat /kvm-disks/images/guest.qcow2
++ date +%s
+ NEWDISKPATH=/kvm-disks/images/guest_1605822992.qcow2
+ virsh snapshot-create-as --domain guest --name temporary-after-migration --disk-only --atomic --no-metadata --diskspec vda,file=/kvm-disks/snapshots/guest.snap
Domain snapshot temporary-after-migration created
+ qemu-img convert -f qcow2 -O qcow2 -o preallocation=metadata /kvm-disks/images/guest.qcow2 /kvm-disks/images/guest_1605822992.qcow2
+ virsh blockcopy --domain guest --path vda --dest /kvm-disks/images/guest_1605822992.qcow2 --shallow --reuse-external --transient-job --pivot

Successfully pivoted
+ rm -v /kvm-disks/snapshots/guest.snap
removed '/kvm-disks/snapshots/guest.snap'
+ rm -v /kvm-disks/images/guest.qcow2
removed '/kvm-disks/images/guest.qcow2'

### now you can see that files in /etc/apparmor.d/libvirt/ are wrong.
### you can use ./apparmor-fix.sh for that if you want...
# ./check-if-apparmor-rules-are-ok.sh
2e1da611-96fd-412b-a441-2efc76c42d6f differs
```
