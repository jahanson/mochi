{...}: {
  name = "Soft Serve";
  log = {
    format = "text";
    time_format = "2006-01-02 15:04:05";
  };
  ssh = {
    listen_addr = ":23231";
    public_url = "ssh://10.1.1.61:23231";
    key_path = "ssh/soft_serve_host_ed25519";
    client_key_path = "ssh/soft_serve_client_ed25519";
    max_timeout = 0;
    idle_timeout = 600;
  };
  git = {
    listen_addr = ":9418";
    public_url = "git://10.1.1.61";
    max_timeout = 0;
    idle_timeout = 3;
    max_connections = 32;
  };
  http = {
    listen_addr = ":23232";
    tls_key_path = null;
    tls_cert_path = null;
    public_url = "http://10.1.1.61:23232";
  };
  stats = {
    enabled = false;
    listen_addr = "10.1.1.61:23233";
  };
  db = {
    driver = "sqlite";
    data_source = "soft-serve.db?_pragma=busy_timeout(5000)&_pragma=foreign_keys(1)";
  };
  lfs = {
    enabled = true;
    ssh_enabled = false;
  };
  jobs = {
    mirror_pull = "@every 10m";
  };
  initial_admin_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILcLI5qN69BuoLp8p7nTYKoLdsBNmZB31OerZ63Car1g jahanson@telchar"
  ];
}
