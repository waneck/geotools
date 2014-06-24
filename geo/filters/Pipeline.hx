package geo.filters;
import haxe.ds.Vector;

class Pipeline<T:Location>
{
	var path:Path<T>;
	var length:Int;
	private function new(path:Path<T>, src:Path<T>)
	{
		Vector.blit(src.data, src.start, path.data, 0, src.length);
		this.path = path;
		this.length = src.length;
	}

	inline public static function create<T:Location>(fromPath:Path<T>):Pipeline<T>
	{
		return new Pipeline(new Vector(fromPath.length), fromPath);
	}

	public function map(fn:T->Null<T>):Pipeline<T>
	{
		var data = path.data,
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

	public function end():Path<T>
	{
		var ret = new Path(path.data, 0, this.length);
		// make sure this cannot be used anymore
		this.path = null;
		return ret;
	}
}
