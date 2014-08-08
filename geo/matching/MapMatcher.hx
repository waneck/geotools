package geo.matching;
import geo.network.*;
import geo.*;
import geo.units.*;

@:forward @:dce abstract MapMatcher(IMapMatcher) from IMapMatcher to IMapMatcher
{

}

interface IMapMatcher
{
	function match<Loc:Location>(network:Network, path:Path<Loc>):Array<Link>;
}

class DefaultMapMatcher
{

	private var pathDeviation:Float;
	private var distanceDeviation:Float;
	private var boxDistance:Meters;

	public function new(pathDeviation=10.0, distanceDeviation=20.0, boxDistance:Meters=30.0)
	{
		this.pathDeviation = pathDeviation;
		this.distanceDeviation = distanceDeviation;
		this.boxDistance = boxDistance;
	}

	public function match<Loc:Location>(network:Network, path:Path<Loc>):Array<Link>
	{
		var pathinfo = [ for (p in path)
	}
}

private class NetworkRelation
{
	public var link:Link;
	public var interpolation:Float;
	public var loc:Location;
	public var tangentVector:Location;

	public function new(link:Link,inflectionPos:Int,interpolation:Float)
	{
		var geom = link.geom;
		var d:Meters = 0.0;
		for (i in 0...inflectionPos)
		{
			d += geom[i].dist(geom[i+1]);
		}

		if (interpolation != 0)
		{
			this.loc = Location.lerp(geom[inflectionPos],geom[inflectionPos+1], interpolation);
		} else {
			this.loc = geom[inflectionPos];
		}
		if (inflectionPos > 0)
		{
			tangentVector = new GeoPoint(geom[inflectionPos].lon - geom[inflectionPos - 1].lon, geom[inflectionPos].lat - geom[inflectionPos - 1].lat);
		} else {
			tangentVector = new GeoPoint(geom[inflectionPos+1].lon - geom[inflectionPos].lon, geom[inflectionPos+1].lat - geom[inflectionPos].lat);
		}
		if (link.dir == -1)
			tangentVector = new GeoPoint( -tangentVector.lon, -tangentVector.lat);
		interpolation = d / link.lenghtInKM();
	}
}
