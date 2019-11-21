package argparse;

@:forward(iterator, shift)
abstract Flags(Array<String>) from Array<String> to Array<String>
{
	@:from static function fromString(str:String):Flags
	{
		return [str];
	}
}

typedef ArgumentDef = {
	flags: Flags,
	?numArgs: Int,
	?defaultValue: String,
	?optional: Bool,
}

class Argument
{
	public final name:String;
	public final numArgs:Int;
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
		numArgs = def.numArgs == null ? 0 : def.numArgs;
		optional = def.optional == null ? false : def.optional;
		defaultValue = def.defaultValue;
	}
}
