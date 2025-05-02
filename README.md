# Osmosis Docker Container

[Osmosis](https://wiki.openstreetmap.org/wiki/Osmosis) is a command line Java application for processing OpenStreetMap data. The tool consists of pluggable components that can be chained to perform a larger operation.

This repo contains a workflow to automatically create a docker image with the latest osmosis release and publish it to the GitHub Container Registry and the image registry on Docker Hub. You can add other container registries as needed.

Workflow runs on schedule weekly on Sunday at midnight.

## Repository Setup Instructions

To use this workflow, you need to set up the following repository variables and secrets:

### Repository Variables

1. **`JRE_BASE_IMAGE`**
   - Current value: `eclipse-temurin:24.0.1_9-jdk-alpine-3.21`
   - Description: The base JRE image used for building the Osmosis Docker image
   - How to set: `gh variable set JRE_BASE_IMAGE -b "eclipse-temurin:24.0.1_9-jdk-alpine-3.21" --repo owner/repo-name`

2. **`OSMOSIS_VERSION`**
   - Initial value: `0.49.2` (or the current version when setting up)
   - Description: The version of Osmosis to build
   - Note: This will be automatically updated by the workflow when a new version is detected
   - How to set: `gh variable set OSMOSIS_VERSION -b "0.49.2" --repo owner/repo-name`

### Registries Credentials

For each registry you want to publish to, you need to add a corresponding secret:

1. **`ghcr.io`**
   - GitHub Container Registry credentials
   - There is used your standard `github.actor` and `secrets.GITHUB_TOKENN` so you don't need to do anything

2. **`docker.io`**
   - Docker Hub credentials
   - This should be your Docker Hub credentials: login and access token
   - How to set: `gh secret set DOCKERHUB_LOGIN -b "your-login-here" --repo owner/repo-name`
   - How to set: `gh secret set DOCKERHUB_TOKEN -b "your-token-here" --repo owner/repo-name`

3. **`quay.io`**
   - Quay.io registry credentials
   - This should be your Quay.io credentials
   - How to set: `gh secret set QUAY_LOGIN -b "your-login-here" --repo owner/repo-name`
   - How to set: `gh secret set QUAY_TOKEN -b "your-token-here" --repo owner/repo-name`

More details you may find in GitHub Marketplace <https://github.com/marketplace/actions/docker-login>

### Setting Up Variables and Secrets using GitHub Web Interface

1. Go to your GitHub repository
2. Navigate to "Settings" > "Secrets and variables" > "Actions"
3. Add the variables and secrets listed above
4. Make sure the GitHub Actions workflow has permissions to read/write variables

### Permissions

The workflow requires the following permissions to work properly:

1. **Read/write repository variables** (to update OSMOSIS_VERSION)
2. **Read repository secrets** (to access registry credentials)

To enable these permissions, go to "Settings" > "Actions" > "General" and make sure the "Read and write permissions" option is selected under "Workflow permissions".

### Notes

- If a registry secret is not set, the workflow will skip publishing to that registry
- The workflow runs weekly to check for new Osmosis versions
- You can also trigger the workflow manually via the "workflow_dispatch" event

## Licence

Osmosis is distributed under the terms of the Public Domain Licence.

Code from this repo is provided under the terms of the MIT licence.
