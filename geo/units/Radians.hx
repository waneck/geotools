package geo.units;

abstract Radians(Float) from Float
{
	public static inline var One:Radians = 1;
	public static inline var Zero:Radians = 0;
	public static inline var Pi:Radians = 3.1415926535897932384626433832795028841971693993751058; //I know that's overkill
	public static inline var HalfPi:Radians = Pi / 2;

	@:extern inline public function new(f:Float)
	{
		this = f;
	}

	@:extern @:op(-A) public static function neg(s:Radians):Radians;
	@:extern @:op(A+B) public static function add(lhs:Radians, offset:Radians):Radians;
	@:extern @:op(A-B) public static function sub(lhs:Radians, offset:Radians):Radians;
	@:extern @:op(A>B) public static function gt(lhs:Radians, rhs:Radians):Bool;
	@:extern @:op(A>=B) public static function gte(lhs:Radians, rhs:Radians):Bool;
	@:extern @:op(A<B) public static function lt(lhs:Radians, rhs:Radians):Bool;
	@:extern @:op(A<=B) public static function lte(lhs:Radians, rhs:Radians):Bool;
	@:extern @:op(A==B) public static function eq(lhs:Radians, rhs:Radians):Bool;
	@:extern inline public function float() return this;

	@:commutative @:extern @:op(A*B) public static function add(lhs:Radians, scalar:Float):Radians;
	@:commutative @:extern @:op(A/B) public static function add(lhs:Radians, scalar:Float):Radians;

	public static function fromPoints(x1:Float, y1:Float, x2:Float, y2:Float):Radians
	{
		var d = x1 * x2 + y1 * y2;
		var m1 = Math.sqrt(x1 * x1 + y1 * y1);
		var m2 = Math.sqrt(x2 * x2 + y2 * y2);
		return acos(d / (m1 * m2));
	}

	@:extern inline public static function acos(cos:Float):Radians
	{
		return Math.acos(cos);
	}

	@:extern inline public function toString()
	{
		return '$this(rad)';
	}
}
