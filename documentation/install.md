# Instalacja maszynek:

Polecam zainstalowac [Vagrant na Windows](https://developer.hashicorp.com/vagrant/install).

`Vagrant` - provisioner maszynek (głównie dla desktopowych hypervisorów typu 2 - VirtualBox, VMware Workstation, Hyper-V). Jednym zdaniem - Vagrant pomaga szybko stawiać maszynki wirtualne.

Po instalacji Vagranta możemy stworzyć `Vagrantfile` czyli specyfikacje maszyny wirtualnej.

Żeby zainstalować maszynki (master node oraz worker node) na swoim VirtualBoxie, tworzymy `Vagrantfile` z nastepującą treścią:

```
//todo
```
Vagrantfile bedzie dostepny w repo w folderze `setup/vm`.

Aby stworzyć maszynki wpisujemy do terminala:

```
vagrant up
```

Jeśli chcemy usunąć maszyny - wpisujemy `vagrant destroy`
