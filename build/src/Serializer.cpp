#include "Serializer.h"

/*
BOOL Serializer::USE_CACHE = false;
BOOL Serializer::USE_ENUM_INDEX = false;
char *Serializer::BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";

Serializer::Serializer()
{
	buf = new StringBuf();
	cache = new Array();
	useCache = USE_CACHE;
	useEnumIndex = USE_ENUM_INDEX;
	shash = new haxe.ds.StringMap();
	scount = 0;
}

void Serializer::toString()
{
	return buf.toString();
}

void Serializer::serializeString(string s)
	var x = shash.get(s);
	if( x != null ) {
		buf.add("R");
		buf.add(x);
		return;
	}
	shash.set(s,scount++);
	buf.add("y");
	s = StringTools.urlEncode(s);
	buf.add(s.length);
	buf.add(":");
	buf.add(s);
}

void Serializer::serializeRef(void *v)
{
	for( i in 0...cache.length )
	{
		if( cache[i] == v ) {
			buf.add("r");
			buf.add(i);
			return true;
		}
	}
	cache.push_back(v);
	return false;
}

void Serializer::serializeFields(void *v)
{
	for( f in Reflect.fields(v) )
	{
		serializeString(f);
		serialize(Reflect.field(v,f));
	}
	buf.add("g");
}

void Serializer::serialize(void *v)
{
	switch( Type.typeof(v) ) {
	case TNull:
		buf.add("n");
	
	case TInt:
		if( v == 0 ) {
			buf.add("z");
			return;
		}
		buf.add("i");
		buf.add(v);
	
	case TFloat:
		if( Math.isNaN(v) )
			buf.add("k");
		else if( !Math.isFinite(v) )
			buf.add(if( v < 0 ) "m" else "p");
		else {
			buf.add("d");
			buf.add(v);
		}
	
	case TBool:
		buf.add(if( v ) "t" else "f");
	
	case TClass(c):
		if (c == String)
		{
			serializeString(v);
			return;
		}
		if (useCache && serializeRef(v)) return;
		switch(c)
		{
			case cast Array:
				var ucount = 0;
				buf.add("a");
				#if flash9
				var v : Array<Dynamic> = v;
				#end
				var l = v.__length();
				for( i in 0...l ) {
					if( v[i] == null )
						ucount++;
					else {
						if( ucount > 0 ) {
							if( ucount == 1 )
								buf.add("n");
							else {
								buf.add("u");
								buf.add(ucount);
							}
							ucount = 0;
						}
						serialize(v[i]);
					}
				}
				if( ucount > 0 ) {
					if( ucount == 1 )
						buf.add("n");
					else {
						buf.add("u");
						buf.add(ucount);
					}
				}
				buf.add("h");
			case #if (neko || cs) "List" #else cast List #end:
				buf.add("l");
				var v : List<Dynamic> = v;
				for( i in v )
					serialize(i);
				buf.add("h");
			case #if (neko || cs) "Date" #else cast Date #end:
				var d : Date = v;
				buf.add("v");
				buf.add(d.toString());
			case #if (neko || cs) "haxe.ds.StringMap" #else cast haxe.ds.StringMap #end:
				buf.add("b");
				var v : haxe.ds.StringMap<Dynamic> = v;
				for( k in v.keys() ) {
					serializeString(k);
					serialize(v.get(k));
				}
				buf.add("h");
			case #if (neko || cs) "haxe.ds.IntMap" #else cast haxe.ds.IntMap #end:
				buf.add("q");
				var v : haxe.ds.IntMap<Dynamic> = v;
				for( k in v.keys() ) {
					buf.add(":");
					buf.add(k);
					serialize(v.get(k));
				}
				buf.add("h");
			case #if (neko || cs) "haxe.ds.ObjectMap" #else cast haxe.ds.ObjectMap #end:
				buf.add("M");
				var v : haxe.ds.ObjectMap<Dynamic,Dynamic> = v;
				for ( k in v.keys() ) {
					#if (js || flash8 || neko)
					var id = Reflect.field(k, "__id__");
					Reflect.deleteField(k, "__id__");
					serialize(k);
					Reflect.setField(k, "__id__", id);
					#else
					serialize(k);
					#end
					serialize(v.get(k));
				}
				buf.add("h");
			case #if (neko || cs) "haxe.io.Bytes" #else cast haxe.io.Bytes #end:
				var v : haxe.io.Bytes = v;
				var i = 0;
				var max = v.length - 2;
				var charsBuf = new StringBuf();
				var b64 = BASE64;
				while( i < max ) {
					var b1 = v.get(i++);
					var b2 = v.get(i++);
					var b3 = v.get(i++);

					charsBuf.add(b64.charAt(b1 >> 2));
					charsBuf.add(b64.charAt(((b1 << 4) | (b2 >> 4)) & 63));
					charsBuf.add(b64.charAt(((b2 << 2) | (b3 >> 6)) & 63));
					charsBuf.add(b64.charAt(b3 & 63));
				}
				if( i == max ) {
					var b1 = v.get(i++);
					var b2 = v.get(i++);
					charsBuf.add(b64.charAt(b1 >> 2));
					charsBuf.add(b64.charAt(((b1 << 4) | (b2 >> 4)) & 63));
					charsBuf.add(b64.charAt((b2 << 2) & 63));
				} else if( i == max + 1 ) {
					var b1 = v.get(i++);
					charsBuf.add(b64.charAt(b1 >> 2));
					charsBuf.add(b64.charAt((b1 << 4) & 63));
				}
				var chars = charsBuf.toString();
				buf.add("s");
				buf.add(chars.length);
				buf.add(":");
				buf.add(chars);
			default:
				cache.pop();
				if (v.hxSerialize != null)
				{
					buf.add("C");
					serializeString(Type.getClassName(c));
					cache.push_back(v);
					v.hxSerialize(this);
					buf.add("g");
				}
				else
				{
					buf.add("c");
					serializeString(Type.getClassName(c));
					cache.push_back(v);
					serializeFields(v);
				}
			}
		case TObject:
			if( useCache && serializeRef(v) )
				return;
			buf.add("o");
			serializeFields(v);
		case TEnum(e):
			if( useCache && serializeRef(v) )
				return;
			cache.pop();
			buf.add(useEnumIndex?"j":"w");
			serializeString(Type.getEnumName(e));

			if( useEnumIndex ) {
				buf.add(":");
				buf.add(v.__Index());
			} else
				serializeString(v.__Tag());
			buf.add(":");
			var pl : Array<Dynamic> = v.__EnumParams();
			if( pl == null )
				buf.add(0);
			else {
				buf.add(pl.length);
				for( p in pl )
					serialize(p);
			}
			cache.push_back(v);
		case Tvoid:
			throw "Cannot serialize void";
			
		default:
			throw "Cannot serialize "+Std.string(v);
	}
}

void Serializer::serializeException(void *e)
{
	buf.add("x");
	serialize(e);
}

string Serializer::run(void *v)
{
	var s = new Serializer();
	s.serialize(v);
	return s.toString();
}
*/