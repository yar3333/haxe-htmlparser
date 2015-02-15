package htmlparser;

private typedef HtmlLexem =
{
	var all : String;
	var allPos : Int;
	var script : String;
	var scriptAttrs : String;
	var scriptText : String;
	var style : String;
	var styleAttrs : String;
	var styleText : String;
	var elem : String;
	var tagOpen : String;
	var attrs : String;
	var tagEnd : String;
	var close : String;
	var tagClose : String;
	var comment : String;
}

class HtmlParser
{
    public static var SELF_CLOSING_TAGS_HTML(default, null) : Dynamic = { img:1, br:1, input:1, meta:1, link:1, hr:1, base:1, embed:1, spacer:1, source:1, param:1 };
    
	static var reID = "[a-z](?:-?[_a-z0-9])*";
	static var reNamespacedID = reID + "(?::" + reID + ")?";
	
	static var reCDATA = "[<]!\\[CDATA\\[[\\s\\S]*?\\]\\][>]";
	static var reScript = "[<]\\s*script\\s*([^>]*)>([\\s\\S]*?)<\\s*/\\s*script\\s*>";
	static var reStyle = "<\\s*style\\s*([^>]*)>([\\s\\S]*?)<\\s*/\\s*style\\s*>";
	static var reElementOpen = "<\\s*(" + reNamespacedID + ")";
	static var reAttr = reNamespacedID + "\\s*=\\s*(?:'[^']*'|\"[^\"]*\"|[-_a-z0-9]+)";
	static var reElementEnd = "(/)?\\s*>";
	static var reElementClose = "<\\s*/\\s*(" + reNamespacedID + ")\\s*>";
	static var reComment = "<!--[\\s\\S]*?-->";
	
	static var reMain = new EReg("(" + reCDATA + ")|(" + reScript + ")|(" + reStyle + ")|(" + reElementOpen + "((?:\\s+" + reAttr +")*)\\s*" + reElementEnd + ")|(" + reElementClose + ")|(" + reComment + ")", "i");
	
	static var reParseAttrs = new EReg("(" + reID + ")\\s*=\\s*('[^']*'|\"[^\"]*\"|[-_a-z0-9]+)" , "i");
	
	var matches : Array<HtmlLexem>;
	var str : String;
	var i : Int;
	
	public static function run(str:String) : Array<HtmlNode> return new HtmlParser().parse(str);
	
	function new() { }
	
	public function parse(str:String) : Array<HtmlNode>
    {
		matches = [];
		var pos = 0; while (pos < str.length && reMain.matchSub(str, pos))
		{
			var p = reMain.matchedPos();
			var cdata = getMatched(reMain, 1);
			if (cdata == null || cdata == "")
			{
				var r = {
					 all : reMain.matched(0)
					,allPos : p.pos
					,script : getMatched(reMain, 2)
					,scriptAttrs : getMatched(reMain, 3)
					,scriptText : getMatched(reMain, 4)
					,style : getMatched(reMain, 5)
					,styleAttrs : getMatched(reMain, 6)
					,styleText : getMatched(reMain, 7)
					,elem : getMatched(reMain, 8)
					,tagOpen : getMatched(reMain, 9)
					,attrs : getMatched(reMain, 10)
					,tagEnd : getMatched(reMain, 11)
					,close : getMatched(reMain, 12)
					,tagClose : getMatched(reMain, 13)
					,comment : getMatched(reMain, 14)
				};
				matches.push(r);
			}
			pos = p.pos + p.len;
		}
        
		if (matches.length > 0)
        {
			this.str = str;
			this.i = 0;
			var nodes = processMatches();
            if (i < matches.length)
			{
				throw("Error parsing XML at " + i + ":\n" + str);
			}
            return nodes;
        }
		
        return str.length > 0 ? cast [ new HtmlNodeText(str) ] : [];
    }
	
