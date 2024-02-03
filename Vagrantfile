require 'fileutils'

IMAGE_NAME = "generic/debian12"
IMAGE_VERSION = "4.3.10"
MASTERS = 1
SLAVES = 2
EXTRA_DISKS = 2
MTU = 1342

$script1 = <<-SCRIPT
sudo ip link set eth0 mtu #{MTU}
sudo ip link set eth1 mtu #{MTU}
SCRIPT

# sudo sed -i.bak \
#     -e 's#deb.debian.org#mirror.sjtu.edu.cn#g' \
#     -e 's#security.debian.org#mirror.sjtu.edu.cn#g' \
#     /etc/apt/sources.list
# sudo apt-get update && sudo apt-get install -y gpg parted
$script2 = <<-SCRIPT
echo "Set default time zone to Asia/Shanghai..."
sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
sudo echo "Asia/Shanghai" > /etc/timezone
SCRIPT

# Disable parallel provisioning to avoid failure
ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure("2") do |config|
    if ARGV[0] == 'up'
      # vailidate and save mock test env meta info into file
      validate_meta_info()
    end

    vagrant_provider = get_provider(ARGV)
    cert_type, mock_set, question, cluster = get_quartet(read_meta_info())
    print_banner(cert_type, mock_set, question, cluster, 66) 

    if ARGV[0] == 'destroy'
      # remove mock test env meta info file
      remove_meta_info()
    end

    # set MTU when vm need cross GFW
    config.vm.provision "shell", inline: $script1, run: "always"
    # apply local settings such as time zone
    config.vm.provision "shell", inline: $script2

    # You may need copy the private key manually from existing env
    config.ssh.private_key_path = ["~/.vagrant.d/insecure_private_keys/vagrant.key.rsa"]
    config.ssh.insert_key = false
    config.vm.box_check_update = false

    # take care of /etc/hosts in both host and guest
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true

    (1..SLAVES + MASTERS).each do |i|
        prefix = "#{cert_type}#{mock_set}-c#{cluster}"
        # node_id = i <= MASTERS ? "#{prefix}-master" : "#{prefix}-slave-#{i - MASTERS}"
        node_id = i <= MASTERS ? "master" : "slave-#{i - MASTERS}"
        config.vm.define node_id do |node|
            node.vm.box = IMAGE_NAME
            node.vm.box_version = IMAGE_VERSION
            if vagrant_provider == 'libvirt'
                node.vm.network "private_network",
                    ip: "192.168.122.#{i + 9}",
                    :libvirt__network_name => "kubernetes",
                    :libvirt__mtu => MTU,
                    :autostart => true
            else
                node.vm.network "private_network", ip: "192.168.56.#{i + 9}"
            end
            node.vm.hostname = node_id
            node.vm.provision :hostmanager
            node.hostmanager.aliases = "#{node_id}.kube.vn"
    
            node.vm.provider "libvirt" do |v|
                v.management_network_mtu = MTU
                # the default pool is full
                # v.storage_pool_name = "home-pool"
                v.title = node_id
                v.description = "Kubernetes node: " + node_id
                v.memory = 2048
                v.cpus = 2
                if i > MASTERS
                    (1..EXTRA_DISKS).each do |j|
                        v.storage :file, :size => '30G'
                    end
                end
            end
    
            node.vm.provider "virtualbox" do |v|
                # vm name must be assigned w/ node id
                # otherwise, extra disks won't be created
                v.name = node_id
                v.memory = 2048
                v.cpus = 2
                v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                if i > MASTERS
                    (1..EXTRA_DISKS).each do |j|
                        v.storage :file, :size => '30G'
                    end
                end
            end
    
            dir = "#{cert_type}/mock/#{mock_set}/.infra/cluster#{cluster}"
            if i == MASTERS
                node.vm.provision "ansible" do |ansible|
                    ansible.playbook = "#{dir}/playbook-master.yml"
                    ansible.config_file = "ansible.cfg"
                    ansible.limit = "master"
                    ansible.extra_vars = {
                        hypervisor: vagrant_provider
                    }
                end
            end
            if i == SLAVES + MASTERS
                node.vm.provision "ansible" do |ansible|
                    ansible.playbook = "#{dir}/playbook-node.yml"
                    ansible.config_file = "ansible.cfg"
                    ansible.limit = "slave-*"
                    ansible.extra_vars = {
                        hypervisor: vagrant_provider
                    }
                end
                if File.exists?("#{dir}/playbook-setup.yml")
                    node.vm.provision "ansible" do |ansible|
                        ansible.playbook = "#{dir}/playbook-setup.yml"
                        ansible.config_file = "ansible.cfg"
                        ansible.limit = "master"
                        ansible.extra_vars = {
                        hypervisor: vagrant_provider
                        }
                    end
                end
            end
        end
    end
end

def get_provider_from_state()
  # fix here for multi-master cluster
  libvirt_dir = File.join(".vagrant", "machines",  "master", "libvirt")
  if File.exists?(libvirt_dir)
    return "libvirt"
  end
  for i in 1..SLAVES
    libvirt_dir = File.join(".vagrant", "machines",  "slave-#{i}", "libvirt")
    if File.exists?(libvirt_dir)
      return "libvirt"
    end
  end
  return nil
end

def get_provider_from_args(args)
  provider = nil
  for i in 0..args.length-1
    if args[i] == '--provider'
      provider = args[i+1]
      break
    elsif args[i].start_with?("--provider=")
      provider = args[i].split(/=/, 2)[1]
      break
    end
  end
  return provider || ENV['VAGRANT_DEFAULT_PROVIDER'] || "virtualbox"
