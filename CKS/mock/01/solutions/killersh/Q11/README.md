# Solution

Find the cacert, cert and key using the kube-apiserver command line.
    etcdctl get /registry/secret/team-green/database-access

Get the decrypted database password:
    kubectl -n team-green get secret database-accesss -ojsonpath='{.data.pass}' | base64 -d > database-password
