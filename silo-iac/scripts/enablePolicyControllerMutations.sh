#!/bin/sh

# fetch the current ConfigSync configuration
CONFIGSYNC_SPEC=$(gcloud alpha container hub config-management fetch-for-apply --membership $1)
# update the value of mutations flag
UPDATED_SPEC=$(echo "${CONFIGSYNC_SPEC//mutationEnabled: false/mutationEnabled: true}")
# apply the updated config
echo "Enabling PolicyController mutations"
gcloud alpha container hub config-management apply --membership $1 --config $UPDATED_SPEC