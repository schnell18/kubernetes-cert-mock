# Solution

Namespace `development` creation:

    kubectl create ns development

Create csr:

    openssl req -new -newkey rsa:2048 -keyout john.key -nodes -out john.csr

Create k8s csr as listed in the file `john-csr.yaml` according to [Create a
CertficateSigningRequest][1].

     kubectl apply -f john-csr.yaml

Approve the CSR:

     kubectl certificate approve john-developer

Get certificate:

     kubectl get csr john-developer -o jsonpath='{.status.certificate}' | base64 -d > john.crt

[1]: https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#create-certificatessigningrequest
