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

	/**
		Returns a Location from the `interpolation` of `from` to `to`
	**/
	public static function lerp(from:Location, to:Location, interpolation:Float):Location
	{
		if (interpolation == 0)
			return from;
		else if (interpolation == 1)
			return to;
		else
			return new Location(from.lat + interpolation * (to.lat - from.lat), from.lon + interpolation * (to.lon - from.lon));
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

	public function sqrDist(to:Location):Float
	{
		var lat = this.lat - to.lat,
				lon = this.lon - to.lon;
		return lat * lat + lon * lon;
	}

	/**
		From the segment defined by `segPointA` and `segPointB`, find the interpolation of the closest point to `this`.
	**/
	public function segInterpolation(segPointA:Location, segPointB:Location):Float
	{
		return segInterpolationInline(segPointA, segPointB);
	}

	@:extern inline public function segInterpolationInline(segPointA:Location, segPointB:Location):Float
	{
		var x1 = segPointA.lon;
		var x2 = segPointB.lon;
		var y1 = segPointA.lat;
		var y2 = segPointB.lat;
		var x3 = this.lon;
		var y3 = this.lat;

		// point -> point
		var dp0 = (x1 - x3) * (x1 - x3) + (y1 - y3) * (y1 - y3);
		var dp1 = (x2 - x3) * (x2 - x3) + (y2 - y3) * (y2 - y3);
		// point -> line
		var u = ( (x3 - x1) * (x2 - x1) + (y3 - y1) * (y2 - y1) ) / ( (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) );
		var dr = Math.POSITIVE_INFINITY;
		if (u <= 1 && u >= 0)
		{
			//interseccao
			var x = x1 + u * (x2 - x1);
			var y = y1 + u * (y2 - y1);
			dr = (x - x3) * (x - x3) + (y - y3) * (y - y3);
		}
		if (dp0 < dr && dp0 < dp1)
		{
			u = 0;
		} else if (dp1 < dr && dp1 < dp0) {
			u = 1;
		}

		return u;
	}

	/**
		From the line defined by segment `segPointA` and `segPointB`, find the interpolation value of the closest point to `this`
	**/
	public function lineInterpolation(segPointA:Location, segPointB:Location):Float
	{
		return lineInterpolationInline(segPointA,segPointB);
	}

	@:extern inline public function lineInterpolationInline(segPointA:Location, segPointB:Location):Float
	{
		var x1 = segPointA.lon;
		var x2 = segPointB.lon;
		var y1 = segPointA.lat;
		var y2 = segPointB.lat;
		var x3 = this.lon;
		var y3 = this.lat;

		// point -> line
		return ( (x3 - x1) * (x2 - x1) + (y3 - y1) * (y2 - y1) ) / ( (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) );
	}

	public function eq(loc:Location, precision=1e7):Bool
	{
		if (loc == null)
			return false;
		var prec5 = .5 * (1 / precision);
		return this == loc || (Std.int((prec5 + this.lat) * precision) - Std.int((prec5 + loc.lat) * precision) == 0 && Std.int((prec5 + this.lon) * precision) - Std.int((prec5 + loc.lon) * precision) == 0);
	}

	public function toString()
	{
		return '($lat,$lon)';
	}
}
