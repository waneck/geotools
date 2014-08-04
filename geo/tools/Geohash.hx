package geo.tools;
import geo.*;
using StringTools;

/**
	Simple geohash implementation. Ported from https://github.com/sunng87/node-geohash/blob/master/main.js

	Copyright (c) 2011, Sun Ning.
 **/
abstract Geohash(String) to String
{
	static var BASE32_CODES = "0123456789bcdefghjkmnpqrstuvwxyz";
	static var BASE32_DICT = [ for (i in 0...BASE32_CODES.length) BASE32_CODES.charCodeAt(i) => i ];

	@:extern inline public function new(s)
	{
		this = s;
	}

	public static function geohash(pos:Location, numberOfChars=9):Geohash
	{
		var chars = [], bits = 0,
				hash_value = 0;
		var lat = pos.lat, lon = pos.lon;

		var maxlat = 90., minlat = -90.;
		var maxlon = 180., minlon = -180.;

		var mid;
		var islon = true;
		while(chars.length < numberOfChars) {
			if (islon){
				mid = (maxlon+minlon)/2;
				if(lon > mid){
					hash_value = (hash_value << 1) + 1;
					minlon=mid;
				} else {
					hash_value = (hash_value << 1) + 0;
					maxlon=mid;
				}
			} else {
				mid = (maxlat+minlat)/2;
				if(lat > mid ){
					hash_value = (hash_value << 1) + 1;
					minlat = mid;
				} else {
					hash_value = (hash_value << 1) + 0;
					maxlat = mid;
				}
			}
			islon = !islon;

			bits++;
			if (bits == 5) {
				var code = BASE32_CODES.charAt(hash_value);
				chars.push(code);
				bits = 0;
				hash_value = 0;
			}
		}
		return new Geohash(chars.join(''));
	}

	@:extern inline public static function fromPos(pos:Location):Geohash
	{
		return geohash(pos);
	}

	@:to public function toRange():Range
	{
		var hash_string = this.toLowerCase();
		var islon = true;
		var maxlat = 90., minlat = -90.;
		var maxlon = 180., minlon = -180.;

		var hash_value = 0;
		for (i in 0...hash_string.length)
		{
			var code = hash_string.fastCodeAt(i);
			hash_value = BASE32_DICT[code];

			var bits = 5;
			while (--bits >= 0)
			{
				var bit = (hash_value >> bits) & 1;
				if (islon){
					var mid = (maxlon+minlon)/2;
					if(bit == 1){
						minlon = mid;
					} else {
						maxlon = mid;
					}
				} else {
					var mid = (maxlat+minlat)/2;
					if(bit == 1){
						minlat = mid;
					} else {
						maxlat = mid;
					}
				}
				islon = !islon;
			}
		}
		return new Range(minlat,maxlat, minlon,maxlon);
	}

	public function neighbor(direction:Location):Geohash
	{
		var range = toRange(),
				lonlat = range.mid();
		var nlat = lonlat.lat + (range.maxLat - lonlat.lat) * direction.lat * 2,
				nlon = lonlat.lon + (range.maxLon - lonlat.lon) * direction.lon * 2;
		return geohash( new Location(nlat,nlon), this.length );
	}

	@:extern inline public static function eachBoxIn(range:Range, numberOfChars=9, doFn:Geohash->Void):Void
	{
		var minLat = range.minLat,
				maxLat = range.maxLat,
				minLon = range.minLon,
				maxLon = range.maxLon;
		var hashSouthWest = geohash(new Location(minLat, minLon), numberOfChars);
		var hashNorthEast = geohash(new Location(maxLat, maxLon), numberOfChars);

		var range = hashSouthWest.toRange(),
				latlon = range.mid();

		var perLat = (range.maxLat - latlon.lat) * 2;
		var perLon = (range.maxLon - latlon.lon) * 2;

		var boxSouthWest = range;
		var boxNorthEast = hashNorthEast.toRange();

		var latStep = Math.round((boxNorthEast.minLat - boxSouthWest.minLat)/perLat);
		var lonStep = Math.round((boxNorthEast.minLon - boxSouthWest.minLon)/perLon);

		for (lat in 0...(latStep + 1))
			for (lon in 0...(lonStep + 1))
				doFn( hashSouthWest.neighbor(new Location(lat,lon)) );
	}

	public static function fromRange(range:Range, numberOfChars=9):Array<Geohash>
	{
		var ret =[];
		eachBoxIn(range,numberOfChars,function(gh) ret.push(gh));
		return ret;
	}

	@:extern inline public function toString():String
	{
		return this;
	}
}
