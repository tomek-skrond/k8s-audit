# Nginx Ingress - Instalacja

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```

```
helm show values ingress-nginx/ingress-nginx > ingress.yaml
```

```
kubectl create ns ingress-nginx
```

### ingress.yaml:
- change hostNetwork: true
- change hostIP: true
- change Deployment to DaemonSet

Komenda zmienia wpisy w ingress.yaml automatycznie (jak nie zadziala to manualnie zmienic)
```
sed -i 's/kind:\ Deployment/kind:\ DaemonSet/g;s/hostNetwork:\ false/hostNetwork:\ true/g' ingress.yaml

IS_HOSTPORT_FALSE=$(grep "hostPort:" -n -F -w -A 2 ingress.yaml | grep -E "enabled:\ " | grep -o "false")

if [[ ${IS_HOSTPORT_FALSE} == "false" ]]; then
    LINE_TO_SWAP=$(grep "hostPort:" -n -F -w -A 2 ingress.yaml | grep -E "enabled:\ " | cut -d - -f 1)
    sed "${LINE_TO_SWAP}s/enabled:\ false/enabled: true/g" ingress.yaml
fi
```


```
helm install myingress ingress-nginx/ingress-nginx -n ingress-nginx --values ingress.yaml
```

# Nginx Ingress - konfiguracja

Dla testowej aplikacji:
```
kubectl apply -f ingress-resource-1.yaml
```
