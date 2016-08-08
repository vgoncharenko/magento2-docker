#!/usr/bin/env bash

if [ $magento_install_port == "80" ]; then
   magento_base_url=$hostname
else
   magento_base_url=$hostname':'$magento_install_port
fi

if [ $magento_ssl_enable == "true" ]; then
   magento_base_url_secure="--base-url-secure=https://${hostname}/"
else
   magento_base_url_secure=''
fi

if [ $magento_install_table_prefix == "-" ]; then
   db_prefix=""
else
   db_prefix='--db-prefix='$magento_install_table_prefix
fi

if [ $rabbitmq_enabled == "true" ]; then
   amqp="--amqp-host=${rabbitmq_amqp_host} --amqp-port=${rabbitmq_amqp_port} --amqp-user=${rabbitmq_amqp_user} --amqp-password=${rabbitmq_amqp_pass}"
else
   amqp=''
fi

sed -i "s'<item name=\"frontend\" xsi:type=\"string\">Magento/luma</item>'<item name=\"frontend\" xsi:type=\"string\">Magento/${magento_theme}</item>'g" $theme_di_file_path
cd $magento_dir
chown -R $server_group . &
find . -type d -exec chmod 770 {} \; && find . -type f -exec chmod 660 {} \; && chmod u+x bin/magento
php -f bin/magento setup:install --base-url=http://${magento_base_url} ${magento_base_url_secure} --backend-frontname=${magento_install_backend_frontname} --session-save=${magento_install_session_save} --admin-use-security-key=${magento_install_admin_secret_key} --db-host=${db_host} --db-name=${db_magento_name} --db-user=${db_magento_user} --db-password=${db_magento_pass} ${db_prefix} --admin-firstname=John --admin-lastname=Doe --admin-email=admin@example.com --admin-user=${magento_install_admin_user} --admin-password=${magento_install_admin_pass} --language=${magento_install_language} --currency=${magento_install_currency} --timezone=${magento_install_timezone} --use-rewrites=${magento_install_use_rewrites} ${amqp}
# scalable_checkout_install
if [ $magento_scalable_checkout == 'true' ] && [ $magento_edition == "EE" ]; then
   quote_db_host=$quote_db_host
   sales_db_host=$sales_db_host
   #Create scalable checkout
   php -f bin/magento setup:db-schema:split-quote --host=${quote_db_host} --dbname=${db_magento_name}_quote --username=${db_magento_user} --password=${db_magento_pass}
   #Create scalable OMS
   php -f bin/magento setup:db-schema:split-sales --host=${sales_db_host} --dbname=${db_magento_name}_sales --username=${db_magento_user} --password=${db_magento_pass}
fi
