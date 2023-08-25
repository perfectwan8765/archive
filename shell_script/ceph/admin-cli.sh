# ceph health check
ceph health detail

# ceph osd config update
ceph tell 'osd.*' injectargs --osd-max-backfills=2 --osd-recovery-max-active=6

# pg scrub check
ceph pg ${pg} query | jq .scrubber 
