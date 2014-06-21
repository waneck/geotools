package geo;
import geo.Units;

@:forward abstract TzDate(DateData)
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

	public static function now():TzDate
	{
		return new TzDate(Date.now(), timezone());
	}

}

class DateData
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
		return date.getTime() + timeZone;
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
			ret.add( this.timeZone < 0 ? '-' : '+' );
			ret.add( str( tz / 60 ) );
			ret.add( str( tz % 60 ) );
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
