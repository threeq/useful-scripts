#!/usr/bin/env bash

host="$1"

scp -r ${host}:/root/* ./