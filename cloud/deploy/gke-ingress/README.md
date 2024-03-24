# GCE Ingress

### Pre:
Stworzenie globalnego statycznego adresu IP:
```
gcloud compute addresses create my-static-ip --global
```

```
gcloud compute addresses list
```

```
gcloud compute addresses describe my-static-ip --forma='value(address)'
```

Instalacja cert-managera:
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
```

## Generowanie certyfikatu

### Issuer - staging:
