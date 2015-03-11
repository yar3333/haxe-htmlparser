package htmlparser;

import haxe.Serializer;
import haxe.Unserializer;

class HtmlNodeText extends HtmlNode
{
    public var text : String;

    public function new(text) : Void
    {
        this.text = text;
    }
 
	public override function toString()
    {
        return this.text;
    }
	
	/**
	 * Return decoded text.
	 */
	override public function toText() : String
    {
		return ~/[<]!\[CDATA\[((?:.|[\r\n])*?)\]\][>]|&[^;]+;/gs.map(text, function(re)
		{
			var s = re.matched(0);
			if (s.charAt(0) == "&")
			{
				var r = htmlUnescapeMap.get(s.substring(1, s.length - 1));
				return r != null ? r : s;
			}
			return re.matched(1);
		});
    }
	
	override function hxSerialize(s:Serializer)
	{
		s.serialize(text);
	}
	
	override function hxUnserialize(s:Unserializer) 
	{
		text = s.unserialize();
    }
	
	@:isVar static var htmlUnescapeMap(get, null) : Map<String, String>;
	static function get_htmlUnescapeMap()
	{
		if (htmlUnescapeMap == null)
		{
			htmlUnescapeMap =
			[
				"nbsp" => " ",
				"amp" => "&",
				"lt" => "<",
				"gt" => ">",
				"quot" => "\"",
				"euro" => "€",
				"iexcl" => "¡",
				"cent" => "¢",
				"pound" => "£",
				"curren" => "¤",
				"yen" => "¥",
				"brvbar" => "¦",
				"sect" => "§",
				"uml" => "¨",
				"copy" => "©",
				"ordf" => "ª",
				"not" => "¬",
				"shy" => "­",
				"reg" => "®",
				"macr" => "¯",
				"deg" => "°",
				"plusmn" => "±",
				"sup2" => "²",
				"sup3" => "³",
				"acute" => "´",
				"micro" => "µ",
				"para" => "¶",
				"middot" => "·",
				"cedil" => "¸",
				"sup1" => "¹",
				"ordm" => "º",
				"raquo" => "»",
				"frac14" => "¼",
				"frac12" => "½",
				"frac34" => "¾",
				"iquest" => "¿",
				"Agrave" => "À",
				"Aacute" => "Á",
				"Acirc" => "Â",
				"Atilde" => "Ã",
				"Auml" => "Ä",
				"Aring" => "Å",
				"AElig" => "Æ",
				"Ccedil" => "Ç",
				"Egrave" => "È",
				"Eacute" => "É",
				"Ecirc" => "Ê",
				"Euml" => "Ë",
				"Igrave" => "Ì",
				"Iacute" => "Í",
				"Icirc" => "Î",
				"Iuml" => "Ï",
				"ETH" => "Ð",
				"Ntilde" => "Ñ",
				"Ograve" => "Ò",
				"Oacute" => "Ó",
				"Ocirc" => "Ô",
				"Otilde" => "Õ",
				"Ouml" => "Ö",
				"times" => "×",
				"Oslash" => "Ø",
				"Ugrave" => "Ù",
				"Uacute" => "Ú",
				"Ucirc" => "Û",
				"Uuml" => "Ü",
				"Yacute" => "Ý",
				"THORN" => "Þ",
				"szlig" => "ß",
				"agrave" => "à",
				"aacute" => "á",
				"acirc" => "â",
				"atilde" => "ã",
				"auml" => "ä",
				"aring" => "å",
				"aelig" => "æ",
				"ccedil" => "ç",
				"egrave" => "è",
				"eacute" => "é",
				"ecirc" => "ê",
				"euml" => "ë",
				"igrave" => "ì",
				"iacute" => "í",
				"icirc" => "î",
				"iuml" => "ï",
				"eth" => "ð",
				"ntilde" => "ñ",
				"ograve" => "ò",
				"oacute" => "ó",
				"ocirc" => "ô",
				"otilde" => "õ",
				"ouml" => "ö",
				"divide" => "÷",
				"oslash" => "ø",
				"ugrave" => "ù",
				"uacute" => "ú",
				"ucirc" => "û",
				"uuml" => "ü",
				"yacute" => "ý",
				"thorn" => "þ",
			];
		}
		return htmlUnescapeMap;
	}
}
