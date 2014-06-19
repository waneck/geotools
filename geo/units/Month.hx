package geo.units;

@:enum abstract Month(Int) from Int
{
	var Jan = 0;
	var Feb = 1;
	var Mar = 2;
	var Apr = 3;
	var May = 4;
	var Jun = 5;
	var Jul = 6;
	var Aug = 7;
	var Sep = 8;
	var Oct = 9;
	var Nov = 10;
	var Dec = 11;

	public function toString()
	{
		return switch (this)
		{
			case 0: "Jan";
			case 1: "Feb";
			case 2: "Mar";
			case 3: "Apr";
			case 4: "May";
			case 5: "Jun";
			case 6: "Jul";
			case 7: "Aug";
			case 8: "Sep";
			case 9: "Oct";
			case 10: "Nov";
			case 11: "Dec";
			case _: "INV_MONTH(" + this +")";
		}
	}

	inline public function toInt():Int
	{
		return this;
	}
}
