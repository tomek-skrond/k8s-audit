https://github.com/tomek-skrond/k8s-audit/issues# Instalacja maszynek:

Polecam zainstalowac [Vagrant na Windows](https://developer.hashicorp.com/vagrant/install).

`Vagrant` - provisioner maszynek (głównie dla desktopowych hypervisorów typu 2 - VirtualBox, VMware Workstation, Hyper-V). Jednym zdaniem - Vagrant pomaga szybko stawiać maszynki wirtualne.

Po instalacji Vagranta możemy stworzyć `Vagrantfile` czyli specyfikacje maszyny wirtualnej.

Żeby zainstalować maszynki (master node oraz worker node) na swoim VirtualBoxie, tworzymy `Vagrantfile` z nastepującą treścią:

```
### WORKER NODE
Vagrant.configure("2") do |config|
  config.vbguest.auto_update = false
  config.vm.box = "rockylinux/9"
  config.vm.provider :virtualbox do |vb|
    vb.name = "worker-node"
  end
end

### MASTER NODE
Vagrant.configure("2") do |config|
  config.vbguest.auto_update = false
  config.vm.box = "rockylinux/9"
  config.vm.provider :virtualbox do |vb|
    vb.name = "master-node"
  end
end
```
Vagrantfile bedzie dostepny w repo w folderze `setup/vm`.

Aby stworzyć maszynki wpisujemy do terminala:

```
vagrant up
```

Jeśli chcemy usunąć maszyny - wpisujemy `vagrant destroy`
