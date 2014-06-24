package geo.io._internal;
using StringTools;

extern private class S {
	public static inline var IGNORE_SPACES 	= 0;
	public static inline var BEGIN			= 1;
	public static inline var BEGIN_NODE		= 2;
	public static inline var TAG_NAME		= 3;
	public static inline var BODY			= 4;
	public static inline var ATTRIB_NAME	= 5;
	public static inline var EQUALS			= 6;
	public static inline var ATTVAL_BEGIN	= 7;
	public static inline var ATTRIB_VAL		= 8;
	public static inline var CHILDS			= 9;
	public static inline var CLOSE			= 10;
	public static inline var WAIT_END		= 11;
	public static inline var WAIT_END_RET	= 12;
	public static inline var PCDATA			= 13;
	public static inline var HEADER			= 14;
	public static inline var COMMENT		= 15;
	public static inline var DOCTYPE		= 16;
	public static inline var CDATA			= 17;
	public static inline var ESCAPE			= 18;
}

class XmlParser
{
	static var escapes = {
		var h = new haxe.ds.StringMap();
		h.set("lt", "<");
		h.set("gt", ">");
		h.set("amp", "&");
		h.set("quot", '"');
		h.set("apos", "'");
		h.set("nbsp", String.fromCharCode(160));
		h;
	}

	static public function parse(str:String, delegate)
	{
		doParse(str, 0, "", delegate);
	}

