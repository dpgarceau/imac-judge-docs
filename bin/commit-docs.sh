#!/bin/bash

#######################
# Setup...            #
#######################

###########  Defines
CON_ERR='\033[0;31m'
CON_INFO='\033[0;32m'
CON_WARN='\033[0;33m'
COFF='\033[0;0m'
INFO="${CON_INFO}INFO:${COFF}"
ERROR="${CON_ERROR}ERROR:${COFF}"
WARN="${CON_WARN}WARNING:${COFF}"
DryRun=false

###########  Process CmdLineArguments
while getopts "d" opt; do
    case $opt in
        d) DryRun=true;;
    esac
done
shift $((OPTIND -1))

if $DryRun; then
    echo -e "$INFO DryRun: $DryRun"
    set -x
fi

apt-get update
apt-get -y install git rsync

#######################
# Functions           #
#######################

function executeCopyCmd() {
    DOCROOT=$1
    DEST=$2
    if [ ! -d "$DOCROOT" ]; then
        echo -e "$ERROR Could not find soures to build at ${DOCROOT}"
        return -1
    fi

    DIRNAME=$(basename "$DOCROOT")

    echo -e "$INFO Copying HTML files."
    rsync -a "${DOCROOT}/build/html/" "${DEST}/${DIRNAME}"

    echo -e "$INFO Copying PDF file."
    find "${DOCROOT}/build/latex/" -name \*.pdf -ls -exec cp {} "${DEST}/${DIRNAME}/" \;
}

#######################
# Update GitHub Pages #
#######################

set -x
git config --global user.name "${GITHUB_ACTOR}"
git config --global user.email "${GITHUB_EMAIL}"
set +x
 
tmpdocroot=`mktemp -d`

# Find the docs that were created and copy them.
DOCSDIR="/docs"
for M in */Makefile; do
    DOCROOT=$(dirname "$DOCSDIR/$M")
    [ "$DOCROOT" == "$DOCSDIR/_Template" ] || executeCopyCmd "$DOCROOT" "$tmpdocroot"
done

echo "${GITHUB_DEPLOY_KEY}" > ~/id_temp
chmod 600 ~/id_temp

pushd "${tmpdocroot}"

git init
git remote add deploy "git@github.com:/${GITHUB_REPOSITORY}.git"
git config core.sshCommand "ssh -o StrictHostKeyChecking=no -i ~/id_temp"
git checkout -b docs
 
# Adds .nojekyll file to the root to signal to GitHub that  
# directories that start with an underscore (_) can remain
touch .nojekyll
 
# Add README
cat > README.md <<EOF
# README for Sphinx Docs
This branch is simply a cache for the website served from https://github.com/${GITHUB_REPOSITORY}/,
and is not intended to be viewed on github.com.
EOF
 
# Copy the resulting html pages built from Sphinx to the gh-pages branch 
git add .
 
# Make a commit with changes and any new files
msg="Updating Docs for commit ${GITHUB_SHA} made from ${GITHUB_SHA} by ${GITHUB_ACTOR}"
git commit -am "${msg}"
 
# overwrite the contents of the gh-pages branch on our github.com repo
if $DryRun; then
    echo "$INFO Not Executing (DryRun): git push deploy docs --force"
else
    git push deploy docs --force
    RC=$?
fi

popd # return to main repo sandbox root
rm -f ~/id_temp

# exit cleanly
exit $RC