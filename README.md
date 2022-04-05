# hello-k8s
k8s demo

## 开发环境搭建
  ### multipass
    * 安装（略）
      * "C:\Windows\System32\config\systemprofile\AppData\Roaming\multipassd\vault\instances"
    * 创建multipass虚拟机
      ```bash
        multipass launch docker -n k8s-master -d 40G -m 8G -c 4 --cloud-init cloud-config.yml
        multipass launch docker -n k8s-node-1 -d 40G -m 4G -c 2 --cloud-init cloud-config.yml
        multipass launch docker -n k8s-node-2 -d 40G -m 4G -c 2 --cloud-init cloud-config.yml
        multipass launch docker -n k8s-node-3 -d 40G -m 4G -c 2 --cloud-init cloud-config.yml
      ```
  ### k8s 
    * 安装kubeadm kubeadm kubectl
      ```bash
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl
        sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg
        echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
        sudo apt update
        sudo apt install -y kubelet kubeadm kubectl
      ```
  ### 初始化k8s集群
  > --pod-network-cidr一定要和k8s-master的eth0地址吻合！
    * kubeadm config images list
    * docker pull docker/desktop-kubernetes-apiserver:v1.23.5
    * docker pull docker/desktop-kubernetes-controller-manager:v1.23.5
    * docker pull docker/desktop-kubernetes-scheduler:v1.23.5
    * docker pull docker/desktop-kubernetes-proxy:v1.23.5
    * docker pull shirley01/pause:3.6
    * docker pull bitnami/etcd:3.5.1
    * docker pull shirley01/coredns:v1.8.6
    * (废弃) kubeadm config print init-defaults >kubeadm.cfg
    * (废弃) sed -i 's/k8s.gcr.io//g'
    * (废弃) kubeadm config images pull --config kubeadm.cfg
    * (废弃) sudo kubeadm init --pod-network-cidr=172.29.132.89/20 --config kubeadm.cfg
    * sudo kubeadm init --pod-network-cidr=172.29.132.89/20

## docker加速
  ```bash
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
    {
      "registry-mirrors": ["https://g710x36t.mirror.aliyuncs.com"]
    }
    EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
  ```
## build
* docker build -t hello-k8s .

## k8s
* [minikube](https://minikube.sigs.k8s.io/docs/start/)
* `kubectl apply -f mongo-config.yaml`
* `kubectl apply -f mongo-secret.yaml`
* kubectl get all
* kubectl get pod
* kubectl get svc
* kubectl get configmap
* kubectl get secret
* kubectl get node -o wide
* kubectl describe service xxx
* kubectl describe pod xxx
* kubectl minikube ip
* kubectl logs webapp-deployment-56dbf5d695-7lzml
* kubectl logs webapp-deployment-56dbf5d695-7lzml -f

## multipass 使用方式
  * multipass launch docker --name foo
  * multipass networks
  * multipass launch -n foo --network WSL
  * multipass exec foo -- lsb_release -- -a
  * multipass list
  * multipass stop foo bar
  * multipass start foo
  * multipass delete bar
  * multipass purge
  * multipass find
  * multipass shell foo
  * multipass exec foo sudo apt update
  * multipass exec primary lsb_release -- -a
  * multipass transfer xxx.txt foo:/home/ubuntu/xxx.txt
  * multipass set local.privileged-mounts=on
  * multipass mount D:\github\hello-k8s master:/home/ubuntu/hello-k8s/
  * multipass launch minikube -n master -d 10G -m 8G -c 4 --cloud-init cloud-config.yaml

  * sudo hostnamectl set-hostname master-node

