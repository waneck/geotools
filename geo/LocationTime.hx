package geo;
import geo.Units;

/**
	A position in time.
**/
class LocationTime extends Location
{
	public var time(default,null):UnixDate;

	public function new(lat,lon,time)
	{
		super(lat,lon);
		this.time = time;
	}

	@:extern inline public static function loctime(lat,lon,time)
	{
		return new LocationTime(lat,lon,time);
	}

	override public function toString()
	{
		return '($lat,$lon @ $time)';
	}
}
