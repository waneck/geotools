package geo.input;
import geo.input.PathInput;

class Gpx implements PathInput<LocationTime>
{
	var input:haxe.io.Input;
	public function new(input)
	{
		this.input = input;
	}

	override public function readAll():Path<LocationTime>
	{
		var ret = [];
		var it = new Fast(Xml.parse(input.readAll().toString()).firstElement());
		// for (trk in it.node.trk.nodes.trkseg)
		for (trk in it.nodes.trk) for (trk in trk.nodes.trkseg)
		{
			// var r = [];
			// ret.push(r);
			for (x in trk.nodes.trkpt)
			{
				var lat = Std.parseFloat(x.att.lat);
				var lon = Std.parseFloat(x.att.lon);
				var time = x.node.time.innerData;
				var speed = if (x.hasNode.speed) Std.parseFloat(x.node.speed.innerData) else null;

				var s = StringTools.replace(time.substr(0, time.length - 1), "T", " ");
				var date = DateTools.delta(Date.fromString(s), timeZoneDelta);

				ret.push(loc(lat,lon,date.getTime()));
			}
		}

		return ret;

	}

}
