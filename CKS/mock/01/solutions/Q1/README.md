# Solution

Create the RuntimeClass as

    # RuntimeClass is defined in the node.k8s.io API group
    apiVersion: node.k8s.io/v1
    kind: RuntimeClass
    metadata:
      # The name the RuntimeClass will be referenced by.
      # RuntimeClass is a non-namespaced resource.
      name: gvisor 
    # The name of the corresponding CRI configuration
    handler: gvisor

Note the name of the handler is `gvisor` rather than `runsc`.

Change the deployments in `team-purple` to add `runtimeClassName`
attribute to under the `template`(above `containers`):

    kubectl -n team-purple edit deployment deployment1

Save and quit, then the pods will be restarted.
