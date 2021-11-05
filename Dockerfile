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

# Initialize the root user and the skel (new user account) directory
RUN /opt/conda/bin/ansible-playbook initialize_root_and_skel_playbook.yaml

# Set up the Docker Build shell as a login shell so that the environment gets activated.
SHELL ["/bin/bash", "--login", "-c"]

# Verify that the environment is activated
RUN ansible-playbook --version

# Set up mambauser
ENV MAMBAUSER=mambauser
RUN useradd -ms /bin/bash ${MAMBAUSER}
RUN echo "${MAMBAUSER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER ${MAMBAUSER}

# Example running sudo mamba install as user to add a package to global env
RUN sudo mamba install --yes tqdm

# Example create a new environment as user
RUN mamba create --name myenv --yes s3fs-fuse

CMD ["/bin/bash"]

COPY entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT [ "/bin/entrypoint.sh" ]
