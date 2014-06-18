package geo;
import geo.Units;

/**
  A simple position defined by (lat,lon)
**/
class Location
{
	public var lat(default, null):Float;
	public var lon(default, null):Float;

	public function new(latitude:Float, longitude:Float)
	{
		this.lat = latitude;
		this.lon = longitude;
	}

	static inline var R = 6371 * 1000;
  static inline var toRad = 0.017453292519943295;

	public function dist(to:Location):Meters
	{
		var lat1 = lat, lat2 = to.lat;
		var lon1 = lon, lon2 = to.lon;
		var dlat:Float = lat1 - lat2, dlon:Float = lon1 - lon2;
		dlat *= toRad; dlon *= toRad;
		lat1 *= toRad; lat2 *= toRad;
		lon1 *= toRad; lon2 *= toRad;

		var b1 = Math.sin(dlat / 2), b2 = Math.sin(dlon / 2);
		var a = (b1 * b1) + Math.cos(lat1) * Math.cos(lat2) * (b2 * b2);
		var c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1 - a) );
		return R * c;
	}

	public function toString()
	{
		return '($lat,$lon)';
	}
}
