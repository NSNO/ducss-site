#!/bin/bash

new_install=false
VENV_NAME='ducss-site'

if [ ! -d "../virtualenvs/$VENV_NAME" ]; then

	#
	# Check if Homebrew is installed
	#
	which -s brew
	if [[ $? != 0 ]] ; then
		# Install Homebrew
		# https://github.com/mxcl/homebrew/wiki/installation
		/usr/bin/ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
	else
		brew update
	fi

	# needs sudo for this to run.
	#which -s pip || easy_install pip
	which -s mysql || brew install mysql

	#
	# Check if Git is installed
	#
	which -s git || brew install git

	which -s python || brew install python --with-brewed-openssl

	# Needs to escalate to sudo to install virtualenv
	which -s virtualenv || pip install virtualenv

	#Setting up virtualenv
	if [ ! -d "../virtualenvs" ]; then
		mkdir "../virtualenvs"
	fi

	virtualenv --no-site-packages "../virtualenvs/$VENV_NAME"

	source "../virtualenvs/$VENV_NAME/bin/activate"

	#
	# Check if Memcached is installed
	#
	which -s memcached || brew install memcached

	#
	# Install application requirements
	#
	pip install -r requirements.txt || { echo ' === localrun failed. pip could not installed the required files. === ' ; exit 1; }
else
	source "../virtualenvs/$VENV_NAME/bin/activate"
fi


if [ ! -f "project/database.sqlite3" ]; then
	new_install=true
fi
( cd project ; python manage.py syncdb --noinput);
( cd project ; python manage.py migrate);

if $new_install ; then
	echo ' ==== First Time Setup - Create an Administration Account ==== '; 
	( cd project ; python manage.py createsuperuser );
fi
( cd project ; python manage.py runserver );

