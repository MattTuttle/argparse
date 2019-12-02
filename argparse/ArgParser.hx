package argparse;

import argparse.Namespace;
import argparse.Argument;
import haxe.ds.StringMap;

class ArgIterator
{
	public function new(data:Array<String>)
	{
		this.data = data;
	}

	public function stepBack():Void
	{
		index = Std.int(Math.max(index - 1, 0));
	}

	public inline function hasNext():Bool
	{
		return index < data.length;
	}

	public function next():String
	{
		var current = data[index];
		index += 1;
		return current;
	}

	private final data:Array<String>;
	private var index:Int = 0;
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
	public function addArgument(def:ArgumentDef)
	{
		var arg = new Argument(def);
		if (arg.positional)
		{
			_positional.push(arg);
		}
		else
		{
			for (flag in def.flags)
			{
				_flags.set(flag, arg);
			}
		}
	}

	function matchArgs(it:ArgIterator, rule:Argument):Array<Null<String>>
	{
		var vals:Array<Null<String>> = [];
		var max = switch (rule.numArgs) {
			case Range(_, max):
				max;
			case Infinite(_):
				null;
		}

		if (max == 0)
		{
			vals.push(rule.positional ? it.next() : rule.defaultValue);
		}
		else
		{
			while (it.hasNext())
			{
				vals.push(it.next());
				if (max != null && vals.length >= max)
				{
					break;
				}
			}
		}
		return vals;
	}

	/**
	 * Parse the arguments passed by matching them with the rules provided
	 */
	public function parse(args:Array<String>, verify:Bool=true):Namespace
	{
		var ns = new Namespace();
		var it = new ArgIterator(args);
		var positional = _positional.iterator();
		while (it.hasNext())
		{
			var arg = it.next();
			var rule = _flags.get(arg);
			if (rule == null)
			{
				if (positional.hasNext())
				{
					rule = positional.next();
					it.stepBack();
				}
				else if (verify)
				{
					throw 'No rule for $arg';
				}
				else
				{
					continue;
				}
			}
			for (arg in matchArgs(it, rule)) {
				ns.set(rule.name, arg);
			}
		}
		if (verify)
		{
			this.validate(ns);
		}
		return ns;
	}

	function validateRule(rule:Argument, ns:Namespace)
	{
		if (ns.exists(rule.name))
		{
			var found = ns.get(rule.name).length;
			switch (rule.numArgs)
			{
				case Range(min, max):
					trace(rule.name, found, min, max);
					if (found < min || found > max)
					{
						throw 'Invalid number of arguments for ${rule.name}';
					}
				case Infinite(min):
					trace(rule.name, found, min, "inf");
					if (found < min)
					{
						throw 'Invalid number of arguments for ${rule.name}';
					}
			}
		}
		else if (!rule.optional)
		{
			throw 'Expected argument for ${rule.name}';
		}
	}

	function validate(ns:Namespace)
	{
		for (rule in _flags)
		{
			validateRule(rule, ns);
		}
		for (rule in _positional)
		{
			validateRule(rule, ns);
		}
	}

	var _positional = new Array<Argument>();
	var _flags = new StringMap<Argument>();

}
