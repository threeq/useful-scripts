#!/usr/bin/env bash

host="$1"
sub_path="$2"

ssh ${host} "mkdir -p /root/monitor-service/${sub_path}/"

echo "scp -r ./${sub_path}/* ${host}:/root/monitor-service/${sub_path}/"
scp -r ./${sub_path}/* ${host}:/root/monitor-service/${sub_path}/