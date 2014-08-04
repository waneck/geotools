package geo.network;
import geo.*;
import geo.network.NetworkErrors;

@:forward abstract Network(AbstractNetwork) from AbstractNetwork to AbstractNetwork
{
	@:extern inline public function new(precision:Int)
	{
		this = new BasicNetwork(precision);
	}
}

@:abstract class AbstractNetwork
{
	/**
		Returns all links that share their `to` node with the `from` node from `link`.
		Depending on the network, this may be different than calling `linksWithTo(link.from)`,
		as this method may evaluate forbidden conversions, or links in different altitutes.

		@throws `LinkNotInNetwork` if link does not belong to network
	**/
	inline public function joinedByFrom(link:Link):Array<Link>
	{
#if debug
		if (link.network != this) throw LinkNotInNetwork(link);
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
		if (link.network != this) throw LinkNotInNetwork(link);
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
		@throws `LinkNotFound` if the link is not present
	**/
	public function getLink(from:Location, to:Location):Link
	{
		return throw LinkNotFound(from,to);
	}

	/**
		This function is called internally from new Link(), and registers the link - if it's not registered already
	**/
	public function registerLink(link:Link):Void
	{
		throw "NI";
	}
}

@:access(geo.network.Link) class BasicNetwork extends AbstractNetwork
{
	private var nodes:LocMap<Location,Array<Link>>;
	private var precision:Float;

	public function new(precision:Float=1e7)
	{
		this.precision = precision;
		this.nodes = new LocMap(precision);
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
			throw LinkNotFound(from,to);
		for (l in n)
			if (l.to.eq(to,precision))
				return l;
		throw LinkNotFound(from,to);
	}

	public function registerLink(link:Link):Void
	{
		if (link.network != null)
			if (link.network == this)
				return;
			else
				throw "Link " + link + " is already on another network";
		var nfrom = nodes[link.from];
		if (nfrom == null)
		{
			nfrom = nodes[link.from] = [];
		}
		if (nto == null)
		{
			nto = nodes[link.to] = [];
		}
		for (f in nfrom)
			for (t in nto)
				if (f == t)
					throw "A link with same nodes as this " + link + " is already present in this network: " + f;
		nto.push(link);
		nfrom.push(link);
	}
}
