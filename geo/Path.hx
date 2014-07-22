package geo;
import geo.units.*;
import haxe.ds.Vector;

@:allow(geo) class Path<Pos : Location>
{
	private var data:Vector<Pos>;
	public var start(default,null):Int;
	public var length(default,null):Int;

	public function new(data,start=0,length=-1)
	{
		this.data = data;
		this.start = start;
		this.length = length < 0 ? data.length - start : length;
	}

	@:arrayAccess inline public function get(at:Int):Pos
	{
		return data[start + at];
	}

	public function lengthMeters():Meters
	{
		var data = data,
				len = new Meters(0);
		for (i in start...(start+length - 1))
		{
			len += data[i].dist(data[i+1]);
		}
		return len;
	}

	public function expand():Path<Pos>
	{
		var data = data;
		var len = data.length;
		while (len > 0 && data[len-1] == null)
			len--;
		return new Path(data,0,len);
	}

	inline public function constrain(start:Int, length=-1):Path<Pos>
	{
		return new Path(data, start + this.start, length < 0 ? this.length - (start + this.start) : length);
	}

	inline public static function fromArray<Pos:Location>(arr:Array<Pos>, start:Int = 0, length = -1):Path<Pos>
	{
		length = length < 0 ? arr.length - start : length;
		var ret = new Vector(length);
		for (i in start...(start+length))
		{
			ret[i] = arr[start+i];
		}
		return new Path(ret,start,length);
	}

	inline public function iter(fn:Pos->Void):Void
	{
		var data = data;
		for (i in start...(start+length))
		{
			fn(data[i]);
		}
	}

	inline public function map<OtherPos : Location>(fn:Pos->OtherPos):Path<OtherPos>
	{
		return mapInternal(fn,new Vector(length));
	}

	@:extern inline public function mapInline<OtherPos : Location>(fn:Pos->OtherPos):Path<OtherPos>
	{
		var ret = new Vector(length);
		var data = data,
				len = 0;
		for (i in start...(start + length))
		{
			var r = fn(data[i]);
			if (r != null)
			{
				ret[len++] = r;
			}
		}

		return new Path(ret,0,len);
	}

	function mapInternal<OtherPos : Location>(fn:Pos->OtherPos, ret:Vector<OtherPos>):Path<OtherPos>
	{
		var data = data,
				len = 0;
		for (i in start...(start + length))
		{
			var r = fn(data[i]);
			if (r != null)
			{
				ret[len++] = r;
			}
		}

		return new Path(ret,0,len);
	}

	inline public function filter(fn:Pos->Bool):Path<Pos>
	{
		return filterInternal(fn,new Vector(length));
	}

	@:extern inline public function filterInline(fn:Pos->Bool):Path<Pos>
	{
		var ret = new Vector(length),
				len = 0;
		for (i in start...(start + length))
		{
			var pos = data[i];
			if (fn(pos))
			{
				ret[len++] = pos;
			}
		}

		if (len == 0)
		{
			return new Path(null,0,0);
		// } else if (len <= ret.length / 2) {
		// 	var r = new Vector(len);
		// 	Vector.blit(ret,0,r,0,len);
		// 	return new Path(r,0,len);
		} else {
			return new Path(ret,0,len);
		}
	}

	function filterInternal(fn:Pos->Bool, ret:Vector<Pos>):Path<Pos>
	{
		var len = 0;
		for (i in start...(start + length))
		{
			var pos = data[i];
			if (fn(pos))
			{
				ret[len++] = pos;
			}
		}

		if (len == 0)
		{
			return new Path(null,0,0);
		// } else if (len != ret.length) {
		// 	var r = new Vector(len);
		// 	Vector.blit(ret,0,r,0,len);
		// 	return new Path(r,0,len);
		} else {
			return new Path(ret,0,len);
		}
	}

	inline public function iterator():PathIterator<Pos>
	{
		return new PathIterator(this);
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

class PathIterator<Pos : Location>
{
	var data:Vector<Pos>;
	var index:Int;
	var end:Int;
	inline public function new(data:Path<Pos>)
	{
		this.data = data.data;
		this.index = data.start;
		this.end = data.start + data.length;
	}

	inline public function hasNext():Bool
	{
		return this.index < end;
	}

	inline public function next():Pos
	{
		return data[this.index++];
	}
}
