{...}: {
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  # Secret for machine-specific pushover
  sops.secrets = {
    "services/pushover/env" = {
      sopsFile = ./secrets.sops.yaml;
    };
    pushover-user-key = {
      sopsFile = ./secrets.sops.yaml;
    };
    pushover-api-key = {
      sopsFile = ./secrets.sops.yaml;
    };
  };
}
