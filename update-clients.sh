#!/bin/bash
shopt -s nullglob

NEW_CLIENTS=("$@")

# Create a list of provisioned clients from easy-rsa pki index
mapfile -t CURRENT_CLIENTS < <(awk 'NR > 1 && $1 == "V" {split($0, a, "="); print a[2]}' /etc/openvpn/easy-rsa/pki/index.txt)

# Revoke excess client certificates
for CURRENT_CLIENT in "${CURRENT_CLIENTS[@]}"
do
  if [[ " ${NEW_CLIENTS[*]} " == *" $CURRENT_CLIENT "* ]]
  then
    echo "Keeping certificate for client '${CURRENT_CLIENT}'."
  else
    echo "Revoking certificate for client '${CURRENT_CLIENT}'!"

    export MENU_OPTION="2" # Revoke client option
    export CLIENT="${CURRENT_CLIENT}"
    ./openvpn-install.sh
  fi
done

# Create new clients
for NEW_CLIENT in "${NEW_CLIENTS[@]}"
do
  if [[ " ${CURRENT_CLIENTS[*]} " == *" $NEW_CLIENT "* ]]
  then
    echo "'${NEW_CLIENT}' already exists. Skipping."
  else
    echo "Creating new client '${NEW_CLIENT}'."

    export MENU_OPTION="1" # Create client option
    export CLIENT="${NEW_CLIENT}"
    export PASS="1" # No Passphrase
    ./openvpn-install.sh
  fi
done
