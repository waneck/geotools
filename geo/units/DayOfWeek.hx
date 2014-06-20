package geo.units;

@:enum abstract DayOfWeek(Int) from Int
{
	var Sunday = 0;
	var Monday = 1;
	var Tuesday = 2;
	var Wednesday = 3;
	var Thursday = 4;
	var Friday = 5;
	var Saturday = 6;

	public function toString()
	{
		return switch (this)
		{
			case 0: "Sunday";
			case 1: "Monday";
			case 2: "Tuesday";
			case 3: "Wednesday";
			case 4: "Thursday";
			case 5: "Friday";
			case 6: "Saturday";
			case _: throw 'NOTDAY($this)';
		}
	}

	inline public function toInt():Int
	{
		return this;
	}
}
