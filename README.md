<div align="center">
  <h3>terraform-docker</h3>
  <p>Terraform Docker images</p>
  <p>
    <!-- Build Status -->
    <a href="https://actions-badge.atrox.dev/hansohn/terraform-docker/goto?ref=main">
      <img src="https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fhansohn%2Fterraform-docker%2Fbadge%3Fref%3Dmain&style=for-the-badge">
    </a>
    <!-- Github Tag -->
    <a href="https://gitHub.com/hansohn/terraform-docker/tags/">
      <img src="https://img.shields.io/github/tag/hansohn/terraform-docker.svg?style=for-the-badge">
    </a>
    <!-- License -->
    <a href="https://github.com/hansohn/terraform-docker/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/hansohn/terraform-docker.svg?style=for-the-badge">
    </a>
    <!-- LinkedIn -->
    <a href="https://linkedin.com/in/ryanhansohn">
      <img src="https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555">
    </a>
  </p>
</div>

### Description

Welcome to my Terraform docker repo. I've built this image with Terraform
development and CI/CD in mind. The image contains various popular utilities often
used in Terraform development. By default this image targets the latest versions of
these utilities and are built and published to Docker Hub every Monday, Wednesday,
Friday.

### Whats Included

The following utilities are included in this image:

- [terraform](https://github.com/hashicorp/terraform): Software tool that enables you to safely and predictably create, change, and improve infrastructure
- [terragrunt](https://github.com/gruntwork-io/terragrunt): A thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules
- [terraform-docs](https://github.com/terraform-docs/terraform-docs): Generate documentation from Terraform modules in various output formats
- [tfint](https://github.com/terraform-linters/tflint): A Pluggable Terraform Linter
- [tfsec](https://github.com/aquasecurity/tfsec): Security scanner for your Terraform code
- [aws-cli](https://github.com/aws/aws-cli): Universal Command Line Interface for Amazon Web Services

### Tags

I've written a Terraform release metadata tool called [tfrelease](https://github.com/hansohn/tfrelease)
that generates tags for my image releases. The tags follow the following naming
convention.

```
# tag formats
hansohn/terraform:latest        latest release of Terraform
hansohn/terraform:1             latest 1.x.x version release of Terraform
hansohn/terraform:1.2           latest 1.2.x version release of Terraform
hansohn/terraform:1.2.3         1.2.3 version of Terraform
```

### :open_book: Usage

Published images can be ran using the following syntax

```
# run latest publsihed version
$ docker run -it --rm hansohn/terraform:latest /bin/bash
```

Local images can be built and run using the following syntax

```
# build and run local image
make docker
```

Additionally a Makefile has been included in this repo to assist with common development
related functions. I've included the following make targets for convenience:

```
Available targets:

  clean                               Clean everything
  clean/docker                        Clean docker build images
  docker                              Docker lint, build and run image
  docker/build                        Docker build image
  docker/lint                         Lint Dockerfile
  docker/push                         Docker push image
  docker/run                          Docker run image
  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
```

### Customization

#### Utilities

I publish images with the latest versions of the included utilities. Alternatively
you can build a customized image and pin any of these utilities to a version that
matches your specific needs. Versions can be pinned by defining any of the following
environment variables with the desired version.

- TERRAFORM_VERSION
- TERRAGRUNT_VERSION
- TERRAFORM_DOCS_VERSION
- TFLINT_VERSION
- TFSEC_VERSION

```bash
# example
$ TERRAFORM_VERSION=0.15.5 make docker/build

# example with logs pipped to console
$ DOCKER_BUILDKIT=0 TERRAFORM_VERSION=0.15.5 make docker/build
```

#### Distros

Currently I only build and publish Debian images to Docker Hub. That being said
I have also included Dockerfile configurations for both Alpine and Ubuntu
distributions. The `DOCKER_BUILD_PATH` environment variable can be used to target
either of these alternative distro builds.

```
# example
$ DOCKER_BUILD_PATH=ubuntu make docker
```
