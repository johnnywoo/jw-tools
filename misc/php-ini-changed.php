<?

// this script shows the part of php.ini that actually changes something to a non-default value


// NO EXTENSIONS!


function get_config($args)
{
	$cmd = 'php '.$args.' -r '.escapeshellarg('echo base64_encode(serialize(ini_get_all(null, false)));');
	$x = exec($cmd, $out, $err);
	if($err) die('error in cmd: '.$cmd."\n");

	return unserialize(base64_decode($x));
}

array_shift($argv); // removing script filename

$verbose = false;
if($argv[0] == '-v')
{
	$verbose = true;
	array_shift($argv);
}

$fname = $argv[0];
if($verbose) echo "Analyzing $fname\n";

$orig_config = get_config('-n');
$config = get_config('-c '.escapeshellarg($fname));

$diff_keys = array_keys(array_diff_assoc($orig_config, $config));
// another round for them bools
foreach($diff_keys as $k=>$name)
{
	if($orig_config[$name] == '0' && !strlen($config[$name]))
	{
		unset($diff_keys[$k]);
	}
}

if($verbose)
{
	if(empty($diff_keys))
	{
		echo "\nConfigs are identical\n";
		exit;
	}
	else
	{
		echo "\nDirective => Given file => Default\n";
		foreach($diff_keys as $name)
		{
			echo "$name => ".$config[$name].' => '.$orig_config[$name]."\n";
		}

		echo "\nCleaned config file:\n";
	}
}

foreach(file($fname) as $line)
{
	// ignoring comments, sections and empty lines
	if(!preg_match('/^\s*([^\s;\]]+)\s*=/', $line, $m)) continue;
	$name = $m[1];
	// ignoring non-change lines
	if(!in_array($name, $diff_keys)) continue;
	echo $line;
}