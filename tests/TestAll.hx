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

		Report.create(runner);
		runner.run();
	}

}
