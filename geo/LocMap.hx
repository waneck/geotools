package geo;
import geo.tools.Geohash.*;
import geo.tools.Geohash;
import haxe.ds.StringMap;

@:dce abstract LocMap<K:Location,V>(LocMapTree<K,V>)
{
	/**
		Creates a new LocMap. The higher the precision defined, the better.
		If the `precision` is a power of ten, it will represent the amount of decimal spaces to be considered
	**/
	@:extern inline public function new(precision:Float=1e7)
	{
		this = new LocMapTree(precision);
	}

	/**
		Maps `key` to `value`.

		If `key` already has a mapping, the previous value disappears.

		If `key` is null, the result is unspecified.
	**/
	public inline function set(key:K, value:V) this.set(key, value);

	/**
		Returns the current mapping of `key`.

		If no such mapping exists, null is returned.

		Note that a check like `map.get(key) == null` can hold for two reasons:

		1. the map has no mapping for `key`
		2. the map has a mapping with a value of `null`

		If it is important to distinguish these cases, `exists()` should be
		used.

		If `key` is null, the result is unspecified.
	**/
	@:arrayAccess public inline function get(key:K) return this.get(key);

	/**
		Returns true if `key` has a mapping, false otherwise.

		If `key` is null, the result is unspecified.
	**/
	public inline function exists(key:K) return this.exists(key);

	/**
		Removes the mapping of `key` and returns true if such a mapping existed,
		false otherwise.

		If `key` is null, the result is unspecified.
	**/
	public inline function remove(key:K) return this.remove(key);

	/**
		Returns an Iterator over the keys of `this` Map.

		The order of keys is undefined.
	**/
	inline public function keys():Iterator<K> {
		return this.keys();
	}

	/**
		Returns an Iterator over the values of `this` Map.

		The order of values is undefined.
	**/
	public inline function iterator():Iterator<V> {
		return this.iterator();
	}

	/**
		Returns a String representation of `this` Map.

		The exact representation depends on the platform and key-type.
	**/
	inline public function toString():String
	{
		return this.toString();
	}

	@:arrayAccess @:noCompletion public inline function arrayWrite(k:K, v:V):V
	{
		this.set(k, v);
		return v;
	}
}

class LocMapTree<K:Location, V> extends haxe.ds.BalancedTree<K, V> implements Map.IMap<K,V>
{
	var precision:Float;
	public function new(precision:Float)
	{
		super();
		this.precision = precision;
	}

	override function compare(k1:Location, k2:Location):Int
	{
		var precision = precision,
				prec5 = .5 * (1 / precision);
		var lat1 = Std.int(precision * (prec5 + k1.lat)),
				lon1 = Std.int(precision * (prec5 + k1.lon)),
				lat2 = Std.int(precision * (prec5 + k2.lat)),
				lon2 = Std.int(precision * (prec5 + k2.lon));
		var ret = lat1 - lat2;
		if (ret == 0)
			return lon1 - lon2;
		else
			return ret;
	}
}
