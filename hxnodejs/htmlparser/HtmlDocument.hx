package htmlparser;

@:jsRequire("re-html-parser", "HtmlDocument") extern class HtmlDocument extends htmlparser.HtmlNodeElement
{
	function new(?str:String, ?tolerant:Bool) : Void;
}