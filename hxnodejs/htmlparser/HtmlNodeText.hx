package htmlparser;

@:jsRequire("re-html-parser", "HtmlNodeText") extern class HtmlNodeText extends htmlparser.HtmlNode
{
	function new(text:String) : Void;
	var text : String;
	override function toString() : String;
	override function toText() : String;
	private override function hxSerialize(s:haxe.Serializer) : Void;
	private override function hxUnserialize(s:haxe.Unserializer) : Void;
}