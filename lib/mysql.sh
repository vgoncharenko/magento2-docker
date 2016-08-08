#!/usr/bin/env bash

# Wait to start mysqld service on server
wait_mysql_start () {
    sleep 5
}

# Create bd
create_bd () {
    db_name=$1
    mysql -u${db_magento_user} -p${db_magento_pass} -h${db_host} -e "CREATE DATABASE IF NOT EXISTS ${db_name};"
}

# Insert data to DB core_config_data Table
insert_core_config () {
    values=$1
    ${mysql_cmd} -e "INSERT INTO ${db_prefix}core_config_data (path, value) VALUES (${values}) ON DUPLICATE KEY UPDATE path=VALUES(path), value=VALUES(value)"
}

$@