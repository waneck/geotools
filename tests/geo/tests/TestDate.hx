package geo.tests;

import geo.*;
import geo.Units;
import utest.Assert;

class TestDate
{
	public function new()
	{
	}

	public function testToString()
	{
		var stamp = new UtcDate(1403208368);
		Assert.equals('2014-06-19T20:06:08Z', stamp.toString());
		trace(Date.fromTime(stamp.getTime().float() * 1000));
	}
}
