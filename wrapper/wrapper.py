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
