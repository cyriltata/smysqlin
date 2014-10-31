#!/bin/bash

function usage {
	echo "
	Some simple batch script to run mysql schema/patches from a well-defined directory

	Executing the bash file requires that MySQL client is installed and bash 3.2.48 (OS X 10.8.2)
	When executing the bash file (smysqlin.sh), you MUST specify the following parameters

	-d : The absolute path to the directory containing the schema file and patches directory. For exampe /var/apps/myapp/sql
	-c : Connection parameters that will be used with MySQL client. Specify same parameters as used when running the
		 mysql comman in a string for example -c \"-h 127.0.0.1 -u root -pMyPassword -D datbasename\"
		 Depending on your configuration, you might be promted to enter DB password again.

	Examples:

	./smysqlin.sh -d /var/apps/myapp/sql -c \"-h 127.0.0.1 -u root -pMyPassword -D databasename\"
	
	Defined directory should have file structure of the form
	
		schema.sql
		patches
		  001_first_patch.sql
		  002_second_patch.sql
		  ...

	"
	exit 1;
}

# Default variables
dir=
sqlConnect=

while getopts ":d:c:" opt; do
    case "$opt" in
		c)
			sqlConnect=$OPTARG
			;;
		d)
			dir=$OPTARG
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

schemafile=$dir/schema.sql;
lockfile=$dir/patches.lock;
executed_patches=;

# Check if DIR where to read sql files exist
if [ ! -d $dir ]
then
    echo "ERROR: Directory $dir does not exist";
	exit 1;
fi

# Check if SQL connection parameters are specified
if [ ! -n "$sqlConnect" ]
then
    echo "ERROR: Specify SQL connection parameters with -c option. For example -c \"-h host_name -u user_name -p password -D db_name\"";
	exit 1;
fi

# Check if initial schema is present
if [ ! -f $schemafile ]; then
	echo "Schema file $schemafile does not exist";
	exit 1;
fi

if [ -f $lockfile ]; then
	executed_patches="$(cat $lockfile)";
fi

# Set up SQL file that will hold query blob
sqlrunfile=$dir/runqueries.sql;
cat >$sqlrunfile &
echo "">>$sqlrunfile
echo "-- Generating smysqlin SQL Run File $(date +%Y-%m-%d_%H:%M:%S)">>$sqlrunfile

# Processs schema
if [ ! -f $lockfile ]; then
	statement="Executing schema file ${schemafile##*/} ...";
	echo ";SELECT '$statement' AS ' ';">>$sqlrunfile;
	cat $schemafile>>$sqlrunfile;
	echo ";SELECT 'Done' AS ' ';">>$sqlrunfile;
	executed_patches="$executed_patches,$schemafile";
fi

# Process patches
patches=$dir/patches
for file in $patches/*.sql; do
	name=$(basename $file);
	#if a patch is not present in chunk of executed patches then add it to be executed
	if [[ ! "$executed_patches" =~ "$name" ]]; then
		statement="Executing patch file ${file##*/} ...";
		echo ";SELECT '$statement' AS ' ';">>$sqlrunfile;
		cat $file>>$sqlrunfile;
		echo ";SELECT 'Done' AS ' ';">>$sqlrunfile;
		executed_patches="$executed_patches,$file";
	fi
done;

mysql $sqlConnect < $sqlrunfile;
if [ "$?" != "0" ]; then
	echo "Exiting execution due to error..."
	exit 1;
fi

# Save executed patches in lock file
cat >$lockfile &
echo $executed_patches>$lockfile
rm $sqlrunfile

echo "";
echo "Executed and Locked";
