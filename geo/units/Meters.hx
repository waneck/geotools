package geo.units;

abstract Meters(Float) from Float
{
	@:extern inline public function new(f:Float)
	{
		this = f;
	}

	@:extern @:op(A+B) public static function add(lhs:Meters, rhs:Meters):Meters;
	@:extern @:op(A-B) public static function sub(lhs:Meters, rhs:Meters):Meters;
  @:extern @:op(A>B) public static function gt(lhs:Meters, rhs:Meters):Bool;
  @:extern @:op(A>=B) public static function gte(lhs:Meters, rhs:Meters):Bool;
  @:extern @:op(A<B) public static function lt(lhs:Meters, rhs:Meters):Bool;
  @:extern @:op(A<=B) public static function lte(lhs:Meters, rhs:Meters):Bool;
  @:extern inline public function float() return this;

  public function toString()
  {
    return '$this(m)';
  }
}
