package htmlparser;

@:jsRequire("htmlparser", "XmlNodeElement") extern class XmlNodeElement extends htmlparser.HtmlNodeElement
{
	function new(name:String, attributes:Array<htmlparser.HtmlAttribute>) : Void;
	private override function isSelfClosing() : Bool;
	private override function set_innerHTML(value:String) : String;
}