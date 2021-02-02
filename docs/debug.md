# Debug

## Podman

Print the IP, network and listening ports for each container

```sh
podman inspect -f '{{.Name}}-{{range  $k, $v := .NetworkSettings.Networks}}{{$k}}-{{.IPAddress}} {{end}}-{{range $k, $v := .NetworkSettings.Ports}}{{ if not $v }}{{$k}} {{end}}{{end}} -{{range $k, $v := .NetworkSettings.Ports}}{{ if $v }}{{$k}} => {{range . }}{{ .HostIp}}:{{.HostPort}}{{end}}{{end}} {{end}}' $(podman ps -aq) | column -t -s-
```

## WireGuard

[HTTP request output](https://github.com/traefik/whoami)

```sh
podman run --rm -it -p 80:8080 --name iamfoo traefik/whoami
```
