#!/bin/bash

###########  Defines
CON_ERR='\033[0;31m'
CON_INFO='\033[0;32m'
CON_WARN='\033[0;33m'
COFF='\033[0;0m'
INFO="${CON_INFO}INFO:${COFF}"
ERROR="${CON_ERROR}ERROR:${COFF}"
WARN="${CON_WARN}WARNING:${COFF}"
DryRun=false
DOCKERISED=false

###########  Process CmdLineArguments
while getopts "b:dD" opt; do
    case $opt in
        b) BuildCommandsArgs+=("$OPTARG");;
        d) DryRun=true;;
        D) DOCKERISED=true;;
    esac
done
shift $((OPTIND -1))

for val in "${BuildCommandsArgs[@]}"; do
    IFS=', ' read -r -a array <<< "$val"
    BuildCommands+=(${array[@]})
done

if $DryRun; then
    echo -e "$INFO DryRun: $DryRun"
fi

###########  FUNCTIONS
function checkEnvironment() {
    ENVTOCHECK=$1
    python "$SCRIPTDIR/checkEnvironment.py" "$ENVTOCHECK"
    return $?
}

function executeBuildCmd() {
    DOCROOT=$1
    BUILDCMD=$2

    if [ ! -d "$DOCROOT" ]; then
        echo -e "$ERROR Could not find soures to build at ${DOCROOT}"
        return -1
    fi

    PWDSAVE=$(pwd)
    cd "$DOCROOT"

    if $DryRun; then
        echo -e "$INFO Not Executing (DryRun): ${DOCROOT}/make ${BUILDCMD}"
        RC=0
    else
        echo -e "$INFO Executing: ${DOCROOT}/make ${BUILDCMD}"
        if [ -f ./requirements.txt ]; then
            pip install -q -r ./requirements.txt
            RC=$?
        else
            RC=0
        fi

        if [ $RC -eq 0 ]; then
            make "$BUILDCMD"
            RC=$?
        fi
    fi
    cd "$PWDSAVE"
    return $RC
}

function processDir() {
    THEDIR=$1

    echo -e "$INFO: Processing $THEDIR"
    for val in "${BuildCommands[@]}"; do
        [ $(basename "$THEDIR") == "_Template" ] || executeBuildCmd "$THEDIR" "$val"
    done
}
###########  Main Code

# Make sure we have the SCRIPTDIR variable set.
if $DOCKERISED; then
    SCRIPTDIR="/scripts"
    DOCSDIR="/docs"
else
    if [ -z "$WorkSpaceFolder" ] ; then
        echo -e "$ERROR WorkSpaceFolder is not defined."
        exit 1
    else
        SCRIPTDIR="$WorkSpaceFolder/bin"
        DOCSDIR="$WorkSpaceFolder/docs"
    fi

    # Do we have a good python env?
    if ! checkEnvironment "$WorkSpaceFolder/.env"; then
        exit 1
    fi
fi
# The sphinx installations are in the docs dir.   Lets check.
if [ -d "$DOCSDIR" ]; then
    echo -e "$INFO Found docs dir, checking for makefiles."
else
    echo -e "$ERROR No docs file found: quitting.."
    exit 1
fi

# Find the Makefiles so we know which docs to build...
CWDSAVE=$(pwd)
cd "$DOCSDIR"

if [ -f ./Makefile ]; then
    processDir "$DOCSDIR";
else
    for M in */Makefile; do
        DOCROOT=$(dirname "$DOCSDIR/$M")
        processDir "$DOCROOT";
    done
fi
cd "$CWDSAVE"