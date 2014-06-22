package geo.input;
import geo.input._internal.XmlParser;

class Gpx
{
	public static function stream(input:String, onData:LocationTime->Void, onEndPath:Void->Void, onError:Dynamic->Void):Void
	{
		var delegate = new Delegate(onData, onEndPath, onError);
		try
		{
			XmlParser.parse( input, delegate );
		}
		catch(e:Dynamic)
		{
			onError(e);
		}
	}

	public static function readAll(input:String):Array<Path<LocationTime>>
	{
		var ret = [],
				cur = null;
		stream(input,
		function(loc) {
			if (cur == null)
			{
				cur = [];
				ret.push(cur);
			}
			cur.push(loc);
		},
		function() {
			cur = null;
		},
		function(err:Dynamic) {
			throw err;
		});

		return [ for (r in ret) Path.fromArray(r) ];
	}

}

private class Delegate extends AbstractXmlDelegate
{
	var onData:LocationTime->Void;
	var onEndPath:Void->Void;
	var onError:Dynamic->Void;

	var lat:Null<Float>;
	var lon:Null<Float>;
	var time:Null<TzDate>;

	public function new(onData, onEndPath, onError)
	{
		this.onData = onData;
		this.onEndPath = onEndPath;
		this.onError = onError;
	}

	override public function beginProcessChild(parentName:String, name:String):Null<AbstractXmlDelegate>
	{
		// trace('beginProcessChild',parentName,name);
		switch [parentName, name]
		{
			case [_, 'gpx'] | ['gpx', "trk"] | ["trk", "trkseg"] | ["trkseg", "trkpt"] | ["trkpt", _]:
				return this;
			case _:
				return null;
		}
	}

	override public function onAttribute(name:String, attributeName:String, attributeValue:String):Void
	{
		// trace('onAttribute',name,attributeName,attributeValue);
		if (name == "trkpt")
		{
			switch (attributeName)
			{
				case 'lat':
					if (this.lat != null)
						throw "Lat already present: " + this.lat + ' and ' + attributeValue;
					this.lat = Std.parseFloat(attributeValue);
				case 'lon':
					if (this.lon != null)
						throw "Lon already present: " + this.lon + ' and ' + attributeValue;
					this.lon = Std.parseFloat(attributeValue);
			}
		}
	}

	override public function onCData(parent:String, data:String, start:Int, end:Int):Void
	{
		// trace('onCData',parent,data.substring(start,end));
		if (parent == "time" && lat != null && lon != null)
		{
			if (this.time != null)
				throw "Duplicate time definition at " + lat + " , " + lon;
			this.time = TzDate.fromIso(data.substring(start,end));
		}
	}

	override public function onPCData(parent:String, data:String)
	{
		// trace('onPCData',data);
		if (parent == "time" && lat != null && lon != null)
		{
			if (this.time != null)
				throw "Duplicate time definition at " + lat + " , " + lon;
			this.time = TzDate.fromIso(data);
		}
	}

	override public function endProcessNode(parentName:String, name:String):Void
	{
		// trace('endProcessNode',parentName,name);
		if (parentName == "trkseg" && name == "trkpt")
		{
			if (lat == null || lon == null || time == null)
			{
				throw 'Incomplete node: lat == $lat, lon == $lon, time == $time';
			}
			onData(new LocationTime(lat,lon,time.date));
			this.lat = null;
			this.lon = null;
			this.time = null;
		} else if (parentName == "trk" && name == "trkseg") {
			onEndPath();
		}

	}

}
