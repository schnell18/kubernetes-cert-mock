# Solution

Create runtime class:

    apiVersion: node.k8s.io/v1
    kind: RuntimeClass
    metadata:
      name: gvisor 
    handler: gvisor

Create namespace team-purple:

    kubectl create ns team-purple

Create required pod yaml skeleton:

    kubectl run gvisor-test --image=nginx:1.19.2 --dry-run=client -o yaml > gvisor-test.yaml
