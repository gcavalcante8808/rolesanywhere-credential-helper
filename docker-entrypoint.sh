#!/usr/bin/env bash

set -euo pipefail


if [[ -n "${CREATE_AWS_CREDENTIALS_FILE:-}" ]]; then
  echo "Create ${CREDENTIALS_FILE_PATH%/*} if needed."
  mkdir -p "${CREDENTIALS_FILE_PATH%/*}"

  cat > "${CREDENTIALS_FILE_PATH}" <<- EOF
    [default]
    credential_process = aws_signing_helper credential-process --certificate ${CERTIFICATE_FILE_PATH?Please set the CERTIFICATE_FILE_PATH variable.} --private-key ${CERTIFICATE_KEY_PATH?Please set the CERTIFICATE_KEY_PATH variable.} --trust-anchor-arn ${TRUST_ANCHOR_ARN?Please set the TRUST_ANCHOR_ARN variable.} --profile-arn ${PROFILE_ARN?Please set the PROFILE_ARN variable.} --role-arn  ${ROLE_ARN?Please set the ROLE variable.}
EOF
  echo "Credential file created at ${CREDENTIALS_FILE_PATH}"
fi

exec /usr/bin/aws_signing_helper "${@}"
