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
    multipass launch --name k8s-node-0 --disk 40G --mem 4G --cpus 2 --cloud-init cloud-config.yml docker
  ```

### docker
* 设置mirror
  ``` bash
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
    {
      "exec-opts": ["native.cgroupdriver=systemd"],
      "registry-mirrors": ["https://g710x36t.mirror.aliyuncs.com"]
    }
    EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    sudo docker login --username=beecluster registry.cn-hangzhou.aliyuncs.com
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

* 关闭虚拟内存
  ``` bash
  # 永久关闭虚拟内存：注释掉swap或者sw相关行
  sudo vim /etc/fstab 
  # 临时关闭虚拟内存
  sudo swapoff -a 
  ```

* 初始化k8s集群
  > 因为k8s.gcr.io被强，所以下载阿里云镜像然后重新tag。
  ```bash

  # 生成配置文件
  kubeadm config print init-defaults >kubeadm.cfg

  # 拉取镜像
  kubeadm config images pull --config kubeadm.cfg

  # 修改配置文件
  sed -i "s/imageRepository: .*/imageRepository: registry.cn-hangzhou.aliyuncs.com\/google_containers/g" kubeadm.cfg
  /**
    apiVersion: kubeadm.k8s.io/v1beta3
    bootstrapTokens:
    - groups:
      - system:bootstrappers:kubeadm:default-node-token
      token: abcdef.0123456789abcdef
      ttl: 24h0m0s
      usages:
      - signing
      - authentication
    kind: InitConfiguration
    localAPIEndpoint:
      advertiseAddress: 172.22.26.62  # 改为本机局域网ip
      bindPort: 6443
    nodeRegistration:
      criSocket: /var/run/dockershim.sock
      imagePullPolicy: IfNotPresent
      name: node
      taints: null
    ---
    apiServer:
      timeoutForControlPlane: 4m0s
    apiVersion: kubeadm.k8s.io/v1beta3
    certificatesDir: /etc/kubernetes/pki
    clusterName: kubernetes
    controllerManager: {}
    dns: {}
    etcd:
      local:
        dataDir: /var/lib/etcd
    imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers  # 设置为为阿里云镜像
    kind: ClusterConfiguration
    kubernetesVersion: 1.23.0
    networking:
      podSubnet: 10.244.0.0/16 # --pod-network-cidr 稍后要设置flanel插件和这个一致
       # podSubnet: "172.22.31.39/20" # multipass 一定要和k8s-master的eth0地址吻合！
      dnsDomain: cluster.local
      serviceSubnet: 10.96.0.0/12
    scheduler: {}
  * /

  # initializes cluster master node
  sudo kubeadm init --config kubeadm.cfg

  # 按照提示复制集群配置文件
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  # 查看状态
  # 注意这里一定不能用sudo 否则会提示The connection to the server localhost:8080 was refused - did you specify the right host or port?
  # 如果出现权限问题，则把权限问题解决，用普通用户执行(fuck this shit)。
  kubectl get nodes  # status: NotReady
  kubectl get pods --all-namespaces  # status:pending

  # 初始化集群网络
  wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
  /**
    net-conf.json: |
      {
        "Network": "10.244.0.0/16",  # 改为和--pod-network-cidr一致
        "Backend": {
          "Type": "vxlan"
        }
      }
  */
  kubectl apply -f kube-flannel.yml

  # join
  sudo kubeadm join 172.22.16.82:6443 --token abcdef.0123456789abcdef  --discovery-token-ca-cert-hash sha256:d481878e274ccb45ff506db551f3388c9cb44da3a414d631e591742fdc7d703d

  # create an nginx deployment
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/nginx-app.yaml
  ```
* 删除cluster
  ```bash
  sudo kubeadm reset  
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