end

def get_provider(args)
  return get_provider_from_state() || get_provider_from_args(args)
end

def format_cluster(cert_type, mock_set, question, cluster)
  cert_type ||= "XXX"
  mock_set ||= "NN"
  cluster ||= "NN"
  if question
    return "#{cert_type}-M#{mock_set}-C#{cluster}(Q#{question})"
  else
    return "#{cert_type}-M#{mock_set}-C#{cluster}"
  end
end

def extract_from_array(args)
  cert_type, mock_set, question = nil, nil, nil
  for i in 0..args.length-1
    if args[i] == '--cert-type'
      cert_type = args[i+1]
    elsif args[i].start_with?("--cert-type=")
      cert_type = args[i].split(/=/, 2)[1]
    elsif args[i] == '--mock-set'
      mock_set = args[i+1]
    elsif args[i].start_with?("--mock-set=")
      mock_set = args[i].split(/=/, 2)[1]
    elsif args[i] == '--question'
      question = args[i+1]
    elsif args[i].start_with?("--question=")
      question = args[i].split(/=/, 2)[1]
    end
  end
  return cert_type, mock_set, question
end

def get_cluster_by_triple(cert_type, mock_set, question)
  question = question.to_i
  question_dict = {
    '01' => {
      1 => { 'cluster' => 1 },
      2 => { 'cluster' => 1 },
      3 => { 'cluster' => 2 },
      4 => { 'cluster' => 3 },
      5 => { 'cluster' => 6 },
      6 => { 'cluster' => 1 },
      7 => { 'cluster' => 5 },
      8 => { 'cluster' => 6 },
      9 => { 'cluster' => 6 },
      10 => { 'cluster' => 6 },
      11 => { 'cluster' => 6 },
      12 => { 'cluster' => 7 },
      13 => { 'cluster' => 8 },
      14 => { 'cluster' => 1 },
      15 => { 'cluster' => 6 },
      16 => { 'cluster' => 1 },
      17 => { 'cluster' => 9 },
      18 => { 'cluster' => 10 },
    }
  }
  if !question_dict.has_key?(mock_set)
    mock_set = "01"
  end
  if question > question_dict[mock_set].keys.max() || question < 1
    question = 1
  end
  return question_dict[mock_set][question]['cluster']
end

def get_quartet(args)
  cert_type, mock_set, question = extract_from_array(args)
  cert_type ||= ENV['CERTIFICATION_TYPE'] || "CKS"
  mock_set ||= ENV['MOCK_SET'] || "01"
  question ||= ENV['QUESTION']
  question = question.to_i
  cluster = get_cluster_by_triple(cert_type, mock_set, question)
  return cert_type.upcase, mock_set, question, cluster
end

def persist_meta_info(cert_type, mock_set, question)
  meta_dir = File.join(".vagrant", "cert")
  FileUtils.mkpath(meta_dir) unless File.exists?(meta_dir)
  meta_info = File.join(".vagrant", "cert", "meta-info.txt")
  open(meta_info, 'w') do |f|
      f.puts "--cert-type=#{cert_type}"
      f.puts "--mock-set=#{mock_set}"
      f.puts "--question=#{question}"
  end
end

def validate_meta_info()
  cert_type = ENV['CERTIFICATION_TYPE'] || "CKS"
  mock_set = ENV['MOCK_SET'] || "01"
  question = ENV['QUESTION']
  meta_info = File.join(".vagrant", "cert", "meta-info.txt")
  if File.exists?(meta_info)
    cert_type_f, mock_set_f, question_f = extract_from_array(read_meta_info())
    if cert_type_f == cert_type and mock_set_f == mock_set
      cluster = get_cluster_by_triple(cert_type, mock_set, question) 
      cluster_f = get_cluster_by_triple(cert_type, mock_set, question_f) 
      if question_f == question
        abort("Kubernetes cluster #{format_cluster(cert_type, mock_set, question, cluster)} is already provisioned!")
      elsif cluster == cluster_f
        # update question parameter in meta-info.txt
        persist_meta_info(cert_type, mock_set, question)
        abort("Question Q#{question} and Q#{question_f} share same kubernetes cluster #{format_cluster(cert_type, mock_set, nil, cluster)} which is already provisioned!")
      else
        abort("You are requesting cluster #{format_cluster(cert_type, mock_set, question, cluster)}, you have to destroy the existing cluster #{format_cluster(cert_type_f, mock_set_f, question_f, cluster_f)} first!")
      end
    end
  else
    if !question
      abort("You must specify question number as QUESTION=n followed by vagrant up!")
    end
    persist_meta_info(cert_type, mock_set, question)
  end
end

def read_meta_info()
  meta_info = File.join(".vagrant", "cert", "meta-info.txt")
  if File.exists?(meta_info)
    return File.read(meta_info).split
  end
  return ARGV
end

def remove_meta_info()
  meta_info = File.join(".vagrant", "cert", "meta-info.txt")
  if File.exists?(meta_info)
    return File.delete(meta_info)
  end
end

def print_banner(cert_type, mock_set, question, cluster, banner_len)
    banner_text = "Kubernetes cluster #{format_cluster(cert_type, mock_set, question, cluster)}"
    puts "#" * banner_len
    puts "#" + " " * (banner_len - 2) + "#"
    puts "#" + banner_text.center(banner_len-2) + "#"
    puts "#" + " " * (banner_len - 2) + "#"
    puts "#" * banner_len
end

# vim:set nu ai expandtab sw=4 ts=4 syntax=ruby:
