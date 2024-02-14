# Solution

The service account token is granted non-resource permissions such as:

    kubectl auth can-i --list -n default --as system:serviceaccount:sa-verify:admin

    Resources                                       Non-Resource URLs   Resource Names   Verbs
    selfsubjectreviews.authentication.k8s.io        []                  []               [create]
    selfsubjectaccessreviews.authorization.k8s.io   []                  []               [create]
    selfsubjectrulesreviews.authorization.k8s.io    []                  []               [create]
                                                    [/api/*]            []               [get]
                                                    [/api]              []               [get]
                                                    [/apis/*]           []               [get]
                                                    [/apis]             []               [get]
                                                    [/healthz]          []               [get]
                                                    [/healthz]          []               [get]
                                                    [/livez]            []               [get]
                                                    [/livez]            []               [get]
                                                    [/openapi/*]        []               [get]
                                                    [/openapi]          []               [get]
                                                    [/readyz]           []               [get]
                                                    [/readyz]           []               [get]
                                                    [/version/]         []               [get]
                                                    [/version/]         []               [get]
                                                    [/version]          []               [get]
                                                    [/version]          []               [get]

As a result, you can access the sensitive data such secret even if you don't have explicit
permission on there secrets by executing the following command inside the container:

    curl -k https://kubernetes.default/api/v1/namespaces/<TARGET_NAMESPACE>/secrets -H "Authorization: Bearer $(cat /run/secrets/kubernetes.io/serviceaccount/token)"

To protect the sensitive data, you can disable the mount of service account
token by setting `automountServiceAccountToken` to false in the ServiceAccount
declaration:

    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: admin
    automountServiceAccountToken: false
    ...

Or opt out of automounting at Pod level:

    apiVersion: v1
    kind: Pod
    metadata:
      name: my-pod
    spec:
      serviceAccountName: admin
      automountServiceAccountToken: false

Grant the admin and default service account with permission to `get`
secret in namespace `sa-verify`:

    kubectl -n sa-verify create role secret-access --verb=get --resource=secret
    kubectl -n sa-verify create rolebinding secret-access-binding-default --role=secret-access --service-account sa-verify:default
    kubectl -n sa-verify create rolebinding secret-access-binding-admin --role=secret-access --service-account sa-verify:default

Create a pod with automounted service account token:

    kubectl apply -f box1.yaml

And verify it can issue API call to get secret with the token:

    kubectl -n sa-verify exec -it box1 -- bash
    # curl --cacert /run/secrets/kubernetes.io/serviceaccount/ca.crt https://kubernetes.default/api/v1/namespaces/sa-verify/secrets/database-access -H "Authorization: Bearer $(cat /run/secrets/kubernetes.io/serviceaccount/token)"

You should the API object of the requested secret.

Create a pod without automounted service account token:

    kubectl apply -f box2.yaml

Verify that the token for service account is not mounted:

    kubectl -n sa-verify exec box2 -- ls /run/secrets/kubernetes.io/serviceaccount/token
