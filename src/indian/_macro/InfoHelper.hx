package indian._macro;

class InfoHelper
{
	macro public static function isWindows()
	{
		return macro $v{Sys.systemName() == "Windows"};
	}

	macro public static function isM64()
	{
		if (Sys.systemName() == "Windows")
		{
			return macro false;
			// var architecture = Sys.getEnv ("PROCESSOR_ARCHITEW6432");
			// if (architecture != null && architecture.indexOf ("64") > -1)
			// {
			// 	return macro true;
			// }
			// else
			// {
			// 	return macro false;
			// }
		}
		else
		{
			var process = new sys.io.Process("uname", [ "-m" ]);
			var output = process.stdout.readAll().toString();
			var error = process.stderr.readAll().toString();
			process.exitCode();
			process.close();

			if (output.indexOf("64") > -1)
			{
				return macro true;
			}
			else
			{
				return macro false;
			}
		}
	}
}
