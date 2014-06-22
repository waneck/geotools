package geo;
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

	inline public function expand():Path<Pos>
	{
		return new Path(data);
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
		var ret = new haxe.ds.Vector(this.data.length),
				data = data;
		for (i in start...(start + length))
		{
			ret[i] = fn(data[i]);
		}

		return new Path(ret,0,length);
	}

	public function filter(fn:Pos->Bool):Path<Pos>
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
			return new Path(null,0,0);
		else if (len != ret.length)
		{
			var r = new Vector(len);
			for (i in 0...len)
				r[i] = ret[i];
			return new Path(r,0,len);
		} else {
			return new Path(ret,0,len);
		}
	}

	inline public function iterator():PathIterator<Pos>
	{
		return new PathIterator(this);
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
