{ ... }:
{
  global = {
    "workgroup" = "WORKGROUP";
    "server string" = "gandalf";
    "netbios name" = "gandalf";
    "security" = "user";
    # note: localhost is the ipv6 localhost ::1
    "hosts allow" = "0.0.0.0/0";
    "guest account" = "nobody";
    "map to guest" = "bad user";
  };
  xen = {
    path = "/eru/xen-backups";
    browseable = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "create mask" = "0644";
    "directory mask" = "0755";
    "force user" = "apps";
    "force group" = "apps";
  };
  hansonhive = {
    path = "/eru/hansonhive";
    browseable = "yes";
    "read only" = "no";
    "guest ok" = "no";
    "create mask" = "0644";
    "directory mask" = "0755";
    "force user" = "www-data";
    "force group" = "www-data";
  };
  tm_joe = {
    path = "/eru/tm_joe";
    "valid users" = "jahanson";
    public = "no";
    writeable = "yes";
    "guest ok" = "no";
    "force user" = "jahanson";
    "fruit:aapl" = "yes";
    "fruit:time machine" = "yes";
    "vfs objects" = "catia fruit streams_xattr";
  };
  tm_elisia = {
    path = "/eru/tm_elisia";
    "valid users" = "emhanson";
    public = "no";
    writeable = "yes";
    "guest ok" = "no";
    "force user" = "emhanson";
    "fruit:aapl" = "yes";
    "fruit:time machine" = "yes";
    "vfs objects" = "catia fruit streams_xattr";
  };
}
