ARG UBUNTU_VERSION=latest

# terragrunt
FROM ubuntu:${UBUNTU_VERSION} as terragrunt
ARG TERRAGRUNT_VERSION=v0.38.0
ADD https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 /usr/local/bin/terragrunt
RUN /bin/bash -c 'chmod +x /usr/local/bin/terragrunt && \
      terragrunt --version'

# terraform-docs
FROM ubuntu:${UBUNTU_VERSION} as terraform-docs
ARG TERRAFORM_DOCS_VERSION=v0.16.0
RUN apt-get update && apt-get install -y \
      bash
ADD https://github.com/terraform-docs/terraform-docs/releases/download/${TERRAFORM_DOCS_VERSION}/terraform-docs-${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz terraform-docs.tar.gz
RUN /bin/bash -c 'tar -xzf terraform-docs.tar.gz && \
    mv terraform-docs /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform-docs && \
    terraform-docs --version'

# tflint
FROM ubuntu:${UBUNTU_VERSION} as tflint
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
      AWSVERSION=$(curl -s "https://api.github.com/repos/terraform-linters/tflint-ruleset-aws/releases/latest" | jq -r .tag_name | sed -e "s:^v::") && \
      sed -ie "s:AWSVERSION:$AWSVERSION:" /root/.tflint.hcl && \
      tflint --version && \
      tflint --init'

# tfsec
FROM ubuntu:${UBUNTU_VERSION} as tfsec
ARG TFSEC_VERSION=v1.26.0
ADD https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64 /usr/local/bin/tfsec
RUN bin/bash -c 'chmod +x /usr/local/bin/tfsec && \
      tfsec --version'

# awscli
FROM ubuntu:${UBUNTU_VERSION} as awscli
RUN apt-get update && apt-get install -y \
      bash \
      libc6 \
      unzip
ADD https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip /tmp/awscliv2.zip
RUN /bin/bash -c 'cd /tmp && \
      unzip awscliv2.zip && \
      ./aws/install --bin-dir /aws-cli-bin/ && \
      /aws-cli-bin/aws --version'

# terraform
FROM ubuntu:${UBUNTU_VERSION}
ARG TERRAFORM_VERSION=1.2.3
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
      bash \
      ca-certificates \
      curl \
      git \
      gnupg2 \
      groff \
      less \
      lsb-core \
      openssl \
      software-properties-common \
      vim
COPY --from=terragrunt /usr/local/bin/terragrunt /usr/local/bin/
COPY --from=terraform-docs /usr/local/bin/terraform-docs /usr/local/bin/
COPY --from=tflint /usr/local/bin/tflint /usr/local/bin/
COPY --from=tflint /root/.tflint.hcl /root/
COPY --from=tfsec /usr/local/bin/tfsec /usr/local/bin/
COPY --from=awscli /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=awscli /aws-cli-bin/ /usr/local/bin/
COPY .terraformrc /root/.terraform.d/
RUN /bin/bash -c 'curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
  apt-get update && \
  apt-get install -y terraform=${TERRAFORM_VERSION} && \
  mkdir -p /root/.terraform.d/plugin-cache && \
  terraform version && \
  tflint --init && \
  echo "complete -C /usr/local/bin/aws_completer aws" >> /root/.bashrc'

ENTRYPOINT []
