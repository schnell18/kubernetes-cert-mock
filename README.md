# Introduction

This project provides tools for preparing kubernetes certifications such as
CKA, CKS and CKAD. The unique feature of the project is that it runs the
kubernetes clusters on VirtualBox or libvirt so that you can use your own PC
or laptop without incurring the cost of cloud. It creates kubernetes cluster
according to the following criteria:

- certification type(default `CKS`, set via environment variable `CERTIFICATION_TYPE`)
- mock test set(default `01`, set via environment variable `MOCK_SET`)
- question number(mandatory, set via environment variable `QUESTION`)

So if you wish to prepare a kubernetes cluster to solve the question 1 of the
CKS '01' mock set, you lanuch the cluster as follows:

     QUESTION=1 MOCK_SET=01 CERTIFICATION_TYPE=CKS vagrant up

Due to limited resources on PC and laptop, you should remove existing cluster
before creating a new one:

    vagrant destroy

Otherwise, you will encounter error similar to the one that follows:

    You are requesting cluster CKS-M01-C9(Q17), you have to destroy the existing cluster CKS-M01-C10(Q18) first!

To learn the current cluster, you run:

    vagrant status

And you will get output like:

    ##################################################################
    #                                                                #
    #              Kubernetes cluster CKS-M01-C10(Q18)               #
    #                                                                #
    ##################################################################
    Current machine states:
    
    master                    running (libvirt)
    slave-1                   running (libvirt)
    slave-2                   running (libvirt)
    
    This environment represents multiple VMs. The VMs are all listed
    above with their current state. For more information about a specific
    VM, run `vagrant status NAME`.

which displays the certification type, mock set, cluster number and
question nubmer as indicated in the parenthesis of the third line.

## Pre-requisite

You need the following tools required by this project:

- [libvirt][10](Linux) or [Virtualbox][1](Windows/MacOS)
- [Vagrant][2]
- [vagrant-libvirt][11]
- [vagrant-hostmanager][7]
- [Ansible][3]

Although VirtualBox also works on Linux, it is recommended you use libvirt as
it provisions virtual machines faster. Install these tools using the package
manager of operating systems such as apt-get on Debian/Ubuntu or pacman on Arch Linux.

The `vagrant-hostmanager` is a vagrant plugin which enables you to access the
kubernetes nodes using host name by creating entries in the `/etc/hosts` file
on the host. To install this plugin, you type:

    vagrant plugin install vagrant-hostmanager

If you use libvirt on Linux, you need the `vagrant-libvirt` plugin, which can
be installed as follows:

    vagrant plugin install vagrant-libvirt

## Available test sets

Currently, there is very limited number of test set.

| Type           | Set           | Questions      | Link               | notes     |
| -------------- | ------------- | -------------: | ------------------ | --------- |
| CKS            | 01            |             18 | [Test set spec][13]|           |

## Launch a kubernetes certification cluster

Firstly, you clone this project. Open a command line window, nagivate to the
root directory of this project. Then run the following commands if you use
libvirt:

    QUESTION=n vagrant up --provider=libvirt

Otherwise, run this command instead: 

    QUESTION=n vagrant up

Substitute the question number `n` with the one you are going to solve.  If
everything goes smoothly, the master and work nodes will be installed and
configured automatically and mock test related setup will be conducted. In case
the provision of master fails, you may trigger the setup by:

    QUESTION=1 vagrant reload master --provision

Likewise, if the provision of work node fails for reasons such as network
connectivity, you may re-run ansible as follows:

    QUESTION=1 vagrant reload slave-? --provision

Substitute the question mark with the appropriate slave number.

## kubectl setup

You need install [kubectl][6] on your laptop and copy the `/tmp/kubeconfig`,
which is feteched from the master node, to `~/.kube/config` or alternatively
you set the `KUBECONFIG` environment variable as follows:

    export KUBECONFIG=/tmp/kubeconfig

It is highly recommended that you setup alias `k` for `kubectl` to save
typing. Follow the [official kubernetes documentation][12] to properly
configure your environment.

## notes on internet access and VPN

If you prepare the certification practice in an environnent where access to
sites such as:

- docker.io
- pkgs.k8s.io
- github.com

is restricted and you have VPN as an alternative, you should make sure the MTU
of the VPN matches the virtual machine and virtual NICs on which the kubernetes
cluster in running. If your VPN or tunnel's MTU is lower than 1500, then you
should configure the variables `MTU` and `libvirt__mtu` in the `Vagrantfile`
appropriately. Otherwise, you will experience extreme slow network transmission
or broken connections.

[1]: https://www.virtualbox.org/
[2]: https://www.vagrantup.com/
[3]: https://www.ansible.com/
[4]: https://github.com/schnell18/vmbot/tree/master/debian
[5]: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
[6]: https://k8smeetup.github.io/docs/tasks/tools/install-kubectl/
[7]: https://github.com/devopsgroup-io/vagrant-hostmanager
[8]: https://kubernetes.io/blog/2023/03/10/image-registry-redirect/
[9]: https://kubernetes.io/blog/2023/08/31/legacy-package-repository-deprecation/
[10]: https://libvirt.org/
[11]: https://vagrant-libvirt.github.io/vagrant-libvirt/ 
[12]: https://kubernetes.io/docs/reference/kubectl/quick-reference/#kubectl-autocomplete 
[13]: https://github.com/schnell18/kube-cert/CKS/mock/01/README.md
