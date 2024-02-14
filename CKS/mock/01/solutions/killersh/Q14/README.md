# Solution

Find all pod and their hosting node under the target namespace:

    kubectl -n team-yellow get pods -o wide

For each suspect, logon the node to locate PID of containers of the pod:

    crictl pods --name <pod_name>
    crictl ps --pod <pod_id>
    crictl inspect -o go-template --template='{{.info.pid}}' <contaier_id>
    # if jq is installed, you can use jq instead:
    crictl inspect <contaier_id> | jq -r '.info.pid'

Then you use the `strace` to attach to the running process to inspect
active syscalls.

    strace -p <pid>
