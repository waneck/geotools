package geo.units;

abstract Hours(Float) from Float
{
	public static inline var One:Hours = 1;
	public static inline var Zero:Hours = 0;

	@:extern inline public function new(f:Float)
	{
		this = f;
	}

	@:extern @:op(-A) public static function neg(s:Hours):Hours;
	@:extern @:op(A+B) public static function add(lhs:Hours, offset:Hours):Hours;
	@:extern @:op(A-B) public static function sub(lhs:Hours, offset:Hours):Hours;
	@:extern @:op(A>B) public static function gt(lhs:Hours, rhs:Hours):Bool;
	@:extern @:op(A>=B) public static function gte(lhs:Hours, rhs:Hours):Bool;
	@:extern @:op(A<B) public static function lt(lhs:Hours, rhs:Hours):Bool;
	@:extern @:op(A<=B) public static function lte(lhs:Hours, rhs:Hours):Bool;
	@:extern @:op(A==B) public static function eq(lhs:Hours, rhs:Hours):Bool;
	@:extern inline public function float() return this;

	@:commutative @:extern @:op(A+B) inline public static function adds(lhs:Hours, offset:Seconds):Seconds
	{
		return lhs.toSeconds() + offset;
	}

	@:commutative @:extern @:op(A-B) inline public static function subs(lhs:Hours, offset:Seconds):Seconds
	{
		return lhs.toSeconds() + offset;
	}

	@:extern @:to inline public function toSeconds():Seconds
	{
		return this * 60.0 * 60.0;
	}

	@:extern inline public function toString()
	{
		return '$this(h)';
	}
}
