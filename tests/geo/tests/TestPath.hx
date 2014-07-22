package geo.tests;
import utest.Assert;
import geo.Units;
import geo.*;

class TestPath
{

	public function new()
	{
	}

	public function test_path()
	{
		var vec = new haxe.ds.Vector(50);
		for (i in 0...50)
		{
			vec[i] = new Location(i,i);
		}
		var p = new PathWay(new Path(vec));
		Assert.same(new Location(0,0), p[0]);
		Assert.same(new Location(1,1), p[1]);
		Assert.same(new Location(49,49), p[49]);

		p = p.constrain(10);
		Assert.same(new Location(10,10),p[0]);
		Assert.same(new Location(11,11),p[1]);
		Assert.same(new Location(49,49),p[39]);
		Assert.same(new Location(9,9),p[-1]); //no bounds check
		var i = 0;
		p.iter(function(l) {
			Assert.same(new Location(10+i, 10+i), l);
			i++;
		});
		Assert.equals(40,i);
		i = 0;
		for (l in p)
		{
			Assert.same(new Location(10+i, 10+i), l);
			i++;
		}
		Assert.equals(40,i);

		p = p.constrain(10,10);
		Assert.same(new Location(20,20),p[0]);
		Assert.same(new Location(21,21),p[1]);
		// no bounds check here
		Assert.same(new Location(49,49),p[29]);
		Assert.same(new Location(19,19),p[-1]); //no bounds check
		i = 0;
		p.iter(function(l) {
			Assert.same(new Location(20+i, 20+i), l);
			i++;
		});
		Assert.equals(10,i);

		p = p.expand();
		Assert.same(new Location(0,0), p[0]);
		Assert.same(new Location(1,1), p[1]);
		Assert.same(new Location(49,49), p[49]);
		p = p.constrain(20,10);

		i = 0;
		for (l in p)
		{
			Assert.same(new Location(20+i, 20+i), l);
			i++;
		}
		Assert.equals(10,i);

		p = p.filter(function(loc) return loc.lat % 2 == 0);
		i = 0;
		p.iter(function(l) {
			Assert.same(new Location(20+i,20+i),l);
			i += 2;
		});
		Assert.equals(10,i);

		p = p.map(function(loc) return new Location(loc.lat * 10, loc.lon * 10));
		i = 0;
		p.iter(function(l) {
			Assert.same(new Location((20+i) * 10,(20+i) * 10),l);
			i += 2;
		});
		Assert.equals(10,i);

		p = p.expand();
		i = 0;
		p.iter(function(l) {
			Assert.same(new Location((20+i) * 10,(20+i) * 10),l);
			i += 2;
		});
		Assert.equals(10,i);
	}

