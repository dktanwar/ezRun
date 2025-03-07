#!/bin/bash

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get -y install libreadline-dev

# Check the R info
echo -e "Check the R info...\n"

R -q -e "sessionInfo()"

echo -e "\nInstall R from source, done!"
