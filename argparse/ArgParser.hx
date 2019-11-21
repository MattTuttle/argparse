package argparse;

import argparse.Namespace;
import argparse.Argument;
import haxe.ds.StringMap;

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

	/**
	 * Parse the arguments passed by matching them with the rules provided
	 */
	public function parse(args:Array<String>):Namespace
	{
		var ns = new Namespace();
		var it = args.iterator();
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
				}
				else
				{
					throw 'No rule for $arg';
				}
			}
			if (rule.numArgs > 0)
			{
				for (_ in 0...rule.numArgs)
				{
					if (!it.hasNext())
					{
						throw 'Not enough arguments for $arg';
					}
					ns.set(rule.name, it.next());
				}
			}
			else
			{
				if (rule.positional)
				{
					ns.set(rule.name, arg);
				}
				else
				{
					ns.set(rule.name, rule.defaultValue);
				}
			}
		}
		verify(ns);
		return ns;
	}

	function verify(ns:Namespace)
	{
		for (rule in _flags)
		{
			if (rule.optional) continue; // skip optional verification for now

			if (ns.exists(rule.name))
			{
				if (rule.numArgs != ns.get(rule.name).length)
				{
					throw 'Invalid number of arguments for ${rule.name}';
				}
			}
			else
			{
				throw 'Expected argument for ${rule.name}';
			}
		}
	}

	var _positional = new Array<Argument>();
	var _flags = new StringMap<Argument>();

}
