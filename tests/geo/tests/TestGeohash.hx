package geo.tests;

import geo.*;
import geo.tools.Geohash.*;
import geo.tools.Geohash;
import geo.Units;
import utest.Assert;

class TestGeohash
{

  public function new()
  {
  }

  public function test_geohash()
  {
    var lon = 112.5584;
    var lat = 37.8324;

    var pos = new Loc(lat,lon);

    var hashstring = geohash(pos,9);
    Assert.equals(hashstring, 'ww8p1r4t8');

    var latlon = new Geohash('ww8p1r4t8').toRange().mid();
    Assert.isTrue(Math.abs(37.8324-latlon.lat) < 0.0001);
    Assert.isTrue(Math.abs(112.5584-latlon.lon) < 0.0001 );

    var north = new Geohash('dqcjq').neighbor(new Loc(1,0));
    Assert.equals(north, 'dqcjw');

    var southwest = new Geohash('DQCJQ').neighbor(new Loc(-1,-1));
    Assert.equals(southwest, 'dqcjj');

    var bboxes = Geohash.fromRange( new Range( 30, 30.0001, 120, 120.0001), 8);
    Assert.equals(bboxes[bboxes.length-1], geohash(new Loc(30.0001,120.0001), 8));
  }

}
