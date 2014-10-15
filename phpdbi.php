<?php

/**
 * PHP DB INSTALL
 * 
 * @package phpdbi
 * @author Cyril Tata <cyril.tata@gmail.com>
 * @license	GNU GPL
 * @version 1.0-1
 */

/**
 * This PHP file MUST used alongside the bash file phpdbi.sh in order to read and execute
 * MySQL queries from a pre-defined structure as explained below:
 * 
 * In your application, have a directory containing:
 *  1. FILE schema.sql - The base DB schema for your application
 *  2. DIR patches - In this directory, sql files to patch the initial schema can be placed and MUST the prefixed
 *     with numeric values, preferably numbered incrementally. For example your patches directory can contain files like
 *     - 001_some_patch.sql
 *     - 002_here_is_another_patch.sql
 * 
 * So a typical directory structure to work with will look like
 * ---- schema.sql 
 * ---- patches
 * -------- 001_first_patch.sql
 * -------- 002_second_patch.sql
 * -------- 003_third_patch.sql
 * 
 * Executing the bash file requires that MySQL client is installed
 * When executing the bash file (phpdbi.sh), you can specify the following parameters
 * 
 * -p : The absolute path to this PHP file, defaults to ./phpdbi.php
 * -d : The absolute path to the directory containing the above mentioned files. For exampe /var/apps/myapp/sql
 * -c : Connection parameters that will be used with MySQL client. Specify same parameters as used when running the
 *		mysql command in a string for example -c "-h 127.0.0.1 -u root -pMyPassword -D datbasename"
 *		Depending on your configuration, you might be prompted to enter DB password again.
 * 
 * Examples:
 * 
 * ./phpdbi.sh -d /var/apps/myapp/sql -c "-h 127.0.0.1 -u root -pMyPassword -D datbasename" (assumes phpdbi.php is in pwd)
 * ./phpdbi.sh -p /usr/share/php/phpdbi.php -d /var/apps/myapp/sql -c "-h 127.0.0.1 -u root -pMyPassword -D datbasename"
 *
 */

date_default_timezone_set('Europe/Berlin');

class PHP_DBI {

	/**
	 * Absolute path to where sql schema and patches are present
	 * Should have at least write permissions by the user running this script
	 *
	 * @var string
	 */
	protected $installDir;

	/**
	 * Absolute path to directory containing sql patches
	 *
	 * @var string
	 */
	protected $patchesDir;

	/**
	 * Path to lock file. This file will be used to register what patches have been run and so on.
	 *
	 * @var string
	 */
	protected $lockFile;

	/**
	 * Absolue path to initial schema file
	 *
	 * @var string
	 */
	protected $schemaFile;

	/**
	 * An array that will contain paths of sql sources to be returned to bactch script for execution
	 *
	 * @var Array
	 */
	protected $sources = array();

	/**
	 * @var boolean
	 */
	protected $lock = false;

	/**
	 * If true, lock contents will be returned
	 *
	 * @var boolean
	 */
	protected $rlock = false;

	/**
	 * @var string
	 */
	protected $patches;

	protected function __construct() {
		$options = getopt('lrd:p:');
		if (empty($options['d'])) {
			throw new PHP_DBI_Exception("Specify a directory with a -d option");
		}

		if (!is_dir($options['d'])) {
			throw new PHP_DBI_Exception("'{$options['d']}' is not a valid directory");
		}

		$this->installDir = $options['d'];
		$this->lockFile = $this->installDir . '/lock.json';
		$this->patchesDir = $this->installDir . '/patches';
		$this->schemaFile = $this->installDir . '/schema.sql';
		$this->lock = isset($options['l']);
		$this->rlock = isset($options['r']);
		$this->patches = !empty($options['p']) ? explode(',', trim($options['p'])) : array();
	}

	/**
	 * @return PHP_DBI
	 */
	public static function getInstance() {
		return new self();
	}

	/**
	 * If lock file is already present, it means we just need to run patches
	 * as schema must have been presen already
	 */
	public function run() {
		if ($this->lock) {
			return $this->processLock();
		}

		if ($this->rlock) {
			return $this->processLock(true);
		}

		if (!file_exists($this->lockFile)) {
			return $this->processSchema();
		} else {
			return $this->processPatches();
		}
	}

	protected function processSchema() {
		if (!file_exists($this->schemaFile)) {
			throw new PHP_DBI_Exception("Schema file {$this->schemaFile} not found.");
		}
		$this->sources[] = $this->schemaFile;
		return $this->processPatches();
	}

