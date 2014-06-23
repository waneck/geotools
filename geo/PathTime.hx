package geo;

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

	public function byTimeRelative(date:UtcDate, expand=true):LocationTime
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
			if (date < imid.time)
			{
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
		return new LocationTime( d1.lat + (d2.lat - d1.lat) * pct, d1.lon + (d2.lon - d1.lon) * pct, new UtcDate( d1.time.getTime() + (d2.time.getTime().float() - d1.time.getTime().float()) * pct ) );
	}

	@:arrayAccess @:extern inline public function byTime(date:UtcDate):T
	{
		return this.data[ timeIndex(date) ];
	}

	public function timeIndex(date:UtcDate):Int
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
				return mid;
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

	public function constrainTime(startDate:UtcDate, endDate:UtcDate):PathTime<T>
	{
		var cstart = timeIndex(startDate),
				cend = timeIndex(endDate);
		return this.constrain(cstart, cend - cstart);
	}
}
