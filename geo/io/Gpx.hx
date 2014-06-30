package geo.io;
import geo.io._internal.XmlParser;

//TODO improve interface to abstract input and output for e.g. paths
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

	public static function readAll(input:String):Array<{ path:Path<LocationTime>, name:String }>
	{
		var ret = [],
				cur = null,
				delegate:Delegate = null;
		function onData(loc)
		{
			if (cur == null)
			{
				cur = [];
				ret.push({ name: delegate.name, path:cur });
			}
			cur.push(loc);
		}

		function onEndPath()
		{
			cur = null;
		}

		function onError(err:Dynamic)
		{
			throw err;
		}

		delegate = new Delegate(onData, onEndPath, onError);
		try
		{
			XmlParser.parse( input, delegate );
		}
		catch(e:Dynamic)
		{
			onError(e);
		}

		return [ for (r in ret) { name:r.name, path:Path.fromArray(r.path) } ];
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

	public var name(default,null):String;
	var parent:String;

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
			case [_, 'gpx'] | ['gpx', "trk"] | ["trk", "trkseg"] | ["trkseg", "trkpt"] | ["trkpt", _] | [_,"name"]:
				this.parent = parentName;
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
		} else if (parent == "name" && (this.parent == "trk" || this.parent == "trkseg")) {
			this.name = data.substring(start,end);
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
		} else if (parent == "name" && (this.parent == "trk" || this.parent == "trkseg")) {
			this.name = data;
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
