package geo.network;
import haxe.ds.Vector;
import geo.*;
import geo.network.NetworkError;

class Link
{
	public var from(default,null):Location;
	public var to(default,null):Location;
	public var geom(default,null):PathWay;
	public var network(get,never):Network;
	var _network:Null<Network>;

	/**
		Creates a new Link from the points `from` and `to`.
		If `geom` is null, a geometry path is created using `from` and `to`;
		If `geom` doesn't start at `from` and end at `to`, `InvalidLink` exception is thrown
		The constructor will make a few checks to make sure that `geom` is valid:
		 - Check if the geometry is in the reverse order; If it is, throw an error
	**/
	public function new(from,to,?geom:PathWay)
	{
		this.from = from;
		this.to = to;
		var g = geom;
		if (g == null)
		{
			var p = haxe.ds.Vector.fromArrayCopy([from,to]);
			g = new Path(p);
		} else if (g.length < 2 || !from.eq(g[0]) || !to.eq(g[g.length-1])) {
			throw InvalidLink(from,to,g);
		}
		if (g.length >= 4)
		{
			// check if not reversed

		}
		this.geom = g;
	}

	/**
		Creates a Link from inflection points instead of geometry (the geometry must include the `from` nor `to` points)
	**/
	public static function fromInflectionPoints(from,to,inflectionPoints:PathWay):Link
	{
		if (inflectionPoints == null || inflectionPoints.length == 0)
		{
			return new Link(from,to);
		} else {
			var i = 0,
					needsFrom = false,
					needsTo = false;
			if (!inflectionPoints[0].eq(from))
			{
				needsFrom = true;
				i++;
			}
			if (!inflectionPoints[inflectionPoints.length-1].eq(to))
			{
				needsTo = true;
				i++;
			}

			if (i == 0)
				return new Link(from,to,inflectionPoints);
			var newp = new Vector(inflectionPoints.length + i);
			i = 0;
			if (needsFrom)
			{
				newp[i++] = from;
			}
			inflectionPoints.copyTo(newp,i);
			if (needsTo)
			{
				newp[ newp.length - 1 ] = to;
			}

			return new Link(from,to,new Path(newp));
		}
	}

	/**
		Returns all links that connect to `this` link.
		The results should *not* contain `this` link
	**/
	inline public function fromLinks():Array<Link>
	{
		return _network.joinedByFrom(this);
	}

	/**
		Returns all links that connect to `this` link.
		The results should *not* contain `this` link
	**/
	inline public function toLinks():Array<Link>
	{
		return _network.joinedByTo(this);
	}

	public function get_network():Network
	{
		if (_network == null) throw LinkNotInNetwork(this);
		return _network;
	}

	/**
		Convenience method that adds `this` link to `network`.
		@see Network.addLink
		@return itself to provide a fluent interface (e.g. `doSomething(link.reverse().addTo(link.network))` )
	**/
	public function addTo(network:Network,replace=false):Link
	{
		if (_network != null && _network != network)
			throw LinkNotInNetwork(this);
		network.addLink(this,replace);
		return this;
	}

	/**
		Reverses `from`, `to` and the `geom` so that the new Link's `from` points to `to`, and `to` points to `from`.
		The new link returned is not automatically added to the network `this` belongs to; this must be explicit
	**/
	public function reverse():Link
	{
		var from = to,
				to = from;
		if (this.geom.length > 2)
		{
			var geom = geom;
			var ret = new Vector(geom.length);
			for (i in 0...geom.length)
			{
				ret[i] = geom[ geom.length - i - 1];
			}
			return new Link(from,to,new Path(ret));
		} else {
			return new Link(from,to);
		}
	}

	public function toString()
	{
		return 'Link ($from - $to)';
	}
}
