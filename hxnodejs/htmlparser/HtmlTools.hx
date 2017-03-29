package htmlparser;

@:jsRequire("htmlparser", "HtmlTools") extern class HtmlTools
{
	private static var htmlUnescapeMap(get, null) : Map<String, String>;
	private static function get_htmlUnescapeMap() : Map<String, String>;
	static function escape(text:String, ?chars:String) : String;
	static function unescape(text:String) : String;
}