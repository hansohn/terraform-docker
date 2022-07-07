ARG ALPINE_VERSION=latest


# builder
FROM alpine:${ALPINE_VERSION} as builder
ARG TERRAFORM_DOCS_VERSION=latest
ARG TERRAFORM_VERSION=latest
ARG TERRAGRUNT_VERSION=latest
ARG TFLINT_VERSION=latest
ARG TFSEC_VERSION=latest
COPY dotfiles/. /root/
ENV CURL='curl -fsSL --netrc-optional'
RUN apk add --update --no-cache \
    bash \
    ca-certificates \
    curl \
    jq \
    unzip

# terraform
RUN /bin/bash -c 'if [[ "${TERRAFORM_VERSION}" == "latest" ]]; then TERRAFORM_VERSION=$(${CURL} "https://api.github.com/repos/hashicorp/terraform/releases/latest" | jq -r .tag_name  | sed -e "s:^v::"); fi \
      && ${CURL} https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
      && unzip terraform.zip \
      && mv terraform /usr/local/bin/ \
      && chmod +x /usr/local/bin/terraform \
      && mkdir -p /root/.terraform.d/plugin-cache \
      && terraform --version'

# terragrunt
RUN /bin/bash -c 'if [[ "${TERRAGRUNT_VERSION}" == "latest" ]]; then TERRAGRUNT_VERSION=$(curl -fsSL "https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest" | jq -r .tag_name); fi \
      && curl -fsSL https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -o /usr/local/bin/terragrunt \
      && chmod +x /usr/local/bin/terragrunt \
      && terragrunt --version'

# terraform-docs
RUN /bin/bash -c 'if [[ "${TERRAFORM_DOCS_VERSION}" == "latest" ]]; then TERRAFORM_DOCS_VERSION=$(${CURL} "https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest" | jq -r .tag_name); fi \
      && ${CURL} https://github.com/terraform-docs/terraform-docs/releases/download/${TERRAFORM_DOCS_VERSION}/terraform-docs-${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz -o terraform-docs.tar.gz \
      && tar -xzf terraform-docs.tar.gz \
      && mv terraform-docs /usr/local/bin/ \
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


# main
FROM alpine:${ALPINE_VERSION} as main
COPY --from=builder /root/.terraform.d/. /root/.terraform.d/
COPY --from=builder /root/.tflint.d/. /root/.tflint.d/
COPY --from=builder /root/.tflint.hcl /root/
COPY --from=builder /usr/local/bin/terra* /usr/local/bin/
COPY --from=builder /usr/local/bin/tf* /usr/local/bin/

ENTRYPOINT []
