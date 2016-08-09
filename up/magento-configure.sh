#!/usr/bin/env bash

export mysql_cmd="mysql -u${db_magento_user} -p${db_magento_pass} -h${db_host} -D ${db_magento_name}"
cd $magento_dir
if [ $magento_install_table_prefix == '-' ]; then
    export db_prefix=''
else
    export db_prefix=$magento_install_table_prefix
fi

# magento::setup::db
    # Set WYSIWYG Editor
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'cms/wysiwyg/enabled','${magento_config_wysiwyg_editor}'"
    #Set Admin account sharing
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'admin/security/admin_account_sharing','${magento_config_admin_account_sharing}'"
    #Set JS Bundling
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'dev/js/enable_js_bundling','${magento_config_js_bundling}'"
    #Set Merge JS
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'dev/js/merge_files','${magento_config_js_merge}'"
    #Set Minify JS
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'dev/js/minify_files','${magento_config_js_minification}'"
    #Set Minify CSS
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'dev/css/minify_files','${magento_config_css_minification}'"
    #Set Merge CSS
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'dev/css/merge_css_files','${magento_config_css_merge}'"
    #Set Minify HTML':
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'dev/template/minify_html','${magento_config_html_minification}'"
    # Use Flat Catalog Category
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'catalog/frontend/flat_catalog_category','${magento_config_flat_catalog_category}'"
    # Use Flat Catalog Product
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'catalog/frontend/flat_catalog_product','${magento_config_flat_catalog_product}'"
# magento::setup::ssl
if [ $magento_ssl_enable == "true" ]; then
    #Enable URLs on Storefront
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'web/secure/use_in_frontend','1'"
    #Enable URLs in Admin
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'web/secure/use_in_adminhtml','1'"
fi
# magento::setup::varnish
if [ $varnish_enabled == "true" ]; then
    # Set Varnish Caching Application
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'system/full_page_cache/caching_application','2'"
    # Set Varnish Access list
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'system/full_page_cache/varnish/access_list','${hostname}'"
    # Set Varnish backend port
    sh ${tool_folder}/lib/mysql.sh insert_core_config "'system/full_page_cache/varnish/backend_port','${web_server_listen_port}'"
    # Set cache hosts
    php -f bin/magento setup:config:set --http-cache-hosts=${ip}:${varnish_listen_port}
fi
# magento::setup::magento_cli
if [ $magento_application_mode != 'default' ]; then
    # Set application mode
    echo Set application mode
    php -f bin/magento deploy:mode:set ${magento_application_mode}
    echo 'done'
fi

if [ $magento_deploy_static == 'true' ] && [ $magento_application_mode != 'production' ]; then
    # Compiling static content
    echo Compiling static content
    if [ $magento_install_language == 'en_US' ]; then
        php -f bin/magento setup:static-content:deploy
    else
        php -f bin/magento setup:static-content:deploy en_US ${magento_install_language}
    fi
    echo 'done'
fi

if [ $magento_compilation == 'true' ] && [ $magento_application_mode != 'production' ]; then
    # Run compilation command
    echo Run compilation command
    php -f bin/magento setup:di:compile
    echo 'done'
fi

#Set index mode type
echo Set index mode type
php -f bin/magento indexer:set-mode ${magento_index_mode}
echo 'done'

# Run Magento reindex
echo Run Magento reindex
php -f bin/magento indexer:reindex
echo 'done'

# Set cache status
echo Set cache status
php -f bin/magento cache:${magento_cache_status}
echo 'done'

# Flush cache
echo Flush cache
php -f bin/magento cache:flush
echo 'done'