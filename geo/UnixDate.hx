package geo;
import geo.Units;

@:dce abstract UnixDate(Seconds /* secs since 1970 */)
{
	@:extern inline public function new(secs)
	{
		this = secs;
	}

	inline public function getTime():Seconds
	{
		return this;
	}

	public static function now():UnixDate
	{
		return Date.now();
	}

	@:from inline public static function fromDate(d:Date):UnixDate
	{
		return new UnixDate( d.getTime() / 1000 );
	}

	public static function fromDay(year:Int, month:Month, day:Int):UnixDate
	{
		var day:Float = day;
		if (year < 1970)
			throw 'Year must be after 1970';
		if (day < 0 || day >= 31)
			throw "Invalid day " + day;

		year -= 1970;
		if (year <= 1)
		{
			if (month == Month.Jan)
				day = day + year * 365;
			else
				day = day + year_months[ month.toInt() - 1 ] + year * 365;
		} else {
			year -= 2;
			day += 365 + 365;
			var d = Std.int(year / 4),
					rem = Std.int(year % 4);
			day += DAYS_IN_FOUR_YEARS * d;
			if (rem == 0)
			{
				if (month != Month.Jan)
					day += year_months_leap[ month.toInt() - 1 ];
			} else {
				day += 366;
				rem--;
				if (month != Month.Jan)
					day += year_months[ month.toInt() - 1 ] + rem * 365;
				else
					day += rem * 365;
			}
		}

		return new UnixDate( day * 24 * 60 * 60 );
	}

	public function getMonth():Month
	{
		var days = this.float() / (60 * 60 * 24),
				year = year_months;
		if (days <= (365 + 365))
		{
			days = days % 365;
		} else {
			days -= 365 + 365;
			var rem = days % DAYS_IN_FOUR_YEARS;
			if (rem <= 366)
			{
				year = year_months_leap;
				days = rem;
			} else {
				days = (rem - 366) % 365;
			}
		}

		//search for the month
		if (days <= DAYS_IN_JUL)
		{
			for (i in 0...7)
				if (days < year[i])
					return i;
		} else {
			for (i in 7...12)
				if (days < year[i])
					return i;
		}
		return throw "assert";
	}

	inline public function getSeconds():Seconds
	{
		return Std.int(this.float() % 60);
	}

	inline public function getMinutes():Minutes
	{
		return Std.int( (this.float() / 60) % 60 );
	}

	inline public function getHours():Hours
	{
		return Std.int( (this.float() / (60 * 60) ) % 24 );
	}

	public function getDate():Int
	{
		var days = this.float() / (60 * 60 * 24),
				years = year_months;
		if (days <= (365 + 365))
		{
			days = days % 365;
		} else {
			days -= 365 + 365;
			var rem = days % DAYS_IN_FOUR_YEARS;
			if (rem <= 366)
			{
				days = rem;
				years = year_months_leap;
			} else {
				days = (rem - 366) % 365;
			}
		}
		var last = 0,
				days = Std.int(days);
		for (v in years)
		{
			if (v > days)
			{
				return days - last + 1;
			}
			last = v;
		}
		return throw "assert";
	}

	public function getYear():Int
	{
		var days = this.float() / (60 * 60 * 24);
		var year = 1970;

		//check if we are in between 1970-1972 (1972 was a leap year)
		if (days < 0)
		{
			//someday we'll tackle this
			throw "Timestamp cannot be negative";
		} else {
			if (days <= 365 + 365)
			{
				year += Std.int( days / 365 );
			} else {
				days -= 365 + 365;
				var y = Std.int(days / DAYS_IN_FOUR_YEARS),
						rem = days % DAYS_IN_FOUR_YEARS;
				year += y * 4 + 2;

				// rem is the remaining days we have. the month will depend if we're on a leap year
				if (rem > 366)
				{
					// past leap year
					rem -= 366;
					year += 1 + Std.int(rem / 365);
				}
			}
		}
		return year;
	}

	public function getDayOfWeek():DayOfWeek
	{
		return Std.int( (4 + (this.float() / (60 * 60 * 24))) % 7);
	}

	@:extern inline public function inlineWithParts<T>(fn:Int->Month->Int->Int->Int->Seconds->T):T
	{
		var S = this.float(),
				M = S / 60,
				H = M / 60,
				days = H / 24;
		var year = 1970,
				month = -1,
				yearMonths = year_months;

		//check if we are in between 1970-1972 (1972 was a leap year)
		if (days < 0)
		{
			//someday we'll tackle this
			throw "Timestamp cannot be negative";
		} else {
			// var y = days % DAYS_IN_YOUR_YEARS;
			// // 1972 was a leap year. So if y <= 2 and february,
			if (days <= 365 + 365)
			{
				year += Std.int( days / 365 );
				days = days % 365;
			} else {
				days -= 365 + 365;
				var y = Std.int(days / DAYS_IN_FOUR_YEARS),
						rem = days % DAYS_IN_FOUR_YEARS;
				year += y * 4 + 2;

				// rem is the remaining days we have. the month will depend if we're on a leap year
				if (rem >= 366)
				{
					// past leap year
					rem -= 366;
					year += 1 + Std.int(rem / 365);
					days = rem % 365;
				} else {
					yearMonths = year_months_leap;
					days = rem;
				}
			}
		}

		var last = 0;
		for (i in 0...12)
		{
			var ym = yearMonths[i];
			if (days < ym)
			{
				month = i;
				days = days - last;
				break;
			}
			last = ym;
		}
		if (month < 0)
			throw "assert: month is " + month + "; days is " + days + " for timestamp " + this;

		return fn(year,month,Std.int(days + 1), Std.int(H % 24), Std.int(M % 60), Std.int(S % 60));
	}

	public function withParts<T>(fn):T
	{
		return inlineWithParts(fn);
	}

	public function toString():String
	{
		return withParts(function(year,month,day,hour,minute,sec) {
			var ret = new StringBuf();
			ret.add(year);
			ret.add('-');
			ret.add(str(month.toInt()+1));
			ret.add('-');
			ret.add(str(day));
			ret.add('T');
			ret.add(str(hour));
			ret.add(':');
			ret.add(str(minute));
			ret.add(':');
			ret.add(str(sec.float()));
			ret.add('Z');
			return ret.toString();
		});
	}

	inline private static function str(i:Float)
	{
		return i < 10 ? '0' + Std.int(i) : '' + Std.int(i);
	}

	/**
		Drops the Date portion of the UnixDate and keeps only the time
	**/
	public function dropDate():UnixDate
	{
		return new UnixDate(this.float() % (60 * 60 * 24));
	}

	/**
		Drops the time portion of the UnixDate and keeps only the date
	**/
	public function dropTime():UnixDate
	{
		return new UnixDate(Math.floor(this.float() / (60*60*24)) * 60.0 * 60 * 24);
	}

	private static inline var DAYS_IN_FOUR_YEARS = 366 + 365 + 365 + 365;
	private static inline var DAYS_IN_JAN = 31;
	private static inline var DAYS_IN_FEB = DAYS_IN_JAN + 28;
	private static inline var DAYS_IN_FEBL = DAYS_IN_JAN + 29;
	private static inline var DAYS_IN_MAR = DAYS_IN_FEB + 31;
	private static inline var DAYS_IN_MARL = DAYS_IN_FEBL + 31;
	private static inline var DAYS_IN_APR = DAYS_IN_MAR + 30;
	private static inline var DAYS_IN_APRL = DAYS_IN_MARL + 30;
	private static inline var DAYS_IN_MAY = DAYS_IN_APR + 31;
	private static inline var DAYS_IN_MAYL = DAYS_IN_APRL + 31;
	private static inline var DAYS_IN_JUN = DAYS_IN_MAY + 30;
	private static inline var DAYS_IN_JUNL = DAYS_IN_MAYL + 30;
	private static inline var DAYS_IN_JUL = DAYS_IN_JUN + 31;
	private static inline var DAYS_IN_JULL = DAYS_IN_JUNL + 31;
	private static inline var DAYS_IN_AUG = DAYS_IN_JUL + 31;
	private static inline var DAYS_IN_AUGL = DAYS_IN_JULL + 31;
	private static inline var DAYS_IN_SEP = DAYS_IN_AUG + 30;
	private static inline var DAYS_IN_SEPL = DAYS_IN_AUGL + 30;
	private static inline var DAYS_IN_OCT = DAYS_IN_SEP + 31;
	private static inline var DAYS_IN_OCTL = DAYS_IN_SEPL + 31;
	private static inline var DAYS_IN_NOV = DAYS_IN_OCT + 30;
	private static inline var DAYS_IN_NOVL = DAYS_IN_OCTL + 30;
	private static inline var DAYS_IN_DEC = DAYS_IN_NOV + 31;
	private static inline var DAYS_IN_DECL = DAYS_IN_NOVL + 31;

	private static var year_months = haxe.ds.Vector.fromArrayCopy([ DAYS_IN_JAN, DAYS_IN_FEB, DAYS_IN_MAR, DAYS_IN_APR, DAYS_IN_MAY, DAYS_IN_JUN, DAYS_IN_JUL, DAYS_IN_AUG, DAYS_IN_SEP, DAYS_IN_OCT, DAYS_IN_NOV, DAYS_IN_DEC ]);
	private static var year_months_leap = haxe.ds.Vector.fromArrayCopy([ DAYS_IN_JAN, DAYS_IN_FEBL, DAYS_IN_MARL, DAYS_IN_APRL, DAYS_IN_MAYL, DAYS_IN_JUNL, DAYS_IN_JULL, DAYS_IN_AUGL, DAYS_IN_SEPL, DAYS_IN_OCTL, DAYS_IN_NOVL, DAYS_IN_DECL ]);

	@:commutative @:extern @:op(A+B) inline public static function adds(lhs:UnixDate, offset:Seconds):UnixDate
	{
		return new UnixDate(lhs.getTime() + offset);
	}

	@:commutative @:extern @:op(A-B) inline public static function subs(lhs:UnixDate, offset:Seconds):UnixDate
	{
		return new UnixDate(lhs.getTime() + offset);
	}

	@:commutative @:extern @:op(A+B) inline public static function addm(lhs:UnixDate, offset:Minutes):UnixDate
	{
		return new UnixDate(lhs.getTime() + offset);
	}

	@:commutative @:extern @:op(A-B) inline public static function subm(lhs:UnixDate, offset:Minutes):UnixDate
	{
		return new UnixDate(lhs.getTime() + offset);
	}

	@:commutative @:extern @:op(A+B) inline public static function addh(lhs:UnixDate, offset:Hours):UnixDate
	{
		return new UnixDate(lhs.getTime() + offset);
	}

	@:commutative @:extern @:op(A-B) inline public static function subh(lhs:UnixDate, offset:Hours):UnixDate
	{
		return new UnixDate(lhs.getTime() + offset);
	}

	@:extern @:op(A>B) inline public static function gt(lhs:UnixDate, rhs:UnixDate):Bool
	{
		return lhs.getTime().float() > rhs.getTime().float();
	}

	@:extern @:op(A>=B) inline public static function gte(lhs:UnixDate, rhs:UnixDate):Bool
	{
		return lhs.getTime().float() >= rhs.getTime().float();
	}

	@:extern @:op(A<B) inline public static function lt(lhs:UnixDate, rhs:UnixDate):Bool
	{
		return lhs.getTime().float() < rhs.getTime().float();
	}

	@:extern @:op(A<=B) inline public static function lte(lhs:UnixDate, rhs:UnixDate):Bool
	{
		return lhs.getTime().float() <= rhs.getTime().float();
	}

	@:extern @:op(A==B) inline public static function eq(lhs:UnixDate, rhs:UnixDate):Bool
	{
		return lhs.getTime().float() == rhs.getTime().float();
	}

	inline public function between(minDateIncluded:UnixDate, maxDateIncluded:UnixDate):Bool
	{
		return this >= minDateIncluded.getTime() && this <= maxDateIncluded.getTime();
	}

	@:extern inline public function float():Float
	{
		return this.float();
	}

	public function format(format:String, timeZone:Seconds=0)
	{
		return formatAs(new UnixDate(this), format, timeZone);
	}

	public static function formatAs(date:UnixDate, format:String, timeZone:Seconds):String
	{
		var result = new StringBuf();
		var index = 0;
		var code = 0;

		if (timeZone != 0)
		{
			date = new UnixDate(date.getTime() + timeZone);
		}

		while (index != format.length) {
			code = format.charCodeAt( index );

			switch (code) {
				case '%'.code:
					index++;
					code = format.charCodeAt( index );

					switch (code) {
						case 'a'.code:
							result.add( date.getDayOfWeek().toString().substring(0, 3) );

						case 'A'.code:
							result.add( date.getDayOfWeek().toString() );

						case 'w'.code:
							result.add( date.getDayOfWeek().toInt() );

						case 'd'.code:
							var date = date.getDate();
							result.add( date < 10 ? '0$date' : '$date' );

						case 'b'.code:
							result.add( date.getMonth().toString().substring(0, 3) );

						case 'B'.code:
							result.add( date.getMonth().toString() );

						case 'm'.code:
							var month = date.getMonth().toInt() + 1;
							result.add( month < 10 ? '0$month' : '$month' );

						case 'y'.code:
							result.add( '${date.getYear()}'.substring(2, 4) );

						case 'Y'.code:
							result.add( '${date.getYear()}' );

						case 'H'.code:
							var h = Std.int(date.getHours().float()) + "";
							if (h.length == 1)
								h = "0" + h;
							result.add(h);

						case 'I'.code:
							var hour = date.getHours().float();
							hour = hour > 12 ? hour % 12 : hour;
							result.add( hour < 10 ? '0$hour' : '$hour' );

						case 'p'.code:
							result.add( date.getHours().float() < 12 ? 'AM' : 'PM');

						case 'M'.code:
							var m = Std.int(date.getMinutes().float()) + "";
							if (m.length == 1)
								m = "0" + m;
							result.add(m);

						case 'S'.code:
							var s = Std.int(date.getSeconds().float()) + "";
							if (s.length == 1)
								s = "0" + s;
							result.add(s);

						case 'f'.code:
							result.add( date.getTime().toString() );

						case 'z'.code:
							var hour = '' + Std.int((timeZone.float() / (60 * 60)));
							var minute = '' + Std.int(timeZone.float() % 60);
							var negative = hour.charCodeAt(0) == '-'.code;

							if (negative) hour = hour.substring(1, hour.length);

							result.add( negative ? '-' : '+' );
							result.add( hour.length == 1 ? '0$hour' : hour );
							result.add( minute.length == 1 ? '0$minute' : minute );

						case 'Z'.code:


						case 'j'.code:
							result.add( (year_months)[date.getMonth().toInt()] - (31 - date.getDate()) + 1 );

						case 'U'.code:
							result.add(Std.int((((year_months)[date.getMonth().toInt()] + date.getDate() - 31 + 1) - (date.getDayOfWeek().toInt() == 0?7:date.getDayOfWeek().toInt()) + 10) / 7));

						case 'W'.code:
							result.add(Std.int((((year_months)[date.getMonth().toInt()] + date.getDate() - 31 + 1) - (date.getDayOfWeek().toInt() == 0?7:date.getDayOfWeek().toInt()) + 10) / 7));

						case 'c'.code:
							result.add( formatAs(date, '%a %b %d %H:%M:%S %Y', timeZone) );

						case 'x'.code:
							result.add( formatAs(date, '%m/%d/%y', timeZone) );

						case 'X'.code:
							result.add( formatAs(date, '%H:%M:%S', timeZone) );

						case _:
							result.add( String.fromCharCode( code ) );

					}

				case _:
					result.add( String.fromCharCode( code ) );

			}

			index++;

		}

		return result.toString();
	}

}

