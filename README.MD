↖️ Table of Contents

<h1 align="center"><code>Roles Anywhere Credential Helper - Docker Image</code></h1>

<div align="center">
  <a href="https://github.com/gcavalcante8808/rolesanywhere-credential-helper/actions/workflows/daily-builds.yml">
    <img src="https://github.com/gcavalcante8808/rolesanywhere-credential-helper/actions/workflows/daily-builds.yml/badge.svg">
  </a>
  <a href="https://www.buymeacoffee.com/gcavalcante8808">
    <img src="https://img.shields.io/badge/-buy_me_a%C2%A0coffee-gray?logo=buy-me-a-coffee" alt="buy me a coffee">
  </a>
</div>
<br>

This repository serves as a source for `gcavalcante8808/rolesanywhere-credential-helper` docker image with daily Linux
builds for arm64 and amd64, with Debian and Alpine builds.

## Usage

You can call the image directly using the following command:

```bash
docker run -it --rm gcavalcante8808/rolesanywhere-credential-helper:v1.1.1 version
```

It's also possible to use an alpine variant:

```bash
docker run -it --rm gcavalcante8808/rolesanywhere-credential-helper:v1.1.1_alpine3.19 version
```

You can also copy the binary in your docker image by using the following statement in your Dockerfile:

```dockerfile
COPY --from=gcavalcante8808/rolesanywhere-credential-helper:v1.1.1 /usr/bin/aws_signing_helper /usr/bin/aws_signing_helper
```

> Important note: the credentials helper binary is build using the main aws script and thus relies on linux and gblic
> libraries to work.

### Automatic creation of the `.aws/credentials` file

It's possible to create a `credentials file` automatically by settings the following environment variables:

| Environment Variable        | Description                                                                                       | Default                                     | Required?                                  |
| --------------------------- |---------------------------------------------------------------------------------------------------|---------------------------------------------| ------------------------------------------ |
| CREATE_AWS_CREDENTIALS_FILE | Should the entrypoint create an aws credential file? Any value set here will enable the behavior. | Empty - the file is not created by default. | NO                                         |
| CREDENTIALS_FILE_PATH       | Where should the entrypoint create the `credentials` file? Eg: /home/user/.aws/credentials     | N?A.                                        | NO                                         |
| CERTIFICATE_FILE_PATH       | Filesystem full path of the PEM public Key.                                                       | N/A                                         | when `CREATE_AWS_CREDENTIALS_FILE` is set. |
| CERTIFICATE_KEY_PATH        | Filesystem Full Path of the PEM private key.                                                      | N/A                                         | when `CREATE_AWS_CREDENTIALS_FILE` is set. |
| TRUST_ANCHOR_ARN            | AWS Roles Anywhere Trust Anchor ARN.                                                              | N/A                                         | when `CREATE_AWS_CREDENTIALS_FILE` is set. |
| PROFILE_ARN                 | AWS Roles Anywhere Trust Profile ARN.                                                             | N/A                                         | when `CREATE_AWS_CREDENTIALS_FILE` is set. |
| ROLE_ARN                    | AWS IAM Role ARN.                                                                                 | N/A                                         | when `CREATE_AWS_CREDENTIALS_FILE` is set. |

The credentials file created use the external authentication format like the one bellow:

```bash
[default]
    credential_process = ./aws_signing_helper credential-process --certificate /path/to/certificate --private-key /path/to/private-key --trust-anchor-arn arn:aws:rolesanywhere:region:account:trust-anchor/TA_ID --profile-arn arn:aws:rolesanywhere:region:account:profile/PROFILE_ID --role-arn arn:aws:iam::account:role/role-name-with-path
```

Check https://docs.aws.amazon.com/rolesanywhere/latest/userguide/credential-helper.html#credential-helper-examples for details regarding the helper command.

### Bonus: aws-credentials-wrapper static binary

For specific cases, eg projects using old versions of aws-sdk-go, when the local profiles are not read/respected by the target binary, this image provides a very simple and small static binary called `aws-credentials-wrapper` which has the following code:

```python
#!/usr/bin/env python3

## A very simple script copied from https://github.com/hashicorp/vault/issues/12568 that help in cases where
## the target binary doesn't have support to use local profiles.


import os
import sys

import boto3

session = boto3.session.Session()

creds = session.get_credentials()
creds = creds.get_frozen_credentials()

os.environ["AWS_ACCESS_KEY_ID"] = creds.access_key
os.environ["AWS_SECRET_ACCESS_KEY"] = creds.secret_key
os.environ["AWS_SESSION_TOKEN"] = creds.token

os.system(" ".join(sys.argv[1:]))
```

You can use the binary in the following way:

```commandline
docker run -it --rm --entrypoint /usr/bin/aws-credentials-wrapper  gcavalcante8808/rolesanywhere-credential-helper:v1.1.1 ./some-small-program-that-relies-on-aws-credentials-to-work
```

You can also copy it to your image by using the following Dockerfile statement:

```dockerfile
COPY --from=gcavalcante8808/rolesanywhere-credential-helper:v1.1.1 /usr/bin/aws-credentials-wrapper /usr/bin/aws-credentials-wrapper
```

### Author

Author: Gabriel Cavalcante (gabriel.cavalcante88 at gmail.com)
