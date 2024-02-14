# Solution

    apiVersion: audit.k8s.io/v1 # This is required.
    kind: Policy
    omitStages:
      - "RequestReceived"
    rules:
      - level: Metadata
        resources:
        - group: ""
          resources: ["secrets"]

      - level: RequestResponse
        userGroups: ["system:nodes"]

      - level: None
