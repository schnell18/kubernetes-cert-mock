# Solution

    k -n rbac-1 get rolebindings
    k -n rbac-1 describe rolebindings dev 
    k -n rbac-1 edit role dev
    k -n rbac-2 create role dev --verb=get --verb=list --resource=configmap 
    k -n rbac-2 create rolebinding dev --role=dev --serviceaccount=rbac-1:dev
