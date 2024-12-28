{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.mySystem.services.dnsmasq;
in
{
  options.mySystem.services.dnsmasq = {
    enable = mkEnableOption "dnsmasq";
    package = mkPackageOption pkgs "dnsmasq" { };
    bootAsset = mkOption {
      type = types.str;
      example = "http://10.1.1.57:8086/boot.ipxe";
    };
    tftpRoot = mkOption {
      type = types.str;
      example = "/srv/tftp";
    };
  };

  config = mkIf cfg.enable {
    # Ensure the tftpRoot directory exists
    systemd.tmpfiles.rules = [
      "d ${cfg.tftpRoot} 0755 dnsmasq dnsmasq"
    ];

    networking.firewall = {
      # dhcp ports | tftp port
      allowedUDPPorts = [
        67
        68
        69
      ]; # server/client/tftp
    };

    # Proxy DHCP for PXE booting. This leaves DHCP address allocation alone and dhcp clients
    # should merge all responses from their DHCPDISCOVER request.
    # https://matchbox.psdn.io/network-setup/#proxy-dhcp
    services.dnsmasq = {
      enable = true;
      package = cfg.package;
      # we just want to proxy DHCP, not serve DNS
      resolveLocalQueries = false;
      settings = {
        # Disables only the DNS port.
        port = 0;
        dhcp-range = [ "10.1.1.1,proxy,255.255.255.0" ];
        # serves TFTP from dnsmasq
        enable-tftp = true;
        tftp-root = cfg.tftpRoot;
        # if request comes from iPXE user class, set tag "ipxe"
        dhcp-userclass = "set:ipxe,iPXE";
        # if request comes from older PXE ROM, chainload to iPXE (via TFTP)
        # ALSO
        # point ipxe tagged requests to the matchbox iPXE boot script (via HTTP)
        # pxe-service="tag:ipxe,0,matchbox,http://10.1.1.57:8080/boot.ipxe";
        pxe-service = [
          "tag:#ipxe,x86PC,\"PXE chainload to iPXE\",undionly.kpxe"
          "tag:ipxe,0,matchbox,${cfg.bootAsset}"
        ];
        log-queries = true;
        log-dhcp = true;
      };
    };
  };
}
