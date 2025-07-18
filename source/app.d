module main;

import std.stdio;
import std.file;
import std.getopt;

void main(string[] args)
{
	string target;

	if (args.length == 3 && args[1] == "build")
	{
		target = args[2];
	}
	else if (args.length != 2 || args[1] != "build")
	{
		writeln("Usage: vidmarilla build <target>");
		return;
	}

	if (!exists("vidmarilla.yaml"))
	{
		stderr.writeln("Error: 'vidmarilla.yaml' not found in current directory.");
		return;
	}

	auto source = readText("vidmarilla.yaml");

	import parser;

	Target config;

	try
	{
		config = parse_target(target, source);
	}
	catch (Exception e)
	{
		stderr.writeln(e.msg);
		return;
	}

	stdout.writeln(
		"Successfully read target `", target, "`.\n",
		"Preparing to assemble target `", target,"` to `", config.format, "` format."
	);

	import assembler;

	try
	{
		assemble_target(config);
		writeln("Video assembled successfully: ", target, ".", config.format);
	}
	catch (Exception e)
	{
		stderr.writeln("Assembly failed: ", e.msg);
	}
}
