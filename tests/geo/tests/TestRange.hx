package geo.tests;

import geo.*;
import geo.Units;
import utest.Assert;

class TestRange
{
  public function new()
  {
  }

  public function test_range()
  {
    var pos = [for (i in 0...5) new Pos(2 - i, i - 2)];

    //all possible outcomes
    var indices = [
      [0,1,2,3,4],
      [4,3,2,1,0],
      [0,4,1,3,2],
      [3,0,1,2,4],
      [4,1,0,3,2]
    ];

    var inf = Range.infinity;
    for (idx in indices)
    {
      var r = Range.empty;
      for (i in idx)
      {
        Assert.isFalse( r.contains(pos[i]) );
        Assert.isTrue( inf.contains(pos[i]) );
      }
      for (i in 0...5)
      {
        r = r.constrain( pos[ idx[i] ] );
        inf = inf.constrain( pos[ idx[i] ] );
        for (j in 0...(i+1))
          Assert.isTrue( r.contains( pos[ idx[i] ] ) );
      }
    }
    Assert.equals(Range.infinity,inf);
  }

}
