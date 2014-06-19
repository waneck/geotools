package geo.units;

abstract Seconds(Float) from Float
{
	@:extern inline public function new(f:Float)
	{
		this = f;
	}

	@:extern @:op(A+B) public static function add(lhs:Seconds, offset:Seconds):Seconds;
	@:extern @:op(A-B) public static function sub(lhs:Seconds, offset:Seconds):Seconds;
  @:extern @:op(A>B) public static function gt(lhs:Seconds, rhs:Seconds):Bool;
  @:extern @:op(A>=B) public static function gte(lhs:Seconds, rhs:Seconds):Bool;
  @:extern @:op(A<B) public static function lt(lhs:Seconds, rhs:Seconds):Bool;
  @:extern @:op(A<=B) public static function lte(lhs:Seconds, rhs:Seconds):Bool;
  @:extern inline public function float() return this;

  @:from public static function fromDate(d:Date):Seconds
  {
    return d.getTime() / 1000;
  }

  public function toString()
  {
    return '$this(s)';
  }
}
