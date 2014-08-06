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

	private function networkTest(net:Network)
	{
		var link1 = new Link( new Location(0,0), new Location(0,1) );
		//make sure link's geometry contains at least the from and to points
		Assert.isTrue(link1.from.eq(link1.geom[0]));
		Assert.isTrue(link1.to.eq(link1.geom[1]));

		// No network was available yet
		raises(function() link1.network, NetworkError);
		net.addLink(link1,false);
		Assert.equals( net, link1.network );

		var link2 = new Link(
			new Location(0,1.000000001),
			new Location(0, 2),
			Path.fromArray([ for (i in 0...11) new Location(0, 1 + i / 10) ]));
		net.addLink(link2,false);

		var toLinks = link1.toLinks();
		Assert.equals(1,toLinks.length);
		Assert.equals(link2,toLinks[0]);

		var fromLinks = link2.fromLinks();
		Assert.equals( 1, fromLinks.length );
		Assert.equals( link1,fromLinks[0] );

		var link1Repl = new Link(
			new Location(0, 0.00000004),
			new Location(0.000000001, 0.9999999999999),
			Path.fromArray([ for (i in 0...21) new Location(0, i / 20) ]));
	}

	static function raises(method:Void -> Void, ?type:Dynamic, ?msgNotThrown : String , ?msgWrongType : String, ?pos : haxe.PosInfos)
	{
		if(type == null)
			type = String;
		try {
			method();
			if (null == msgNotThrown)
				msgNotThrown = "exception not raised";
			Assert.fail(msgNotThrown, pos);
		} catch (ex : Dynamic) {
			if (null == msgWrongType)
				msgWrongType = "unexpected type for exception: "  + ex;
			Assert.isTrue(Std.is(ex,type),msgWrongType,pos);
		}
	}

}
