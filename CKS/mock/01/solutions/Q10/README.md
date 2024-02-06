# Solution

      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        runAsGroup: 3000
        runAsUser: 3000

To make /tmp writable, create an emptydir volume and mount it into /tmp:

    apiVersion: apps/v1
    kind: Deployment
    spec:
      template:
        spec:
          volumes:
            - name: tmp
              emptyDir: {}
            containers:
              - name: <my-component-name>
                volumeMounts:
                  - name: tmp
                    mountPath: "/tmp"
