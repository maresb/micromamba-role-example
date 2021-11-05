#!/bin/bash

# Activate the enivronment before executing the command
source /usr/local/bin/_activate-conda /opt/conda

exec "$@"
