ARG DEBIAN_VERSION=stable-slim


# builder
FROM debian:${DEBIAN_VERSION} as builder
ARG TFSWITCH_VERSION=latest
ARG TFSWITCH_TERRAFORM_VERSIONS=
ARG TFENV_VERSION=latest
ARG TFENV_TERRAFORM_VERSIONS=
ARG TERRAFORM_DOCS_VERSION=latest
ARG TERRAFORM_VERSION=latest
ARG TERRAGRUNT_VERSION=latest
ARG TFLINT_VERSION=latest
ARG TFSEC_VERSION=latest
COPY dotfiles/. /root/
ENV CURL='curl -fsSL --netrc-optional'
RUN apt-get update && apt-get install --no-install-recommends -y \
      bash \
      ca-certificates \
      curl \
      jq \
      libc6 \
      unzip

# tfenv
RUN /bin/bash -c 'if [[ "${TFENV_VERSION}" == "latest" ]]; then TFENV_VERSION=$(${CURL} "https://api.github.com/repos/tfutils/tfenv/releases/latest" | jq -r .tag_name  | sed -e "s:^v::"); fi \
      && ${CURL} https://github.com/tfutils/tfenv/archive/refs/tags/v${TFENV_VERSION}.tar.gz -o tfenv.tar.gz \
      && tar -xzf tfenv.tar.gz \
      && mv tfenv-${TFENV_VERSION} $HOME/.tfenv \
      && chmod +x $HOME/.tfenv/bin/tfenv \
      && $HOME/.tfenv/bin/tfenv --version'

# tfswitch
RUN /bin/bash -c 'if [[ "${TFSWITCH_VERSION}" == "latest" ]]; then TFSWITCH_VERSION=$(${CURL} "https://api.github.com/repos/warrensbox/terraform-switcher/releases/latest" | jq -r .tag_name  | sed -e "s:^v::"); fi \
      && ${CURL} https://github.com/warrensbox/terraform-switcher/releases/download/${TFSWITCH_VERSION}/terraform-switcher_${TFSWITCH_VERSION}_linux_amd64.tar.gz -o terraform-switcher.tar.gz \
      && tar -xzf terraform-switcher.tar.gz \
      && mv tfswitch /usr/local/bin/ \
      && chown root:root /usr/local/bin/tfswitch \
      && chmod +x /usr/local/bin/tfswitch \
      && tfswitch --version'

# terraform
RUN /bin/bash -c 'if [[ "${TERRAFORM_VERSION}" == "latest" ]]; then TERRAFORM_VERSION=$(${CURL} "https://api.github.com/repos/hashicorp/terraform/releases/latest" | jq -r .tag_name  | sed -e "s:^v::"); fi \
      && ${CURL} https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
      && unzip terraform.zip \
      && mv terraform /usr/local/bin/ \
      && chmod +x /usr/local/bin/terraform \
      && mkdir -p /root/.terraform.d/plugin-cache \
      && terraform --version'

# terragrunt
RUN /bin/bash -c 'if [[ "${TERRAGRUNT_VERSION}" == "latest" ]]; then TERRAGRUNT_VERSION=$(${CURL} "https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest" | jq -r .tag_name); fi \
      && ${CURL} https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -o /usr/local/bin/terragrunt \
      && chmod +x /usr/local/bin/terragrunt \
      && terragrunt --version'

# terraform-docs
RUN /bin/bash -c 'if [[ "${TERRAFORM_DOCS_VERSION}" == "latest" ]]; then TERRAFORM_DOCS_VERSION=$(${CURL} "https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest" | jq -r .tag_name); fi \
      && ${CURL} https://github.com/terraform-docs/terraform-docs/releases/download/${TERRAFORM_DOCS_VERSION}/terraform-docs-${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz -o terraform-docs.tar.gz \
      && tar -xzf terraform-docs.tar.gz \
      && mv terraform-docs /usr/local/bin/ \
      && chown root:root /usr/local/bin/terraform-docs \
      && chmod +x /usr/local/bin/terraform-docs \
      && terraform-docs --version'

# tflint
RUN /bin/bash -c 'if [[ "${TFLINT_VERSION}" == "latest" ]]; then TFLINT_VERSION=$(${CURL} "https://api.github.com/repos/terraform-linters/tflint/releases/latest" | jq -r .tag_name); fi \
      && ${CURL} https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip -o tflint.zip \
      && unzip tflint.zip \
      && mv tflint /usr/local/bin/ \
      && chmod +x /usr/local/bin/tflint \
      && TFLINT_AWS_VERSION=$(${CURL} "https://api.github.com/repos/terraform-linters/tflint-ruleset-aws/releases/latest" | jq -r .tag_name | sed -e "s:^v::") \
      && sed -ie "s:TFLINT_AWS_VERSION:$TFLINT_AWS_VERSION:" /root/.tflint.hcl \
      && GITHUB_TOKEN=${GITHUB_TOKEN:-$(awk "'"c&&!--c;/github.com/{c=2}"'" /root/.netrc | awk "'"{print $2;exit}"'")} \
      && tflint --version \
      && tflint --init'

# tfsec
RUN bin/bash -c 'if [[ "${TFSEC_VERSION}" == "latest" ]]; then TFSEC_VERSION=$(${CURL} "https://api.github.com/repos/aquasecurity/tfsec/releases/latest" | jq -r .tag_name); fi \
      && ${CURL} https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64 -o /usr/local/bin/tfsec \
      && chmod +x /usr/local/bin/tfsec \
      && tfsec --version'

# awscli
ADD https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip /tmp/awscliv2.zip
RUN /bin/bash -c 'cd /tmp \
      && unzip awscliv2.zip \
      && ./aws/install --bin-dir /aws-cli-bin/ \
      && /aws-cli-bin/aws --version'


# main
FROM debian:${DEBIAN_VERSION} as main
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends -y \
      bash \
      ca-certificates \
      curl \
      git \
      groff \
      jq \
      unzip \
      vim \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*
COPY --from=builder /aws-cli-bin/ /usr/local/bin/
COPY --from=builder /root/.terraform.d/. /root/.terraform.d/
COPY --from=builder /root/.tfenv/. /root/.tfenv/
COPY --from=builder /root/.tflint.d/. /root/.tflint.d/
COPY --from=builder /root/.tflint.hcl /root/
COPY --from=builder /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=builder /usr/local/bin/terra* /usr/local/bin/
COPY --from=builder /usr/local/bin/tf* /usr/local/bin/
RUN echo "complete -C /usr/local/bin/aws_completer aws" >> /root/.bashrc
RUN echo "export PATH=\"$PATH:$HOME/.tfenv/bin\"" >> /root/.bashrc

ENTRYPOINT []
