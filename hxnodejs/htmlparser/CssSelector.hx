package htmlparser;

@:jsRequire("haxelib/hxnodejs-htmlparser", "CssSelector") extern class CssSelector
{
	private function new(type:String) : Void;
	var type(default, null) : String;
	var tagNameLC(default, null) : String;
	var id(default, null) : String;
	var classes(default, null) : Array<String>;
	var index(default, null) : Int;
	private static var reID : String;
	private static var reNamespacedID : String;
	private static var reSelector : String;
	static function parse(selector:String) : Array<Array<htmlparser.CssSelector>>;
	private static function parseInner(selector:String) : Array<htmlparser.CssSelector>;
}