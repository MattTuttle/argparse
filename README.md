# Argument parser library for Haxe

This library is for parsing command line arguments for tools. It works similar to Python's argparse library but has it's own quirks.

## Getting started

Install the library using haxelib.

```
haxelib install argparse
```

Then you can start by creating a new ArgParser instance and setting the arguments you wish to parse.

```haxe
import argparse.ArgParser;

class Main
{
    public static function main()
    {
	    var parser = new ArgParser();
        parser.addArgument({flags: ["--verbose", "-v"], help: "Increase verbosity"});
        var args = parser.parse(Sys.argv());
        var verbose = args.exists("verbose");
    }
}
```
