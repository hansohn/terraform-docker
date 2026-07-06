ARG DEBIAN_VERSION=bookworm-slim


# builder
FROM debian:${DEBIAN_VERSION} AS builder
ARG DEBIAN_FRONTEND=noninteractive
ARG BUILDARCH
ARG TARGETARCH
# renovate: datasource=github-releases depName=hashicorp/terraform extractVersion=^v(?<version>.+)$
ARG TERRAFORM_VERSION=1.15.7
# renovate: datasource=github-releases depName=gruntwork-io/terragrunt
ARG TERRAGRUNT_VERSION=v1.1.0
# renovate: datasource=github-releases depName=terraform-docs/terraform-docs
ARG TERRAFORM_DOCS_VERSION=v0.24.0
# renovate: datasource=github-releases depName=terraform-linters/tflint
ARG TFLINT_VERSION=v0.63.1
# renovate: datasource=github-releases depName=aquasecurity/trivy extractVersion=^v(?<version>.+)$
ARG TRIVY_VERSION=0.72.0
ENV CURL='curl -fsSL'
ENV CACHE_DIR='/var/cache/github-api'
# TARGETARCH/BUILDARCH are only populated by BuildKit; fail fast on the legacy
# builder rather than constructing malformed download URLs below.
RUN if [ -z "${TARGETARCH}" ] || [ -z "${BUILDARCH}" ]; then \
  echo "TARGETARCH/BUILDARCH not set; build with BuildKit (docker buildx build)" >&2; exit 1; \
  fi
RUN apt-get update && apt-get install --no-install-recommends -y \
  bash \
  ca-certificates \
  curl \
  jq \
  unzip \
  && mkdir -p ${CACHE_DIR}
COPY scripts/resolve-version.sh /opt/build/resolve-version

# terraform
RUN --mount=type=cache,target=/var/cache/github-api \
  --mount=type=cache,target=/var/cache/downloads \
  /bin/bash -c 'set -e; \
  TERRAFORM_VERSION=$(/opt/build/resolve-version terraform "${TERRAFORM_VERSION}"); \
  ARCHIVE="terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip"; \
  if [[ ! -f "/var/cache/downloads/terraform-${TERRAFORM_VERSION}-${TARGETARCH}.zip" ]]; then \
  ${CURL} https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${ARCHIVE} -o /var/cache/downloads/terraform-${TERRAFORM_VERSION}-${TARGETARCH}.zip; \
  fi; \
  if [[ ! -f "/var/cache/downloads/terraform-${TERRAFORM_VERSION}_SHA256SUMS" ]]; then \
  ${CURL} https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS -o /var/cache/downloads/terraform-${TERRAFORM_VERSION}_SHA256SUMS; \
  fi; \
  EXPECTED_SHA=$(grep " ${ARCHIVE}\$" /var/cache/downloads/terraform-${TERRAFORM_VERSION}_SHA256SUMS | cut -d" " -f1); \
  ACTUAL_SHA=$(sha256sum /var/cache/downloads/terraform-${TERRAFORM_VERSION}-${TARGETARCH}.zip | cut -d" " -f1); \
  if [[ -z "${EXPECTED_SHA}" ]] || [[ "${EXPECTED_SHA}" != "${ACTUAL_SHA}" ]]; then \
  echo "Checksum verification failed for ${ARCHIVE}" >&2; exit 1; \
  fi; \
  unzip -o /var/cache/downloads/terraform-${TERRAFORM_VERSION}-${TARGETARCH}.zip -d /usr/local/bin \
  && rm -f /usr/local/bin/LICENSE.txt \
  && chmod +x /usr/local/bin/terraform \
  && if [ "${TARGETARCH}" = "${BUILDARCH}" ]; then terraform --version; fi'

# terragrunt
RUN --mount=type=cache,target=/var/cache/github-api \
  --mount=type=cache,target=/var/cache/downloads \
  /bin/bash -c 'set -e; \
  TERRAGRUNT_VERSION=$(/opt/build/resolve-version terragrunt "${TERRAGRUNT_VERSION}"); \
  BINARY="terragrunt_linux_${TARGETARCH}"; \
  if [[ ! -f "/var/cache/downloads/terragrunt-${TERRAGRUNT_VERSION}-${TARGETARCH}" ]]; then \
  ${CURL} https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/${BINARY} -o /var/cache/downloads/terragrunt-${TERRAGRUNT_VERSION}-${TARGETARCH}; \
  fi; \
  if [[ ! -f "/var/cache/downloads/terragrunt-${TERRAGRUNT_VERSION}_SHA256SUMS" ]]; then \
  ${CURL} https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/SHA256SUMS -o /var/cache/downloads/terragrunt-${TERRAGRUNT_VERSION}_SHA256SUMS; \
  fi; \
  EXPECTED_SHA=$(grep " ${BINARY}\$" /var/cache/downloads/terragrunt-${TERRAGRUNT_VERSION}_SHA256SUMS | cut -d" " -f1); \
  ACTUAL_SHA=$(sha256sum /var/cache/downloads/terragrunt-${TERRAGRUNT_VERSION}-${TARGETARCH} | cut -d" " -f1); \
  if [[ -z "${EXPECTED_SHA}" ]] || [[ "${EXPECTED_SHA}" != "${ACTUAL_SHA}" ]]; then \
  echo "Checksum verification failed for ${BINARY}" >&2; exit 1; \
  fi; \
  cp /var/cache/downloads/terragrunt-${TERRAGRUNT_VERSION}-${TARGETARCH} /usr/local/bin/terragrunt \
  && chmod +x /usr/local/bin/terragrunt \
  && if [ "${TARGETARCH}" = "${BUILDARCH}" ]; then terragrunt --version; fi'

