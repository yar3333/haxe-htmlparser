package haxe.htmlparser;

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
    public static var selfClosingTags = { img:1, br:1, input:1, meta:1, link:1, hr:1, base:1, embed:1, spacer:1, innercontent:1 };
    static var inline regExpForID = '[a-z](?:-?[_a-z0-9])*';

    static public function parse(str:String) : Array<HtmlNode>
    {
        var reID = regExpForID;
        var reAttr = regExpForID + "\\s*=\\s*(?:'[^']*'|\"[^\"]*\"|[-_a-z0-9]+)" ;
        var reElementName = reID + "(?::" + reID + ")?";
		var reScript = "[<]\\s*script\\s*([^>]*)>([\\s\\S]*?)<\\s*/\\s*script\\s*>";
		var reStyle = "<\\s*style\\s*([^>]*)>([\\s\\S]*?)<\\s*/\\s*style\\s*>";
		var reElementOpen = "<\\s*(" + reElementName+ ")";
        var reAttr = reID + "\\s*=\\s*(?:'[^']*'|\"[^\"]*\"|[-_a-z0-9]+)";
        var reElementEnd = "(/)?\\s*>";
        var reElementClose = "<\\s*/\\s*(" + reElementName + ")\\s*>";
        var reComment = "<!--[\\s\\S]*?-->";
		
        var reStr = "(" + reScript + ")|(" + reStyle + ")|(" + reElementOpen 
		          + "((?:\\s+" + reAttr +")*)\\s*" + reElementEnd + ")|(" + reElementClose + ")|(" + reComment + ")";
		
		var re = new EReg(reStr, "i");
		var matches = new Array<HtmlLexem>();
		var parsedStr : String = str;
		var cutted = 0;
		while (parsedStr != null && parsedStr != "" && re.match(parsedStr))
		{
			var r = {
				 all : re.matched(0)
				,allPos : re.matchedPos().pos + cutted
				,script : getMatched(re, 1)
				,scriptAttrs : getMatched(re, 2)
				,scriptText : getMatched(re, 3)
				,style : getMatched(re, 4)
				,styleAttrs : getMatched(re, 5)
				,styleText : getMatched(re, 6)
				,elem : getMatched(re, 7)
				,tagOpen : getMatched(re, 8)
				,attrs : getMatched(re, 9)
				,tagEnd : getMatched(re, 10)
				,close : getMatched(re, 11)
				,tagClose : getMatched(re, 12)
				,comment : getMatched(re, 13)
			};
			
			matches.push(r);
			
			var rightStr = re.matchedRight();
			cutted += parsedStr.length - rightStr.length;
			parsedStr = rightStr;
		}
        
		if (matches.length > 0)
        {
            var i = { i:0 };
			var nodes =  parseInner(str,  matches, i);
            if (i.i < matches.length)
			{
				throw("Error parsing XML:\n<br>" + str);
			}
            return nodes;
        }
		
        return str.length > 0 ? cast [ new HtmlNodeText(str) ] : [];
    }
	
	
	static function getMatched(re:EReg, n:Int)
	{
		try { return re.matched(n); } 
		catch (e:Dynamic) { return null; }
	}
	
	private static function parseInner(str:String, matches:Array<HtmlLexem>, i:{i:Int}) : Array<HtmlNode>
    {
		var nodes = new Array<HtmlNode>();
        
		var prevEnd = i.i > 0 ? matches[i.i - 1].allPos + matches[i.i - 1].all.length : 0;
        var curStart = matches[i.i].allPos;
        
		if (prevEnd < curStart)
        {
            nodes.push(new HtmlNodeText(str.substr(prevEnd, curStart - prevEnd)));
        }

        while (i.i < matches.length)
        {
            var m = matches[i.i];
            
			if (m.elem != null && m.elem != '')
            {
				nodes.push(parseElement(str, matches, i));
            }
            else
            if (m.script != null && m.script != '')
            {
                var scriptNode = new HtmlNodeElement('script', parseAttrs(m.scriptAttrs));
                scriptNode.addChild(new HtmlNodeText(m.scriptText));
                nodes.push(scriptNode);
            }
            else
            if (m.style != null && m.style != '')
            {
                var styleNode = new HtmlNodeElement('style', parseAttrs(m.styleAttrs));
                styleNode.addChild(new HtmlNodeText(m.styleText));
                nodes.push(styleNode);
            }
            else
            if (m.close != null && m.close != '') break;
            else
            if (m.comment != null && m.comment != '')
            {
                nodes.push(new HtmlNodeText(m.comment));
            }
            else
            {
                throw("Error");
            }
            
			var curEnd = matches[i.i].allPos + matches[i.i].all.length;
            var nextStart = i.i + 1 < matches.length ? matches[i.i + 1].allPos : str.length;
            if (curEnd < nextStart)
            {
                nodes.push(new HtmlNodeText(str.substr(curEnd, nextStart - curEnd)));
            }
			
			i.i++;
        }
		
		return nodes;
    }

    private static function parseElement(str, matches:Array<HtmlLexem>, i:{i:Int}) : HtmlNodeElement
    {
		var tag = matches[i.i].tagOpen;
        var attrs = matches[i.i].attrs;
        var isWithClose = matches[i.i].tagEnd != null && matches[i.i].tagEnd != "" || Reflect.hasField(selfClosingTags, tag);
		
        var elem = new HtmlNodeElement(tag, parseAttrs(attrs));
        if (!isWithClose)
        {
            i.i++;
            var nodes = parseInner(str, matches, i);
            for (node in nodes) elem.addChild(node);
            if (matches[i.i].close == null || matches[i.i].close == '' || matches[i.i].tagClose != tag)
			{
                throw("XML parse error: tag <" + tag + "> not closed. ParsedText = \n<pre>" + str + "</pre>\n");
			}
        }

        return elem;
    }

    private static function parseAttrs(str:String) : Hash<HtmlAttribute>
    {
        var attributes = new Hash<HtmlAttribute>();

		var re = new EReg("(" + regExpForID + ")\\s*=\\s*('[^']*'|\"[^\"]*\"|[-_a-z0-9]+)" , "i");
		var parsedStr = str;
        while (parsedStr != null && parsedStr != '' && re.match(parsedStr))
        {
			var name =  re.matched(1);
			var value = re.matched(2);
			var quote = value.substr(0, 1);
			if (quote == '"' || quote == "'")
			{
				value = value.substr(1, value.length - 2);
			}
			else
			{
				quote = '';
			}
			attributes.set(name.toLowerCase(), new HtmlAttribute(name, value, quote));
			parsedStr = re.matchedRight();
        }

        return attributes;
    }
    
    public static function parseCssSelector(selector : String) : Array<Array<CssSelector>>
    {
		var reg = new EReg('\\s*,\\s*', "");
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
    
    private static function parseCssSelectorInner(selector): Array<CssSelector>
    {
        var reSubSelector = '[.#]?' + regExpForID + '(?::' + regExpForID + ')?';
        
        var parsedSelectors = [];
		var reg = new EReg("([ >])((?:" + reSubSelector + ")+|[*])", "i");
		
		var strSelector = ' ' + selector;
        while (reg.match(strSelector))
        {
			var tags = [];
			var ids = [];
			var classes = [];
			if (reg.matched(2) != '*')
			{
				var subreg : EReg = new EReg(reSubSelector, "is");
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
}
