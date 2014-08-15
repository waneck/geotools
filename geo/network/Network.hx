package geo.network;
import geo.*;
import geo.network.NetworkError;

@:forward abstract Network(AbstractNetwork) from AbstractNetwork to AbstractNetwork
{
	@:extern inline public function new(precision=1e7)
	{
		this = new BasicNetwork(precision);
	}
}

@:access(geo.network.Link) @:abstract class AbstractNetwork
{
	public var precision(default,null):Float;
	public var name(default,null):String;

	private static var id = 0;

	public function new(precision=1e7,?name)
	{
		this.precision = precision;
		this.name = name != null ? name : "anon-" + id++;
	}

	/**
		Returns all links that share their `to` node with the `from` node from `link`.
		Depending on the network, this may be different than calling `linksWithTo(link.from)`,
		as this method may evaluate forbidden conversions, or links in different altitutes.

		@throws `LinkNotInNetwork` if link does not belong to network
	**/
	inline public function joinedByFrom(link:Link):Array<Link>
	{
#if debug
		if (link._network != this) throw LinkNotInNetwork(link);
#end
		return p_joinedByFrom(link);
	}

	private function p_joinedByFrom(link:Link):Array<Link>
	{
		return throw "NI";
	}

	/**
		Returns all links that share their `from` node with the `to` node from `link`.
		Depending on the network, this may be different than calling `linksWithFrom(link.to)`,
		as this method may evaluate forbidden conversions, or links in different altitutes.

		@throws `LinkNotInNetwork` if link does not belong to network
	**/
	inline public function joinedByTo(link:Link):Array<Link>
	{
#if debug
		if (link._network != this) throw LinkNotInNetwork(link);
#end
		return p_joinedByTo(link);
	}

	private function p_joinedByTo(link:Link):Array<Link>
	{
		return throw "NI";
	}

	/**
		Returns all links whose `from` nodes are defined by `node`.
		The precision of the `node` search varies from network

		@throws `NodeNotFound` if node is not found in network
	**/
	public function linksWithFrom(node:Location):Array<Link>
	{
		return throw NodeNotFound(node);
	}

	/**
		Returns all links whose `to` nodes are defined by `node`.
		The precision of the `node` search varies from network

		@throws `NodeNotFound` if node is not found in network
	**/
	public function linksWithTo(node:Location):Array<Link>
	{
		return throw NodeNotFound(node);
	}

	/**
		Gets a link that is defined by `from` and `to`.
		@throws `InvalidLink` if the link is not present
	**/
	public function getLink(from:Location, to:Location):Link
	{
		return throw InvalidLink(from,to);
	}

	/**
		Call this function to register the link `link` to `this` network.
		If `link` is already registered in another network, an error will be thrown.
		If another link is defined with the same `to` and `from`, it will either be replaced - if `replace` is true -
		or an error will be thrown
	**/
	public function addLink(link:Link, replace:Bool):Void
	{
		throw "NI";
	}

	public function iterator():Iterator<Link>
	{
		throw "NI";
	}

	public function toString()
	{
		return 'Network $name';
	}
}

@:access(geo.network.Link) class BasicNetwork extends AbstractNetwork
{
	private var nodes:LocMap<Location,Array<Link>>;
	private var links:Map<Link,Bool>;

	public function new(precision:Float=1e7,?name)
	{
		super(precision,name);
		this.nodes = new LocMap(precision);
		this.links = new Map();
	}

	override private function p_joinedByFrom(link:Link):Array<Link>
	{
		var from = link.from;
		var ret = nodes[from];
		if (ret == null) return [];
		else return [ for (r in ret) if (r != link && r.to.eq(from,precision)) r ];
	}

	override private function p_joinedByTo(link:Link):Array<Link>
	{
		var to = link.to;
		var ret = nodes[to];
		if (ret == null) return [];
		else return [ for (r in ret) if (r != link && r.from.eq(to,precision)) r ];
	}

	override public function linksWithFrom(node:Location):Array<Link>
	{
		var ret = nodes[node];
		if (ret == null) throw NodeNotFound(node);
		return [ for (r in ret) if (r.from.eq(node,precision)) r ];
	}

	override public function linksWithTo(node:Location):Array<Link>
	{
		var ret = nodes[node];
		if (ret == null) throw NodeNotFound(node);
		return [ for (r in ret) if (r.to.eq(node,precision)) r ];
	}

	override public function getLink(from:Location, to:Location):Link
	{
		var n = nodes[from];
		if (n == null)
			throw InvalidLink(from,to);
		for (l in n)
			if (l.to.eq(to,precision))
				return l;
		throw InvalidLink(from,to);
	}

	override public function addLink(link:Link, replace:Bool):Void
	{
		if (link._network != null)
			if (link._network == this)
				return;
			else
				throw LinkNotInNetwork(link);
		var nfrom = nodes[link.from];
		if (nfrom == null)
		{
			nfrom = nodes[link.from] = [];
		}
		var nto = nodes[link.to];
		if (nto == null)
		{
			nto = nodes[link.to] = [];
		}

		var cont = true,
				fromLoc = link.from;
		for (f in nfrom)
		{
			if (!cont) break;
			for (t in nto)
			{
				if (f == t && f.from.eq(fromLoc) && f.to.eq(link.to))
				{
					if (replace)
					{
						f._network = null;
						nto.remove(f);
						nfrom.remove(t);
						links.remove(t);
						cont = false;
						break;
					} else {
						throw LinkAlreadyExists(f,link);
					}
				}
			}
		}

		links[link] = true;
		nto.push(link);
		nfrom.push(link);
		link._network = this;
	}

	override public function iterator():Iterator<Link>
	{
		return links.keys();
	}
}
