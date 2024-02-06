# Solution

    kubectl label --overwrite ns team-red \
      pod-security.kubernetes.io/enforce=baseline \
      pod-security.kubernetes.io/enforce-version=latest
