#!/bin/bash
# Credit : https://developer.wordpress.org/advanced-administration/upgrade/upgrading/

plugins_version_filename="plugins_version.txt"
wordpress_version_filename="wordpress_version.txt"

usage() {
  echo "Usage: $0 [-d directory] [-t upgrade type]"
  echo "Options:"
  echo "  -d    Directory wordpress"
  echo "  -t    Upgrade type (all=all, plugin=only plugin, wordpress=only wordpress)"
  exit 1
}

while getopts "d:t:" opt
do
   case "$opt" in
      d ) directory="$OPTARG" ;;
      t ) upgrade_type="$OPTARG" ;;
      ? ) usage ;; 
   esac
done

if [ -z "$directory" ] || [ -z "$upgrade_type" ] 
then
    usage
fi 

if [[ "$upgrade_type" != "all" && "$upgrade_type" != "plugin" && "$upgrade_type" != "wordpress" ]]; then
    echo "Error: Invalid upgrade type. Valid options are 'all' or 'plugin' or 'wordpress'." >&2
    usage
fi

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

function shutdown {
    echo "Shutting down application from entry script..."
    Clean_tmp_file "./tmp"
    Clean_tmp_file "./plugins"
    Clean_tmp_file "./wordpress"
    wait $pid
    echo "Shutdown completed successfully"
}

trap shutdown EXIT

mkdir -p plugins
mkdir -p tmp

if [[ $upgrade_type == "all" ]]; then
    echo "Upgrade both plugins and wordpress"

    Download_new_version "./$plugins_version_filename" "./plugins" 
    Download_new_version "./$wordpress_version_filename" "." 
    Clean_wordpress_folder "$directory"
    Move_file_to_folder "./wordpress" "$directory"
    Move_file_to_folder "./plugins" "$directory/wp-content/plugins"
fi

if [[ $upgrade_type == "plugin" ]]; then
    echo "Upgrade only plugins"

    Download_new_version "./$plugins_version_filename" "./plugins" 
    Move_file_to_folder "./plugins" "$directory/wp-content/plugins"
fi

if [[ $upgrade_type == "wordpress" ]]; then
    echo "Upgrade only wordpress"

    Download_new_version "./$wordpress_version_filename" "." 
    Clean_wordpress_folder "$directory"
    Move_file_to_folder "./wordpress" "$directory"
fi

echo -e "\n######################\n"
echo -e "Go to this url for update database your wordpress : \nhttps://example.com/wp-admin/upgrade.php\nhttps://example.com/blog/wp-admin/upgrade.php"