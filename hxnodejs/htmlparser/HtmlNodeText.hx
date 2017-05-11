package htmlparser;

@:jsRequire("haxelib/hxnodejs-htmlparser", "HtmlNodeText") extern class HtmlNodeText extends htmlparser.HtmlNode
{
	function new(text:String) : Void;
	var text : String;
	override function toString() : String;
	override function toText() : String;
	private override function hxSerialize(s:{ function serialize(d:Dynamic) : Void; }) : Void;
	private override function hxUnserialize(s:{ function unserialize() : Dynamic; }) : Void;
}