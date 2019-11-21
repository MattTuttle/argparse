package argparse;

import haxe.ds.StringMap;

/**
 * Contains a hash of values
 */
class Namespace
{
	public function new() {}

	/**
	 * Get the values associated with the name requested
	 * @exception if name doesn't exist
	 */
	public function get(name:String):Array<String>
	{
		var v = values.get(name);
		if (v != null)
		{
			return v;
		}
		else
		{
			throw 'No value for $name';
		}
	}

	/**
	 * Check if a value exists
	 */
	public inline function exists(name:String):Bool
	{
		return values.exists(name);
	}

	function set(name:String, value:Null<String>):Void
	{
		var v = values.get(name);
		if (v == null)
		{
			v = [];
			values.set(name, v);
		}

		if (value != null)
		{
			v.push(value);
		}
	}

	var values = new StringMap<Array<String>>();
}
