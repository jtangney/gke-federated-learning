#!/bin/sh

# fetch the current ConfigSync configuration
CONFIGSYNC_SPEC=$(gcloud alpha container hub config-management fetch-for-apply --membership $1)
# write a local temp file, setting the value of mutations flag
tmpfile=$(mktemp)
echo "${CONFIGSYNC_SPEC//mutationEnabled: false/mutationEnabled: true}" > $tmpfile
# apply the updated config
gcloud alpha container hub config-management apply --membership $1 --config $tmpfile
# cleanup
rm $tmpfile