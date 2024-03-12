### Nginx Ingress Controller
[Guide](https://github.com/marcel-dempers/docker-development-youtube-series/tree/master/kubernetes/ingress/controller/nginx)


### demo folder
Prerequisites: K8s Cluster, MetalLB + NGINX Ingress Controller installed

Creates an Nginx Ingress object + nginx test deployment/service.

Ingress config applies reverse proxy path rewrite from internal nginx port 8080 to path `/testpath` and port `80`.