package geo.network;
import geo.*;

enum NetworkErrors
{
	LinkNotInNetwork(link:Link);
	LinkNotFound(from:Location,to:Location);
	NodeNotFound(node:Location);
}

