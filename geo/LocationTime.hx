package geo;
import geo.Units;

/**
	A position in time. Time must be in seconds and must have the same reference point (be it Jan 1st 1970 or any other) for all instances.
**/
class LocationTime extends Location
{
	public var time(default,null):Seconds;

	public function new(lat,lon,time)
	{
		super(lat,lon);
		this.time = time;
	}

	@:extern inline public static function loctime(lat,lon,time)
	{
		return new LocationTime(lat,lon,time);
	}
}