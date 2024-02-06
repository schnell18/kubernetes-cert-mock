# Solution

Procedure:

- load apparmor profile to worker nodes
- create deployment using annonation
  `container.apparmor.security.beta.kubernetes.io/<container_name>` to
  constraint the container with apparmor profile loaded in previous step
