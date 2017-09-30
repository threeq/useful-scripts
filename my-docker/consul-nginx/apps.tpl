{{range services}} {{$name := .Name}} {{$service := service .Name}}

{{if eq $name "default_server"}} 

server {
  listen 80 default_server;

  location / {
    root /usr/share/nginx/html/;
    index index.html;
  }

  location /stub_status {
    stub_status;
  }

}

{{else if .Tags | contains "open_web"}}

upstream {{$name}} {
  zone upstream-{{$name}} 64k;

  {{range $service}}
    server {{.Address}}:{{.Port}} max_fails=3 fail_timeout=60 weight=1;
  {{else}}
    server 127.0.0.1:65535; # force a 502
  {{end}}
} 

server {
  listen 80;
  server_name {{$name | replaceAll "-" "."}};

  location / {
    proxy_pass http://{{$name}};
  }

}

{{end}}

{{end}}
