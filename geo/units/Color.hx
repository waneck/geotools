package geo.units;
using StringTools;

/**
	ARGB Int
**/
abstract Color(Int) from Int
{
	public static inline var Red:Color = 0xFFFF0000;
	public static inline var Green:Color = 0xFF00FF00;
	public static inline var Blue:Color = 0xFF0000FF;
	public static inline var Black:Color = 0xFF000000;
	public static inline var White:Color = 0xFFFFFFFF;

	public var red(get,never):Int;
	public var green(get,never):Int;
	public var blue(get,never):Int;
	public var alpha(get,never):Int;

	inline public function new(argb:Int)
	{
		this = argb;
	}

	inline private function get_red():Int
	{
		return (this >> 16) & 0xff;
	}

	inline private function get_green():Int
	{
		return (this >> 8) & 0xff;
	}

	inline private function get_blue():Int
	{
		return (this & 0xff);
	}

	inline private function get_alpha():Int
	{
		return (this >>> 24) & 0xff;
	}

	inline public function setRed(red:Int):Color
	{
		return (this & 0xFF00FFFF) | ((red & 0xff) << 16);
	}

	inline public function setGreen(green:Int):Color
	{
		return (this & 0xFFFF00FF) | ((green & 0xff) << 8);
	}

	inline public function setBlue(blue:Int):Color
	{
		return (this & 0xFFFFFF00) | ((blue & 0xff));
	}

	inline public function setAlpha(alpha:Int):Color
	{
		return (this & 0x00FFFFFF) | ((alpha & 0xff) << 24);
	}

	inline public static function fromParts(red:Int, green:Int, blue:Int, alpha:Int=0xff):Color
	{
		return ((alpha & 0xff) << 24) | ((red & 0xff) << 16) | ((green & 0xff) << 8) | (blue & 0xff);
	}

	public function toABGR():String
	{
		inline function c(i:Int)
		{
			return i.hex().lpad("0",2).substr(0,2);
		}
		return c(alpha) + c(blue) + c(green) + c(red);
	}

	public function toString():String
	{
		inline function c(i:Int)
		{
			return i.hex().lpad("0",2).substr(0,2);
		}
		return "#" + c(alpha) + c(red) + c(green) + c(blue);
	}
}
