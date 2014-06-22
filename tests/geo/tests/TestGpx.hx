package geo.tests;
import geo.*;
import geo.input.*;
import utest.Assert;

class TestGpx
{

	public function new()
	{
	}

	public function test_gpx_parser()
	{
		var gpx = Gpx.readAll(haxe.Resource.getString('gpx'));
		Assert.equals(3,gpx.length);
		Assert.equals(17,gpx[0].length);
		var g:PathTime<LocationTime> = gpx[0];
		Assert.same(new LocationTime(1.188282013,22.885936737,TzDate.fromIso('2014-03-25T07:50:29Z').date), g[0]);
		Assert.same(new LocationTime(1.188299179,22.886020660,TzDate.fromIso('2014-03-25T07:50:59Z').date), g[1]);
		Assert.same(new LocationTime(1.188093185,22.886108398,TzDate.fromIso('2014-03-25T07:51:04Z').date), g[2]);
		Assert.same(new LocationTime(1.186864853,22.886234283,TzDate.fromIso('2014-03-25T07:51:34Z').date), g[3]);
		Assert.same(new LocationTime(1.179378510,22.888370514,TzDate.fromIso('2014-03-25T07:55:19Z').date), g[16]);
		g = gpx[1];
		Assert.same(new LocationTime(1.179357529,22.886291504,TzDate.fromIso('2014-03-25T20:32:37Z').date), g[0]);
		Assert.same(new LocationTime(1.179412842,22.886253357,TzDate.fromIso('2014-03-25T20:32:42Z').date), g[1]);
		Assert.same(new LocationTime(1.179500580,22.886371613,TzDate.fromIso('2014-03-25T20:32:47Z').date), g[2]);
		Assert.same(new LocationTime(1.199392319,22.888992310,TzDate.fromIso('2014-03-25T22:44:43Z').date), g[g.length-1]);
		g = gpx[2];
		Assert.same(new LocationTime(1.179641724,22.888412476,TzDate.fromIso('2014-03-26T00:51:12Z').date), g[0]);
		Assert.same(new LocationTime(1.179813385,22.888710022,TzDate.fromIso('2014-03-26T00:51:17Z').date), g[1]);
		Assert.same(new LocationTime(1.179523468,22.888351440,TzDate.fromIso('2014-03-26T00:51:42Z').date), g[2]);
		Assert.same(new LocationTime(1.179492950,22.888248444,TzDate.fromIso('2014-03-26T02:54:35Z').date), g[g.length-1]);
	}

}
