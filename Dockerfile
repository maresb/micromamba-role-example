FROM ubuntu:20.04

RUN apt-get update && apt-get install -y ansible sudo nano

RUN ansible-galaxy role install maresb.micromamba

# Copy the files necessary for "conda_system_install_playbook.yaml"
COPY ./ansible/roles/conda_system_install/ /opt/ansible/roles/conda_system_install/
COPY ./ansible/conda_system_install_playbook.yaml /opt/ansible/

WORKDIR /opt/ansible

RUN ansible-playbook conda_system_install_playbook.yaml

# Get rid of system Ansible and Python!
RUN apt-get remove -y --autoremove ansible

# Copy the files necessary for "initialize_root_and_skel_playbook.yaml"
COPY ./ansible/roles/initialize_home/ /opt/ansible/roles/initialize_home/
COPY ./ansible/initialize_root_and_skel_playbook.yaml /opt/ansible/

# Here sudo is a trick to help find the ansible-playbook executable.
# Alternatively we could have done /opt/conda/ansible-playbook ...
RUN sudo ansible-playbook initialize_root_and_skel_playbook.yaml

# Set up mambauser
ENV MAMBAUSER=mambauser
RUN useradd -ms /bin/bash ${MAMBAUSER}
RUN echo "${MAMBAUSER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER ${MAMBAUSER}

# Example running sudo mamba install as user to add a package to global env
RUN sudo mamba install --yes tqdm

# Example create a new environment as user
RUN /opt/conda/bin/mamba create --name myenv --yes s3fs-fuse
