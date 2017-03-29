package htmlparser;

@:jsRequire("htmlparser", "HtmlParserException") extern class HtmlParserException
{
	function new(message:String, pos:{ var column : Int; var length : Int; var line : Int; }) : Void;
	var message : String;
	var line : Int;
	var column : Int;
	var length : Int;
	function toString() : String;
}