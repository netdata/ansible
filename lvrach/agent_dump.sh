#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

if [ $# -ne 1 ]
then
  echo "./debug_agent.sh.sh <agent-id>"
  exit 1
fi

AGENT_ID="$1"

printf "verneMQ records:\n"
kubectl -n infra exec pod/vernemq-0  -- vmq-admin session show --client_id=$AGENT_ID --session_started_at --queue_size --is_online

printf "NODE SOT \n"

printf "# reachable: \n"
kubectl -n infra exec pod/crdb-cockroachdb-0 -- ./cockroach sql --host=localhost:26257 --insecure -e \
    "SELECT id, reachable, space_id, updated_at, created_at FROM node.nodes WHERE id='$AGENT_ID' "
printf "\n"

printf "# info: \n"
kubectl -n infra exec pod/crdb-cockroachdb-0 -- ./cockroach sql --host=localhost:26257 --insecure -e "SELECT * FROM node.nodes_info WHERE node_id='$AGENT_ID' "
printf "\n"

printf "# charts count: \n"
kubectl -n infra exec pod/crdb-cockroachdb-0 -- ./cockroach sql --host=localhost:26257 --insecure -e "SELECT count(*) AS number_of_charts FROM node.node_charts WHERE node_id='$AGENT_ID' "
printf "\n"

printf "# charts with default context: \n"
kubectl -n infra exec pod/crdb-cockroachdb-0 -- ./cockroach sql --host=localhost:26257 --insecure -e "SELECT * FROM node.node_charts WHERE node_id='$AGENT_ID' AND context IN ('system.cpu', 'mem.available', 'disk.io', 'net.net') "
printf "\n"

printf "# configured alarms: \n"
kubectl -n infra exec pod/crdb-cockroachdb-0 -- ./cockroach sql --host=localhost:26257 --insecure -e "SELECT count(*) AS number_of_alarms FROM node.node_alarms WHERE node_id='$AGENT_ID'"
printf "\n"

printf "# active alarms: \n"
kubectl -n infra exec pod/crdb-cockroachdb-0 -- ./cockroach sql --host=localhost:26257 --insecure -e "SELECT * FROM node.node_alarm_events WHERE node_id='$AGENT_ID' AND status != 'cleared'"
printf "\n"

printf "# node service node matview (availableCharts omitted): \n"
printf "use nodes-svc; \n db.nodes.find({\"_id\":\"$AGENT_ID\"}, {\"availableCharts\": 0})" \
    | kubectl -n mongodb exec -i $(kubectl get -n mongodb pods -o name | grep -m1 mongos | cut -d'/' -f 2) -- bash -c 'mongo -u root -p $(<$MONGODB_ROOT_PASSWORD_FILE)'
printf "\n"

printf "# spaceroom service node matview (contexts omitted): \n"
printf "use spaceroom-svc; \n db.nodes.find({\"_id\":\"$AGENT_ID\"}, {\"contexts\": 0})" \
    | kubectl -n mongodb exec -i $(kubectl get -n mongodb pods -o name | grep -m1 mongos | cut -d'/' -f 2) -- bash -c 'mongo -u root -p $(<$MONGODB_ROOT_PASSWORD_FILE)'
printf "\n"

printf "# data ctrl node matview: \n"
printf "use agent-data-ctrl; \n db.nodes.find({\"_id\":\"$AGENT_ID\"})" \
    | kubectl -n mongodb exec -i $(kubectl get -n mongodb pods -o name | grep -m1 mongos | cut -d'/' -f 2) -- bash -c 'mongo -u root -p $(<$MONGODB_ROOT_PASSWORD_FILE)'
printf "\n"
