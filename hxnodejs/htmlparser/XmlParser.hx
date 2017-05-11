package htmlparser;

@:jsRequire("re-html-parser", "XmlParser") extern class XmlParser extends htmlparser.HtmlParser
{
	private function new() : Void;
	private override function isSelfClosingTag(tag:String) : Bool;
	private override function newElement(name:String, attributes:Array<htmlparser.HtmlAttribute>) : htmlparser.XmlNodeElement;
	static function run(str:String) : Array<htmlparser.HtmlNode>;
}