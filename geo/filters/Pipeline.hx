package geo.filters;
import haxe.ds.Vector;

class Pipeline<T:Location>
{
	var dst:Vector<T>;
	var length:Int;
	private function new(dst:Vector<T>, src:Path<T>)
	{
		if (src.length > 0)
			Vector.blit(src.data, src.start, dst, 0, src.length);
		this.dst = dst;
		this.length = src.length;
	}

	inline public static function create<T:Location>(fromPath:Path<T>):Pipeline<T>
	{
		return new Pipeline(new Vector(fromPath.length), fromPath);
	}

	public function map(fn:T->Null<T>):Pipeline<T>
	{
		var data = dst,
				len = 0;
		for (i in 0...this.length)
		{
			var tmp = fn(data[i]);
			if (tmp != null)
				data[len++] = tmp;
		}

		this.length = len;
		return this;
	}

	public function unsafe(fn:Vector<T>->Int->Int):Pipeline<T>
	{
		this.length = fn(dst,this.length);
		return this;
	}

	public function end():Path<T>
	{
		var ret = new Path(dst, 0, this.length);
		// make sure this cannot be used anymore
		this.dst = null;
		return ret;
	}
}
