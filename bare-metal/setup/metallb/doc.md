# MetalLB - Instalacja
Jedna komenda ;)
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.3/config/manifests/metallb-native.yaml
```

### MetalLB - konfiguracja
Edytuj plik ipaddress-pools zgodnie z Twoją konfiguracją sieciową. 

Dla przykładu, jeśli klaster stoi na adresacji: `172.16.16.0/24`, użyj przedziałów adresów w tej sieci (np. `172.16.16.100-172.16.16.200`)
```
kubectl apply -f ipaddress-pool.yaml
```