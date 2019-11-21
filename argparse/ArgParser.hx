package argparse;

import argparse.Namespace;
import haxe.ds.StringMap;

@:forward(iterator)
abstract Flags(Array<String>) from Array<String> to Array<String>
{
	@:from static function fromString(str:String):Flags
	{
		return [str];
	}
}

typedef Argument = {
	var flags: Flags;
	var ?numArgs: Int;
	var ?defaultValue: String;
	var ?optional: Bool;
}

class ArgParser
{

	public function new()
	{
	}

	/**
	 * Add an argument to be parsed
	 */
	public function addArgument(arg:Argument)
	{
		if (arg.numArgs == null) arg.numArgs = 0;
		if (arg.optional == null) arg.optional = false;
		for (flag in arg.flags)
		{
			_args.set(flag, arg);
		}
	}

	public function parse(args:Array<String>):Namespace
	{
		var result = new Namespace();
		var it = args.iterator();
		while (it.hasNext())
		{
			var arg = it.next();
			var rule = _args.get(arg);
			if (rule == null)
			{
				throw 'No rule for $arg';
			}

			var name = rename(rule.flags[0]);
			if (rule.numArgs > 0)
			{
				for (_ in 0...rule.numArgs)
				{
					if (!it.hasNext())
					{
						throw 'Not enough arguments for $arg';
					}
					result.set(name, it.next());
				}
			}
			else
			{
				result.set(name, rule.defaultValue);
			}
		}
		return result;
	}

	/**
	 * Renames the rule by removing dashes
	 */
	function rename(name:String):String
	{
		return StringTools.replace(name, '-', '');
	}

	var _args = new StringMap<Argument>();

}
