package geo;

@:dce @:forward abstract PathTime<T:LocationTime>(Path<T>) from Path<T> to Path<T>
{
	@:extern inline public function new(path)
	{
		this = path;
	}

	@:arrayAccess public function byTime(date:UtcDate):LocationTime
	{
	}

	inline public function timeIndex(date:UtcDate):Int
	{
	}

	public function constrain(startDate:UtcDate, endDate:UtcDate):LocationTime
	{
	}
}
