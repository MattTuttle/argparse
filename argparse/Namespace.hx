package argparse;

import haxe.ds.StringMap;

class Namespace
{
    public function new() {}

    public inline function get(name:String):Array<String>
    {
        return values.get(name);
    }

    public inline function exists(name:String):Bool
    {
        return values.exists(name);
    }

	public function set(name:String, value:String):Void
	{
        if (!exists(name))
        {
            values.set(name, []);
        }
        if (value != null)
        {
            var v = values.get(name);
            v.push(value);
        }
	}

    var values = new StringMap<Array<String>>();
}
