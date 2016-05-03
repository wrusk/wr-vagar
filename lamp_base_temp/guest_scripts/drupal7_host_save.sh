#!/usr/bin/env bash

# Load guest variables for passwords, projects, etc.
source guest_vars.cfg

#back up existing archive and db_dump if they exist
if [ -e "/vagrant/project_io/${PROJECTFOLDER}.tgz"] 
	then
		mv "/vagrant/project_io/${PROJECTFOLDER}.tgz" "/vagrant/project_io/${PROJECTFOLDER}_old.tgz"
fi

if [ -e "/vagrant/project_io/${PROJECTFOLDER}.sql"] 
	then
		mv "/vagrant/project_io/${PROJECTFOLDER}.sql" "/vagrant/project_io/${PROJECTFOLDER}_old.sql"
fi

#create a tgz archive of the project directory
cd /var/www/html
cd "${PROJECTFOLDER}"
tar -czvf "/vagrant/project_io/${PROJECTFOLDER}.tgz" .

#create a db dump of the project
drush cc all
drush sql-dump > "/vagrant/project_io/${PROJECTFOLDER}.sql"

cd /home/vagrant/scripts