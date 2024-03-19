# Vagrant

`Vagrant` - provisioner maszynek (głównie dla desktopowych hypervisorów typu 2 - VirtualBox, VMware Workstation, Hyper-V). Jednym zdaniem - Vagrant pomaga szybko stawiać maszynki wirtualne.

Polecam zainstalowac [Vagrant na Windows](https://developer.hashicorp.com/vagrant/install).

Po instalacji Vagranta możemy stworzyć `Vagrantfile` czyli specyfikacje maszyny wirtualnej.

# Instalacja maszyn:
Wybralem ostatecznie dystrybucje Linuxa: `Alma Linux` wersja 9. Jest to prawie to samo co Rocky Linux (systemy nie roznia sie technicznie niczym oprocz nazwy).

Przed stworzeniem maszyn, trzeba zainstalowac add-on do vagranta:
```
vagrant plugin install vagrant-vbguest
```

Żeby zainstalować maszynki (master node oraz worker node) na swoim VirtualBoxie, tworzymy `Vagrantfile` z nastepującą treścią (lub wchodzimy do folderu w repo `setup/vm/`):

```
Vagrant.configure("2") do |config|
  
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end
  config.vm.provision "shell", path: "bootstrap.sh"

  config.vm.define "worker-node" do |node|
    node.vm.box = "almalinux/9"
    # node.vm.box_check_update  = false
    node.vm.provider :virtualbox do |vb|
      vb.name = "worker-node"
      vb.memory = 1024
      vb.cpus = 1
    end
  end

  config.vm.define "master-node" do |node|
    node.vm.box = "almalinux/9"
    # node.vm.box_check_update  = false
    node.vm.provider :virtualbox do |vb|
      vb.name = "master-node"
      vb.memory = 2048
      vb.cpus = 2
    end
  end
end
```

Vagrantfile bedzie dostepny w repo w folderze `setup/vm`.

Aby stworzyć maszynki wpisujemy do terminala:

```
vagrant up
```

Jeśli chcemy usunąć maszyny - wpisujemy `vagrant destroy`

# Konfiguracja VMek
Wstepnie zainstalujemy po jednym master i worker nodzie.
### Master Node:
- CPU: 2 rdzenie
- Memory: 2048 MB
- Dysk: 20GB
### Worker Node:
- CPU: 2 rdzenie
- Memory: 2048 MB
- Dysk: 20GB
### Credentiale/polaczenia:
Do maszynek można połączyć się komendą:
```
vagrant ssh <nazwa_maszynki>
```
Na przykład:
```
vagrant ssh master-node
```

#### Credentiale dla każdej z VMek:
- User: vagrant
- Hasło: vagrant
- User root: root
- Hasło root: vagrant