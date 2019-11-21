import argparse.ArgParser;
import utest.Test;
import utest.Assert;

class TestArgs extends Test
{

	public function testNoArgs()
	{
		var a = new ArgParser();
		Assert.isFalse(a.parse([]).exists("anything"));
	}

	public function testResultsAreSameButNotEqual()
	{
		var a = new ArgParser();
		a.addArgument({flags:"-g"});

		var ra = a.parse(["-g"]);
		var rb = a.parse(["-g"]);
		Assert.same(ra, rb);
		Assert.notEquals(ra, rb);
	}

	public function testRaiseOnMissingResult()
	{
		var a = new ArgParser();
		Assert.raises(() -> a.parse([]).get("foo"));
	}

	public function testOrdering()
	{
		var a = new ArgParser();
		a.addArgument({flags: "ls"});
		a.addArgument({flags: "-g"});

		Assert.isTrue(a.parse(["-g", "ls"]).exists("g"));
		Assert.isTrue(a.parse(["ls", "-g"]).exists("g"));
	}

	public function testMultipleArgsForOneTarget()
	{
		var a = new ArgParser();
		a.addArgument({flags:["list", "ls"]});

		Assert.isTrue(a.parse(["ls"]).exists("list"));
		Assert.raises(() -> a.parse(["lst"]));
		Assert.isTrue(a.parse(["list"]).exists("list"));
	}

	public function testSingleArgument()
	{
		var a = new ArgParser();
		a.addArgument({flags: '-o', numArgs: 1});
		Assert.same(['filename'], a.parse(['-o', 'filename']).get("o"));

		Assert.raises(() -> a.parse(['hi', '-o']));
	}

	public function testMultipleArguments()
	{
		var a = new ArgParser();
		a.addArgument({flags: ['--files', '-f'], numArgs: 3});
		Assert.same(['a', 'bb', 'cdef'], a.parse(['-f', 'a', 'bb', 'cdef']).get("files"));

		Assert.raises(() -> a.parse(['-f', 'a', 'b']));
	}

}
