# Solution

To secure the authentication, edit the `kubernetes-dashboard` deployment
to drop the:

- --enable-skip-login
- --enable-insecure-login

Then change the service `kubernetes-dashboard` to ClusterIP, drop the
`externalTraficPolicy: Cluster` line.

kubernetes-dashboard startup options are documented [here][1]

[1]: https://github.com/kubernetes/dashboard/blob/master/docs/common/arguments.md
