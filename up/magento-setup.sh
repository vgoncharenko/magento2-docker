#!/usr/bin/env bash

# Wait for mysql is UP
sh ${tool_folder}/lib/mysql.sh wait_mysql_start

# Create Magento Database if it need
sh ${tool_folder}/lib/mysql.sh create_bd ${db_magento_name}