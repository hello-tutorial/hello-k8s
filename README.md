# hello-k8s

k8s demo

# 开发环境搭建

### multipass

* 安装（略）
  
  * "C:\Windows\System32\config\systemprofile\AppData\Roaming\multipassd\vault\instances"
  * hyper-v之前安装过的无用虚拟机删除

* 创建multipass虚拟机
  
  ```bash
    multipass launch --name k8s-master --disk 40G --mem 8G --cpus 4 --cloud-init cloud-config.yml docker
    multipass launch --name k8s-node-1 --disk 40G --mem 4G --cpus 2 --cloud-init cloud-config.yml docker
    multipass launch --name k8s-node-2 --disk 40G --mem 4G --cpus 2 --cloud-init cloud-config.yml docker
    multipass launch --name k8s-node-3 --disk 40G --mem 4G --cpus 2 --cloud-init cloud-config.yml docker
  ```

### k8s

* 安装kubeadm kubelet kubectl
  ```bash
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl
  sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg
  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt update
  sudo apt install -y kubelet kubeadm kubectl
  ```
  
 * 设置docker镜像
  ```bash
  sudo mkdir -p /etc/docker
  sudo tee /etc/docker/daemon.json <<-'EOF'
  {
    "registry-mirrors": ["https://g710x36t.mirror.aliyuncs.com"]
  }
  EOF
  sudo systemctl daemon-reload
  sudo systemctl restart docker
  sudo docker login --username=beecluster registry.cn-hangzhou.aliyuncs.com
  ```

* 初始化k8s集群
  ```bash
  kubeadm config images list
  kubeadm config print init-defaults >kubeadm.cfg
  // sed -i 's/k8s.gcr.io/registry.cn-hangzhou.aliyuncs.com/google_containers/g'
  /**
    修改kubeadm.cfg中的apiServer配置节。
    1. 添加--pod-network-cidr 参数，一定要和k8s-master的eth0地址吻合！
    2. k8s.gcr.io 改为 registry.cn-hangzhou.aliyuncs.com/google_containers
    apiServer:
    apiVersion: kubeadm.k8s.io/v1beta3
    imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
    kind: ClusterConfiguration
    kubernetesVersion: 1.23.0
    networking:
      podSubnet: "172.22.31.39/20" # --pod-network-cidr
  * /
  kubeadm config images pull --config kubeadm.cfg
  sudo kubeadm init --config kubeadm.cfg
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

# multipass 使用方式

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