	static function doParse(str:String, p:Int = 0, parent:String, delegate:AbstractXmlDelegate):Int
	{
		var xmlName:String = null;
		var curDelegate = delegate;
		var state = S.BEGIN;
		var next = S.BEGIN;
		var aname = null;
		var start = 0;
		var nsubs = 0;
		var nbrackets = 0;
		var c = str.fastCodeAt(p);
		var buf = new StringBuf();
		while (!StringTools.isEof(c))
		{
			switch(state)
			{
				case S.IGNORE_SPACES:
					switch(c)
					{
						case
							'\n'.code,
							'\r'.code,
							'\t'.code,
							' '.code:
						default:
							state = next;
							continue;
					}
				case S.BEGIN:
					switch(c)
					{
						case '<'.code:
							state = S.IGNORE_SPACES;
							next = S.BEGIN_NODE;
						default:
							start = p;
							state = S.PCDATA;
							continue;
					}
				case S.PCDATA:
					if (c == '<'.code)
					{
						if (delegate != null)
							delegate.onPCData(parent, buf.toString() + str.substr(start, p - start) );
						buf = new StringBuf();
						nsubs++;
						state = S.IGNORE_SPACES;
						next = S.BEGIN_NODE;
					}
					#if !flash9
					else if (c == '&'.code) {
						buf.addSub(str, start, p - start);
						state = S.ESCAPE;
						next = S.PCDATA;
						start = p + 1;
					}
					#end
				case S.CDATA:
					if (c == ']'.code && str.fastCodeAt(p + 1) == ']'.code && str.fastCodeAt(p + 2) == '>'.code)
					{
						if (delegate != null)
							delegate.onCData(parent, str, start, p);
						nsubs++;
						p += 2;
						state = S.BEGIN;
					}
				case S.BEGIN_NODE:
					switch(c)
					{
						case '!'.code:
							if (str.fastCodeAt(p + 1) == '['.code)
							{
								p += 2;
								if (str.substr(p, 6).toUpperCase() != "CDATA[")
									throw("Expected <![CDATA[");
								p += 5;
								state = S.CDATA;
								start = p + 1;
							}
							else if (str.fastCodeAt(p + 1) == 'D'.code || str.fastCodeAt(p + 1) == 'd'.code)
							{
								if(str.substr(p + 2, 6).toUpperCase() != "OCTYPE")
									throw("Expected <!DOCTYPE");
								p += 8;
								state = S.DOCTYPE;
								start = p + 1;
							}
							else if( str.fastCodeAt(p + 1) != '-'.code || str.fastCodeAt(p + 2) != '-'.code )
								throw("Expected <!--");
							else
							{
								p += 2;
								state = S.COMMENT;
								start = p + 1;
							}
						case '?'.code:
							state = S.HEADER;
							start = p;
						case '/'.code:
							if( parent == null )
								throw("Expected node name");
							start = p + 1;
							state = S.IGNORE_SPACES;
							next = S.CLOSE;
						default:
							state = S.TAG_NAME;
							start = p;
							continue;
					}
				case S.TAG_NAME:
					if (!isValidChar(c))
					{
						if( p == start )
							throw("Expected node name");
						var name = str.substr(start, p-start);
						xmlName = name;
						if (delegate != null)
							curDelegate = delegate.beginProcessChild(parent, name);
						state = S.IGNORE_SPACES;
						next = S.BODY;
						continue;
					}
				case S.BODY:
					switch(c)
					{
						case '/'.code:
							state = S.WAIT_END;
							nsubs++;
						case '>'.code:
							state = S.CHILDS;
							nsubs++;
						default:
							state = S.ATTRIB_NAME;
							start = p;
							continue;
					}
				case S.ATTRIB_NAME:
					if (!isValidChar(c))
					{
						var tmp;
						if( start == p )
							throw("Expected attribute name");
						tmp = str.substr(start,p-start);
						aname = tmp;
						state = S.IGNORE_SPACES;
						next = S.EQUALS;
						continue;
					}
				case S.EQUALS:
					switch(c)
					{
						case '='.code:
							state = S.IGNORE_SPACES;
							next = S.ATTVAL_BEGIN;
						default:
							throw("Expected =");
					}
				case S.ATTVAL_BEGIN:
					switch(c)
					{
						case '"'.code, '\''.code:
							state = S.ATTRIB_VAL;
							start = p;
						default:
							throw("Expected \"");
					}
				case S.ATTRIB_VAL:
					if (c == str.fastCodeAt(start))
					{
						if (curDelegate != null)
							curDelegate.onAttribute(xmlName, aname, str.substr(start+1,p-start-1));
						state = S.IGNORE_SPACES;
						next = S.BODY;
					}
				case S.CHILDS:
					p = doParse(str, p, xmlName, curDelegate);
					if (curDelegate != null)
						curDelegate.endProcessNode(parent, xmlName);
					start = p;
					state = S.BEGIN;
				case S.WAIT_END:
					switch(c)
					{
						case '>'.code:
							state = S.BEGIN;
						default :
							throw("Expected >");
					}
				case S.WAIT_END_RET:
					switch(c)
					{
						case '>'.code:
							return p;
						default :
							throw("Expected >");
					}
				case S.CLOSE:
					if (!isValidChar(c))
					{
						if( start == p )
							throw("Expected node name");

						var v = str.substr(start,p - start);
						if (v != parent)
							throw "Expected </" +parent+ ">";

						state = S.IGNORE_SPACES;
						next = S.WAIT_END_RET;
						continue;
					}
				case S.COMMENT:
					if (c == '-'.code && str.fastCodeAt(p +1) == '-'.code && str.fastCodeAt(p + 2) == '>'.code)
					{
						if (delegate != null)
							delegate.onComment(str, start, p);
						p += 2;
						state = S.BEGIN;
					}
				case S.DOCTYPE:
					if(c == '['.code)
						nbrackets++;
					else if(c == ']'.code)
						nbrackets--;
					else if (c == '>'.code && nbrackets == 0)
					{
						if (delegate != null)
							delegate.onDocType(str, start, p);
						state = S.BEGIN;
					}
				case S.HEADER:
					if (c == '?'.code && str.fastCodeAt(p + 1) == '>'.code)
					{
						p++;
						var str = str.substr(start + 1, p - start - 2);
						if (delegate != null)
							delegate.onProcessingInstruction(str);
						state = S.BEGIN;
					}
				case S.ESCAPE:
					if (c == ';'.code)
					{
						var s = str.substr(start, p - start);
						if (s.fastCodeAt(0) == '#'.code) {
							var i = s.fastCodeAt(1) == 'x'.code
								? Std.parseInt("0" +s.substr(1, s.length - 1))
								: Std.parseInt(s.substr(1, s.length - 1));
							buf.add(String.fromCharCode(i));
						} else if (!escapes.exists(s))
							buf.add('&$s;');
						else
							buf.add(escapes.get(s));
						start = p + 1;
						state = next;
					}
			}
			c = str.fastCodeAt(++p);
		}

		if (state == S.BEGIN)
		{
			start = p;
			state = S.PCDATA;
		}

		if (state == S.PCDATA)
		{
			if (p != start || nsubs == 0)
				if (delegate != null)
					delegate.onPCData(parent, buf.toString() + str.substr(start, p - start));
			return p;
		}

		throw "Unexpected end";
	}

	static inline function isValidChar(c) {
		return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || (c >= '0'.code && c <= '9'.code) || c == ':'.code || c == '.'.code || c == '_'.code || c == '-'.code;
	}
}

class AbstractXmlDelegate
{
	public function beginProcessChild(parentName:String, name:String):Null<AbstractXmlDelegate> // if null, do not process
	{
		// trace('beginProcessChild',parentName,name);
		return null;
	}

	public function endProcessNode(parentName:String, name:String):Void
	{
		// trace('endProcessNode',parentName,name);
	}

	public function onAttribute(name:String, attributeName:String, attributeValue:String):Void
	{
		// trace('onAttribute',name,attributeName,attributeValue);
	}

	public function onPCData(parentName:String, data:String):Void
	{
		// trace('onPCData',data);
	}

	public function onCData(parentName:String, data:String, start:Int, end:Int):Void
	{
		// trace('onCData',parentName,data.substring(start,end));
	}

	public function onComment(data:String, start:Int, end:Int):Void
	{
		// trace('onComment',data.substring(start,end));
	}

	public function onDocType(data:String, start:Int, end:Int):Void
	{
		// trace('onDocType',data.substring(start,end));
	}

	public function onProcessingInstruction(str:String):Void
	{
		// trace('onProcessingInstruction',str);
	}
}