	public function test_path_time()
	{
		var vec = new haxe.ds.Vector(50);
		for (i in 0...50)
		{
			vec[i] = new LocationTime(i * 1.0,i * 1.0, new UnixDate(new Hours(i)));
		}
		var p = new PathTime(new Path(vec));

		Assert.same(new LocationTime(0.0,0.0,new UnixDate(0.0)), p[0]);
		Assert.same(new LocationTime(1.0,1.0,new UnixDate(60.0 * 60)), p[1]);
		Assert.same(new LocationTime(49.0,49.0, new UnixDate(49.0 * 60 * 60)), p[49]);
		//time index
		Assert.equals(9, p.timeIndex(new UnixDate(new Hours(9))));
		Assert.equals(9, p.timeIndex(new UnixDate(new Hours(9.4))));
		Assert.equals(10, p.timeIndex(new UnixDate(new Hours(9.6))));
		Assert.equals(11, p.timeIndex(new UnixDate(new Hours(10.6))));
		Assert.equals(49, p.timeIndex(new UnixDate(new Hours(50.6))));
		Assert.equals(0, p.timeIndex(new UnixDate(new Hours(-1))));
		//date index
		Assert.equals(p[9], p[new UnixDate(new Hours(9))]);
		Assert.equals(p[9], p[new UnixDate(new Hours(9.4))]);
		Assert.equals(p[10], p[new UnixDate(new Hours(9.6))]);
		Assert.equals(p[11], p[new UnixDate(new Hours(10.6))]);
		Assert.equals(p[49], p[new UnixDate(new Hours(50.6))]);
		Assert.equals(p[0], p[new UnixDate(new Hours(-1))]);
		//date index precise
		Assert.equals(p[9], p.byTimeRelative(new UnixDate(new Hours(9))));
		Assert.same(new LocationTime(9.4,9.4, new UnixDate(new Hours(9.4))), p.byTimeRelative(new UnixDate(new Hours(9.4))));
		Assert.same(new LocationTime(9.6,9.6,new UnixDate( new Hours(9.6) )), p.byTimeRelative(new UnixDate(new Hours(9.6))));
		Assert.same(new LocationTime(10.6,10.6,new UnixDate( new Hours(10.6) )), p.byTimeRelative(new UnixDate(new Hours(10.6))));
		Assert.equals(p[49], p.byTimeRelative(new UnixDate(new Hours(50.6))));
		Assert.equals(p[0], p.byTimeRelative(new UnixDate(new Hours(-1))));

		p = p.constrain(10);
		Assert.same(new LocationTime(10.0,10.0, new UnixDate(new Hours(10))),p[0]);
		Assert.same(new LocationTime(11.0,11.0, new UnixDate(new Hours(11))),p[1]);
		Assert.same(new LocationTime(49.0,49.0, new UnixDate(new Hours(49))),p[39]);
		Assert.same(new LocationTime(9.0,9.0, new UnixDate(new Hours(9))),p[-1]); //no bounds check
		//time index
		Assert.equals(0, p.timeIndex(new UnixDate(new Hours(9))));
		Assert.equals(0, p.timeIndex(new UnixDate(new Hours(9.4))));
		Assert.equals(0, p.timeIndex(new UnixDate(new Hours(9.6))));
		Assert.equals(0, p.timeIndex(new UnixDate(new Hours(10.0))));
		Assert.equals(1, p.timeIndex(new UnixDate(new Hours(10.6))));
		Assert.equals(39, p.timeIndex(new UnixDate(new Hours(50.6))));
		Assert.equals(0, p.timeIndex(new UnixDate(new Hours(-1))));
		//date index precise
		Assert.same(p[-1], p.byTimeRelative(new UnixDate(new Hours(9))));
		Assert.same(new LocationTime(9.4,9.4, new UnixDate(new Hours(9.4))), p.byTimeRelative(new UnixDate(new Hours(9.4))));
		Assert.same(new LocationTime(9.6,9.6,new UnixDate( new Hours(9.6) )), p.byTimeRelative(new UnixDate(new Hours(9.6))));
		Assert.same(new LocationTime(10.6,10.6,new UnixDate( new Hours(10.6) )), p.byTimeRelative(new UnixDate(new Hours(10.6))));
		Assert.equals(p[39], p.byTimeRelative(new UnixDate(new Hours(50.6))));
		Assert.same(new LocationTime(48.6,48.6, new UnixDate( new Hours(48.6) )), p.byTimeRelative(new UnixDate(new Hours(48.6))));
		Assert.equals(p[-10], p.byTimeRelative(new UnixDate(new Hours(-1))));
		Assert.equals(p[-1], p.byTimeRelative(new UnixDate(new Hours(9))));

		Assert.equals(p[0], p.byTimeRelative(new UnixDate(new Hours(9.4)),false));
		Assert.equals(p[0], p.byTimeRelative(new UnixDate(new Hours(9.6)),false));
		Assert.same(new LocationTime(10.6,10.6,new UnixDate( new Hours(10.6) )), p.byTimeRelative(new UnixDate(new Hours(10.6)),false));
		Assert.equals(p[0], p.byTimeRelative(new UnixDate(new Hours(-1)),false));
		Assert.equals(p[39], p.byTimeRelative(new UnixDate(new Hours(50.6))));
		Assert.same(new LocationTime(48.6,48.6, new UnixDate( new Hours(48.6) )), p.byTimeRelative(new UnixDate(new Hours(48.6))));

		p = p.constrain(0,10);
		Assert.equals(p[9], p.byTimeRelative(new UnixDate(new Hours(50.6)),false));
		Assert.equals(p[9], p.byTimeRelative(new UnixDate(new Hours(48.6)),false));
	}
}
