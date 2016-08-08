#!/usr/bin/env bash

# Set file_name property
set_file_name () {
    file_name=$1
    if [ $file_name == '' ]; then
        echo 'Config file name is require param.'
    fi
}

# Export variables from config file
export_config () {
    set_file_name $1
    echo $(cat ${file_name} | sed 's/#.*$//' | sed '/^$/d' | sed 's/^/export /')
}

# Set config file variables to docker env-config file
set_docker_config () {
    set_file_name $1
    override=$2
    docker_env_file=$3

    if [ ! -d $temp_dir ]; then
        mkdir -p ${temp_dir}
    fi
    if [ $override == 'yes' ]; then
        cat ${file_name} | sed 's/#.*$//' | sed '/^$/d' | sed 's/ //g' > ${docker_env_file}
    else
        cat ${file_name} | sed 's/#.*$//' | sed '/^$/d' | sed 's/ //g' >> ${docker_env_file}
    fi
}

$@