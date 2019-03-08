#!/bin/sh
set +e

if [[ -z "${COGNOS_WAIT_DB2_MINS}" ]]; then
  COGNOS_WAIT_DB2_MINS=${COGNOS_WAIT_DB2_MINS_DEF}
  echo "Using default DB2 wait time ${COGNOS_WAIT_DB2_MINS}"
fi

echo "--------------------------------------------------------"
echo "Waiting ${COGNOS_WAIT_DB2_MINS} minutes to get DB2 time to startup"
sleep ${COGNOS_WAIT_DB2_MINS}m

echo "--------------------------------------------------------"
echo "Renaming cogstartup.xml* files in ${COGNOS_DIR}"
mv ${COGNOS_DIR}/configuration/cogstartup.xml ${COGNOS_DIR}/configuration/cogstartup.xml_backup
cp ${COGNOS_DIR}/configuration/cogstartup.xml_configured ${COGNOS_DIR}/configuration/cogstartup.xml

echo "--------------------------------------------------------"
echo "Running unattended config"
cd ${COGNOS_DIR}/bin64
./cogconfig.sh -s

echo "--------------------------------------------------------"
CONFIG_STATUS=$?
echo "Config status: ${CONFIG_STATUS}"

tail -f ${COGNOS_DIR}/logs/cogconfig_response.csv

ps -ef

