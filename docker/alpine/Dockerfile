ARG ALPINE_VERSION=latest


# builder
FROM alpine:${ALPINE_VERSION} AS builder
ARG TERRAFORM_DOCS_VERSION=latest
ARG TERRAFORM_VERSION=latest
ARG TERRAGRUNT_VERSION=latest
ARG TFGET_VERSION=latest
ARG TFLINT_VERSION=latest
ARG TFSEC_VERSION=latest
COPY dotfiles/. /root/
ENV CURL='curl -fsSL --netrc-optional'
ENV CACHE_DIR='/var/cache/github-api'
RUN apk add --update --no-cache \
  bash \
  ca-certificates \
  curl \
  jq \
  unzip \
  && mkdir -p ${CACHE_DIR}

# terraform
RUN --mount=type=cache,target=/var/cache/github-api \
  --mount=type=cache,target=/var/cache/downloads \
  /bin/bash -c 'set -e; \
  CACHE_FILE="${CACHE_DIR}/tfget-version"; \
  if [[ "${TFGET_VERSION}" == "latest" ]]; then \
  if [[ -f "${CACHE_FILE}" ]] && [[ $(($(date +%s) - $(stat -c %Y "${CACHE_FILE}" 2>/dev/null || echo 0))) -lt 3600 ]]; then \
  TFGET_VERSION=$(cat "${CACHE_FILE}"); \
  else \
  TFGET_VERSION=$(${CURL} "https://api.github.com/repos/hansohn/tfget/releases/latest" | jq -r .tag_name | sed -e "s:^v::"); \
  echo "${TFGET_VERSION}" > "${CACHE_FILE}"; \
  fi; \
  fi; \
  if [[ ! -f "/var/cache/downloads/tfget-${TFGET_VERSION}.tar.gz" ]]; then \
  ${CURL} https://github.com/hansohn/tfget/releases/download/${TFGET_VERSION}/tfget-${TFGET_VERSION}.tar.gz -o /var/cache/downloads/tfget-${TFGET_VERSION}.tar.gz; \
  fi; \
  tar -xzf /var/cache/downloads/tfget-${TFGET_VERSION}.tar.gz -C /tmp \
  && mv /tmp/tfget /usr/local/bin/ \
  && chmod +x /usr/local/bin/tfget \
  && tfget ${TERRAFORM_VERSION} \
  && terraform --version'

# terragrunt
RUN --mount=type=cache,target=/var/cache/github-api \
  --mount=type=cache,target=/var/cache/downloads \
  /bin/bash -c 'set -e; \
  CACHE_FILE="${CACHE_DIR}/terragrunt-version"; \
  if [[ "${TERRAGRUNT_VERSION}" == "latest" ]]; then \
  if [[ -f "${CACHE_FILE}" ]] && [[ $(($(date +%s) - $(stat -c %Y "${CACHE_FILE}" 2>/dev/null || echo 0))) -lt 3600 ]]; then \
  TERRAGRUNT_VERSION=$(cat "${CACHE_FILE}"); \
  else \
  TERRAGRUNT_VERSION=$(${CURL} "https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest" | jq -r .tag_name); \
  echo "${TERRAGRUNT_VERSION}" > "${CACHE_FILE}"; \
  fi; \
  fi; \
  if [[ ! -f "/var/cache/downloads/terragrunt-${TERRAGRUNT_VERSION}" ]]; then \
  ${CURL} https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -o /var/cache/downloads/terragrunt-${TERRAGRUNT_VERSION}; \
  fi; \
  cp /var/cache/downloads/terragrunt-${TERRAGRUNT_VERSION} /usr/local/bin/terragrunt \
  && chmod +x /usr/local/bin/terragrunt \
  && terragrunt --version'

