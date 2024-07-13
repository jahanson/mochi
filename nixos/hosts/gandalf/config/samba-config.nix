{ config, ... }:
''
  workgroup = WORKGROUP
  server string = gandalf
  netbios name = gandalf
  security = user 
  # note: localhost is the ipv6 localhost ::1
  hosts allow = 0.0.0.0/0
  guest account = nobody
  map to guest = bad user
''
