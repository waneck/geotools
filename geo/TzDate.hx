package geo;

abstract TzDate(DateData)
{
}

class DateData
{
	public var unixTime(default,null):Seconds;
	public var timeZone(default,null):Seconds;

	public function new(unixTime, tz=0)
	{
		this.unixTime = unixTime;
		this.timeZone = tz;
	}

	@:extern inline public function getTime():Seconds
	{
		return unixTime;
	}
}
