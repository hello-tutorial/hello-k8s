# hello-k8s
k8s demo

## build
* docker build -t hello-k8s .

## k8s
* [minikube](https://minikube.sigs.k8s.io/docs/start/)

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
  * multipass mount c:/share foo:/home/ubuntu/share
  * multipass launch minikube -n master -d 10G -m 8G -c 4 --cloud-init cloud-config.yaml
  * cloud-config
    ```yaml
    runcmd:
       - curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
       - sudo apt-get install -y nodejs
    packages:
      nginx
    ```
