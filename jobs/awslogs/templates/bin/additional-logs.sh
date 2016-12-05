#!/bin/bash

mkdir -p /var/vcap/jobs/awslogs/conf.d

for I in `find  /var/vcap/sys/log -type f`
do
  # deliberately excluding obviously non-ingestable files (only ASCII, text or empty files,
  # no timestamp-rotated files) to reduce log readers and thus forestall lost log lines
  echo $I | egrep -q 'log.[0-9][0-9][0-9]+$' && continue
  file $I | egrep -q 'ASCII|text|empty' || continue
  GROUP_NAME=`dirname $I | xargs basename`
  echo ""
  echo "[$I]"
  echo "file = $I"
  echo "buffer_duration = 5000"
  echo "log_stream_name = {instance_id}-$I"
  echo "initial_position = start_of_file"
  echo "log_group_name = $GROUP_NAME"
done > /var/vcap/jobs/awslogs/conf.d/all-vcap-logs.conf
monit restart awslogs