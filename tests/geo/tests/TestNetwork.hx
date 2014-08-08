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

		var outgoing = link1.outgoing();
		Assert.equals(1,outgoing.length);
		Assert.equals(link2,outgoing[0]);

		var incoming = link2.incoming();
		Assert.equals( 1, incoming.length );
		Assert.equals( link1, incoming[0] );

		var link1Repl = new Link(
			new Location(0, 0.00000004),
			new Location(0.000000001, 0.9999999999999),
			Path.fromArray([ for (i in 0...21) new Location(0, i / 20) ]));
		raises(function() net.addLink(link1Repl,false), NetworkError);
		net.addLink(link1Repl, true);
		raises(function() link1.network, NetworkError);
		raises(function() link1.outgoing());

		link1 = link1Repl;
		outgoing = link1.outgoing();
		Assert.equals(1,outgoing.length);
		Assert.equals(link2,outgoing[0]);

		incoming = link2.incoming();
		Assert.equals( 1, incoming.length );
		Assert.equals( link1,incoming[0] );

		var link3 = new Link(
			new Location(0,1),
			new Location(1,0));
		net.addLink(link3,false);

		outgoing = link1.outgoing();
		Assert.equals(2,outgoing.length);
		Assert.isTrue(link2 == outgoing[0] || link2 == outgoing[1]);
		Assert.isTrue(link3 == outgoing[0] || link3 == outgoing[1]);

		incoming = link2.incoming();
		Assert.equals( 1, incoming.length );
		Assert.equals( link1, incoming[0] );

		var links = Lambda.array(net);
		Assert.equals(links.length,3);
		Assert.isTrue(links.indexOf(link1) >= 0);
		Assert.isTrue(links.indexOf(link2) >= 0);
		Assert.isTrue(links.indexOf(link3) >= 0);
	}

	static function raises(method:Void -> Void, ?type:Dynamic, ?msgNotThrown : String , ?msgWrongType : String, ?pos : haxe.PosInfos)
	{
		try {
			method();
			if (null == msgNotThrown)
				msgNotThrown = "exception not raised";
			Assert.fail(msgNotThrown, pos);
		} catch (ex : Dynamic) {
			if (type != null)
			{
				if (null == msgWrongType)
					msgWrongType = "unexpected type for exception: "  + ex;
				Assert.isTrue(Std.is(ex,type),msgWrongType,pos);
			}
		}
	}

}
