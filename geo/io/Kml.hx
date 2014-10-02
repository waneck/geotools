package geo.io;
import geo.*;
import geo.units.*;

abstract Kml(KmlState)
{
	public function new(name:String="", ?description)
	{
		this = new KmlState(name,description);
	}

	public function hideChildren(flag:Bool):Kml
	{
		this.hideChildren = flag;
		return t();
	}

	public function enableTimestamps(flag:Bool):Kml
	{
		this.enableTimestamps = flag;
		return t();
	}

	public function lineStyle(?thickness:Float, ?color:Color):Kml
	{
		if (thickness != null && thickness != this.lineThick)
		{
			this.lineStyle = null;
			this.lineThick = thickness;
		}
		if (color != null && color != this.lineColor)
		{
			this.lineStyle = null;
			this.lineColor = color;
		}
		return t();
	}

	public function labelStyle(?scale:Float,?color:Color):Kml
	{
		if (scale != null && scale != this.labelScale)
		{
			this.labelScale = scale;
			this.pointStyle = null;
		}
		if (color != null && color != this.labelColor)
		{
			this.labelColor = color;
			this.pointStyle = null;
		}
		return t();
	}

	public function pointIcon(?icon:KmlIcon, ?scale:Float, ?color:Color):Kml
	{
		if (icon != null && icon != this.icon)
		{
			this.icon = icon;
			this.pointStyle = null;
		}

		if (scale != null && scale != this.iconScale)
		{
			this.iconScale = scale;
			this.pointStyle = null;
		}

		if (color != null && color != this.iconColor)
		{
			this.iconColor = color;
			this.pointStyle = null;
		}

		return t();
	}

	@:op(A+B) inline public function opPoint<T:Location>(pt:T):Kml
	{
		return point(this.nextLabel,this.nextDescription,pt);
	}

	@:op(A+B) inline public function opPathTime<T:LocationTime>(path:PathTime<T>):Kml
	{
		return pathTime(this.nextLabel, this.nextDescription, path);
	}

	@:op(A+B) inline public function opPath<T:Location>(p:Path<T>):Kml
	{
		return path(this.nextLabel, this.nextDescription, p);
	}

	@:op(A+B) public function folder(child:Kml):Kml
	{
		var buf = new StringBuf();
		buf.add('<Folder>');
		var cthis:KmlState = cast child;
		if (cthis.hideChildren)
		{
			buf.add('<Style><ListStyle><listItemType>checkHideChildren</listItemType></ListStyle></Style>');
		}
		if (cthis.name != null)
		{
			buf.add('<name>${cthis.name}</name>');
		}
		if (cthis.description != null)
		{
			buf.add('<description>${cthis.description}</description>');
		}
		this.data.push({ style:null, tag:null, contents:buf });

		for (data in cthis.data)
		{
			this.data.push(data);
		}

		buf = new StringBuf();
		buf.add("</Folder>");
		this.data.push({ style:null, tag:null, contents:buf });

		return t();
	}

	public function next(label:String, ?description:KmlDescription):Kml
	{
		this.nextLabel = label;
		if (description != null)
			this.nextDescription = description;
		return t();
	}

	public function point<T:Location>(label:String, ?description:KmlDescription, point:T):Kml
	{
		var buf = new StringBuf();
		buf.add('<Point><coordinates>${point.lon},${point.lat},0</coordinates></Point>');
		if (label != null)
		{
			buf.add('<name>${label}</name>');
		}
		if (description != null)
		{
			buf.add('<description>${description}</description>');
		}
		this.data.push({ style: this.getPointStyle(), tag:'Placemark', contents:buf});

		this.nextLabel = null;
		this.nextDescription = null;
		return t();
	}

	public function pointTime(label:String, ?description:KmlDescription, point:LocationTime):Kml
	{
		var buf = new StringBuf();
		buf.add('<TimeStamp><when>${point.time}</when></TimeStamp>');
		buf.add('<Point><coordinates>${point.lon},${point.lat},0</coordinates></Point>');
		if (label != null)
		{
			buf.add('<name>${label}</name>');
		}
		if (description != null)
		{
			buf.add('<description>${description}</description>');
		}
		this.data.push({ style: this.getPointStyle(), tag:'Placemark', contents:buf});

		this.nextLabel = null;
		this.nextDescription = null;
		return t();
	}

	public function path<T:Location>(label:String, ?description:KmlDescription, ?timestamp:UnixDate, path:Path<T>):Kml
	{
		var buf = new StringBuf();
		if (label != null)
		{
			buf.add('<name>${label}</name>');
		}
		if (description != null)
		{
			buf.add('<description>$description</description>');
		}
		if (timestamp.getTime() > 0)
		{
			buf.add('<TimeStamp><when>${timestamp}</when></TimeStamp>');
		}
		buf.add('<LineString><coordinates>');
		path.iter(function(loc) {
			buf.add(loc.lon);
			buf.add(',');
			buf.add(loc.lat);
			buf.add(',0 ');
		});
		buf.add('</coordinates></LineString>');
		this.data.push({ style: this.getLineStyle(), tag:'Placemark', contents:buf});

		this.nextLabel = null;
		this.nextDescription = null;
		return t();
	}

	public function pathTime<T:LocationTime>(label:String, ?description:KmlDescription, path:PathTime<T>):Kml
	{
		var buf = new StringBuf();
		buf.add('<Folder>');
		buf.add('<Style><ListStyle><listItemType>checkHideChildren</listItemType></ListStyle></Style>');
		if (label != null)
		{
			buf.add('<name>${label}</name>');
		}
		if (description != null)
		{
			buf.add('<description>$description</description>');
		}

		this.data.push({ style:null, tag:null, contents:buf });
		path.iter(function(t) {
			pointTime(null,null,t);
		});

		buf = new StringBuf();
		buf.add("</Folder>");
		this.data.push({ style:null, tag:null, contents:buf });

		this.nextLabel = null;
		this.nextDescription = null;
		return t();
	}

	public function fold<T>(it:Iterable<T>, fn:Kml->T->Kml):Kml
	{
		if (it == null)
			return t();

		var t = t();
		for (a in it)
		{
			t = fn(t,a);
		}
		return t;
	}

	inline private function t():Kml
	{
		return cast this;
	}

	public function consolidate(out:haxe.io.Output):Void
	{
		var ids = 0;
		var styles = new Map(),
				lastStyle:String = null,
				lastStyleName:String = null;
		// var allStyles = [];
		var data = this.data.copy();
		for (d in data)
		{
			if (d.style != null)
			{
				if (d.style == lastStyle)
				{
					d.style = lastStyleName;
				} else {
					lastStyle = d.style;
					lastStyleName = styles[lastStyle];
					if (lastStyleName == null)
					{
						lastStyleName = "style_" + ids++;
						styles[lastStyle] = lastStyleName;
						// allstyles.push(lastStyle);
					}
					d.style = lastStyleName;
				}
			}
		}
		out.writeString('<?xml version="1.0" encoding="UTF-8"?>\n<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">\n<Document>\n');
		// for (s in allstyles)
		for (k in styles.keys())
		{
			out.writeString('<Style id="${styles[k]}">\n\t');
			out.writeString(k);
			out.writeString('</Style>\n');
		}

		if (this.name != null)
		{
			out.writeString('<name>${this.name}</name>');
		}
		if (this.description != null)
		{
			out.writeString('<description>${this.description}</description>');
		}

		for (d in data)
		{
			if (d.tag != null)
			{
				out.writeString('\n<${d.tag}>\n');
				if (d.style != null)
					out.writeString('<styleUrl>#${d.style}</styleUrl>');
				out.writeString(d.contents.toString());
				out.writeString('\n</${d.tag}>\n');
			} else {
				out.writeString(d.contents.toString());
			}
		}
		out.writeString("</Document></kml>");
	}

	public function toString():String
	{
		var out = new haxe.io.BytesOutput();
		consolidate(out);
		return out.getBytes().toString();
	}

#if sys
	@:extern inline public function save(filename:String):Void
	{
		var w =sys.io.File.write(filename);
		consolidate( w );
		w.close();
	}
#end
}

