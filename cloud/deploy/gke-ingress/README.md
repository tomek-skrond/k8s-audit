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
https://cert-manager.io/docs/tutorials/getting-started-with-cert-manager-on-google-kubernetes-engine-using-lets-encrypt-for-ingress-ssl/

### Issuer - staging:
Wejdz w `cert-template/issuer-staging.yaml` i edytuj adres email na swoj.

```
kubectl apply -f cert/template/issuer-staging.yaml
```

Wprowadzic zmiany
```
--- a/ingress.yaml
+++ b/ingress.yaml
@@ -7,7 +7,12 @@ metadata:
     kubernetes.io/ingress.class: gce
     kubernetes.io/ingress.allow-http: "true"
     kubernetes.io/ingress.global-static-ip-name: web-ip
+    cert-manager.io/issuer: letsencrypt-staging
 spec:
+  tls:
+    - secretName: web-ssl
+      hosts:
+        - $DOMAIN_NAME
   defaultBackend:
     service:
       name: web
```

```
kubectl annotate ingress gke-ingress cert-manager.io/issuer=letsencrypt-production --overwrite
```