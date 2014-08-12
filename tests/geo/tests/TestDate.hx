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
		var stamp = new UnixDate(1403208368);
		Assert.equals('2014-06-19T20:06:08Z', stamp.toString());
		Assert.equals('2000-06-19T00:00:00Z', new UnixDate(961372800).toString());
		Assert.equals('2000-01-01T00:00:00Z', new UnixDate(946684800).toString());
		Assert.equals('1970-01-01T00:00:00Z', new UnixDate(0).toString());
		Assert.equals('1972-01-01T00:00:00Z', new UnixDate(63072000).toString());

		//leap years
		Assert.equals('1972-02-29T00:00:00Z', new UnixDate(68169600).toString());
		Assert.equals('2000-02-29T00:00:00Z', new UnixDate(951782400).toString());
		Assert.equals('2014-03-01T00:00:00Z', new UnixDate(1393632000).toString());
		Assert.equals('2014-03-01T00:00:01Z', new UnixDate(1393632001).toString());
		Assert.equals('2014-02-28T23:59:59Z', new UnixDate(1393631999).toString());
		Assert.equals('2014-07-28T00:00:00Z', new UnixDate(1406505600).toString());
		Assert.equals('1972-07-28T00:00:00Z', new UnixDate(81129600).toString());
	}

	public function test_month()
	{
		var stamp = new UnixDate(1403208368);
		Assert.equals(Month.Jun, stamp.getMonth());
		Assert.equals(Month.Jun, new UnixDate(961372800).getMonth());
		Assert.equals(Month.Jan, new UnixDate(946684800).getMonth());
		Assert.equals(Month.Jan, new UnixDate(0).getMonth());
		Assert.equals(Month.Jan, new UnixDate(63072000).getMonth());

		//leap years
		Assert.equals(Month.Feb, new UnixDate(68169600).getMonth());
		Assert.equals(Month.Feb, new UnixDate(951782400).getMonth());
		Assert.equals(Month.Mar, new UnixDate(1393632000).getMonth());
		Assert.equals(Month.Mar, new UnixDate(1393632001).getMonth());
		Assert.equals(Month.Feb, new UnixDate(1393631999).getMonth());
		Assert.equals(Month.Jul, new UnixDate(1406505600).getMonth());
		Assert.equals(Month.Jul, new UnixDate(81129600).getMonth());
	}

	public function test_year()
	{
		var stamp = new UnixDate(1403208368);
		Assert.equals(2014, stamp.getYear());
		Assert.equals(2000, new UnixDate(961372800).getYear());
		Assert.equals(2000, new UnixDate(946684800).getYear());
		Assert.equals(1970, new UnixDate(0).getYear());
		Assert.equals(1972, new UnixDate(63072000).getYear());

		//leap years
		Assert.equals(1972, new UnixDate(68169600).getYear());
		Assert.equals(2000, new UnixDate(951782400).getYear());
		Assert.equals(2014, new UnixDate(1393632000).getYear());
		Assert.equals(2014, new UnixDate(1393632001).getYear());
		Assert.equals(2014, new UnixDate(1393631999).getYear());
		Assert.equals(2014, new UnixDate(1406505600).getYear());
		Assert.equals(1972, new UnixDate(81129600).getYear());
	}

	public function test_day()
	{
		Assert.equals(DayOfWeek.Thursday, new UnixDate(0).getDayOfWeek());
		Assert.equals(DayOfWeek.Friday, new UnixDate(86400).getDayOfWeek());
		Assert.equals(DayOfWeek.Friday, new UnixDate(104400).getDayOfWeek());
		Assert.equals(DayOfWeek.Saturday, new UnixDate(190800).getDayOfWeek());
		Assert.equals(DayOfWeek.Sunday, new UnixDate(277200).getDayOfWeek());
		Assert.equals(DayOfWeek.Monday, new UnixDate(363600).getDayOfWeek());
		Assert.equals(DayOfWeek.Tuesday, new UnixDate(450000).getDayOfWeek());
		Assert.equals(DayOfWeek.Wednesday, new UnixDate(536400).getDayOfWeek());
		Assert.equals(DayOfWeek.Thursday, new UnixDate(622800).getDayOfWeek());
		Assert.equals(DayOfWeek.Friday, new UnixDate(709200).getDayOfWeek());
		Assert.equals(DayOfWeek.Thursday, new UnixDate(1403208368).getDayOfWeek());
	}

	public function test_tzdate()
	{
		var date = new TzDate( new UnixDate(1403377154), -3 * 60 * 60 );
		Assert.equals(1403377154, date.getTime());
		Assert.equals('2014-06-21T15:59:14-0300', date.toString());
		Assert.equals('2014-06-21T18:59:14Z', date.date.toString());
		var otherDay = new TzDate(date.date, 6 * 60 * 60);
		Assert.equals('2014-06-22T00:59:14+0600', otherDay.toString());
		Assert.equals(22, otherDay.getDate());
		Assert.equals(21, date.getDate());

		date = new TzDate( new UnixDate(1404154754), -3 * 60 * 60 );
		otherDay = new TzDate( new UnixDate(1404154754), 6 * 60 * 60 );
		Assert.equals('2014-06-30T15:59:14-0300', date.toString());
		Assert.equals('2014-06-30T18:59:14Z', date.date.toString());
		Assert.equals('2014-07-01T00:59:14+0600', otherDay.toString());
		Assert.equals(01, otherDay.getDate());
		Assert.equals(30, date.getDate());
	}

	public function test_ops()
	{
		var date = new UnixDate(1403377154);
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
		Assert.equals( new Hours(10) + new Minutes(25), TzDate.fromFormat('%H:%M', '10:25', 0).date.getTime() );
		Assert.equals( new Hours(10) + new Minutes(25), TzDate.fromFormat('%I:%M %p', '10:25 AM', 0).date.getTime() );
		Assert.equals( new Hours(22) + new Minutes(25), TzDate.fromFormat('%I:%M %p', '10:25 PM', 0).date.getTime() );
		Assert.equals( new Hours(18) + new Minutes(25), TzDate.fromFormat('%I:%M %p', '10:25 PM', new Hours(4)).date.getTime() );
		Assert.equals( new Hours(18) + new Minutes(25), TzDate.fromFormat('x%I:%M %p', 'x10:25 PM', new Hours(4)).date.getTime() );
		Assert.equals( new Hours(0) + new Minutes(25), TzDate.fromFormat('%I:%M %p', '12:25 AM', 0).date.getTime() );
		Assert.equals( new Hours(12) + new Minutes(25), TzDate.fromFormat('%I:%M %p', '12:25 PM', 0).date.getTime() );
		Assert.equals( '2014-06-30T18:59:14Z', TzDate.fromFormat('%ssome other text', '1404154754some other text', 0).toString() );
		Assert.equals( '2014-06-30T18:59:14Z', TzDate.fromFormat('a%ssome other text', 'a1404154754some other text', new Hours(6)).date.toString() );
	}
	
	public function test_tzDate_formatAs() {
		// Commented line below needs testing.
		//var date = new TzDate( new Date(2013, 11, 4, 17, 15, 30) );
		var date = TzDate.fromFormat('%Y-%m-%d %H:%M:%S', '2013-11-04 17:15:30', 0);
		Assert.equals('2013-11-04', date.formatAs('%Y-%m-%d'));
		Assert.equals('17:15:30', date.formatAs('%H:%M:%S'));
		// Abbreviated week name
		Assert.equals('Mon', date.formatAs('%a'));
		// Full week name
		Assert.equals('Monday', date.formatAs('%A'));
		// Weekday as a number, 0=Sunday, 6=Saturday
		Assert.equals('1', date.formatAs('%w'));
		// Day of the month
		Assert.equals('04', date.formatAs('%d'));
		// Abbreviated month name
		Assert.equals('Nov', date.formatAs('%b'));
		// Full month name
		Assert.equals('November', date.formatAs('%B'));
		// Month as a number
		Assert.equals('11', date.formatAs('%m'));
		// Year without century
		Assert.equals('13', date.formatAs('%y'));
		// Year with century
		Assert.equals('2013', date.formatAs('%Y'));
		// 24 Hour clock
		Assert.equals('17', date.formatAs('%H'));
		// 12 Hour clock
		Assert.equals('05', date.formatAs('%I'));
		// PM
		Assert.equals('PM', date.formatAs('%p'));
		// Minutes
		Assert.equals('15', date.formatAs('%M'));
		// Seconds
		Assert.equals('30', date.formatAs('%S'));
		
		
		
		var other = TzDate.fromFormat('%Y-%m-%d %H:%M:%S', '2013-11-04 11:10:09', 0);
		// AM
		Assert.equals('AM', other.formatAs('%p'));
		
		var pos_timezone = TzDate.fromFormat('%F %T', '2014-06-11 16:45:20', new Hours(3));
		// UTC offset as +HHMM
		Assert.equals('+0300', pos_timezone.formatAs('%z'));
		
		var neg_timezone = TzDate.fromFormat('%F %T', '2014-06-11 16:45:20', new Hours( -3));
		// UTC offset as -HHMM
		Assert.equals('-0300', neg_timezone.formatAs('%z'));
	}
}
