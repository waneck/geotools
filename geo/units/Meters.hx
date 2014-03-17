package geo.units;

abstract Meters(Float) from Float
{
	@:extern inline public function new(f:Float)
	{
		this = f;
	}

	@:extern @:op(A+B) public static function add(lhs:Meters, rhs:Meters):Meters;
	@:extern @:op(A-B) public static function sub(lhs:Meters, rhs:Meters):Meters;
  @:extern public function float() return this;

  public function toString()
  {
    return '$this(m)';
  }
}
