# Prerequisites:
Jeśli zainstalowałeś poprawnie maszynki, aby przygotowac sie do instalacji kubernetesa, wykonaj poniższe kroki.

<b>Zwróć szczególną uwagę, które komendy powinny być wykonywane na `master nodach` a które na `worker nodach`.</b>

#### Przed instalacją:
- utwórz sieć wewnętrzną HOST ONLY w VirtualBoxie
- przypisz STATYCZNE IP każdej VMce w klastrze (ja polecam ustawiać za pomocą komendy `nmtui`)
- przypisz hostname każdej VMce w klastrze (`hostnamectl set-hostname <hostname_vmki>` przykładowy hostname: `master-node`)
- konfiguracja `/etc/hosts` - przypisanie IPkom w klastrze lokalnych nazw

Po wykonaniu tych akcji zrób <b>SNAPSHOT</b> systemów (lepiej tak niż odpalac ciagle Vagranta)

# Instalacja
Instalacja jest opisana w dokumencje `k8s-install.md`