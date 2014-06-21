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
			case 0: "January";
			case 1: "February";
			case 2: "March";
			case 3: "April";
			case 4: "May";
			case 5: "June";
			case 6: "July";
			case 7: "August";
			case 8: "September";
			case 9: "October";
			case 10: "November";
			case 11: "December";
			case _: "INV_MONTH(" + this +")";
		}
	}

	inline public static function fromInt(i:Int):Month
	{
		return (i <= 11) ? i : throw "Invalid month number " + i;
	}

	public static function fromString(str:String):Month
	{
		str = str.toLowerCase();
		return if (str.length == 3)
		{
			switch (str)
			{
				case "jan": 0;
				case "feb": 1;
				case "mar": 2;
				case "apr": 3;
				case "may": 4;
				case "jun": 5;
				case "jul": 6;
				case "aug": 7;
				case "sep": 8;
				case "oct": 9;
				case "nov": 10;
				case "dec": 11;
				case _: throw "Invalid month from String: '" + str + "'";
			}
		} else {
			switch (str)
			{
				case "january": 0;
				case "february": 1;
				case "march": 2;
				case "april": 3;
				case "may": 4;
				case "june": 5;
				case "july": 6;
				case "august": 7;
				case "september": 8;
				case "october": 9;
				case "november": 10;
				case "december": 11;
				case _: throw "Invalid month from String: '" + str + "'";
			}
		}
	}

	inline public function toInt():Int
	{
		return this;
	}
}
