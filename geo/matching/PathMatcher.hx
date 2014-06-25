package geo.matching;
import geo.units.*;
import geo.*;

class PathMatcher<A:Location>
{
	// parameters
	/**
		The maximum square distance (in lat^2 + lon^2) to be considered when no matching direction is found.
		Setting this too high may invalidate a good path because of one direction not found;
		too low may be an issue if very low precision is expected
		@default 1.0
	**/
	public var maxSquareDistance:Float;

	/**
		The maximum angle used to determine if the direction is the same. A wide angle is recommended

		@default Radians.HalfPi
	**/
	public var maxAngle:Radians;

	public var path:Path<A>;
	public var direction:Direction;

	// returns
	public var pathIndex(default,null):Int;
	public var interpolation(default,null):Float;
	public var minDist(default,null):Meters;

	public function new(path:Path<A>, direction:Direction, maxSquareDistance=1.0, ?maxAngle:Float)
	{
		this.maxSquareDistance = maxSquareDistance;
		this.maxAngle = maxAngle == null ? Radians.HalfPi : maxAngle;
		this.path = path;
		this.direction = Direction.BothWays;
	}

	public static function matchPaths<A:Location,B:Location>(pathWay:Path<A>, direction:Direction, geo:Path<B>, dropUnmatched=true):Meters
	{
		var d = .0;
		var all = [];
		var i = -1,
				len = geo.length-1;

		var matcher = new PathMatcher(pathWay, direction);

		while (++i < len)
		{
			var g = geo.get(i), g1 = geo.get(i+1);

			matcher.match(g,g1);
			all.push(matcher.minDist);
			// d += index.dmin;
		}
		if (dropUnmatched)
		{
			all.sort(Reflect.compare);
			for (i in 0...(all.length - Std.int(all.length / 10)))
				d += all[i].float();
		} else {
			for (i in all)
				d += i.float();
		}

		var d = dropUnmatched ? d / (all.length * .9) : d / all.length;
		if (all.length == 0)
		{
			matcher.direction = Direction.BothWays;
			return matcher.match(geo.get(0)).minDist;
		}

		return d;
	}

	/**
		Returns how well `path1` matches `path2`.
		If both `direction` and `p1` are set and not `BothWays`, their direction are also considered
		The returned value is the average distance between `path1` and `path2`, in Meters`
	**/
	public function match(p0:Location, ?p1:Location):PathMatcher<A>
	{
		var maxAngle = maxAngle,
				dir = direction,
				start = path.start,
				end = start + path.length,
				path = path.data;

		minDist = maxSquareDistance;
		pathIndex = -1;
		interpolation = -1.0;

		var x3 = p0.lon;
		var y3 = p0.lat;
		for (i in start...(end))
		{
			var x1 = path[i].lon;
			var x2 = path[i+1].lon;
			var y1 = path[i].lat;
			var y2 = path[i+1].lat;
			var x4 = 0.0;
			var y4 = 0.0;
			if (p1 != null)
			{
				x4 = p1.lon;
				y4 = p1.lat;
			}

			//Ponto a Ponto
			var dp0 = (x1 - x3) * (x1 - x3) + (y1 - y3) * (y1 - y3);
			var dp1 = (x2 - x3) * (x2 - x3) + (y2 - y3) * (y2 - y3);
			//Ponto a Reta
			var u : Float = ( (x3 - x1) * (x2 - x1) + (y3 - y1) * (y2 - y1) ) / ( (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) );
			var dr = Math.POSITIVE_INFINITY;
			if (u <= 1 && u >= 0)
			{
				//interseccao
				var x = x1 + u * (x2 - x1);
				var y = y1 + u * (y2 - y1);
				dr = (x - x3) * (x - x3) + (y - y3) * (y - y3);
			}
			var d;
			if (dp0 < dr && dp0 < dp1)
			{
				d = dp0;
				u = 0;
			}
			else if (dp1 < dr && dp1 < dp0)
			{
				d = dp1;
				u = 1;
			}
			else
				d = dr;

			if (d < minDist)
			{
				var ok = false;
				if (p1 != null)
				{
					var angle1 = Radians.fromPoints(x2 - x1, y2 - y1, x4 - x3, y4 - y3);
					if (dir == Direction.OneWay)
					{
						if (angle1 < maxAngle)
							ok = true;
					} else if (dir == Direction.Reversed) {
						if (angle1 > 180 - maxAngle)
							ok = true;
					} else {
						if (angle1 > 180-maxAngle || angle1 < maxAngle)
							ok = true;
					}
				} else {
					ok = true;
				}

				if (ok && p1!= null)
				{
					var closestPoint = Location.lerp(path[i], path[i + 1], u);
					var angle2 = Radians.fromPoints(closestPoint.lon - x3, closestPoint.lat - y3, x4 - x3, y4 - y3);
					if (angle2 < 90-maxAngle || angle2 > 90+maxAngle)
						ok = false;
				}
				if (ok && d < maxSquareDistance*maxSquareDistance)
				{
					pathIndex = i;
					interpolation = u;
					minDist = d;
				}
			}
		}
		if (interpolation < 1 && pathIndex >= 0)
		{
			var gp = Location.lerp(path[pathIndex], path[pathIndex + 1], interpolation);
			minDist = gp.dist(p0).float() / 1000;
		}
		else
			minDist = path[pathIndex+1].dist(p0).float() / 1000;
		return this;
	}
}
