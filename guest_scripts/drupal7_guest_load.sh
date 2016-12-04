#!/usr/bin/env bash

# Load guest variables for passwords, projects, etc.
source guest_vars.cfg

# add a Drupal db
#clean up first
echo "Dropping database drupal_vagrant if it already exists."
sudo mysql -uroot -p12345678 -e "DROP DATABASE IF EXISTS drupal_vagrant"

echo "Creating new database drupal_vagrant"
sudo mysql -uroot -p12345678 -e "create database drupal_vagrant"

echo "backing up project files"
cd /var/www/html
mv "${PROJECTFOLDER}" "${PROJECTFOLDER}_bak"

#test for existing project archive and database dump. Both must be present to restore a project.
if [ ! -e "/vagrant/project_io/${PROJECTFOLDER}.tgz" ] || [ ! -e "/vagrant/project_io/${PROJECTFOLDER}.sql" ]
	then
		echo "instantiating a new project: ${PROJECTFOLDER}"
		# Tasks for a new  site
		# install drupal7 in project folder
		echo "downloading file"
		drush dl drupal-7.x --drupal-project-rename="${PROJECTFOLDER}"
		cd "${PROJECTFOLDER}"
		CURDIR="$(pwd)"
		echo $CURDIR
		drush site-install standard --account-name=admin --account-pass=admin "--db-url=mysql://root:$PASSWORD@localhost/drupal_vagrant"
	else
		echo "Restoring project: ${PROJECTFOLDER}"
		# Tasks for an existing site with a db_dump and archive in project_io
		# deploy the site archive
		cd "${PROJECTFOLDER}"
		mv "/vagrant/project_io/${PROJECTFOLDER}.tgz" .
		tar -xvf "${PROJECTFOLDER}.tgz"
		rm "${PROJECTFOLDER}.tgz"
		* import the db dump
		drush sql-drop
		drush sql-cli < "/vagrant/project_io/${PROJECTFOLDER}.sql"
fi

cd /home/vagrant/scripts