<div align="center">
  <h3>terraform-docker</h3>
  <p>Terraform Docker image</p>
  <p>
    <!-- Build Status -->
    <a href="https://actions-badge.atrox.dev/hansohn/terraform-docker/goto?ref=main">
      <img src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fhansohn%2Fterraform-docker%2Fbadge%3Fref%3Dmain&style=for-the-badge">
    </a>
    <!-- Github Tag -->
    <a href="https://gitHub.com/hansohn/terraform-docker/tags/">
      <img src="https://img.shields.io/github/tag/hansohn/terraform-docker.svg?style=for-the-badge">
    </a>
    <!-- Docker Pulls -->
    <a href="https://hub.docker.com/r/hansohn/terraform">
      <img src="https://img.shields.io/docker/pulls/hansohn/terraform.svg?style=for-the-badge">
    </a>
    <!-- Docker Image Size -->
    <a href="https://hub.docker.com/r/hansohn/terraform">
      <img src="https://img.shields.io/docker/image-size/hansohn/terraform/latest.svg?style=for-the-badge">
    </a>
    <!-- License -->
    <a href="https://github.com/hansohn/terraform-docker/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/hansohn/terraform-docker.svg?style=for-the-badge">
    </a>
  </p>
</div>

## Table of Contents
- [Description](#description)
- [What's Included](#whats-included)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Tags](#tags)
- [Platform Support](#platform-support)
- [Usage](#usage)
- [Examples](#examples)
- [Customization](#customization)
- [Build & Refresh Schedule](#build--refresh-schedule)
- [Security](#security)
- [Contributing](#contributing)
- [License](#license)

## Description

Welcome to my Terraform Docker repo. I've built this image with Terraform
development and CI/CD in mind. The image contains various popular utilities often
used in Terraform development. Utility versions are pinned in the Dockerfile and
kept current through dependency-update PRs; the image is rebuilt and published to
Docker Hub every Monday, Wednesday, and Friday to pick up base-image security
patches.

## What's Included

The following utilities are included in this image:

- [terraform](https://github.com/hashicorp/terraform): Software tool that enables you to safely and predictably create, change, and improve infrastructure
- [terragrunt](https://github.com/gruntwork-io/terragrunt): A thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules
- [terraform-docs](https://github.com/terraform-docs/terraform-docs): Generate documentation from Terraform modules in various output formats
- [tflint](https://github.com/terraform-linters/tflint): A Pluggable Terraform Linter
- [trivy](https://github.com/aquasecurity/trivy): Security scanner for your Terraform code

## Prerequisites

- Docker 20.10 or later
- Docker Buildx (for multi-platform builds)
- `curl` and `jq` (used by the Makefile to resolve the latest Terraform version)

## Quick Start

```bash
# Pull and run the latest version
docker pull hansohn/terraform:latest
docker run -it --rm hansohn/terraform:latest terraform version

# Run with your Terraform code mounted
docker run -it --rm -v $(pwd):/workspace -w /workspace hansohn/terraform:latest terraform plan
```

## Tags

Docker images are tagged based on the pinned version of Terraform they include.
A single Terraform version is published at a time (the version pinned in the
Dockerfile), and it receives the full set of tags below:

```
# tag formats (for a pinned Terraform version of e.g. 1.15.7)
hansohn/terraform:latest        the currently published release
hansohn/terraform:1             the 1.x.x line
hansohn/terraform:1.15          the 1.15.x line
hansohn/terraform:1.15.7        the exact version
```

For reproducibility, pin by digest (`hansohn/terraform@sha256:...`); every image
ships provenance attestations and an SBOM bound to that digest.

## Platform Support

This image supports multiple platforms:
- `linux/amd64` (x86_64)
- `linux/arm64` (ARM64/Apple Silicon)

Docker will automatically pull the correct architecture for your system.

## Usage

Published images can be run using the following syntax:

```bash
# run latest published version
docker run -it --rm hansohn/terraform:latest /bin/bash
```

Local images can be built and run using the following syntax:

```bash
# build and run local image
make
```

Additionally, a Makefile has been included in this repo to assist with common
development-related functions. I've included the following make targets for
convenience:

```
Available targets:

  clean                               Clean everything
  dev                                  Initialize development environment
  docker/build                        Docker build image
  docker/check                        Check if Docker daemon is running
  docker/clean                        Docker clean build images
  docker/lint                         Lint Dockerfile
  docker/push                         Docker push image
  docker/run                          Docker run image
  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
```

## Examples

### Initialize Terraform

```bash
docker run -it --rm -v $(pwd):/workspace -w /workspace \
  hansohn/terraform:latest terraform init
```

### Plan with Terragrunt

```bash
docker run -it --rm -v $(pwd):/workspace -w /workspace \
  hansohn/terraform:latest terragrunt plan
```

### Generate Documentation

```bash
docker run -it --rm -v $(pwd):/docs -w /docs \
  hansohn/terraform:latest terraform-docs markdown . > README.md
```

### Run Security Scan

```bash
docker run -it --rm -v $(pwd):/src -w /src \
  hansohn/terraform:latest trivy config .
```

### Run Linter

```bash
docker run -it --rm -v $(pwd):/src -w /src \
  hansohn/terraform:latest tflint
```

## Customization

### Utilities

I publish images with the latest versions of the included utilities. Alternatively,
you can build a customized image and pin any of these utilities to a version that
matches your specific needs. Versions can be pinned by defining any of the following
environment variables with the desired version.

- TERRAFORM_VERSION
- TERRAGRUNT_VERSION
- TERRAFORM_DOCS_VERSION
- TFLINT_VERSION
- TRIVY_VERSION

```bash
# example
TERRAFORM_VERSION=0.15.5 make docker/build

# example with logs piped to console
DOCKER_BUILDKIT=0 TERRAFORM_VERSION=0.15.5 make docker/build
```

## Build & Refresh Schedule

Images are automatically:
- **Built** when new tags are pushed
- **Refreshed** every Monday, Wednesday, and Friday at 7am UTC to include latest security patches

This ensures all images stay up-to-date with the latest base image security updates.

## Security

- Images include provenance attestations and SBOM (Software Bill of Materials)
- All images are scanned during build
- Security vulnerabilities? See our [Security Policy](.github/SECURITY.md)

## Contributing

Contributions are welcome! Please see our [Contributing Guide](.github/CONTRIBUTING.md) for details.

- Report bugs via [Issues](https://github.com/hansohn/terraform-docker/issues)
- Request features via [Feature Requests](https://github.com/hansohn/terraform-docker/issues/new?template=feature-request.yml)
- Submit PRs following our [PR Template](.github/PULL_REQUEST_TEMPLATE.md)

## License

This project is licensed under the terms specified in [LICENSE](LICENSE).