	protected function processPatches() {
		$patches = glob($this->patchesDir . "/*.sql");
		$lock = $this->getLockContents();
		$lockPatches = !empty($lock->patches) ? $lock->patches : array();

		foreach ($patches as $file) {
			$number = (int) basename($file);
			$patch_name = PHP_DBI_Patch::name($number);
			if (!isset($lockPatches[$patch_name])) {
				$this->sources[] = $file;
			}
		}
		return $this->sources;
	}

	protected function processLock($return = false) {
		/* @var $lock = PHP_DBI_Lock */
		if (($lock = $this->getLockContents()) !== null && !empty($lock)) {
			// append the new patches that we run and passed to script
			foreach ($this->patches as $patchfile) {
				$patchfile = trim($patchfile);
				if (!$patchfile || !is_file($patchfile)) {
					continue;
				}
				$number = (int) basename($patchfile);
				$patch_name = PHP_DBI_Patch::name($number);
				$lock->patches[$patch_name] = PHP_DBI_Model::map(array(
					'number' => $number,
					'file' => $patchfile,
					'rundate' => date('r'),
					'done' => true,
				), 'PHP_DBI_Patch');
			}
		} else {
			// this is the first time lock is being processed
			$lock = PHP_DBI_Model::map(array(
				'patches' => array(),
				'created' => date('r'),
				'directory' => $this->installDir,
				'schema' => $this->schemaFile,
			), 'PHP_DBI_Lock');
			foreach ($this->patches as $patchfile) {
				$patchfile = trim($patchfile);
				if (!$patchfile || !is_file($patchfile)) {
					continue;
				}
				$number = (int) basename($patchfile);
				$patch_name = PHP_DBI_Patch::name($number);
				$lock->patches[$patch_name] = PHP_DBI_Model::map(array(
					'number' => $number,
					'file' => $patchfile,
					'rundate' => date('r'),
					'done' => true,
				), 'PHP_DBI_Patch');
			}
		}

		$contents = json_encode($lock);
		if (!$return && ($put = file_put_contents($this->lockFile, $contents)) === false) {
			$isDir = is_dir(dirname($this->lockFile)) ? 'yes' : 'no';
			throw new PHP_DBI_Exception("Unable to write lock file {$this->lockFile}. Dir Exists: {$isDir}. Contents: {$contents}}");
		} elseif ($return) {
			$put = $contents;
		}

		return $put;
	}

	protected function getLockContents() {
		if (file_exists($this->lockFile)) {
			$contents = json_decode(file_get_contents($this->lockFile));
			if (!$contents) {
				throw new PHP_DBI_Exception("Unable to read lock file {$this->lockFile}");
			}
			/* @var $lock = PHP_DBI_Lock */
			$lock = PHP_DBI_Lock::map($contents, 'PHP_DBI_Lock');
			return $lock;
		}

		return null;
	}
	
}

class PHP_DBI_Model {
	public static function map($data, $class = null) {
		$self =  $class ? new $class() :  new self();
		foreach ($data as $property => $value) {
			if (property_exists($self, $property)) {
				$self->{$property} = $value;
			}
		}
		return $self;
	}

	public static function multiMap($rows, $class = null) {
		$r = array();
		foreach ($rows as $data) {
			$r[] = PHP_DBI_Model::map($data, $class);
		}
		return $r;
	}
}

class PHP_DBI_Lock extends PHP_DBI_Model {
	public $created;
	public $directory;
	public $schema;
	public $patches = array();

	public static function map($data, $class = null) {
		/* @var $self PHP_DBI_Lock*/
		$self = PHP_DBI_Model::map($data, $class);
		$_patches = $self->patches;
		$self->patches = array();
		foreach ($_patches as $patch_name => $patch) {
			$patch = (array) $patch;
			if (is_numeric($patch_name)) {
				$patch_name = PHP_DBI_Patch::name($patch_name);
			}
			$self->patches[$patch_name] = PHP_DBI_Model::map($patch, 'PHP_DBI_Patch');
		}
		return $self;
	}
}

class PHP_DBI_Patch extends PHP_DBI_Model {
	public $number;
	public $file;
	public $rundate;
	public $done;

	public static function name($number) {
		return 'patch_' . $number;
	}
}

class PHP_DBI_Exception extends Exception {}

try {
	$results = PHP_DBI::getInstance()->run();
	if (!$results) {
		throw new PHP_DBI_Exception('No schema/patches to process');
	}

	if (is_array($results)) {
		$results = implode("\n", $results);
	}
	echo $results;
} catch (PHP_DBI_Exception $e) {
	echo 'PHP_DBI_ERROR: ' . $e->getMessage();
	exit(1);
}