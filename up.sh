#!/usr/bin/env bash

# Set general config variables
eval $(sh `pwd`/lib/variable.sh export_config `pwd`/up/config)

# Prepare Docker env-file by general config variables
sh `pwd`/lib/variable.sh set_docker_config `pwd`/up/config yes $docker_env_file

# Set config variables
eval $(sh `pwd`/lib/variable.sh export_config `pwd`/up/configs/config_${1})

# Prepare Docker env-file by custom config variables
sh `pwd`/lib/variable.sh set_docker_config `pwd`/up/configs/config_${1} yes $docker_env_file

# Clone Magento
sh `pwd`/up/magento-clone.sh $mount_html_folder

# Run Docker container
docker run \
        --name container_config_${1} \
        -p 222:22 -p ${magento_install_port}:${magento_install_port} -p 443:443 \
        -dt \
        --volume ${mount_html_folder}:${html_folder}  --volume `pwd`:${tool_folder} \
        -w ${html_folder} \
#        --env-file ${docker_env_file} \
        ${docker_image}

# Prepare Environment
docker exec -it container_config_${1} sh ${tool_folder}/up/magento-setup.sh

# Install Magento
docker exec -it container_config_${1} sh ${tool_folder}/up/magento-install.sh

# Configure Magento
docker exec -it container_config_${1} sh ${tool_folder}/up/magento-configure.sh

# Final Step
docker exec -it container_config_${1} sh ${tool_folder}/up/final-step.sh