# terraform-docs
RUN --mount=type=cache,target=/var/cache/github-api \
  --mount=type=cache,target=/var/cache/downloads \
  /bin/bash -c 'set -e; \
  CACHE_FILE="${CACHE_DIR}/terraform-docs-version"; \
  if [[ "${TERRAFORM_DOCS_VERSION}" == "latest" ]]; then \
  if [[ -f "${CACHE_FILE}" ]] && [[ $(($(date +%s) - $(stat -c %Y "${CACHE_FILE}" 2>/dev/null || echo 0))) -lt 3600 ]]; then \
  TERRAFORM_DOCS_VERSION=$(cat "${CACHE_FILE}"); \
  else \
  TERRAFORM_DOCS_VERSION=$(${CURL} "https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest" | jq -r .tag_name); \
  echo "${TERRAFORM_DOCS_VERSION}" > "${CACHE_FILE}"; \
  fi; \
  fi; \
  if [[ ! -f "/var/cache/downloads/terraform-docs-${TERRAFORM_DOCS_VERSION}.tar.gz" ]]; then \
  ${CURL} https://github.com/terraform-docs/terraform-docs/releases/download/${TERRAFORM_DOCS_VERSION}/terraform-docs-${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz -o /var/cache/downloads/terraform-docs-${TERRAFORM_DOCS_VERSION}.tar.gz; \
  fi; \
  tar -xzf /var/cache/downloads/terraform-docs-${TERRAFORM_DOCS_VERSION}.tar.gz -C /tmp \
  && mv /tmp/terraform-docs /usr/local/bin/ \
  && chown root:root /usr/local/bin/terraform-docs \
  && chmod +x /usr/local/bin/terraform-docs \
  && terraform-docs --version'

# tflint
RUN --mount=type=cache,target=/var/cache/github-api \
  --mount=type=cache,target=/var/cache/downloads \
  /bin/bash -c 'set -e; \
  CACHE_FILE="${CACHE_DIR}/tflint-version"; \
  if [[ "${TFLINT_VERSION}" == "latest" ]]; then \
  if [[ -f "${CACHE_FILE}" ]] && [[ $(($(date +%s) - $(stat -c %Y "${CACHE_FILE}" 2>/dev/null || echo 0))) -lt 3600 ]]; then \
  TFLINT_VERSION=$(cat "${CACHE_FILE}"); \
  else \
  TFLINT_VERSION=$(${CURL} "https://api.github.com/repos/terraform-linters/tflint/releases/latest" | jq -r .tag_name); \
  echo "${TFLINT_VERSION}" > "${CACHE_FILE}"; \
  fi; \
  fi; \
  if [[ ! -f "/var/cache/downloads/tflint-${TFLINT_VERSION}.zip" ]]; then \
  ${CURL} https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip -o /var/cache/downloads/tflint-${TFLINT_VERSION}.zip; \
  fi; \
  unzip -o /var/cache/downloads/tflint-${TFLINT_VERSION}.zip -d /tmp \
  && mv /tmp/tflint /usr/local/bin/ \
  && chmod +x /usr/local/bin/tflint \
  && tflint --version \
  && tflint --init'

# tfsec
RUN --mount=type=cache,target=/var/cache/github-api \
  --mount=type=cache,target=/var/cache/downloads \
  /bin/bash -c 'set -e; \
  CACHE_FILE="${CACHE_DIR}/tfsec-version"; \
  if [[ "${TFSEC_VERSION}" == "latest" ]]; then \
  if [[ -f "${CACHE_FILE}" ]] && [[ $(($(date +%s) - $(stat -c %Y "${CACHE_FILE}" 2>/dev/null || echo 0))) -lt 3600 ]]; then \
  TFSEC_VERSION=$(cat "${CACHE_FILE}"); \
  else \
  TFSEC_VERSION=$(${CURL} "https://api.github.com/repos/aquasecurity/tfsec/releases/latest" | jq -r .tag_name); \
  echo "${TFSEC_VERSION}" > "${CACHE_FILE}"; \
  fi; \
  fi; \
  if [[ ! -f "/var/cache/downloads/tfsec-${TFSEC_VERSION}" ]]; then \
  ${CURL} https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64 -o /var/cache/downloads/tfsec-${TFSEC_VERSION}; \
  fi; \
  cp /var/cache/downloads/tfsec-${TFSEC_VERSION} /usr/local/bin/tfsec \
  && chmod +x /usr/local/bin/tfsec \
  && tfsec --version'


# main
FROM alpine:${ALPINE_VERSION} AS main
RUN apk add --update --no-cache \
  bash \
  ca-certificates \
  curl \
  jq \
  unzip \
  vim
COPY --from=builder /root/.terraform.d/. /root/.terraform.d/
COPY --from=builder /root/.terraformrc /root/.terraformrc
COPY --from=builder /usr/local/bin/ /usr/local/bin/
RUN /bin/bash -c 'terraform --version'

ENTRYPOINT []
