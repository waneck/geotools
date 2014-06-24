package geo;
import geo.units.*;

@:dce @:forward abstract TimeSpan(TimeSpanData)
{
	@:extern inline public function new(start:UtcDate,end:UtcDate)
	{
		this = (start <= end) ? new TimeSpanData(start,end) : throw 'Impossible TimeSpan: start ($start) is greater than end ($end)';
	}

	@:extern inline public function getDuration():Seconds
	{
		return this.end.getTime() - this.start.getTime();
	}

	@:op(A+B) @:extern inline public function addDate(other:UtcDate):TimeSpan
	{
		return new TimeSpan( new UtcDate(Math.min(this.start.float(), other.float())), new UtcDate(Math.max(this.end.float(), other.float())) );
	}

	@:op(A+B) @:extern inline public function add(other:TimeSpan):TimeSpan
	{
		return new TimeSpan( new UtcDate(Math.min(this.start.float(), other.start.float())), new UtcDate(Math.max(this.end.float(), other.end.float())) );
	}

	public function intersect(other:TimeSpan):Null<TimeSpan>
	{
		var s = Math.max(this.start.float(), other.start.float()),
				e = Math.min(this.end.float(), other.end.float());
		if (s <= e)
			return new TimeSpan(new UtcDate(s),new UtcDate(e));
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
	public var start(default,null):UtcDate;
	public var end(default,null):UtcDate;

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
