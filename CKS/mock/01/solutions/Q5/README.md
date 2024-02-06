# Solution

    mkdir -p artifacts/5
    kubectl -n team-5 get secret db -o jsonpath='{.data.user}' | base64 -d > artifacts/5/user
    kubectl -n team-5 get secret db -o jsonpath='{.data.password}' | base64 -d > artifacts/5/password

    kubectl -n team-5 create secret generic db-admin --from-literal=user=xxx --from-literal=password=yyyy

    kubectl -n team-5 run pod db-admin --image=busybox:1.28 -o yaml --dry-run=client > db-admin-pod.yaml
