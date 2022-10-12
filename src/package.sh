#!/bin/bash -x

PKG=${1:-"all"}

if [ "$PKG" = "all" ]; then 
	PKG="alertaction madhava nodewebserver partha postgresdb shyama"
fi

helm package --dependency-update --destination ../docs/ $PKG

if [ $? -ne 0 ]; then
	echo -e "\nERROR : Helm Package creation failed...\n\n"
	exit 1
fi

helm repo index --url https://gyeeta.io/helmcharts ../docs/

if [ $? -ne 0 ]; then
	echo -e "\nERROR : Helm repo index creation failed...\n\n"
	exit 1
fi

exit 0

