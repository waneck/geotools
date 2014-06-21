package geo;
import geo.Units;
using StringTools;

@:dce @:forward abstract TzDate(DateData)
{
	@:extern inline public function new(date:UtcDate, tz:Seconds=0)
	{
		this = new DateData(date,tz.float());
	}

	@:extern inline public static function toCurrentTimezone(date:UtcDate):TzDate
	{
		return new TzDate(date,timezone());
	}

	@:extern inline public static function timezone():Seconds
	{
		return - (new Date(1970,00,01 , 00,00,00).getTime() / 1000);
	}

	@:extern inline public function toString()
	{
		return this.toString();
	}

	@:extern inline public function getDate():Int
	{
		return UtcDate.getDate( this.date.getTime().float() + this.timeZone.float() );
	}

	@:extern inline public function getMonth():Month
	{
		return UtcDate.getMonth( this.date.getTime().float() + this.timeZone.float() );
	}

	@:extern inline public function getYear():Int
	{
		return UtcDate.getYear( this.date.getTime().float() + this.timeZone.float() );
	}

	public static function now():TzDate
	{
		return new TzDate(Date.now(), timezone());
	}

	/**
		Returns a `TzDate` based on the format provided by `format`.
		The format is compatible with the `strftime` standard format.

		The only format types that actually impact on Date parsing are:
		 - `%b`,`%B` - english month name
		 - `%d` - day of month (e.g. 01)
		 - `%D` - date; same as `%m/%d/%y`
		 - `%F` - full date; same as `%Y-%m-%d`
		 - `%H` - hour (00...23)
		 - `%I` + `%p / %P` - hour (1..12) + AM/PM
		 - `%m` - month
		 - `%M` - minute
		 - `%N` - nanoseconds (000000000..999999999)
		 - `%r` - 12-hour clock time (e.g. 11:35:44 PM)
		 - `%s` - seconds since 1970-01-01 00:00:00 UTC
		 - `%S` - second
		 - `%T` - 24-hour time; same as %H:%M:%S
		 - `%Y` - year
		 - `%z` - +hhmm numeric time zone (e.g. -0300)

		If no time zone format is present, `stdTimezone` will be used.
	**/
	public static function fromFormat(format:String, string:String, stdTimezone:Seconds):TzDate
	{
		var stamp:Null<Float> = null,
				day:Null<Int> = null,
				nano:Null<Float> = null,
				month:Null<Int> = null,
				year:Null<Int> = null,
				hour:Null<Int> = null,
				minute:Null<Int> = null,
				second:Null<Int> = null,
				am:Null<Bool> = null,
				needsAm = false;
		var form = format,
				oldFormat = null,
				oldIdx = 0,
				idx = 0,
				totalIdx = 0;
		while (true)
		{
			if (idx >= (form.length - 1))
			{
				if (oldFormat != null)
				{
					form = oldFormat;
					idx = oldIdx;
					oldFormat = null;
					continue;
				}
			}
			switch(form.fastCodeAt(idx++))
			{
				case '%'.code:
					switch (form.fastCodeAt(idx++))
					{
						case 'b'.code:
							var m = Month.fromString(string.substring(totalIdx, totalIdx += 3));
							if (month != null && month != m.toInt())
								throw "Two different months were parsed: " + Month.fromInt(month) + " and " + m + " for string " + string;
							month = m.toInt();
						case 'B'.code:
							var i = totalIdx;
							while (++i < string.length)
							{
								var s = string.fastCodeAt(i);
								if ( !((s >= 'A'.code && s <= 'Z'.code) || (s >= 'a'.code && s <= 'z'.code)) )
									break;
							}
							var m = Month.fromString(string.substring(totalIdx, totalIdx = i));
							if (month != null && month != m.toInt())
								throw "Two different months were parsed: " + Month.fromInt(month) + " and " + m + " for string " + string;
							month = m.toInt();
						case 'd'.code:
							var d = Std.parseInt(string.substr(totalIdx,2));
							totalIdx += 2;
							if (d == null || d > 31 || d < 1) throw 'Invalid day of month: ${string.substr(totalIdx - 2,2)}';
							if (day != null && day != d) throw 'Two different day of month were parsed: $d and $day for string $string';
							day = d;
						case 'D'.code:
							oldFormat = format;
							oldIdx = idx;
							form = '%m/%d/%y';
							continue;
						case 'F'.code:
							oldFormat = format;
							oldIdx = idx;
							form = '%Y-%m-%d';
							continue;
						case 'H'.code:
							var h = Std.parseInt(string.substr(totalIdx,2));
							totalIdx += 2;
							if (h == null || h >= 24 || h < 0) throw 'Invalid hour: ${string.substr(totalIdx - 2,2)}';
							if (hour != null && hour != h) throw 'Two different hours were parsed: $h and $hour for string $string';
							hour = h;
						case 'I'.code:
							needsAm = true;
							var h = Std.parseInt(string.substr(totalIdx,2));
							totalIdx += 2;
							if (h == null || h > 12 || h < 1) throw 'Invalid hour: ${string.substr(totalIdx - 2,2)}';
							if (hour != null && hour != h) throw 'Two different hours were parsed: $h and $hour for string $string';
							hour = h;
						case 'p'.code | 'P'.code:
							switch (string.substr(totalIdx,2).toLowerCase())
							{
								case 'AM':
									am = true;
								case 'PM':
									am = false;
								case ampm:
									throw 'Invalid AM/PM marker: $ampm';
							}
							totalIdx += 2;
						case 'm'.code:
							var mon = Std.parseInt(string.substr(totalIdx,2));
							totalIdx += 2;
							if (mon == null || mon > 12 || mon < 1) throw 'Invalid month: ${string.substr(totalIdx - 2,2)}';
							if (month != null && month != mon) throw 'Two different months were parsed: $mon and $month for string $string';
							month = mon;
						case 'M'.code:
							var min = Std.parseInt(string.substr(totalIdx,2));
							totalIdx += 2;
							if (min == null || min >= 60 || min < 0) throw 'Invalid minute: ${string.substr(totalIdx - 2,2)}';
							if (minute != null && minute != min) throw 'Two different minutes were parsed: $min and $minute for string $string';
							minute = min;
						case 'N'.code:
							nano = Std.parseFloat(string.substring(totalIdx, totalIdx += 9));
							if (Math.isNaN(nano))
								throw 'Invalid nanoseconds: ${string.substring(totalIdx - 9, totalIdx)}';
						case 'r'.code:
							oldFormat = format;
							oldIdx = idx;
							form = '%I:%M:%S %p';
							continue;
						case 's'.code:
							var len = -1,
									maxlen = string.length - totalIdx;
							while (++len < maxlen)
							{
								var cur = string.fastCodeAt(totalIdx+len);
								if (cur < '0'.code || cur > '9'.code)
									break;
							}
							var s = Std.parseFloat(string.substr(totalIdx,len));
							if (Math.isNaN(s))
								throw 'Invalid timestamp: ${string.substr(totalIdx,len)}';
							if (stamp != null && stamp != s)
								throw 'Two different stamps were parsed: $stamp and $s for string $string';
							stamp = s;
							totalIdx += len;
						case 'S'.code:
							var sec = Std.parseInt(string.substr(totalIdx,2));
							totalIdx += 2;
							if (sec == null || sec >= 60 || sec < 0) throw 'Invalid second: ${string.substr(totalIdx - 2,2)}';
							if (second != null && second != sec) throw 'Two different seconds were parsed: $sec and $second for string $string';
							second = sec;
						case 'T'.code:
							oldFormat = format;
							oldIdx = idx;
							form = '%H:%M:%S';
							continue;
						case 'Y'.code:
							var y = Std.parseInt(string.substr(totalIdx,4));
							totalIdx += 4;
							if (y == null || y >= 60 || y < 0) throw 'Invalid year: ${string.substr(totalIdx - 2,2)}';
							if (year != null && year != y) throw 'Two different years were parsed: $y and $year for string $string';
							year = y;
						case 'z'.code:
							var neg = false;
							switch (string.fastCodeAt(totalIdx++))
							{
								case '+'.code:
								case '-'.code:
									neg = true;
								case 'Z'.code:
									stdTimezone = 0;
									continue;
								case _:
									throw 'Invalid timezone definition: ${string.substr(totalIdx-1,5)}';
							}
							var h = Std.parseInt(string.substr(totalIdx,2));
							totalIdx += 2;
							var m = Std.parseInt(string.substr(totalIdx,2));
							totalIdx += 2;
							stdTimezone = h * 60 * 60 + m * 60;
							if (neg)
								stdTimezone = -stdTimezone;

						case '%'.code:
							if (string.fastCodeAt(totalIdx++) != '%'.code) throw 'Unexpected character ${string.charAt(totalIdx-1)}';
						case 'n'.code:
							if (string.fastCodeAt(totalIdx++) != '\n'.code) throw 'Unexpected character ${string.charAt(totalIdx-1)}';
						case 't'.code:
							if (string.fastCodeAt(totalIdx++) != '\t'.code) throw 'Unexpected character ${string.charAt(totalIdx-1)}';
						case 'a'.code | 'A'.code:
							while (++totalIdx < string.length)
							{
								var s = string.fastCodeAt(totalIdx);
								if ( !((s >= 'A'.code && s <= 'Z'.code) || (s >= 'a'.code && s <= 'z'.code)) )
									break;
							}
						case chr:
							throw 'Invalid %${String.fromCharCode(chr)}';
						}
				case chr:
					if (string.fastCodeAt(totalIdx++) != chr) throw 'Unexpected character ${string.charAt(totalIdx-1)}';
			}
		}

		if (stamp != null)
			return new TzDate( new UtcDate(stamp), stdTimezone );
		var stamp = 0.0;
		if (year != null || month != null || day != null)
		{
			if (year == null)
				throw "Missing year";
			if (month == null)
				throw "Missing month";
			if (day == null)
				throw "Missing day";
			stamp = UtcDate.fromDay(year, month, day).getTime().float();
		}

		if (hour != null)
		{
			if (needsAm)
			{
				if (am == null)
					throw "AM/PM not present";
				if (hour == 12)
					if (am)
						hour = 0;
					else
						hour = 12;
				else
					if (!am)
						hour += 12;
			}

			stamp += hour * 60 * 60;
		}

		if (minute != null)
			stamp += minute * 60;

		if (second != null)
			stamp += second;

		if (nano != null)
			stamp += nano / 1000000000;

		return new TzDate(new UtcDate(stamp), stdTimezone);
	}
}

@:dce class DateData
{
	public var date(default,null):UtcDate;
	public var timeZone(default,null):Seconds;

	public function new(date, tz=0.0)
	{
		this.date = date;
		this.timeZone = tz;
	}

	@:extern inline public function getTime():Seconds
	{
		return date.getTime();
	}

	public function toString()
	{
		if (this.timeZone == 0)
			return this.date.toString();

		var ret = new StringBuf();
		var tz = this.timeZone.float() / 60;
		if (tz < 0) tz = -tz;
		UtcDate.withParts(this.date.getTime() + this.timeZone, function(year,month,day,hour,minute,sec) {
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
			if (tz == 0)
			{
				ret.add('Z');
			} else {
				ret.add( this.timeZone < 0 ? '-' : '+' );
				ret.add( str( tz / 60 ) );
				ret.add( str( tz % 60 ) );
			}
		});
		return ret.toString();
	}

	inline private static function str(i:Float)
	{
		return i < 10 ? '0' + Std.int(i) : '' + Std.int(i);
	}

	inline private function float():Float
	{
		return (date.getTime() + timeZone).float();
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
}
