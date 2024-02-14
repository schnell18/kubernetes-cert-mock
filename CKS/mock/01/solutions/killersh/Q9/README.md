# Solution

Check apparmor status:

    aa-status

Or:

    aa-enabled

Create custom profile, and load with `apparmor_parser`:

    apparmor_parser -r -W /path/to/apparmor-profile

Associate profile with Pod:

    kubectl create deployment armored-nginx --image=nginx:1.19.2 --dry-run=client -o yaml > armored-nginx.yaml

Add annotation `container.apparmor.security.beta.kubernetes.io` and
nodeSelector:

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        app: apparmor
      name: apparmor
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: apparmor
      strategy: {}
      template:
        metadata:
          annotations:
            container.apparmor.security.beta.kubernetes.io/c1: localhost/containerized-nginx
          labels:
            app: apparmor
        spec:
          nodeSelector:
            security: apparmor
          containers:
      - image: nginx:1.19.2
        name: c1
        resources: {}
