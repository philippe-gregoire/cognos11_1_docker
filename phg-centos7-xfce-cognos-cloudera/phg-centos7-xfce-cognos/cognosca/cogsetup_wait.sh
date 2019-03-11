#!/bin/sh
set +e

if [[ -z "${COGNOS_WAIT_DB2_MINS}" ]]; then
  COGNOS_WAIT_DB2_MINS=${COGNOS_WAIT_DB2_MINS_DEF}
  echo "Using default DB2 wait time ${COGNOS_WAIT_DB2_MINS}"
fi

echo "Renaming cogstartup.xml* files in ${COGNOS_DIR}"
mv ${COGNOS_DIR}/configuration/cogstartup.xml ${COGNOS_DIR}/configuration/cogstartup.xml_backup
cp ${COGNOS_DIR}/configuration/cogstartup.xml_configured ${COGNOS_DIR}/configuration/cogstartup.xml

echo "--------------------------------------------------------"
retriesLeft=${COGNOS_MAX_RETRIES}
CONFIG_STATUS=3
while [ $retriesLeft -gt 0 -a $CONFIG_STATUS -ne 0 ]; do
echo "======= Attempting to start Cognos ${retriesLeft} times ========="

waitcnt=${COGNOS_WAIT_DB2_MINS}
while [ $waitcnt -gt 0 ]; do
	echo "Waiting ${waitcnt} minutes to get DB2 time to startup"
	sleep 1m
	waitcnt=$(( $waitcnt - 1 ))
done

echo "====== Running Cognos Unattended config =================="
cd ${COGNOS_DIR}/bin64
./cogconfig.sh -s
CONFIG_STATUS=$?
echo "====== Cognos configuration status: ${CONFIG_STATUS} ====="
if [ $CONFIG_STATUS -ne 0 ]; then
	cat ${COGNOS_DIR}/logs/cogconfig_response.csv
fi

retriesLeft=$(( $retriesLeft - 1 ))
done

if [ $CONFIG_STATUS -eq 0 ]; then
	tail -f ${COGNOS_DIR}/logs/cogconfig_response.csv
else
	echo "Too many retries, exiting "
fi
