ARG ALPINE_VERSION=latest
ARG TERRAFORM_VERSION=latest

# terraform-docs
FROM alpine:${ALPINE_VERSION} as terraform-docs
ARG TERRAFORM_DOCS_VERSION=v0.16.0
RUN apk add --update --no-cache \
      bash
ADD https://github.com/terraform-docs/terraform-docs/releases/download/${TERRAFORM_DOCS_VERSION}/terraform-docs-${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz terraform-docs.tar.gz
RUN /bin/bash -c 'tar -xzf terraform-docs.tar.gz && \
    mv terraform-docs /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform-docs && \
    terraform-docs --version'

# tflint
FROM alpine:${ALPINE_VERSION} as tflint
ARG TFLINT_VERSION=v0.37.0
RUN apt-get update && apt-get install -y \
      bash \
      ca-certificates \
      curl \
      jq \
      unzip
COPY .tflint.hcl /root/
ADD https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip tflint.zip
RUN /bin/bash -c 'unzip tflint.zip && \
      mv tflint /usr/local/bin/ && \
      chmod +x /usr/local/bin/tflint && \
      TFLINT_AWS_VERSION=$(curl -s "https://api.github.com/repos/terraform-linters/tflint-ruleset-aws/releases/latest" | jq -r .tag_name | sed -e "s:^v::") && \
      sed -ie "s:TFLINT_AWS_VERSION:$TFLINT_AWS_VERSION:" /root/.tflint.hcl && \
      tflint --version && \
      tflint --init'

# tfsec
FROM alpine:${ALPINE_VERSION} as tfsec
ARG TFSEC_VERSION=v1.26.0
RUN apk add --update --no-cache \
      bash
ADD https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64 /usr/local/bin/tfsec
RUN /bin/bash -c 'chmod +x /usr/local/bin/tfsec && \
      tfsec --version'

# terragrunt
FROM hashicorp/terraform:${TERRAFORM_VERSION}
ARG TERRAGRUNT_VERSION=v0.38.0
RUN apk add --update --no-cache \
      bash \
      curl \
      git \
      openssh \
      vim
COPY --from=terraform-docs /usr/local/bin/terraform-docs /usr/local/bin/
COPY --from=tflint /usr/local/bin/tflint /usr/local/bin/
COPY --from=tflint /root/.tflint.hcl /root/
COPY --from=tfsec /usr/local/bin/tfsec /usr/local/bin/
COPY .terraformrc /root/.terraform.d/
ADD https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 /usr/local/bin/terragrunt
RUN /bin/bash -c 'chmod +x /usr/local/bin/terragrunt && \
      terragrunt --version && \
      mkdir -p /root/.terraform.d/plugin-cache && \
      terraform version && \
      tflint --init'

ENTRYPOINT []
