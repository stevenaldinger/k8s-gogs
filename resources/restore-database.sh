#!/bin/bash

# install wget and pgfutter tool (https://github.com/lukasmartinelli/pgfutter)
# apt-get update && apt-get -y install wget && \
# cd ~ && \
# wget -O pgfutter https://github.com/lukasmartinelli/pgfutter/releases/download/v1.1/pgfutter_linux_amd64 && \

cp -f /pgfutter-dir/pgfutter /usr/bin/
chmod +x /usr/bin/pgfutter

export DB_USER=gogs
export DB_NAME=gogs
export DB_SCHEMA=public

for table in /sql/*.csv
do
  pgfutter csv --delimiter \; ${table} --dbname gogs --username gogs --schema public
done
