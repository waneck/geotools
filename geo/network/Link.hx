package geo.network;
import geo.*;

class Link
{
	public var from(default,null):Location;
	public var to(default,null):Location;
	public var geom(default,null):PathWay;
	var network(default,null):Network;

	public function new(from,to,geom)
	{
		this.from = from;
		this.to = to;
		this.geom = geom;
		this.network = network;
	}

	/**
		Returns all links that connect to `this` link.
		The results should *not* contain `this` link
	**/
	inline public function fromLinks():Array<Link>
	{
		return network.joinedFrom(this);
	}

	/**
		Returns all links that connect to `this` link.
		The results should *not* contain `this` link
	**/
	inline public function toLinks():Array<Link>
	{
		return network.joinedTo(this);
	}
}
