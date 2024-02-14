# Solution

Add `readonlyRootFilesystem: true` to the `securityContext` of container.
Create an emptyDir volume and mount into the container at /tmp.
