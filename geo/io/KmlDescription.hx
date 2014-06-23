package geo.io;

abstract KmlDescription(String) from String
{
	inline public function new(descr)
	{
		this = descr;
	}

	@:from public static function fromTable(data:Array<{ key:String, value:String }>):KmlDescription
	{
		var buf = new StringBuf();
		buf.add("<table>");
		for (d in data)
		{
			buf.add('<tr><td>');
			buf.add( StringTools.htmlEscape(d.key) );
			buf.add('</td><td>');
			buf.add( StringTools.htmlEscape(d.value) );
			buf.add('</td></tr>');
		}
		buf.add('</table>');
		return StringTools.htmlEscape(buf.toString()); //that's right - escape twice
	}
}
