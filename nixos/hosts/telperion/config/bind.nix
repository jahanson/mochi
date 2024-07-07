{config, ...}: 
''
include "${config.sops.secrets."bind/rndc-keys/externaldns".path}";

acl trusted {
  10.33.44.0/24;  # LAN
  10.1.1.0/24;    # Servers
  10.1.2.0/24;    # Trusted
  10.1.3.0/24;    # IoT
  10.1.4.0/24;    # Video
};

zone "jahanson.tech." {
  type master;
  file "${config.sops.secrets."bind/zones/jahanson.tech".path}";
  journal "${config.services.bind.directory}/db.jahanson.tech.jnl";
  allow-transfer {
    key "externaldns";
  };
  update-policy {
    grant externaldns zonesub ANY;
  };
  allow-query {
    trusted;
  };
};
''