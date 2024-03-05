#!/usr/bin/env bash

set -uo pipefail

FIND_ID_COMMAND="tail -n +2 | grep -o \"[0-9a-z]*\" | head -n 1"

influxd &
PID=$!

# Wait for ping to work so we know that influxd is running
while true; do
  if influx ping &> /dev/null; then
    echo "Influxd running"
    break
  fi

  echo "Influxd not yet running. Waiting..."
  sleep 1
done

influx setup \
  --username $INFLUXDB_ADMIN_USER \
  --password $INFLUXDB_ADMIN_PASSWORD \
  --token $INFLUXDB_ADMIN_TOKEN \
  --retention $INFLUXDB_DB_RETENTIONPOLICY \
  --org wirepas \
  --bucket wirepas \
  --force

BUCKET_ID=$(influx bucket list \
  -o wirepas \
  -n wirepas \
  -t $INFLUXDB_ADMIN_TOKEN 2>/dev/null | eval $FIND_ID_COMMAND)

echo "Bucket id: $BUCKET_ID"

if [ -z "$BUCKET_ID" ]; then
  echo "Empty bucket id. Cannot continue." >&2
  exit 1
fi

influx v1 auth create \
  --read-bucket $BUCKET_ID \
  --write-bucket $BUCKET_ID \
  --username $INFLUXDB_ADMIN_USER \
  --password $INFLUXDB_ADMIN_PASSWORD \
  -o wirepas \
  -t $INFLUXDB_ADMIN_TOKEN

# Delete the old INFLUXDB_READ_USER and create new one to refresh the token
# Cannot delete authentication item as the list command flags does not work correctly in 2.7
READ_USER_ID=$(influx user list \
  -n $INFLUXDB_READ_USER \
  -t $INFLUXDB_ADMIN_TOKEN 2>/dev/null | eval $FIND_ID_COMMAND
)

echo "Read user id: $READ_USER_ID"

if [ ! -z "$READ_USER_ID" ]; then
  influx user delete -i $READ_USER_ID \
    -t $INFLUXDB_ADMIN_TOKEN 2>/dev/null | eval $FIND_ID_COMMAND
fi

influx user create \
  -o wirepas \
  --name $INFLUXDB_READ_USER \
  --password $INFLUXDB_READ_PASSWORD \
  -t $INFLUXDB_ADMIN_TOKEN

influx auth create \
  -o wirepas \
  -u $INFLUXDB_READ_USER \
  --read-bucket $BUCKET_ID \
  -t $INFLUXDB_ADMIN_TOKEN

wait $PID
