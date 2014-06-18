package geo;

class Range
{
  public static var infinity(default,never) = new Range(Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY);
  public static var empty(default,never) = new Range(Math.POSITIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, Math.NEGATIVE_INFINITY);

  public var minLat(default,null):Float;
  public var minLon(default,null):Float;
  public var maxLat(default,null):Float;
  public var maxLon(default,null):Float;

  public function new(minLat,maxLat,minLon,maxLon)
  {
    this.minLat = minLat;
    this.minLon = minLon;
    this.maxLat = maxLat;
    this.maxLon = maxLon;
  }

  /**
    Creates a new Range object with a new contraint
  **/
  public function constrain(pos:Location):Range
  {
    var changed = false;
    var minLat = minLat,
        minLon = minLon,
        maxLat = maxLat,
        maxLon = maxLon;
    if (pos.lat > maxLat)
    {
      maxLat = pos.lat;
      changed = true;
    }
    if (pos.lat < minLat)
    {
      minLat = pos.lat;
      changed = true;
    }

    if (pos.lon > maxLon)
    {
      maxLon = pos.lon;
      changed = true;
    }
    if (pos.lon < minLon)
    {
      minLon = pos.lon;
      changed = true;
    }

    if (changed)
      return new Range(minLat,maxLat,minLon,maxLon);
    else
      return this;
  }

  public function contains(pos:Location):Bool
  {
    var lat = pos.lat, lon = pos.lon;
    return lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon;
  }

  public function mid():Location
  {
    if (!Math.isFinite(minLat) && !Math.isFinite(minLon) && !Math.isFinite(maxLat) && !Math.isFinite(maxLon))
      return new Location(0,0);
    return new Location((minLat + maxLat) / 2, (minLon + maxLon) / 2);
  }

  public function toString()
  {
    return '{ Range = min ($minLat,$minLon) , max ($maxLat,$maxLon) }';
  }
}
