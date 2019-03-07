#!/bin/sh
set +e

env

echo "Renaming cogstartup.xml* files in ${COGNOS_DIR}"
mv ${COGNOS_DIR}/configuration/cogstartup.xml ${COGNOS_DIR}/configuration/cogstartup.xml_backup
cp ${COGNOS_DIR}/configuration/cogstartup.xml_configured ${COGNOS_DIR}/configuration/cogstartup.xml

echo "Running unattended config"
cd ${COGNOS_DIR}/bin64
./cogconfig.sh -s

tail -f ${COGNOS_DIR}/logs/cogconfig_response.csv

ps -ef

ps

