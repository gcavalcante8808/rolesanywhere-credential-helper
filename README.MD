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
builds for arm64 and amd64.

## Usage

You can call the image directly using the following command:

```bash
docker run -it --rm gcavalcante8808/rolesanywhere-credential-helper:v1.1.1 version
```

You can also copy the binary in your docker image by using the following statement in your Dockerfile:

```dockerfile
COPY --from=gcavalcante8808/rolesanywhere-credential-helper:v1.1.1 /usr/bin/aws_signing_helper /usr/bin/aws_signing_helper
```

> Important note: the credentials helper binary is build using the main aws script and thus relies on linux and gblic
> libraries to work.

### Author

Author: Gabriel Cavalcante (gabriel.cavalcante88 at gmail.com)