# terraform-docs
RUN --mount=type=cache,target=/var/cache/github-api \
  --mount=type=cache,target=/var/cache/downloads \
  /bin/bash -c 'set -e; \
  TERRAFORM_DOCS_VERSION=$(/opt/build/resolve-version terraform-docs "${TERRAFORM_DOCS_VERSION}"); \
  if [[ ! -f "/var/cache/downloads/terraform-docs-${TERRAFORM_DOCS_VERSION}-${TARGETARCH}.tar.gz" ]]; then \
  ${CURL} https://github.com/terraform-docs/terraform-docs/releases/download/${TERRAFORM_DOCS_VERSION}/terraform-docs-${TERRAFORM_DOCS_VERSION}-linux-${TARGETARCH}.tar.gz -o /var/cache/downloads/terraform-docs-${TERRAFORM_DOCS_VERSION}-${TARGETARCH}.tar.gz; \
  fi; \
  tar -xzf /var/cache/downloads/terraform-docs-${TERRAFORM_DOCS_VERSION}-${TARGETARCH}.tar.gz -C /tmp \
  && mv /tmp/terraform-docs /usr/local/bin/ \
  && chown root:root /usr/local/bin/terraform-docs \
  && chmod +x /usr/local/bin/terraform-docs \
  && if [ "${TARGETARCH}" = "${BUILDARCH}" ]; then terraform-docs --version; fi'

# tflint
RUN --mount=type=cache,target=/var/cache/github-api \
  --mount=type=cache,target=/var/cache/downloads \
  /bin/bash -c 'set -e; \
  TFLINT_VERSION=$(/opt/build/resolve-version tflint "${TFLINT_VERSION}"); \
  if [[ ! -f "/var/cache/downloads/tflint-${TFLINT_VERSION}-${TARGETARCH}.zip" ]]; then \
  ${CURL} https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_${TARGETARCH}.zip -o /var/cache/downloads/tflint-${TFLINT_VERSION}-${TARGETARCH}.zip; \
  fi; \
  unzip -o /var/cache/downloads/tflint-${TFLINT_VERSION}-${TARGETARCH}.zip -d /tmp \
  && mv /tmp/tflint /usr/local/bin/ \
  && chmod +x /usr/local/bin/tflint \
  && if [ "${TARGETARCH}" = "${BUILDARCH}" ]; then tflint --version && tflint --init; fi'

# trivy
RUN --mount=type=cache,target=/var/cache/github-api \
  --mount=type=cache,target=/var/cache/downloads \
  /bin/bash -c 'set -e; \
  TRIVY_VERSION=$(/opt/build/resolve-version trivy "${TRIVY_VERSION}"); \
  case "${TARGETARCH}" in \
  amd64) TRIVY_ARCH=64bit ;; \
  arm64) TRIVY_ARCH=ARM64 ;; \
  *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  if [[ ! -f "/var/cache/downloads/trivy-${TRIVY_VERSION}-${TARGETARCH}.tar.gz" ]]; then \
  ${CURL} https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${TRIVY_ARCH}.tar.gz -o /var/cache/downloads/trivy-${TRIVY_VERSION}-${TARGETARCH}.tar.gz; \
  fi; \
  tar -xzf /var/cache/downloads/trivy-${TRIVY_VERSION}-${TARGETARCH}.tar.gz -C /tmp \
  && mv /tmp/trivy /usr/local/bin/ \
  && chmod +x /usr/local/bin/trivy \
  && if [ "${TARGETARCH}" = "${BUILDARCH}" ]; then trivy --version; fi'


# main
FROM debian:${DEBIAN_VERSION} AS main
ARG DEBIAN_FRONTEND=noninteractive
ARG BUILDARCH
ARG TARGETARCH
RUN apt-get update && apt-get install --no-install-recommends -y \
  bash \
  curl \
  ca-certificates \
  git \
  jq \
  unzip \
  vim \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY config/.terraformrc /opt/terraform/.terraformrc
COPY config/plugin-cache/. /opt/terraform/plugin-cache/
RUN chmod -R 1777 /opt/terraform/plugin-cache
ENV TF_CLI_CONFIG_FILE='/opt/terraform/.terraformrc'
RUN if [ "${TARGETARCH}" = "${BUILDARCH}" ]; then /bin/bash -c 'terraform --version'; fi

ENTRYPOINT []
