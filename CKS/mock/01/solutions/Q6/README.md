# Solution

Modify the `/etc/kubernetes/manifest/kube-apiserver.yaml` file, add
the command line argument `tls-cipher-suites` like:

    --tls-cipher-suites TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    --tls-min-version VersionTLS13

Modify the `/etc/kubernetes/manifest/etcd.yaml` file, add
the command line argument `cipher-suites` like:

    --cipher-suites 'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'

