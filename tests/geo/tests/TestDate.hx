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
		Assert.equals('2014-07-28T00:00:00Z', new UtcDate(1406505600).toString());
		Assert.equals('1972-07-28T00:00:00Z', new UtcDate(81129600).toString());
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
		Assert.equals(Month.Jul, new UtcDate(1406505600).getMonth());
		Assert.equals(Month.Jul, new UtcDate(81129600).getMonth());
	}

	public function test_year()
	{
		var stamp = new UtcDate(1403208368);
		Assert.equals(2014, stamp.getYear());
		Assert.equals(2000, new UtcDate(961372800).getYear());
		Assert.equals(2000, new UtcDate(946684800).getYear());
		Assert.equals(1970, new UtcDate(0).getYear());
		Assert.equals(1972, new UtcDate(63072000).getYear());

		//leap years
		Assert.equals(1972, new UtcDate(68169600).getYear());
		Assert.equals(2000, new UtcDate(951782400).getYear());
		Assert.equals(2014, new UtcDate(1393632000).getYear());
		Assert.equals(2014, new UtcDate(1393632001).getYear());
		Assert.equals(2014, new UtcDate(1393631999).getYear());
		Assert.equals(2014, new UtcDate(1406505600).getYear());
		Assert.equals(1972, new UtcDate(81129600).getYear());
	}

	public function test_day()
	{
		Assert.equals(DayOfWeek.Thursday, new UtcDate(0).getDayOfWeek());
		Assert.equals(DayOfWeek.Friday, new UtcDate(86400).getDayOfWeek());
		Assert.equals(DayOfWeek.Friday, new UtcDate(104400).getDayOfWeek());
		Assert.equals(DayOfWeek.Saturday, new UtcDate(190800).getDayOfWeek());
		Assert.equals(DayOfWeek.Sunday, new UtcDate(277200).getDayOfWeek());
		Assert.equals(DayOfWeek.Monday, new UtcDate(363600).getDayOfWeek());
		Assert.equals(DayOfWeek.Tuesday, new UtcDate(450000).getDayOfWeek());
		Assert.equals(DayOfWeek.Wednesday, new UtcDate(536400).getDayOfWeek());
		Assert.equals(DayOfWeek.Thursday, new UtcDate(622800).getDayOfWeek());
		Assert.equals(DayOfWeek.Friday, new UtcDate(709200).getDayOfWeek());
		Assert.equals(DayOfWeek.Thursday, new UtcDate(1403208368).getDayOfWeek());
	}

	public function test_tzdate()
	{
		var date = new TzDate( new UtcDate(1403377154), -3 * 60 * 60 );
		Assert.equals(1403377154, date.getTime());
		Assert.equals('2014-06-21T15:59:14-0300', date.toString());
		Assert.equals('2014-06-21T18:59:14Z', date.date.toString());
		var otherDay = new TzDate(date.date, 6 * 60 * 60);
		Assert.equals('2014-06-22T00:59:14+0600', otherDay.toString());
		Assert.equals(22, otherDay.getDate());
		Assert.equals(21, date.getDate());

		date = new TzDate( new UtcDate(1404154754), -3 * 60 * 60 );
		otherDay = new TzDate( new UtcDate(1404154754), 6 * 60 * 60 );
		Assert.equals('2014-06-30T15:59:14-0300', date.toString());
		Assert.equals('2014-06-30T18:59:14Z', date.date.toString());
		Assert.equals('2014-07-01T00:59:14+0600', otherDay.toString());
		Assert.equals(01, otherDay.getDate());
		Assert.equals(30, date.getDate());
	}

	public function test_ops()
	{
		var date = new UtcDate(1403377154);
		Assert.equals('2014-06-21T18:59:14Z', date.toString());
		Assert.equals('2014-06-21T18:59:15Z', (date + Seconds.One).toString());
		Assert.equals('2014-06-21T19:00:14Z', (date + Minutes.One).toString());
		Assert.equals('2014-06-21T19:59:14Z', (date + Hours.One).toString());
	}

	public function test_parse()
	{
		Assert.equals('2014-06-11T16:45:20-0300', TzDate.fromFormat('%F %T', '2014-06-11 16:45:20', new Hours(-3)).toString());
		Assert.equals('2014-06-11T16:45:20-0300', TzDate.fromFormat('%Y-%m-%d %H:%M:%S', '2014-06-11 16:45:20', new Hours(-3)).toString());
		Assert.equals('2014-06-11T15:45:20-0400', TzDate.fromFormat('%Y-%m-%d %H:%M:%S%z', '2014-06-11 15:45:20-0400', new Hours(-3)).toString());
	}
}