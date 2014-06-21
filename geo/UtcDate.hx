package geo;
import geo.Units;

@:dce abstract UtcDate(Seconds /* secs since 1970 */)
{
	@:extern inline public function new(secs)
	{
		this = secs;
	}

	inline public function getTime():Seconds
	{
		return this;
	}

	public static function now():UtcDate
	{
		return Date.now();
	}

	@:from inline public static function fromDate(d:Date):UtcDate
	{
		return new UtcDate( d.getTime() / 1000 );
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

	inline public function getMinutes():Int
	{
		return Std.int( (this.float() / 60) % 60 );
	}

	inline public function getHours():Int
	{
		return Std.int( (this.float() / 60 * 60 ) % 24 );
	}

	public function getDate():Int
	{
		var days = this.float() / (60 * 60 * 24);
		if (days <= (365 + 365))
		{
			days = days % 365;
		} else {
			days -= 365 + 365;
			var rem = days % DAYS_IN_FOUR_YEARS;
			if (rem <= 366)
			{
				days = rem;
			} else {
				days = (rem - 366) % 365;
			}
		}
		return Std.int(days);
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

	@:extern inline public function withParts(fn:Int->Month->Int->Int->Int->Seconds->Void):Void
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
				if (rem > 366)
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

		fn(year,month,Std.int(days + 1), Std.int(H % 24), Std.int(M % 60), Std.int(S % 60));
	}

	@:to inline public function toString():String
	{
		var ret = new StringBuf();
		withParts(function(year,month,day,hour,minute,sec) {
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
		});
		return ret.toString();
	}

	inline private static function str(i:Float)
	{
		return i < 10 ? '0' + Std.int(i) : '' + Std.int(i);
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

}