@:publicFields private class KmlState
{
	var name:String;
	var description:KmlDescription;

	var hideChildren:Bool = false;
	var enableTimestamps = true;

	var lineThick = 1.0;
	var lineColor = Color.White;

	var labelScale = 1.0;
	var labelColor = Color.White;

	var icon = KmlIcon.Wht;
	var iconScale = 1.0;
	var iconColor = Color.White;

	var data:Array<KmlData>;

	var nextLabel:String;
	var nextDescription:KmlDescription;

	var styles:Map<String,String>;
	var lineStyle:Null<String>;
	var pointStyle:Null<String>;

	function new(name,description)
	{
		this.name = name;
		this.description = description;
		styles = new Map();
		data = [];
	}

	function getLineStyle()
	{
		if (lineStyle != null)
			return lineStyle;
		var ret = lineStyle = '<LineStyle><color>${lineColor.toABGR()}</color><width>$lineThick</width></LineStyle>';
		return ret;
	}

	function getPointStyle()
	{
		if (pointStyle != null)
			return pointStyle;
		var buf = new StringBuf();
		buf.add('<IconStyle>');
		buf.add('<scale>${iconScale}</scale><color>${iconColor.toABGR()}</color>');
		if (icon != null)
			buf.add('<Icon><href>${icon}</href></Icon>');
		buf.add('</IconStyle>');
		buf.add('<LabelStyle><scale>${labelScale}</scale><color>${labelColor.toABGR()}</color></LabelStyle>');
		return pointStyle = buf.toString();
	}
}

typedef KmlData = { style:Null<String>, tag:Null<String>, contents:StringBuf };
