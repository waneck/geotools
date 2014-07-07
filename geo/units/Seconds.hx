package geo.units;

abstract Seconds(Float) from Float
{
	public static inline var One:Seconds = 1;
	public static inline var Zero:Seconds = 0;

	@:extern inline public function new(f:Float)
	{
		this = f;
	}

	@:extern inline public static function fromTime(hours:Hours = 0, minutes:Minutes = 0, secs:Seconds = 0):Seconds
	{
		return hours + minutes.toSeconds() + secs;
	}

	@:extern @:op(-A) public static function neg(s:Seconds):Seconds;
	@:extern @:op(A+B) public static function add(lhs:Seconds, offset:Seconds):Seconds;
	@:extern @:op(A-B) public static function sub(lhs:Seconds, offset:Seconds):Seconds;
	@:extern @:op(A>B) public static function gt(lhs:Seconds, rhs:Seconds):Bool;
	@:extern @:op(A>=B) public static function gte(lhs:Seconds, rhs:Seconds):Bool;
	@:extern @:op(A<B) public static function lt(lhs:Seconds, rhs:Seconds):Bool;
	@:extern @:op(A<=B) public static function lte(lhs:Seconds, rhs:Seconds):Bool;
	@:extern @:op(A==B) public static function eq(lhs:Seconds, rhs:Seconds):Bool;
	@:extern inline public function float() return this;

	@:extern @:from inline public static function fromDate(d:Date):Seconds
	{
		return d.getTime() / 1000;
	}

	@:extern inline public function abs():Seconds
	{
		return Math.abs(this);
	}

	public function toString()
	{
		var s = this < 0 ? -this : this,
				m = Std.int(s / 60),
				h = Std.int(m / 60);
		m = m % 60;
		s = s % 60;

		var h =
			if (h > 0)
				h + ":";
			else
				"";

		var m =
			if (m > 0)
				(m < 10) ? "0" + m + ":" : m + ":";
			else if (h == "")
				"";
			else
				"00:";

		s = s % 60;
		return (this < 0 ? "-" : "") + ((s < 10) ? h + m + "0" + s : h + m + s);
	}
}
