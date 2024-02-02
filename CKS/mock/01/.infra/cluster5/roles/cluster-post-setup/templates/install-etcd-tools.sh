install_etcd_tools() {
  pSUB_FOLDER="etcd-${RELEASE}-linux-amd64"
  acrh=$(uname -m)
  export RELEASE=$(curl -s https://api.github.com/repos/etcd-io/etcd/releases/latest|grep tag_name | cut -d '"' -f 4)
  case $acrh in
    x86_64)
      SUB_FOLDER="etcd-${RELEASE}-linux-amd64"
    ;;
    aarch64)
      SUB_FOLDER="etcd-${RELEASE}-linux-arm64"
    ;;
  esac

  cd $HOME
  etcdctl_url="https://github.com/etcd-io/etcd/releases/download/${RELEASE}/${SUB_FOLDER}.tar.gz"
  curl -sL $etcdctl_url | tar -xzvf - ${SUB_FOLDER}/etcdctl ${SUB_FOLDER}/etcdutl
  mv ${SUB_FOLDER}/{etcdctl,etcdutl} /usr/local/bin
  echo "*** etcd = $(etcdctl version)"

  cat > /usr/local/bin/etcd-read <<EOF
ETCDCTL_API=3 etcdctl \
   --cacert=/etc/kubernetes/pki/etcd/ca.crt   \
   --cert=/etc/kubernetes/pki/etcd/server.crt \
   --key=/etc/kubernetes/pki/etcd/server.key  \
   get /registry/secrets/\$1/\$2 | tr -cd '[:print:]\n'
EOF

  chmod +x /usr/local/bin/etcd-read
}

if [[ ! -f /usr/local/bin/etcdctl ]]; then
  install_etcd_tools
  echo "etcd tools installed!"
fi

