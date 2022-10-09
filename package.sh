#!/bin/bash -x

PKG=${1:-"all"}

if [ "$PKG" = "all" ]; then 
	PKG="alertaction madhava nodewebserver partha postgresdb shyama"
fi

if [ ! -f ~/.gnupg/PASS.gyeetainc ]; then
	echo -e "\nERROR : Helm Package creation failed as gyeetainc passphrase file (~/.gnupg/PASS.gyeetainc) not found...\n\n"
	exit 1
fi

helm package --sign --passphrase-file ~/.gnupg/PASS.gyeetainc --key 'Gyeeta' --keyring ~/.gnupg/secring.gpg $PKG

if [ $? -ne 0 ]; then
	echo -e "\nERROR : Helm Package creation failed...\n\n"
	exit 1
fi

exit 0

