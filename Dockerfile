FROM registry.access.redhat.com/ubi9-minimal:latest
ENTRYPOINT ["/bin/bash", "-c", "echo Hello to Kaniko from Kubernetes"]
