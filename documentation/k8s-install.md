### Instalacja:
Wykonaj poniższe komendy na poszczególnych nodach (nie kopiuj wszystkiego na raz pls).

# Wykonaj na wszystkich nodach

### Root login
```
su -
```

### Ustawienie /etc/hosts kierujacy na master-node'a
```
echo "172.16.16.5 master" >> /etc/hosts
```

### Wyłączenie firewall
```
systemctl stop firewalld
systemctl disable firewalld
```
### Swap off
```
cat /etc/fstab; sudo swapoff -a; sed -i '/swap/d' /etc/fstab
```
### Selinux off
```
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux
```

### reboot
```
sudo reboot
```

### kernel variables
```
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system
```

### Instalacja narzedzi + konfiguracja repo
```
yum install -y yum-utils device-mapper-persistent-data lvm2 wget
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl enable --now docker
```

### kubernetes repo
```
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOF
```

### Narzedzia K8s
```
yum install -y kubeadm kubelet kubectl
```

### Czyszczenie iptables
```
sudo iptables -F
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F
```

### Konfiguracja containerd
```
containerd config default > /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

systemctl restart containerd
```

### Kubelet on
```
systemctl enable kubelet.service
systemctl start kubelet.service
```

# Wykonaj TYLKO na master node

GIGA WAŻNE - jak komenda sfailuje to manualnie wbic
ustawiamy hostname ktory bedzie uzywany do instalacji

```
echo "127.0.0.1 master" >> /etc/hosts
```


```
IP_ADDR=$(ip address show dev enp0s8 | grep -E -o '([0-9]{1,3}\.){3}([0-9]{1,3})' | grep -v 255)
```
Jako IP_ADDR wybrać adres IP w sieci wewnętrznej HOST ONLY. Powyżej komenda pokazujaca ten adres. (mozna tez zobaczyc manualnie wpisujac `ip a`, ip bedzie na interfejsie eth1 lub enp0s8)

W tym przypadku `IP_ADDR=172.16.16.5`

### Komenda instalujaca master node
Do instalacji potrzeba adresu IP host only mastera + hostname utworzonego w /etc/hosts dla localhost, chodzi o ten wpis w `/etc/hosts`: 
```
"127.0.0.1 master"
```

Pełna komenda:
```
kubeadm init --apiserver-advertise-address=${IP_ADDR} --pod-network-cidr=192.168.0.0/16 --control-plane-endpoint master:6443
```
Jesli ta komenda sfailuje, to najlepiej wrocic do wczesniejszego snapshota (najlepiej do tego w ktorym wiadomo ze nic nie jest zle zainstalowane).

### Zalogowac sie na uzytkownika non-root (wyjsc z roota)
```
exit
```

Komenda pozwalajaca uzywac `kubectl` z konta non-root
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Deploy Calico overlay network
```
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/tigera-operator.yaml

wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/custom-resources.yaml

kubectl apply -f custom-resources.yaml
```
Poczekaj aż klaster sie stworzy, zeby sie zainstalowal, wszystkie pody muszą miec status Ready 1/1 oraz Running

Zeby to sprawdzic, uzyj komendy: 
```
watch kubectl get pod --all-namespaces
```

### Wygenerowanie komendy dla workerow zeby mogli dolaczyc do klastra
```
kubeadm token create --print-join-command 2>/dev/null
```

Komenda:
```
# Generate join command for the workers
kubeadm token create --print-join-command 2>/dev/null
```
powinna zwrócić podobny output:

```
kubeadm join 172.16.16.5:6443 --token hp9b0k.1g9tqz8vkf78ucwf     --discovery-token-ca-cert-hash sha256:32eb67948d72ba99aac9b5bb0305d66a48f43b0798cb2df99c8b1c30708bdc2c
```

Jest to komenda pozwalająca podłączyć się workerowi do klastra zarządzanego przez odpowiedniego mastera. Pomyślne wykonanie tej komendy na worker-nodzie kończy konfigurację worker node'a (a zarazem klastra).




### Instalacja (jako skrypt):
Wykonaj poniższe komendy na poszczególnych nodach (nie kopiuj wszystkiego na raz pls).
```
################# WYKONAJ NA WSZYSTKICH NODACH #################

# stop & disable firewalld
systemctl stop firewalld
systemctl disable firewalld

# turn swap off
cat /etc/fstab; sudo swapoff -a; sed -i '/swap/d' /etc/fstab

# disable selinux
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# reboot
sudo reboot

# configure kernel variables
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# install packages
yum install -y yum-utils device-mapper-persistent-data lvm2 wget
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce
systemctl enable --now docker

# add kubernetes repos
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOF

# install kubernetes tools
yum install -y kubeadm kubelet kubectl

# Flush & Disable iptables
sudo iptables -F
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F

################# /WYKONAJ NA WSZYSTKICH NODACH #################


################# WYKONAJ NA MASTER NODE #################

# Initialize Kubernetes cluster
systemctl enable kubelet.service
systemctl start kubelet.service

containerd config default > /etc/containerd/config.toml
systemctl restart containerd

# GIGA WAŻNE - jak komenda sfailuje to manualnie wbic
# ustawiamy hostname ktory bedzie uzywany do instalacji
echo "127.0.0.1 master" >> /etc/hosts

# tutaj wybrać adres IP w sieci wewnętrznej HOST ONLY
# IP_ADDR=$(ip address show dev enp0s8 | grep -E -o '([0-9]{1,3}\.){3}([0-9]{1,3})' | grep -v 255)
# IP_ADDR to adres sieci HOST ONLY mastera
IP_ADDR=172.16.16.5

# INSTALACJA -> potrzeba adresu IP host only mastera + hostname utworzonego w /etc/hosts dla localhost
# chodzi o ten wpis w /etc/hosts: "127.0.0.1 master"
kubeadm init --apiserver-advertise-address=${IP_ADDR} --pod-network-cidr=192.168.0.0/16 --control-plane-endpoint master:6443

# tu zalogowac sie na uzytkownika non-root
# Enable kubectl usage on non-root account
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy Calico overlay network
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/tigera-operator.yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/custom-resources.yaml
kubectl apply -f custom-resources.yaml

# Poczekaj aż klaster sie stworzy, zeby sie zainstalowal, wszystkie pody muszą miec status Ready 1/1 oraz Running
# Zeby to sprawdzic, uzyj komendy: 
watch kubectl get pod --all-namespaces

# Wygenerowanie komendy dla workerow zeby mogli dolaczyc do klastra
# Generate join command for the workers
kubeadm token create --print-join-command 2>/dev/null

################# /WYKONAJ NA MASTER NODE #################
```