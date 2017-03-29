package htmlparser;

@:jsRequire("re-html-parser", "XmlBuilder") extern class XmlBuilder
{
	function new(?indent:String, ?newLine:String) : Void;
	private var indent : String;
	private var newLine : String;
	private var cur : htmlparser.XmlNodeElement;
	private var level : Int;
	var xml : htmlparser.XmlDocument;
	function begin(tag:String, ?attrs:Array<{ var value : Dynamic; var name : String; }>) : htmlparser.XmlBuilder;
	function end() : htmlparser.XmlBuilder;
	function attr(name:String, value:Dynamic, ?defValue:Dynamic) : htmlparser.XmlBuilder;
	function content(s:String) : htmlparser.XmlBuilder;
	function toString() : String;
}