# ceph health check
ceph health detail

# ceph osd config update
ceph tell 'osd.*' injectargs --osd-max-backfills=2 --osd-recovery-max-active=6

# pg scrub check
ceph pg ${pg} query | jq .scrubber 

# crash situation
ceph crash ls

ceph crash info ${crash_id}

ceph crash archive ${crash_id} 
ceph crash archive-all
