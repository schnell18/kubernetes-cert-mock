# Solution

## upgrade master node

- drain master node(k drain master --ignore-daemonsets)
- change apt repo to match the minor version and the new pkgs.k8s.io
- unhold kubeadm kubelet kubectl etc
- install new kubeadm
- kubeadm upgrade plan
- kubeadm upgrade apply v1.2x.y or kubeadm upgrade node
- install new kubelet kubectl

## upgrade master node

- drain worker node(k drain slave-1 --ignore-daemonsets)
- change apt repo to match the minor version and the new pkgs.k8s.io
- unhold kubeadm kubelet kubectl etc
- install new kubeadm
- kubeadm upgrade plan
- kubeadm upgrade node
- install new kubelet kubectl
