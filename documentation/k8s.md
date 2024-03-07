# Kubernetes setup:
Jeśli zainstalowałeś poprawnie maszynki, aby zainstalować kubernetesa, wykonaj poniższe kroki.

<b>Zwróć szczególną uwagę, które komendy powinny być wykonywane na `master nodach` a które na `worker nodach`.</b>

### Prerequisites:
#### Przed instalacją:
- utwórz sieć wewnętrzną HOST ONLY w VirtualBoxie
- przypisz STATYCZNE IP każdej VMce w klastrze (ja polecam ustawiać za pomocą komendy `nmtui`)
- przypisz hostname każdej VMce w klastrze (`hostnamectl set-hostname <hostname_vmki>` przykładowy hostname: `master-node`)
- opcjonalne: konfiguracja `/etc/hosts` - przypisanie IPkom w klastrze lokalnych nazw

Po wykonaniu tych akcji zrób <b>SNAPSHOT</b> systemów (lepiej tak niż odpalac ciagle Vagranta)

### Instalacja:
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
yum install -y yum-utils device-mapper-persistent-data lvm2
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

################# /WYKONAJ NA WSZYSTKICH NODACH #################


################# WYKONAJ NA MASTER NODE #################

# Initialize Kubernetes cluster
systemctl enable kubelet.service
systemctl start kubelet.service

rm -rf /etc/containerd/*.toml
systemctl restart containerd

# tutaj wybrać adres IP w sieci wewnętrznej HOST ONLY
IP_ADDR=$(ip address show dev enp0s8 | grep -E -o '([0-9]{1,3}\.){3}([0-9]{1,3})' | grep -v 255)
kubeadm init --apiserver-advertise-address=${IP_ADDR} --pod-network-cidr=192.168.0.0/16

# Enable kubectl usage on root account
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy Calico overlay network
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

# Generate join command for the workers
kubeadm token create --print-join-command 2>/dev/null

################# /WYKONAJ NA MASTER NODE #################
```

Komenda:
```
# Generate join command for the workers
kubeadm token create --print-join-command 2>/dev/null
```
powinna zwrócić podobny output:

```
kubeadm join 192.168.56.110:6443 --token hp9b0k.1g9tqz8vkf78ucwf     --discovery-token-ca-cert-hash sha256:32eb67948d72ba99aac9b5bb0305d66a48f43b0798cb2df99c8b1c30708bdc2c
```

Jest to komenda pozwalająca podłączyć się workerowi do klastra zarządzanego przez odpowiedniego mastera. Pomyślne wykonanie tej komendy na worker-nodzie kończy konfigurację worker node'a (a zarazem klastra).