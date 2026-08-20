#!/bin/bash
set -x

# Replace <PAT> with your actual Azure DevOps Personal Access Token
# IMPORTANT: keep your PAT secret — store it in a pipeline variable and reference it here
PAT=$AZURE_DEVOPS_PAT   # pipeline variable
ORG="dhanushivas12"
PROJECT="voting-app"
REPO="voting-app"

# Construct repo URL with PAT
REPO_URL="https://${PAT}@dev.azure.com/${ORG}/${PROJECT}/_git/${REPO}"

# Clone repo
git clone "$REPO_URL" /tmp/temp_repo
cd /tmp/temp_repo

# Detect default branch automatically
BRANCH=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
git checkout "$BRANCH"

# Update image tag in Kubernetes manifest
sed -i "s|image:.*|image: conregd/$2:$3|g" k8s-specifications/$1-deployment.yaml

# Verify change
grep "image:" k8s-specifications/$1-deployment.yaml

# Configure committer identity (optional, avoids warnings)
git config user.name "Azure DevOps Pipeline"
git config user.email "pipeline@azuredevops.local"

# Commit and push
git add .
git commit -m "Update Kubernetes manifest"
git push origin "$BRANCH"

# Cleanup
rm -rf /tmp/temp_repo
