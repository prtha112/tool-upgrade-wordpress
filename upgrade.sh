#!/bin/bash
# Credit : https://developer.wordpress.org/advanced-administration/upgrade/upgrading/

plugins_version_filename="plugins_version.txt"
wordpress_version_filename="wordpress_version.txt"

Clean_tmp_file () {
    rm -rf $1
}

Clean_wordpress_folder () {
    rm -rf $1/tmp
    rm -rf $1/wp-admin
    rm -rf $1/wp-includes
    rm -rf $1/.buildcomplete
    rm -rf $1/index.php
    rm -rf $1/license.txt
    rm -rf $1/readme.html
    find $1 -maxdepth 1 -type f -name "*.php" ! -name "wp-config.php" -exec rm -f {} +
}

Move_file_to_folder () {
    yes | cp -r $1/* $2
}

Download_new_version () {
    for wp_plugin in `cat $1` 
    do 
        echo "$wp_plugin"
        file_name=$(basename "$wp_plugin")
        wget -q "$wp_plugin" -P ./tmp --show-progress
        unzip -q "./tmp/$file_name" -d "$2"
    done 
}

mkdir -p plugins
mkdir -p tmp

Download_new_version "./$plugins_version_filename" "./plugins" 
Download_new_version "./$wordpress_version_filename" "." 

Clean_wordpress_folder "$1"

Move_file_to_folder "./wordpress" "$1"
Move_file_to_folder "./plugins" "$1/wp-content/plugins"

Clean_tmp_file "./tmp"
Clean_tmp_file "./plugins"
Clean_tmp_file "./wordpress"

echo -e "\n######################\n"
echo -e "Go to this url for update database your wordpress : \nhttps://example.com/wp-admin/upgrade.php\nhttps://example.com/blog/wp-admin/upgrade.php"