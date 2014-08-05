import geo.tests.*;
import utest.*;
import utest.ui.*;

class TestAll
{

	static function main()
	{
		var runner = new Runner();

		runner.addCase(new TestRange());
		runner.addCase(new TestGeohash());
		runner.addCase(new TestDate());
		runner.addCase(new TestPath());
		runner.addCase(new TestGpx());
		runner.addCase(new TestKml());

		runner.addCase(new TestMatrix());
		runner.addCase(new TestKalman());

		runner.addCase(new TestNetwork());

		Report.create(runner);
		runner.run();
	}

}
