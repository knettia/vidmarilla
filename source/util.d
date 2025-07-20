module util;

import std.exception;

/// Returns a string representing the expected timestamp format
string timestamp_format_example()
{
	return "HH:MM:SS.mmm";
}

/// Creates an error message for an invalid timestamp
string invalid_timestamp_message(string ts, string entry, string file, string target)
{
	return "Invalid timestamp `"
	       ~ ts
	       ~ "` in entry `"
	       ~ entry
	       ~ "` of clip `"
	       ~ file
	       ~ "` for target `"
	       ~ target
	       ~ "`. "
	       ~ "Consider using the format: `"
	       ~ timestamp_format_example()
	       ~ "`.";
}

import dyaml.node;

/// Parses a colour from a YAML node and returns it as a hexadecimal string
string parse_colour(Node node)
{
	import std.format;
	import std.conv;

	enforce(node.type != NodeType.null_, "Unexpected null value.");

	if (node.type == NodeType.string)
	{
		auto colour = node.as!string;

		if (colour.length == 7 && colour[0] == '#')
		{
			auto hex_part = colour[1 .. $];
			enforce(is_valid_hex(hex_part), "`#RRGGBB` contains invalid hexadecimal digits.");
			return "0x" ~ hex_part;
		}
		else if (colour.length == 8 && colour[0 .. 2] == "0x")
		{
			auto hex_part = colour[2 .. $];
			enforce(is_valid_hex(hex_part), "`0xRRGGBB` contains invalid hexadecimal digits.");
			return colour;
		}
		else if (colour.length == 6)
		{
			enforce(is_valid_hex(colour), "`RRGGBB` contains invalid hexadecimal digits.");
			return "0x" ~ colour;
		}
		else
		{
			throw new Exception(
				"Invalid colour format in YAML node: `" ~ node.tag() ~ "`\n"
				~ "Acceptable formats: `#RRGGBB`, `0xRRGGBB`, or `RRGGBB`."
			);
		}
	}
	else if (node.type == NodeType.sequence)
	{
		auto seq = node.as!string[];
		enforce(seq.length == 3, "Expected sequence of 3 integers for RGB, received " ~ to!string(seq.length));

		auto r = parse_and_validate_rgb(seq[0]);
		auto g = parse_and_validate_rgb(seq[1]);
		auto b = parse_and_validate_rgb(seq[2]);

		return format("0x%02X%02X%02X", r, g, b);
	}
	else if (node.type == NodeType.mapping)
	{
		enforce(
			node.containsKey("r") && node.containsKey("g") && node.containsKey("b"),
			"Expected mapping with keys `r`, `g`, and `b`."
		);

		auto r = parse_and_validate_rgb(node["r"].as!int);
		auto g = parse_and_validate_rgb(node["g"].as!int);
		auto b = parse_and_validate_rgb(node["b"].as!int);

		return format("0x%02X%02X%02X", r, g, b);
	}
	else
	{
		throw new Exception("Invalid colour format in YAML node.");
	}
}

/// Checks if a given hexadecimal string is valid
bool is_valid_hex(string hex)
{
	foreach (c; hex)
	{
		if (!((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f')))
		{
			return false;
		}
	}
	return true;
}

/// Parses an integer and checks if it is a valid RGB component (0-255)
uint parse_and_validate_rgb(int value)
{
	enforce(value >= 0 && value <= 255, "RGB component value must be between 0 and 255.");
	return cast(uint)value;
}

/// Checks if a given format is supported
bool is_valid_format(string format)
{
	return format == "mp4"
	    || format == "vob"
	    || format == "avi"
	    || format == "mkv"
	    || format == "webm"
	    || format == "mov"
	    || format == "ogg" || format == "ogv";
}
