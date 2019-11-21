import utest.Runner;
import utest.ui.Report;

class TestMain
{
	static public function main()
	{
		var runner = new Runner();
		runner.addCase(new TestArgs());
		Report.create(runner);
		runner.run();
	}
}