	function processMatches() : Array<HtmlNode>
    {
		var nodes = new Array<HtmlNode>();
        
		var prevEnd = i > 0 ? matches[i - 1].allPos + matches[i - 1].all.length : 0;
        var curStart = matches[i].allPos;
        
		if (prevEnd < curStart)
        {
            nodes.push(new HtmlNodeText(str.substr(prevEnd, curStart - prevEnd)));
        }

        while (i < matches.length)
        {
            var m = matches[i];
            
			if (m.elem != null && m.elem != "")
            {
				nodes.push(parseElement());
            }
            else
            if (m.script != null && m.script != "")
            {
                var scriptNode = newElement("script", parseAttrs(m.scriptAttrs));
                scriptNode.addChild(new HtmlNodeText(m.scriptText));
                nodes.push(scriptNode);
            }
            else
            if (m.style != null && m.style != "")
            {
                var styleNode = newElement("style", parseAttrs(m.styleAttrs));
                styleNode.addChild(new HtmlNodeText(m.styleText));
                nodes.push(styleNode);
            }
            else
            if (m.close != null && m.close != "") break;
            else
            if (m.comment != null && m.comment != "")
            {
                nodes.push(new HtmlNodeText(m.comment));
            }
            else
            {
                throw("Error");
            }
            
			var curEnd = matches[i].allPos + matches[i].all.length;
            var nextStart = i + 1 < matches.length ? matches[i + 1].allPos : str.length;
            if (curEnd < nextStart)
            {
                nodes.push(new HtmlNodeText(str.substr(curEnd, nextStart - curEnd)));
            }
			
			i++;
        }
		
		return nodes;
    }
	
    function parseElement() : HtmlNodeElement
    {
		var tag = matches[i].tagOpen;
        var attrs = matches[i].attrs;
        var isWithClose = matches[i].tagEnd != null && matches[i].tagEnd != "" || isSelfClosingTag(tag);
		
        var elem = new HtmlNodeElement(tag, parseAttrs(attrs));
        if (!isWithClose)
        {
            i++;
            var nodes = processMatches();
            for (node in nodes) elem.addChild(node);
            if (matches[i].close == null || matches[i].close == "" || matches[i].tagClose != tag)
			{
                throw("XML parse error: tag <" + tag + "> not closed. ParsedText = \n<pre>" + str + "</pre>\n");
			}
        }

        return elem;
    }
	
	function isSelfClosingTag(tag:String) return Reflect.hasField(SELF_CLOSING_TAGS_HTML, tag);
	
	function newElement(name:String, attributes:Array<HtmlAttribute>) return new HtmlNodeElement(name, attributes);
	
    static function parseAttrs(str:String) : Array<HtmlAttribute>
    {
        var attributes = new Array<HtmlAttribute>();
		
		var pos = 0; while (pos < str.length && reParseAttrs.matchSub(str, pos))
        {
			var name = reParseAttrs.matched(1);
			var value = reParseAttrs.matched(2);
			var quote = value.substr(0, 1);
			if (quote == '"' || quote == "'")
			{
				value = value.substr(1, value.length - 2);
			}
			else
			{
				quote = "";
			}
			attributes.push(new HtmlAttribute(name, value, quote));
			
			var p = reParseAttrs.matchedPos();
			pos = p.pos + p.len;
        }
		
        return attributes;
    }
    
    public static function parseCssSelector(selector:String) : Array<Array<CssSelector>>
    {
		var reg = new EReg("\\s*,\\s*", "");
        var selectors = reg.split(selector);
        var r = [];
        for (s in selectors)
        {
            if (s != "")
			{
				r.push(parseCssSelectorInner(s));
			}
        }
        return r;
    }
    
    static function parseCssSelectorInner(selector:String) : Array<CssSelector>
    {
        var reSubSelector = "[.#]?" + reID + "(?::" + reID + ")?";
        
        var parsedSelectors = [];
		var reg = new EReg("([ >])((?:" + reSubSelector + ")+|[*])", "i");
		
		var strSelector = " " + selector;
        while (reg.match(strSelector))
        {
			var tags = [];
			var ids = [];
			var classes = [];
			if (reg.matched(2) != "*")
			{
				var subreg : EReg = new EReg(reSubSelector, "i");
				var substr = reg.matched(2);
				try
				{
					while(subreg.match(substr))
					{
						var s = subreg.matched(0);
						if      (s.substr(0, 1) == "#") ids.push(s.substr(1));
						else if (s.substr(0, 1) == ".") classes.push(s.substr(1));
						else                            tags.push((s.toLowerCase()));
						substr = subreg.matchedRight();
					}
				}
				catch (e:Dynamic)
				{
					#if neko
					neko.Lib.println(substr);
					#end
					throw e;
				}
			}
			parsedSelectors.push({ 
				type:reg.matched(1), 
				tags:tags, 
				ids:ids, 
				classes:classes
			});
			strSelector = reg.matchedRight();
        }
        return parsedSelectors;
    }
	
	static inline function getMatched(re:EReg, n:Int) return try re.matched(n) catch (_:Dynamic) null;
}
