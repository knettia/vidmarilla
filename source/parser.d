module parser;

import std.stdio;
import std.file;
import std.conv;
import util;

struct ClipSegment
{
	string file;
	string start;
	string end;
}

struct Target
{
	string format;
	string background;
	ClipSegment[] sequence;
}

bool is_valid_timestamp(string ts)
{
	import std.regex;

	auto re = regex(r"^\d{2}:\d{2}:\d{2}(\.\d{1,3})?$");

	auto m = match(ts, re);
	return !m.empty;
}

Target parse_target(string name, string source)
{
	import dyaml;

	auto document = Loader.fromString(source);

	auto root = document.load();
	auto targets_node = root["targets"];

	foreach (string key, Node target_node; targets_node)
	{
		if (key != name)
			continue;

		Target target;

		target.background = "0x000000"; // Default background color

		string format = target_node["format"].as!string;

		if (target_node.containsKey("format"))
		{
			format = target_node["format"].as!string;
			enforce(is_valid_format(format), "Invalid format specified: `" ~ format ~ "`");
		}
		else
		{
			format = "mp4";
		}

		target.format = format;

		if (target_node.containsKey("background"))
		{
			auto bg_node = target_node["background"];
			target.background = parse_colour(bg_node);
		}

		if (!target_node.containsKey("sequence"))
			throw new Exception("No sequence found for target `" ~ name ~ "`");

		auto seq_node = target_node["sequence"];

		uint seq_id = 0;

		foreach (Node entry; seq_node.sequence)
		{
			seq_id++;

			ClipSegment seg;
			seg.start = "";
			seg.end = "";

			if (entry.type == NodeType.string)
			{
				seg.file = entry.as!string;
			}
			else
			{
				seg.file = entry["file"].as!string;

				if (entry.containsKey("start"))
				{
					enforce(
						is_valid_timestamp(entry["start"].as!string),
						invalid_timestamp_message(entry["start"].as!string, "start", seg.file, name)
					);

					seg.start = entry["start"].as!string;
				}

				if (entry.containsKey("end"))
				{
					enforce(
						is_valid_timestamp(entry["end"].as!string),
						invalid_timestamp_message(entry["end"].as!string, "end", seg.file, name)
					);

					seg.end = entry["end"].as!string;
				}
			}

			enforce(
				exists(seg.file), 
				"File `" ~ seg.file ~ "` not found for target `" ~ name ~ "`"
			);

			target.sequence ~= seg;
		}

		return target;
	}

	throw new Exception("No target named `" ~ name ~ "` found.");
}
