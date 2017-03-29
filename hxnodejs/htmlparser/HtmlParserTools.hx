package htmlparser;

@:jsRequire("htmlparser", "HtmlParserTools") extern class HtmlParserTools
{
	static function getAttr(node:htmlparser.HtmlNodeElement, attrName:String, ?defaultValue:Dynamic) : Dynamic;
	static function getAttrString(node:htmlparser.HtmlNodeElement, attrName:String, ?defaultValue:String) : String;
	static function getAttrInt(node:htmlparser.HtmlNodeElement, attrName:String, ?defaultValue:Int) : Int;
	static function getAttrFloat(node:htmlparser.HtmlNodeElement, attrName:String, ?defaultValue:Float) : Float;
	static function getAttrBool(node:htmlparser.HtmlNodeElement, attrName:String, ?defaultValue:Bool) : Bool;
	static function findOne(node:htmlparser.HtmlNodeElement, selector:String) : htmlparser.HtmlNodeElement;
	private static function parseValue(value:String, ?defaultValue:Dynamic) : Dynamic;
}