#!/bin/bash
shopt -s nullglob

CLIENTS=("$@")

# Create a list of provisioned OVPN users from existing *.ovpn files
mapfile -t OVPN_USERS < <(find . -maxdepth 1 -name "*.ovpn" -exec basename {} .ovpn \;)

# Revoke excess client certificates
for OVPN_USER in "${OVPN_USERS[@]}"
do
  if [[ " ${CLIENTS[*]} " == *" $OVPN_USER "* ]];
  then
    echo "Keeping certificate for user ${OVPN_USER}."
  else
    echo "Revoking certificate for user ${OVPN_USER}!"

    # Export the corresponding options and revoke the user certificate
    export MENU_OPTION="2"
    export CLIENT="${OVPN_USER}"
    ./openvpn-install.sh
  fi
done

# Provision an OVPN file for each new user
for CLIENT in "${CLIENTS[@]}"
do
  # Skip all user names that already have a corresponding OVPN file
  ovpn_filename="${CLIENT}.ovpn"
  if [ -f "${ovpn_filename}" ]
  then
      echo "File '${ovpn_filename}' already exists. Skipping."
      continue
  fi

  # Export the corresponding options and add the user name
  export MENU_OPTION="1"
  export CLIENT="${CLIENT}"
  export PASS="1"
  ./openvpn-install.sh
done
