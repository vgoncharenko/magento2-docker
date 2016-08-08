#!/usr/bin/env bash

html_folder=$1
# Set Git credentials
eval $(sh `pwd`/lib/variable.sh export_config `pwd`/up/magento-clone/credentials)

# Set magento-clone config file
eval $(sh `pwd`/lib/variable.sh export_config `pwd`/up/magento-clone/config)

# clone magento
if [ ! -d $html_folder ]; then
    mkdir -p ${html_folder}
fi
cd $html_folder
if [ $magento_download_type == "composer" ]; then
    if [ $magento_edition == "CE" ]; then
       theme_di_file_path=$magento_dir'/vendor/magento/module-theme/etc/di.xml'
       edition_type='project-community-edition'
    else
        theme_di_file_path=$magento_dir'/vendor/magento/module-enterprise/etc/di.xml'
        edition_type='project-enterprise-edition'
    fi
    composer create-project --repository-url=https://repo.magento.com/ magento/$edition_type=$magento_composer_version $github_magento_ce_dir
else
    if [ $magento_edition == "CE" ]; then
       theme_di_file_path="${magento_dir}/app/code/Magento/Theme/etc/di.xml"
    else
       theme_di_file_path="${magento_dir}/app/code/Magento/Enterprise/etc/di.xml"
    fi
    # Clone CE
    echo 'Clone CE'
	git clone --depth=1 -b $github_magento_ce_branch https://${github_token}@${github_magento_ce_url//https:\/\//}
    # Clone EE
    if [ $magento_edition == "EE" ] || [ $magento_edition == 'B2B' ]; then
       echo 'Clone EE'
       git clone --depth=1 -b $github_magento_ee_branch https://${github_token}@${github_magento_ee_url//https:\/\//}
       cp -R $github_magento_ee_dir/* $github_magento_ce_dir
    fi
    # Clone B2B
    if [ $magento_edition == "B2B" ]; then
       echo 'Clone B2B'
       git clone --depth=1 -b $github_magento_b2b_branch https://${github_token}@${github_magento_b2b_url//https:\/\//}
       cp -R $github_magento_b2b_dir/* $github_magento_ce_dir
    fi
    # Run composer install to fetch Magento dependencies
    cd $github_magento_ce_dir
    composer install
fi

# Add new variables to docker env file
echo "theme_di_file_path=${theme_di_file_path}" >> $docker_env_file
