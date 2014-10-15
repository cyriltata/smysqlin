phpdbi
======

## requirements

- bash
- PHP >= 5.3
- mysql client
- an empty/existing MySQL database
 
## installation

No formal install process for now. Just copy the files *phpdbi.sh* and *phpdbi.php* to some directories you will remeber.
** When creating your sql files, all statements should end with a semi colol (;)**

## in brief

Some simple shell script (that requires the associated PHP file) to automate MySQL schema installs and update patches from a pre-defined structure as explained below:
 
In your application, have a directory containing:

 1. FILE *schema.sql* - The base DB schema for your application
 2. DIR *patches* - In this directory, sql files to patch the initial schema can be placed and MUST be prefixed
 with numeric values, preferably numbered incrementally. For example your patches directory can contain files like
  - 001_some_patch.sql
  - 002_here_is_another_patch.sql
 
So a typical directory structure to work with will look like
```
- schema.sql
- patches
  - 001_first_patch.sql
  - 002_second_patch.sql
  - 003_third_patch.sql
```

## usage

 Executing the bash file requires that MySQL client and you can specify the following parameters
  
 * -p : The absolute path to this PHP file, defaults to ./phpdbi.php
 * -d : The absolute path to the directory containing the above mentioned files. For exampe /var/apps/myapp/sql
 * -c : Connection parameters that will be used with MySQL client. Specify same parameters as used when running the
 		mysql command in a string for example `-c "-h 127.0.0.1 -u root -pMyPassword -D datbasename"`
 	Depending on your configuration, you might be prompted to enter DB password again.
  
 **Examples:**
 ```
 ./phpdbi.sh -d /var/apps/myapp/sql -c "-h 127.0.0.1 -u root -pMyPassword -D datbasename" (assumes phpdbi.php is in pwd)
 ./phpdbi.sh -p /usr/share/php/phpdbi.php -d /var/apps/myapp/sql -c "-h 127.0.0.1 -u root -pMyPassword -D datbasename"
 ```
 You could move *phpdbi.sh* to */usr/bin/phpbdi* with `mv ./phpdbi.sh /usr/bin/phpdbi` and run directly as a bash command 
 
 ```
 phpdbi -d /var/apps/myapp/sql -c "-h 127.0.0.1 -u root -pMyPassword -D datbasename"
 ```
