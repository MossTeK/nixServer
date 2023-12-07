#!/run/current-system/sw/bin/bash

# Currently this script just clones the repos to /home/tek/devel/.
# Deployment of new configs still requires manual input,
# this will be updated in the future

git clone https://github.com/MossTeK/nixos-config.git
git clone https://github.com/MossTeK/nixpkgs.git
sudo nixos-rebuild switch