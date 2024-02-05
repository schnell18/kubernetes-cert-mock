# Solution

copy similar rule from `/etc/falco/falco_rule.yaml`.
mapping output fields using `falco --list=syscall | less`, search by keywords.

container.image.repository
container.name
container.id
k8s.ns.name
k8s.pod.name

set the file output
