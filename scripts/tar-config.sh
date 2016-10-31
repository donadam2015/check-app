#!/bin/bash

FILENAME=config-$(date +%Y%m%d%H%M).tar.gz

if [ -n "$1" ]; then
	FILENAME=$1	
fi

tar zcf $FILENAME \
	check-api/config/config.yml \
	check-api/config/database.yml \
	pender/config/config.yml \
	pender/config/database.yml \
	check-web/config.js \
	check-web/test/config.js \
	check-web/test/config.yml

echo check config files: $FILENAME
