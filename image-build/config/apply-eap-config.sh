#!/bin/bash
set -e

function logMessage ()
{
    echo ""
    printf "$1${NC}"
    echo ""
}

function startJboss ()
{
    logMessage "Starting Jboss.."
    $JBOSS_HOME/bin/standalone.sh -c standalone-full.xml --admin-only 2>&1 &
    sleep 15
    logMessage "Jboss started successfully.."
}

function stopJboss ()
{
    logMessage "Stopping Jboss.."
    $JBOSS_HOME/bin/jboss-cli.sh -c --command=:shutdown
    sleep 5
    logMessage "Jboss stopped successfully.."
}

function addModule ()
{
    if [ "$(ls -A ${JBOSS_BASE}/modules)" ]; then
        case $MODULE_NAME in
        mysql)
            logMessage "Adding module for MySQL"
            $JBOSS_HOME/bin/jboss-cli.sh -c --command="module add --name=com.mysql --resources=${JBOSS_BASE}/modules/${JDBC_JAR_NAME}.jar --dependencies=javax.api,javax.transaction.api"
            ;;
        postgresql)
            logMessage "Adding module for PostgreSQL"
            $JBOSS_HOME/bin/jboss-cli.sh -c --command="module add --name=org.postgresql --resources=${JBOSS_BASE}/modules/${JDBC_JAR_NAME}.jar --dependencies=javax.api,javax.transaction.api"
            ;;
        mssql)
            logMessage "Adding module for MSSQL"
            $JBOSS_HOME/bin/jboss-cli.sh -c --command="module add --name=com.microsoft --resources=${JBOSS_BASE}/modules/${JDBC_JAR_NAME}.jar --dependencies=javax.api,javax.transaction.api,javax.xml.bind.api"
            ;;
        oracle)
            logMessage "Adding module for Oracle"
            $JBOSS_HOME/bin/jboss-cli.sh -c --command="module add --name=com.oracle --resources=${JBOSS_BASE}/modules/${JDBC_JAR_NAME}.jar --dependencies=javax.api,javax.transaction.api"
            ;;
        db2)
            logMessage "Adding module for Oracle"
            $JBOSS_HOME/bin/jboss-cli.sh -c --command="module add --name=com.ibm --resources=${JBOSS_BASE}/modules/${JDBC_JAR_NAME}.jar --dependencies=javax.api,javax.transaction.api"
            ;;
        *)
            echo custom module to be added
            ;;
        esac
        logMessage "Module added successfully";
    else
        logMessage "No modules added.." 
    fi
}

function applyConfig ()
{   
    if [ -f "${JBOSS_BASE}/config/standalone-custom.xml" ]; then
        logMessage "Adding custom standalone-full xml";
        mv -f ${JBOSS_CONFIG}/standalone-full.xml ${JBOSS_CONFIG}/standalone-full.xml.bk
        mv -f ${JBOSS_BASE}/config/standalone-custom.xml ${JBOSS_CONFIG}/standalone-full.xml
        logMessage "Custom standalone-full xml added successfully";
        
        # Shutdown JBoss EAP in admin-mode
        stopJboss

    elif [ -f "${JBOSS_BASE}/config/cli-script" ]; then
        logMessage "Applying config via CLI";
        $JBOSS_HOME/bin/jboss-cli.sh -c --properties=$JBOSS_CONFIG/standalone-full.xml --file=${JBOSS_BASE}/config/cli-script
        logMessage "Config via CLI applied successfully";

    else
        logMessage "No configurations added. Using the base EAP 7.2 configuration"
    fi
}

function cleanup ()
{
    rm -rf ${JBOSS_BASE}/modules/
    rm -rf ${JBOSS_BASE}/config/
    logMessage "Temp files deleted.."

    # [ -d "$JBOSS_MODULE/system/layers/base/.overlays" ] && rm -rf $JBOSS_MODULE/system/layers/base/.overlays
    # logMessage "module/overlays directory deleted"
}

###
# Main body of script starts here
###

startJboss
addModule
applyConfig
cleanup