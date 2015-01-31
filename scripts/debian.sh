#!/bin/bash

# Update list and packages.
apt-get update &&
apt-get dist-upgrade -y && 

# Clean-up.
apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/*