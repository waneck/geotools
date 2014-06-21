package geo.units;

abstract Minutes(Float) from Float
{
	public static inline var One:Minutes = 1;
	public static inline var Zero:Minutes = 0;

	@:extern inline public function new(f:Float)
	{
		this = f;
	}

	@:extern @:op(-A) public static function neg(s:Minutes):Minutes;
	@:extern @:op(A+B) public static function add(lhs:Minutes, offset:Minutes):Minutes;
	@:extern @:op(A-B) public static function sub(lhs:Minutes, offset:Minutes):Minutes;
	@:extern @:op(A>B) public static function gt(lhs:Minutes, rhs:Minutes):Bool;
	@:extern @:op(A>=B) public static function gte(lhs:Minutes, rhs:Minutes):Bool;
	@:extern @:op(A<B) public static function lt(lhs:Minutes, rhs:Minutes):Bool;
	@:extern @:op(A<=B) public static function lte(lhs:Minutes, rhs:Minutes):Bool;
	@:extern @:op(A==B) public static function eq(lhs:Minutes, rhs:Minutes):Bool;
	@:extern inline public function float() return this;

	@:commutative @:extern @:op(A+B) inline public static function adds(lhs:Minutes, offset:Seconds):Seconds
	{
		return lhs.toSeconds() + offset;
	}

	@:commutative @:extern @:op(A-B) inline public static function subs(lhs:Minutes, offset:Seconds):Seconds
	{
		return lhs.toSeconds() + offset;
	}

	@:extern @:to inline public function toSeconds():Seconds
	{
		return this * 60.0;
	}

	@:extern inline public function toString()
	{
		return '$this(min)';
	}
}
