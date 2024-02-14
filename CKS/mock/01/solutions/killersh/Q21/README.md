# Solution

    trivy image --scanner vuln --output nginx.txt nginx:1.16.1-alpine
    trivy image --scanner vuln --output apiserver.txt k8s.gcr.io/kube-apiserver:v1.18.0
    trivy image --scanner vuln --output ctl-mgr.txt k8s.gcr.io/kube-controller-manager:v1.18.0
    trivy image --scanner vuln --output weave-kube.txt docker.io/weaveworks/weave-kube:2.7.0
