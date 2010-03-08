<?

// this script shows the part of php.ini that actually changes something to a non-default value

function get_config($args)
{
	$cmd = 'php '.$args.' -r '.escapeshellarg(
		'$x = get_loaded_extensions(); $x[] = null; $s = array(); ' .
		'foreach($x as $name) foreach(ini_get_all($name, false) as $k=>$v) $s[$k] = $v; ' .
		'echo base64_encode(serialize($s));'
	);
	$x = exec($cmd, $out, $err);
	if($err) die('error in cmd: '.$cmd."\n");

	return unserialize(base64_decode($x));
}

function fix_value($v, $definition)
{
	$def = strtolower(trim($definition));
	if($def == 'on' || $def == 'off')
	{
		return $v ? 'On' : 'Off';
	}
	return $v;
}


$ignored_lines = array_filter(explode("\n", "

engine = On
unserialize_callback_func =
safe_mode_include_dir =
auto_prepend_file =
auto_append_file =
doc_root =
user_dir =

"));


array_shift($argv); // removing script filename

$fname = $argv[0];

$orig_config = get_config('-n');
$config = get_config('-c '.escapeshellarg($fname));

$n_comments = 0;
$n_ignored  = 0;
$section = '';
foreach(file($fname) as $line)
{
	$line = trim($line);
	if($line == '' || substr($line, 0, 1) == ';')
	{
		$n_comments++;
		continue;
	}

	if(substr($line, 0, 1) == '[')
	{
		$section = $line;
		continue;
	}

	if(in_array($line, $ignored_lines))
	{
		$n_ignored++;
		continue;
	}

	$cmt = '';
	if(preg_match('/^([^=\s]+)\s*=(.*)$/', $line, $m))
	{
		$key = $m[1];
		if(isset($config[$key]) && isset($orig_config[$key]))
		{
			$v  = fix_value($config[$key], $m[2]);
			$vo = fix_value($orig_config[$key], $m[2]);
			if($v == $vo) continue;
			$cmt = "; orig '$vo'";
		}
	}

	if($section != '')
	{
		echo "\n";
		echo $section."\n";
		$section = '';
	}
	if($cmt) echo $cmt."\n";
	echo $line."\n";
}
