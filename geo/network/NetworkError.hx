package geo.network;
import geo.*;

enum NetworkError
{
	/**
		The link is not in the specified network or it cannot be a part of the specified network
	**/
	LinkNotInNetwork(link:Link);
	/**
		The link defined by `from` and `to` was not found in network or it defines an invalid link
	**/
	InvalidLink(from:Location,to:Location,?geom:PathWay);
	/**
		The node defined by the location `node` was not found in network
	**/
	NodeNotFound(node:Location);
	/**
		There is already a link with the same `from` and `to` defined in the network
	**/
	LinkAlreadyExists(oldLink:Link,newLink:Link);
	Custom(msg:String);
}

