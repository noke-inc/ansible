#!/bin/sh

set -e

# Override default environment parameters here

export DOCKER_VERNEMQ_USER_${MQTT_JSON_USERNAME}="${MQTT_JSON_PASSWORD}"
export DOCKER_VERNEMQ_USER_${MQTT_MASTER_USERNAME}="${MQTT_MASTER_PASSWORD}"
export DOCKER_VERNEMQ_USER_${MQTT_GATEWAY_USERNAME}="${MQTT_GATEWAY_PASSWORD}"
export DOCKER_VERNEMQ_USER_${MQTT_LIBRARY_USERNAME}="${MQTT_LIBRARY_PASSWORD}"

# SYS topic publish interval in ms
export DOCKER_VERNEMQ_SYSTREE_INTERVAL=3600000

# Default online message buffer count is 1000
# which is not enough for bigger networks > 100 000 nodes
export DOCKER_VERNEMQ_MAX_ONLINE_MESSAGES=1000000

# Needed to be able to route > 1000 msg/s for QoS1/2
export DOCKER_VERNEMQ_MAX_INFLIGHT_MESSAGES=10000

export DOCKER_VERNEMQ_ERLANG__MAX_PORTS=256000

# Set persistent client expiration time and offline
# messages amount to prevent the broker from keeping
# too many messages in memory.
export DOCKER_VERNEMQ_PERSISTENT_CLIENT_EXPIRATION="${MQTT_PERSISTENT_CLIENT_EXPIRATION}"
export DOCKER_VERNEMQ_MAX_OFFLINE_MESSAGES=10000
