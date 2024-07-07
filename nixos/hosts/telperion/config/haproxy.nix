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

frontend k8s_apiserver
  bind *:6443
  mode tcp
  option tcplog
  default_backend k8s_controlplane

frontend talos_apiserver
  bind *:50000
  mode tcp
  option tcplog
  default_backend talos_controlplane

backend k8s_controlplane
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  option ssl-hello-chk
  balance roundrobin
  server worker1 10.1.1.61:6443 check

backend talos_controlplane
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
''