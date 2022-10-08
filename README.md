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

This docker image is intended for Terraform development and CI/CD use and includes the following tools:

- [terraform](https://github.com/hashicorp/terraform)
- [terragrunt](https://github.com/gruntwork-io/terragrunt)
- [terraform-docs](https://github.com/terraform-docs/terraform-docs)
- [tfint](https://github.com/terraform-linters/tflint)
- [tfsec](https://github.com/aquasecurity/tfsec)
- [aws-cli](https://github.com/aws/aws-cli)

### Customization

Tool versions are set to `latest` by default but can be explicitly defined by
overriding the following build parameters:

- TERRAFORM_VERSION=latest
- TERRAGRUNT_VERSION=latest
- TERRAFORM_DOCS_VERSION=latest
- TFLINT_VERSION=latest
- TFSEC_VERSION=latest

### Usage

A Makefile has been include with the following targets:

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
