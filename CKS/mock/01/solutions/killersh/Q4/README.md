# Solution

    kubectl create ns example
    kubectl label ns example \
        pod-security.kubernetes.io/warn=baseline \
        pod-security.kubernetes.io/warn-version=latest

    kubectl label --overwrite ns example \
      pod-security.kubernetes.io/enforce=baseline \
      pod-security.kubernetes.io/enforce-version=latest \
      pod-security.kubernetes.io/warn=restricted \
      pod-security.kubernetes.io/warn-version=latest \
      pod-security.kubernetes.io/audit=restricted \
      pod-security.kubernetes.io/audit-version=latest

Verify pod security settings:

    kubectl apply -n example -f https://k8s.io/examples/security/example-baseline-pod.yaml
