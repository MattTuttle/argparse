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
		Assert.equals(0, a.parse([]).get("foo").length);
	}

	public function testMissingArgument()
	{
		a.addArgument({flags: "-hello", optional: false});
		Assert.raises(() -> a.parse([]));
	}

	public function testOptionalMissingArgument()
	{
		a.addArgument({flags: "-hello"});
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
		a.addArgument({flags: ['--files', '-f'], numArgs: 3, optional: false});
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
		a.addArgument({flags: "posarg"});
		Assert.same(["foobar"], a.parse(["foobar"]).get("posarg"));
	}

	public function testOptionalArgument()
	{
		a.addArgument({flags: "question", numArgs: '?'});
		Assert.equals(1, a.parse(["foobar"]).get("question").length);
		Assert.equals(0, a.parse([]).get("question").length);
	}

	public function testNoThrowWhenVerifyIsFalse()
	{
		Assert.isFalse(a.parse(["no_throw"], false).exists("none"));
	}

	public function testMultiplePositionalArgument()
	{
		a.addArgument({flags: "first"});
		a.addArgument({flags: "second"});
		var result = a.parse(["one", "two"]);
		Assert.same(["one"], result.get("first"));
		Assert.same(["two"], result.get("second"));
	}

	public function testPositionalArgumentWithNumArgs()
	{
		a.addArgument({flags: "get_two", numArgs: 2});
		Assert.same(["foo", "bar"], a.parse(["foo", "bar"]).get("get_two"));
		Assert.raises(() -> a.parse(["single"]));
		Assert.raises(() -> a.parse(["one", "two", "three"]));
	}

	public function testWithMoreThanOneArg()
	{
		a.addArgument({flags: "multiple", numArgs: '+'});
		Assert.equals(1, a.parse(["a"]).get("multiple").length);
		Assert.equals(2, a.parse(["a", "d"]).get("multiple").length);
		Assert.equals(4, a.parse(["a", "b", "c", "d"]).get("multiple").length);
		Assert.raises(() -> a.parse([]));
	}

}
