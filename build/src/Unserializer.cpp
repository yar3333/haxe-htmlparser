#include "Unserializer.h"

/*
static char Unserializer::BASE64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";

static map<int, int> Unserializer::CODES;
for (int i=0;i<sizeof(Unserializer::BASE64);i++) Unserializer::CODES[Unserializer::BASE64[i]] = i;

Unserializer::Unserializer(string buf)
{
	this.buf = buf;
	length = buf.length;
	pos = 0;
	scache = new vector();
	cache = new vector();
}

int Unserializer::readDigits()
{
	int k = 0;
	bool s = false;
	int fpos = pos;
	while (true)
	{
		var c = get(pos);
		if (StringTools.isEof(c)) break;
		if (c == "-".code)
		{
			if( pos != fpos )
				break;
			s = true;
			pos++;
			continue;
		}
		if( c < "0".code || c > "9".code )
			break;
		k = k * 10 + (c - "0".code);
		pos++;
	}
	if( s )
		k *= -1;
	return k;
}

void Unserializer::unserializeObject(o)
{
	while (true)
	{
		if (pos >= length) throw "Invalid object";
		if (get(pos) == "g".code) break;
		var k = unserialize();
		if (!Std.is(k,string)) throw "Invalid object key";
		void *v = unserialize();
		Reflect.setField(o,k,v);
	}
	pos++;
}

ISerializable *Unserializer::unserialize()
{
	switch (get(pos++))
	{
		case "n".code:
			return null;
		case "t".code:
			return true;
		case "f".code:
			return false;
		case "z".code:
			return 0;
		case "i".code:
			return readDigits();
		case "d".code:
			var p1 = pos;
			while (true)
			{
				var c = get(pos);
				// + - . , 0-9
				if( (c >= 43 && c < 58) || c == "e".code || c == "E".code )
					pos++;
				else
					break;
			}
			return Std.parseFloat(buf.substr(p1,pos-p1));
		case "y".code:
			int len = readDigits();
			if (get(pos++) != ":".code || length - pos < len)
				throw "Invalid string length";
			var s = buf.substr(pos,len);
			pos += len;
			s = StringTools.urlDecode(s);
			scache.push_back(s);
			return s;
		case "k".code:
			return Math.NaN;
		case "m".code:
			return Math.NEGATIVE_INFINITY;
		case "p".code:
			return Math.POSITIVE_INFINITY;
		case "a".code:
			var buf = buf;
			var a = new vector<Dynamic>();
			cache.push_back(a);
			while (true)
			{
				var c = get(pos);
				if (c == "h".code)
				{
					pos++;
					break;
				}
				if (c == "u".code)
				{
					pos++;
					var n = readDigits();
					a[a.length+n-1] = null;
				}
				else
					a.push_back(unserialize());
			}
			return a;
		case "o".code:
			var o = {};
			cache.push_back(o);
			unserializeObject(o);
			return o;
		case "r".code:
			var n = readDigits();
			if( n < 0 || n >= cache.length )
				throw "Invalid reference";
			return cache[n];
		case "R".code:
			var n = readDigits();
			if( n < 0 || n >= scache.length )
				throw "Invalid string reference";
			return scache[n];
		case "x".code:
			throw unserialize();
		case "c".code:
			var name = unserialize();
			var cl = resolver.resolveClass(name);
			if( cl == null )
				throw "Class not found " + name;
			var o = Type.createEmptyInstance(cl);
			cache.push_back(o);
			unserializeObject(o);
			return o;
		case "l".code:
			var l = new List();
			cache.push_back(l);
			var buf = buf;
			while( get(pos) != "h".code )
				l.add(unserialize());
			pos++;
			return l;
		case "b".code:
			var h = new haxe.ds.StringMap();
			cache.push_back(h);
			var buf = buf;
			while( get(pos) != "h".code ) {
				var s = unserialize();
				h.set(s,unserialize());
			}
			pos++;
			return h;
		case "q".code:
			var h = new haxe.ds.IntMap();
			cache.push_back(h);
			var buf = buf;
			var c = get(pos++);
			while( c == ":".code ) {
				var i = readDigits();
				h.set(i,unserialize());
				c = get(pos++);
			}
			if( c != "h".code )
				throw "Invalid IntMap format";
			return h;
		case "M".code:
			var h = new haxe.ds.ObjectMap();
			cache.push_back(h);
			var buf = buf;
			while( get(pos) != "h".code ) {
				var s = unserialize();
				h.set(s,unserialize());
			}
			pos++;
			return h;
		case "v".code:
			var d = Date.fromString(buf.substr(pos,19));
			cache.push_back(d);
			pos += 19;
			return d;
		case "s".code:
			var len = readDigits();
			var buf = buf;
			if( get(pos++) != ":".code || length - pos < len )
				throw "Invalid bytes length";
			var codes = CODES;
			if( codes == null ) {
				codes = initCodes();
				CODES = codes;
			}
			var i = pos;
			var rest = len & 3;
			var size = (len >> 2) * 3 + ((rest >= 2) ? rest - 1 : 0);
			var max = i + (len - rest);
			var bytes = haxe.io.Bytes.alloc(size);
			var bpos = 0;
			while( i < max ) {
				var c1 = codes[StringTools.fastCodeAt(buf,i++)];
				var c2 = codes[StringTools.fastCodeAt(buf,i++)];
				bytes.set(bpos++,(c1 << 2) | (c2 >> 4));
				var c3 = codes[StringTools.fastCodeAt(buf,i++)];
				bytes.set(bpos++,(c2 << 4) | (c3 >> 2));
				var c4 = codes[StringTools.fastCodeAt(buf,i++)];
				bytes.set(bpos++,(c3 << 6) | c4);
			}
			if( rest >= 2 ) {
				var c1 = codes[StringTools.fastCodeAt(buf,i++)];
				var c2 = codes[StringTools.fastCodeAt(buf,i++)];
				bytes.set(bpos++,(c1 << 2) | (c2 >> 4));
				if( rest == 3 ) {
					var c3 = codes[StringTools.fastCodeAt(buf,i++)];
					bytes.set(bpos++,(c2 << 4) | (c3 >> 2));
				}
			}
			pos += len;
			cache.push_back(bytes);
			return bytes;
		case "C".code:
			var name = unserialize();
			var cl = resolver.resolveClass(name);
			if( cl == null )
				throw "Class not found " + name;
			var o : Dynamic = Type.createEmptyInstance(cl);
			cache.push_back(o);
			o.hxUnserialize(this);
			if( get(pos++) != "g".code )
				throw "Invalid custom data";
			return o;
		default:
	}
	pos--;
	throw "Invalid char "+buf.charAt(pos)+" at position "+pos;
}

public: static void *Unserializer::run(string v)
{
	return new Unserializer(v).unserialize();
}
*/