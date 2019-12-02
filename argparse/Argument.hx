package argparse;

@:forward(iterator, shift)
abstract Flags(Array<String>) from Array<String> to Array<String>
{
	@:from static function fromString(str:String):Flags
	{
		return [str];
	}
}

enum Num
{
	Range(min:Int, max:Int);
	Infinite(min:Int);
}

@:forward(min, max)
abstract Range(Num) from Num to Num
{
	@:from static function fromString(str:String):Range
	{
		return switch (str)
		{
			case '+':
				Infinite(1);
			case '*':
				Infinite(0);
			case '?':
				Range(0, 1);
			default:
				// TODO: parse better range (e.g. 1-5)
				var n = Std.parseInt(str);
				var min = n == null ? 0 : n;
				Range(min, min);
		}
	}

	@:from static function fromInt(val:Int):Range
	{
		return Range(val, val);
	}
}

typedef ArgumentDef = {
	flags: Flags,
	?numArgs: Range,
	?defaultValue: String,
	?optional: Bool,
	?help:String,
}

class Argument
{
	public final name:String;
	public final numArgs:Range;
	public final optional:Bool;
	public final positional:Bool;
	public final defaultValue:Null<String>;

	static function stripDash(str:String):Null<String>
	{
		for (i in 0...str.length)
		{
			if (str.charCodeAt(i) != '-'.code)
			{
				return str.substr(i, str.length);
			}
		}
		return null;
	}

	static function getNameFromArray(array:Array<String>):String
	{
		var max:String = "";
		for (str in array)
		{
			var n = Argument.stripDash(str);
			if (n != null)
			{
				if (max.length < n.length)
				{
					max = n;
				}
			}
		}
		if (max.length == 0) throw "No valid flag was given";
		return max;
	}

	static function isPositional(array:Array<String>):Bool
	{
		for (str in array)
		{
			if (StringTools.startsWith(str, "-"))
			{
				return false;
			}
		}
		return true;
	}

	public function new(def:ArgumentDef)
	{
		name = Argument.getNameFromArray(def.flags);
		positional = Argument.isPositional(def.flags);
		defaultValue = def.defaultValue;

		if (def.numArgs == null)
		{
			numArgs = positional ? 1 : 0;
		}
		else
		{
			numArgs = def.numArgs;
		}

		if (def.optional == null)
		{
			optional = switch (numArgs) {
				case Range(min, _):
					min == 0;
				case Infinite(min):
					min == 0;
			}
		}
		else
		{
			optional = def.optional;
		}
	}
}
