#!/bin/bash

function usage {
	echo "
	Some shitty batch script to run mysql schema/patches from a well-defined directory

	Executing the bash file requires that MySQL client is installed and the PHP file phpdbi found in same package
	When executing the bash file (phpdbi.sh), you can specify the following parameters

	-p : The absolute path to required PHP file, defaults to ./phpdbi.php
	-d : The absolute path to the directory containing the schema file and patches directory. For exampe /var/apps/myapp/sql
	-c : Connection parameters that will be used with MySQL client. Specify same parameters as used when running the
		 mysql comman in a string for example -c \"-h 127.0.0.1 -u root -pMyPassword -D datbasename\"
		 Depending on your configuration, you might be promted to enter DB password again.

	Examples:

	./phpdbi.sh -d /var/apps/myapp/sql -c \"-h 127.0.0.1 -u root -pMyPassword -D datbasename\" (assumes phpdbi.php is in pwd)
	./phpdbi.sh -p /usr/share/php/phpdbi.php -d /var/apps/myapp/sql -c \"-h 127.0.0.1 -u root -pMyPassword -D datbasename\"
	
	Defined directory should have file structure of the form
	
		schema.sql
		patches
		  001_first_patch.sql
		  002_second_patch.sql
		  ...

	"
	exit 1;
}

function checkPHPError {
	if [[ $1 == *PHP_DBI_ERROR* ]]; then
		echo $*;
		exit 1;
	fi
}

# Default variables
phpfile=$(pwd)/phpdbi.php
dir=
sqlConnect=

while getopts ":d:p:c:" opt; do
    case "$opt" in
		c)
			sqlConnect=$OPTARG
			;;
		d)
			dir=$OPTARG
			;;
		p)
			phpfile=$OPTARG
			;;
		\?)
			usage
			;;
		*)
			usage
			;;
    esac
done
shift $((OPTIND-1))

# Check if PHP module exists
if [ ! -f $phpfile ]
then
    echo "ERROR: Required PHP module $phpfile does not exist. Use -f option to provide path to this module";
	exit 1;
fi

# Check if SQL connection parameters are specified
if [ ! -n "$sqlConnect" ]
then
    echo "ERROR: Specify SQL connection parameters with -c option. For example -c \"-h host_name -u user_name -p password -D db_name\"";
	exit 1;
fi

# Get SQL schema/patches to be processed
sqlfiles=$(php $phpfile -d $dir)
checkPHPError $sqlfiles

# Run all SQL files that were gotten from PHP module
sqlrunfile=$dir/runqueries.sql;
cat >$sqlrunfile &
echo "">>$sqlrunfile
echo "-- Generating phpdbi SQL Run File $(date +%Y-%m-%d_%H:%M:%S)">>$sqlrunfile
patches=

for file in ${sqlfiles}; do
	if [[ $file == *patches* ]];
	then
		patches=$file,$patches
		statement="Executing ${file##*/} ..."
	else
		statement="Executing ${file##*/} ..."
	fi
	echo ";SELECT '$statement' AS ' ';">>$sqlrunfile;
	cat $file>>$sqlrunfile;
	echo ";SELECT 'Done' AS ' ';">>$sqlrunfile;
done

mysql $sqlConnect < $sqlrunfile;
if [ "$?" != "0" ]; then
	echo "Exiting execution due to error..."
	exit 1;
fi

# Save executed patches in lock file
locked=$(php $phpfile -r -d $dir -p $patches)
checkPHPError $locked

echo $locked > $dir/lock.json
#rm $sqlrunfile

echo "";
echo "Executed and Locked";
