#!/bin/sh
uptime
echo "Setting up Content Manager database"
if [[ ! -d /database/data/db2inst1/NODE0000/CM ]]; then
	echo "Creating CM database"
	su - db2inst1 -c "db2 -tf /var/cognos_cm/createDb.sql"
else
	echo "CM database already exists"
	su - db2inst1 -c "db2 list db directory"
fi