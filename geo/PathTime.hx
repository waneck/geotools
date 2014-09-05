package geo;
import haxe.ds.Vector;
import geo.units.*;

@:dce @:forward abstract PathTime<T:LocationTime>(Path<T>) from Path<T> to Path<T>
{
	@:extern inline public function new(path)
	{
		this = path;
	}

	@:arrayAccess @:extern inline public function byIndex(idx:Int):T
	{
		return this.get(idx);
	}

	public function expand(time:Seconds=0):PathTime<T>
	{
		if (time == 0)
		{
			return this.expand();
		} else {
			return new PathTime(this.expand()).constrainTime(new UnixDate(this.get(0).time.getTime() - time), new UnixDate(this.get(this.length).time.getTime() + time));
		}
	}

	/**
		Merges pieces of PathTime into a larger PathTime. Each PathTime is of course expected to be sorted by time
	**/
	inline public static function merge<T:LocationTime>(array:Array<PathTime<T>>, removeOverlaps=false):PathTime<T>
	{
		if (array.length <= 1)
		{
			if (array.length == 0)
				return new Path(null,0,0);
			else
				return array[0];
		} else {
			var len = 0;
			for (a in array)
				len += a.length;
			var merged = new Vector<T>(len);

			return mergeInternal(array,removeOverlaps,merged);
		}
	}

	private static function mergeInternal<T:LocationTime>(array:Array<PathTime<T>>, removeOverlaps:Bool, merged:Vector<T>):PathTime<T>
	{
		var all = array.copy();
		all.sort(function(v1,v2) return Reflect.compare(v1[v1.length-1].time, v2[v2.length-1].time));

		//TODO: optimize to O(n)
		var len = merged.length,
				pos = 0;
		for (a in all)
		{
			var i = 0;
			if (removeOverlaps)
			{
				while(pos > 0 && i < a.length && a[i].time < merged[pos - 1].time)
					i++;
			}

			var len = a.length;
			if (i < len)
				Vector.blit(a.data,a.start + i,merged,pos,len - i);
			pos += len - i;
		}

		quicksort(merged, 0, pos - 1);

		return new Path(merged,0,pos);

		// var indices = new Vector<Int>(array.length);
		// var smaller = Math.POSITIVE_INFINITY,
		// 		smallerIndex = 0,
		// 		next = Math.POSITIVE_INFINITY,
		// 		nextIndex = 0;
		// for (a in array)
		// {
		// 	var t = a[0].time.float();
		// 	if (t < smaller)
		// 	{
		// 		next = smaller;
		// 		smallerIndex =
		// 	}
		// }
	}

	static function quicksort<T:LocationTime>( buf:Vector<T>, lo : Int, hi : Int ) : Void
	{
		var i = lo, j = hi;
		var p = buf[(i + j) >> 1].time;
		while ( i <= j )
		{
			while ( buf[i].time < p ) i++;
			while ( buf[j].time > p ) j--;
			if ( i <= j )
			{
				var t = buf[i];
				buf[i++] = buf[j];
				buf[j--] = t;
			}
		}

		if( lo < j ) quicksort( buf, lo, j );
		if( i < hi ) quicksort( buf, i, hi );
	}

	public function byTimeRelative(date:UnixDate, expand=true):LocationTime
	{
		//binary search
		var start = this.start;
		var length = this.length;
		var locs = this.data;
		var min = this.start;
		if (locs.length == 1)
			return locs[min];
		var max = min + length, mid = 0;
		if (expand)
		{
			min = 0;
			max = locs.length;
		}
		while(min < max)
		{
			mid = Std.int(min + (max - min) / 2);
			var imid = locs[mid];
			if (expand && imid == null)
			{
				max = mid;
			} else if (date < imid.time) {
				max = mid;
			} else if (date > imid.time) {
				min = mid + 1;
			} else {
				return imid;
			}
		}

		min = start;
		max = min + length - 1;

		var minbound = min,
				maxbound = max;
		if (expand)
		{
			minbound = 0;
			maxbound = locs.length-1;
		}
		var d1 = null,
				d2 = null;

		if (date < locs[mid].time)
		{
			if (mid <= minbound)
				return locs[minbound];
			d1 = locs[mid - 1];
			d2 = locs[mid];
		} else {
			if (mid >= maxbound)
				return locs[maxbound];
			d1 = locs[mid];
			d2 = locs[mid+1];
		}
		var pct = (date.getTime().float() - d1.time.getTime().float()) / (d2.time.getTime().float() - d1.time.getTime().float());
		return new LocationTime( d1.lat + (d2.lat - d1.lat) * pct, d1.lon + (d2.lon - d1.lon) * pct, new UnixDate( d1.time.getTime() + (d2.time.getTime().float() - d1.time.getTime().float()) * pct ) );
	}

	@:arrayAccess @:extern inline public function byTime(date:UnixDate):T
	{
		return this.data[ this.start + timeIndex(date) ];
	}

	public function timeIndex(date:UnixDate):Int
	{
		//binary search
		var start = this.start;
		var locs = this.data;
		var min = start;
		var max = min + this.length, mid = 0;
		while(min < max)
		{
			mid = Std.int(min + (max - min) / 2);
			var imid = locs[mid];
			if (date < imid.time)
			{
				max = mid;
			} else if (date > imid.time) {
				min = mid + 1;
			} else {
				return mid - start;
			}
		}

		min = start;
		max = min + this.length - 1;
		var difRef = Math.abs(locs[mid].time.getTime().float() - date.getTime().float());
		var dif1 = (mid + 1) < max ? Math.abs(locs[mid + 1].time.getTime().float() - date.getTime().float()) : Math.POSITIVE_INFINITY;
		var dif2 = (mid - 1) >= min ? Math.abs(locs[mid - 1].time.getTime().float() - date.getTime().float()) : Math.POSITIVE_INFINITY;
		if (difRef < dif1)
			if (difRef < dif2)
				return mid - start;
			else
				return mid - 1 - start;
		else
			if (dif1 < dif2)
				return mid + 1 - start;
			else
				return mid - 1 - start;
	}

	public function constrainTime(startDate:UnixDate, endDate:UnixDate):PathTime<T>
	{
		var cstart = timeIndex(startDate),
				cend = timeIndex(endDate);
		return this.constrain(cstart, cend - cstart + 1);
	}
}
