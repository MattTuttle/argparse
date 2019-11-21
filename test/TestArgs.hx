import argparse.ArgParser;
import utest.Test;
import utest.Assert;

class TestArgs extends Test
{
	var a:ArgParser;

	public function setup()
	{
		a = new ArgParser();
	}

	public function testNoArgs()
	{
		Assert.isFalse(a.parse([]).exists("anything"));
	}

	public function testResultsAreSameButNotEqual()
	{
		a.addArgument({flags:"-g"});

		var ra = a.parse(["-g"]);
		var rb = a.parse(["-g"]);
		Assert.same(ra, rb);
		Assert.notEquals(ra, rb);
	}

	public function testRaiseOnMissingResult()
	{
		Assert.raises(() -> a.parse([]).get("foo"));
	}

	public function testMissingArgument()
	{
		a.addArgument({flags: "-hello"});
		Assert.raises(() -> a.parse([]));
	}

	public function testOptionalMissingArgument()
	{
		a.addArgument({flags: "-hello", optional: true});
		Assert.isFalse(a.parse([]).exists("-hello"));
	}

	public function testOrdering()
	{
		a.addArgument({flags: "-ls"});
		a.addArgument({flags: "-g"});

		Assert.isTrue(a.parse(["-g", "-ls"]).exists("g"));
		Assert.isTrue(a.parse(["-ls", "-g"]).exists("g"));
	}

	public function testMultipleArgsForOneTarget()
	{
		a.addArgument({flags:["--list", "-ls"]});

		Assert.isTrue(a.parse(["-ls"]).exists("list"));
		Assert.raises(() -> a.parse(["-lst"]));
		Assert.isTrue(a.parse(["--list"]).exists("list"));
	}

	public function testSingleArgument()
	{
		a.addArgument({flags: '-o', numArgs: 1});
		Assert.same(['filename'], a.parse(['-o', 'filename']).get("o"));

		Assert.raises(() -> a.parse(['hi', '-o']));
	}

	public function testMultipleArguments()
	{
		a.addArgument({flags: ['--files', '-f'], numArgs: 3});
		Assert.same(['a', 'bb', 'cdef'], a.parse(['-f', 'a', 'bb', 'cdef']).get("files"));

		Assert.raises(() -> a.parse(['-f', 'a', 'b']));
	}

	public function testDashInName()
	{
		a.addArgument({flags: "--no-color"});
		Assert.isTrue(a.parse(["--no-color"]).exists("no-color"));
	}

	public function testPositionalArgument()
	{
		a.addArgument({flags: "hello"});
		Assert.same(["foobar"], a.parse(["foobar"]).get("hello"));
	}

	public function testMultiplePositionalArgument()
	{
		a.addArgument({flags: "hello"});
		Assert.same(["foobar"], a.parse(["foobar"]).get("hello"));
	}

}
