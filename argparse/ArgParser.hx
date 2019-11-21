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

@:access(argparse.Namespace)
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
		for (flag in arg.flags)
		{
			_args.set(flag, arg);
		}
	}

	/**
	 * Parse the arguments passed by matching them with the rules provided
	 */
	public function parse(args:Array<String>):Namespace
	{
		var ns = new Namespace();
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
			var numArgs = rule.numArgs == null ? 0 : rule.numArgs;
			if (numArgs > 0)
			{
				for (_ in 0...numArgs)
				{
					if (!it.hasNext())
					{
						throw 'Not enough arguments for $arg';
					}
					ns.set(name, it.next());
				}
			}
			else
			{
				ns.set(name, rule.defaultValue);
			}
		}
		return ns;
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
