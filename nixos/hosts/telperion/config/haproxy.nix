{ ... }:
''
global
  log /dev/log local0
  log /dev/log local1 notice
  daemon

defaults
  mode http
  log global
  option httplog
  option dontlognull
  option http-server-close
  option redispatch
  retries 3
  timeout http-request 10s
  timeout queue 20s
  timeout connect 10s
  timeout client 1h
  timeout server 1h
  timeout http-keep-alive 10s
  timeout check 10s

frontend k8s_homelab_apiserver
  bind *:6443
  mode tcp
  option tcplog
  default_backend k8s_homelab_controlplane

frontend k8s_theshire_apiserver
  bind *:6444
  mode tcp
  option tcplog
  default_backend k8s_theshire_controlplane

backend k8s_homelab_controlplane
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  option ssl-hello-chk
  balance roundrobin
  server shadowfax 10.1.1.61:6443 check

backend k8s_theshire_controlplane
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  option ssl-hello-chk
  balance roundrobin
  server nenya 10.1.1.62:6443 check
  server vilya 10.1.1.63:6443 check
  server narya 10.1.1.64:6443 check
''
