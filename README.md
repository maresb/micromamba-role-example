# micromamba-role-example

## Intro

Here's how I use the [micromamba role](https://github.com/mamba-org/ansible-role-micromamba) to bootstrap from Ubuntu's Ansible to conda-forge's Ansible, and set up a root-owned base environment.

Users with sudo enabled can `sudo mamba install` into the base environment.

Otherwise, users are suggested to `mamba env create` their own environment.

## Building and running

```bash
docker build -t micromamba-role-example .
docker run --rm -it micromamba-role-example
```

Then you can for example run

```bash
mamba activate myenv
s3fs --version
```

## Design choices

### Failed admin group for base environment

I originally wanted /opt/conda to be writable by the group `condaadmins` and tried

```bash
chgrp -R condaadmins /opt/conda
chmod -R g+rwX /opt/conda
find /opt/conda -type d -exec chmod g+s {} \;
```

But unfortunately when conda extracts freshly installed packages, they are not group writeable. Thus this leads to breakage.

### Alternative user init

I have [an idempotent script](alternative-user-init.sh) for updating `/etc/skel` which creates a temporary user, runs `conda init` and `mamba init`, and then copies the resulting `.bashrc` back to `/etc/skel`.
