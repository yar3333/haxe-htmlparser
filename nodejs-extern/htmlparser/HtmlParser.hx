package htmlparser;

@:jsRequire("re-html-parser", "HtmlParser") extern class HtmlParser
{
	private function new() : Void;
	private var tolerant : Bool;
	private var matches : Array<HtmlLexem>;
	private var str : String;
	private var i : Int;
	function parse(str:String, ?tolerant:Bool) : Array<htmlparser.HtmlNode>;
	private function processMatches(openedTagsLC:Array<String>) : { var closeTagLC : String; var nodes : Array<htmlparser.HtmlNode>; };
	private function parseElement(openedTagsLC:Array<String>) : { var closeTagLC : String; var element : htmlparser.HtmlNodeElement; };
	private function isSelfClosingTag(tag:String) : Bool;
	private function newElement(name:String, attributes:Array<htmlparser.HtmlAttribute>) : htmlparser.HtmlNodeElement;
	private function getPosition(matchIndex:Int) : { var column : Int; var length : Int; var line : Int; };
	static var SELF_CLOSING_TAGS_HTML(default, null) : Dynamic;
	private static var reID : String;
	private static var reNamespacedID : String;
	private static var reCDATA : String;
	private static var reScript : String;
	private static var reStyle : String;
	private static var reElementOpen : String;
	private static var reAttr : String;
	private static var reElementEnd : String;
	private static var reElementClose : String;
	private static var reComment : String;
	private static var reMain : EReg;
	private static var reParseAttrs : EReg;
	static function run(str:String, ?tolerant:Bool) : Array<htmlparser.HtmlNode>;
	private static function parseAttrs(str:String) : Array<htmlparser.HtmlAttribute>;
}