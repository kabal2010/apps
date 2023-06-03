#!/bin/bash

# Export required terraform env
export ARM_USE_OIDC="true"
export ARM_OIDC_TOKEN=$(cat $AZURE_FEDERATED_TOKEN_FILE)
export ARM_CLIENT_ID=$AZURE_CLIENT_ID
export ARM_TENANT_ID=$AZURE_TENANT_ID

# Start nginx
nginx &> /dev/null

# Export the latest runner version
version=$(curl --silent "https://api.github.com/repos/actions/runner/releases/latest" | jq -r '.tag_name[1:]')

# Download the latest version
curl -o "actions-runner-linux-x64-${version}.tar.gz" -L "https://github.com/actions/runner/releases/download/v${version}/actions-runner-linux-x64-${version}.tar.gz"

# Extract the downloaded file
tar xvf "actions-runner-linux-x64-${version}.tar.gz"

# Delete the downloded file
rm -f "actions-runner-linux-x64-${version}.tar.gz"

# Get a token for registering the runner
Token=$(curl -s -X POST https://api.github.com/repos/$Repository/actions/runners/registration-token -H "accept: application/vnd.github.everest-preview+json" -H "authorization: token $Token" | jq -r '.token')

# Register the runner
./config.sh --unattended --ephemeral --url "https://github.com/$Repository" --token $Token --name $Name --labels $Labels

# Start the runner
./run.sh

# Sleep for 86400 seconds
sleep 86400
