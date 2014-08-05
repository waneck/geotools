package geo.tests;
import utest.Assert;
import haxe.ds.Vector;
import geo.network.*;
import geo.*;

class TestNetwork
{

	public function new()
	{
	}

	public function test()
	{
		networkTest(new Network());
	}

	private function networkTest(n:Network)
	{
		var link1 = new Link( new Location(0,0), new Location(0,1) );
		//make sure link's geometry contains at least the from and to points
		Assert.isTrue(link1.from.eq(link1.geom[0]));
		Assert.isTrue(link1.to.eq(link1.geom[1]));
	}

	public function testLink()
	{
	}

}
