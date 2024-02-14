# Solution

Create a tls secret to wrap the certificate using kubectl:

    kubectl -n team-pink create secret tls secure-ingress-tls --cert=<the_cert> --key=<the_key>

Edit the ingress object to associate with the secret:

    spec:
      tls:
      - hosts:
          - secure-ingress.kube.vn
        secretName: secure-ingress-tls

## Ingress entry point IP
In non-cloud environment, where LoadBalancer type service is absent, you
create service to the nginx ingress controller using one of:

- NodePort
- External IP

In this example the ingress uses NodePort, 32000 for https and 31000 for http.
The entry IP is the IP address of the hosting node.

The external IP example:

    kind: Service
    apiVersion: v1
    metadata:
      name: ingress-nginx
      namespace: ingress-nginx
      labels:
        app: ingress-nginx
    spec:
      selector:
        app: ingress-nginx
      ports:
      - name: http
        port: 80
        targetPort: http
      - name: https
        port: 443
        targetPort: http
      externalIPs:
      - 80.11.12.10

To test the ingress, use:

    curl -kv https://secure-ingress.kube.vn:32000

You need put a mapping for secure-ingress.kube.vn to the IP of hosting node
in the `/etc/hosts` file or use the `--resolve` switch as:

    curl -kv --resolve "secure-ingress.kube.vn:32000:192.168.122.11" https://secure-ingress.kube.vn:32000

## Create self-signed certificate

    openssl req -new -newkey rsa:2048 -nodes -keyout server.key -out server.csr -x509 -days 365 -config csr.cnf

## Create certificate singed by custom CA

Create TLS certificate signed by custom CA.

- Generate a CSR with SAN populated
- Create a k8s CSR object
- Approved the k8s object and get the certificate

### Generate CSR for serving https

Create a config file with SAN:

    [req]
    distinguished_name = req_distinguished_name
    req_extensions = v3_req
    prompt = no
    
    [req_distinguished_name]
    C = NZ
    ST = Auckland
    L = Auckland
    O = AUT
    OU = IT
    CN = secure-ingress.kube.vn
    
    [v3_req]
    keyUsage = keyEncipherment, dataEncipherment
    extendedKeyUsage = serverAuth
    subjectAltName = @alt_names
    
    [alt_names]
    DNS.1 = 192.168.122.11
    DNS.2 = entry.kube.vn
    DNS.3 = api.kube.vn

Run command:

    openssl req -new -newkey rsa:2048 -nodes -keyout secure-ingress.kube.vn.key -out secure-ingress.kube.vn.csr -config csr.cnf


### Create k8s CSR object

    cat <<EOF | kubectl apply -f -
    apiVersion: certificates.k8s.io/v1
    kind: CertificateSigningRequest
    metadata:
      name: secure-ingress-csr
    spec:
      request: $(cat secure-ingress.kube.vn.csr | base64 | tr -d '\n')
      signerName: <custom/ca>
      usages:
      - digital signature
      - key encipherment
      - server auth
    EOF
