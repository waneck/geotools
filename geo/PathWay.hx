package geo;

@:dce @:forward abstract PathWay(Path<Location>) from Path<Location> to Path<Location>
{
	@:extern inline public function new(path)
	{
		this = path;
	}

	@:arrayAccess @:extern inline public function byIndex(idx:Int):Location
	{
		return this.get(idx);
	}

	/**
		Returns the index of the point that defines with returned index + 1 the line segment
		that is closest to `point`
	**/
	public function closestIndexToPoint(point:Location):Int
	{
		var lat = point.lat,
				lon = point.lon;

		var length = this.length;
		if (length < 2)
			throw "Not enough points to find closest index: " + length;

		var dmin = Math.POSITIVE_INFINITY,
				idx = -1,
				start = this.start,
				data = this.data;
		for (i in 0...(length-1))
		{
			var p0 = data[start+i],
					p1 = data[start+i+1];
			var u = point.segInterpolationInline(p0,p1);
			var ulat = p0.lat + u * (p1.lat - p0.lat),
					ulon = p0.lon + u * (p1.lon - p0.lon);
			var d = (ulat - lat) * (ulat - lat) + (ulon - lon) * (ulon - lon);
			if (d < dmin)
			{
				dmin = d;
				idx = i;
			}
		}

		return idx;
	}

}
