package geo;
import geo.units.*;

@:dce @:forward abstract TimeSpan(TimeSpanData)
{
	@:extern inline public function new(start:UnixDate,end:UnixDate)
	{
		this = (start <= end) ? new TimeSpanData(start,end) : throw 'Impossible TimeSpan: start ($start) is greater than end ($end)';
	}

	@:extern inline public function getDuration():Seconds
	{
		return this.end.getTime() - this.start.getTime();
	}

	@:op(A+B) @:extern inline public function addDate(other:UnixDate):TimeSpan
	{
		return new TimeSpan( new UnixDate(Math.min(this.start.float(), other.float())), new UnixDate(Math.max(this.end.float(), other.float())) );
	}

	@:op(A+B) @:extern inline public function add(other:TimeSpan):TimeSpan
	{
		return new TimeSpan( new UnixDate(Math.min(this.start.float(), other.start.float())), new UnixDate(Math.max(this.end.float(), other.end.float())) );
	}

	public function contains(date:UnixDate):Bool
	{
		return date >= this.start && date <= this.end;
	}

	public function expand(secs:Seconds):TimeSpan
	{
		return new TimeSpan( new UnixDate(this.start.getTime() - secs), new UnixDate(this.end.getTime() + secs) );
	}

	public function intersect(other:TimeSpan):Null<TimeSpan>
	{
		var s = Math.max(this.start.float(), other.start.float()),
				e = Math.min(this.end.float(), other.end.float());
		if (s <= e)
			return new TimeSpan(new UnixDate(s),new UnixDate(e));
		else
			return null;
	}

	public function intersects(other:TimeSpan):Bool
	{
		var s = Math.max(this.start.float(), other.start.float()),
				e = Math.min(this.end.float(), other.end.float());
		return (s <= e);
	}
}

@:dce private class TimeSpanData
{
	public var start(default,null):UnixDate;
	public var end(default,null):UnixDate;

	public function new(start,end)
	{
		this.start = start;
		this.end = end;
	}

	public function toString()
	{
		return '($start - $end)';
	}
}
