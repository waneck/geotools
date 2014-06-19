package geo.tests;

import geo.*;
import geo.Units;
import utest.Assert;

class TestDate
{
	public function new()
	{
	}

	public function test_toString()
	{
		var stamp = new UtcDate(1403208368);
		Assert.equals('2014-06-19T20:06:08Z', stamp.toString());
		Assert.equals('2000-06-19T00:00:00Z', new UtcDate(961372800).toString());
		Assert.equals('2000-01-01T00:00:00Z', new UtcDate(946684800).toString());
		Assert.equals('1970-01-01T00:00:00Z', new UtcDate(0).toString());
		Assert.equals('1972-01-01T00:00:00Z', new UtcDate(63072000).toString());

		//leap years
		Assert.equals('1972-02-29T00:00:00Z', new UtcDate(68169600).toString());
		Assert.equals('2000-02-29T00:00:00Z', new UtcDate(951782400).toString());
		Assert.equals('2014-03-01T00:00:00Z', new UtcDate(1393632000).toString());
		Assert.equals('2014-03-01T00:00:01Z', new UtcDate(1393632001).toString());
		Assert.equals('2014-02-28T23:59:59Z', new UtcDate(1393631999).toString());
	}

	public function test_month()
	{
		var stamp = new UtcDate(1403208368);
		Assert.equals(Month.Jun, stamp.getMonth());
		Assert.equals(Month.Jun, new UtcDate(961372800).getMonth());
		Assert.equals(Month.Jan, new UtcDate(946684800).getMonth());
		Assert.equals(Month.Jan, new UtcDate(0).getMonth());
		Assert.equals(Month.Jan, new UtcDate(63072000).getMonth());

		//leap years
		Assert.equals(Month.Feb, new UtcDate(68169600).getMonth());
		Assert.equals(Month.Feb, new UtcDate(951782400).getMonth());
		Assert.equals(Month.Mar, new UtcDate(1393632000).getMonth());
		Assert.equals(Month.Mar, new UtcDate(1393632001).getMonth());
		Assert.equals(Month.Feb, new UtcDate(1393631999).getMonth());
	}
}
