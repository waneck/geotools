package geo.units;

abstract Degrees(Float) from Float
{
	public static inline var One:Degrees = 1;
	public static inline var Zero:Degrees = 0;
	public static inline var Straight:Degrees = 90;

  static inline var toRad = 0.017453292519943295;

	@:extern inline public function new(f:Float)
	{
		this = f;
	}

	@:extern @:op(-A) public static function neg(s:Degrees):Degrees;
	@:extern @:op(A+B) public static function add(lhs:Degrees, offset:Degrees):Degrees;
	@:extern @:op(A-B) public static function sub(lhs:Degrees, offset:Degrees):Degrees;
	@:extern @:op(A>B) public static function gt(lhs:Degrees, rhs:Degrees):Bool;
	@:extern @:op(A>=B) public static function gte(lhs:Degrees, rhs:Degrees):Bool;
	@:extern @:op(A<B) public static function lt(lhs:Degrees, rhs:Degrees):Bool;
	@:extern @:op(A<=B) public static function lte(lhs:Degrees, rhs:Degrees):Bool;
	@:extern @:op(A==B) public static function eq(lhs:Degrees, rhs:Degrees):Bool;
	@:extern inline public function float() return this;
	@:commutative @:extern @:op(A*B) public static function add(lhs:Degrees, scalar:Float):Degrees;
	@:commutative @:extern @:op(A/B) public static function add(lhs:Degrees, scalar:Float):Degrees;

	@:commutative @:extern @:op(A+B) inline public static function adds(lhs:Degrees, offset:Radians):Radians
	{
		return lhs.toRadians() + offset;
	}

	@:commutative @:extern @:op(A-B) inline public static function subs(lhs:Degrees, offset:Radians):Radians
	{
		return lhs.toRadians() + offset;
	}

	@:extern @:to inline public function toRadians():Radians
	{
		return this * toRad;
	}

	@:extern inline public function toString()
	{
		return '$this°';
	}
}
