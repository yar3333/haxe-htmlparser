package haxe.htmlparser;

#if neko

private typedef NativeHtmlNode =
{
	var kind : Int;
}

private typedef NativeHtmlNodeElement =
{>NativeHtmlNode,
	var name : String;
	var attributes : Array<NativeHtmlAttribute>;
	var nodes : Array<NativeHtmlNode>;
}

private typedef NativeHtmlNodeText =
{>NativeHtmlNode,
	var text : String;
}

private typedef NativeHtmlAttribute =
{
	var name : String;
	var value : String;
	var quote : String;
}

class HtmlParserNeko
{
	static var htmlparser_parse;
	
	public static function parse(str:String) : Array<HtmlNode>
	{
		if (htmlparser_parse == null)
		{
			htmlparser_parse = neko.Lib.load("htmlparser", "htmlparser_parse", 1);
		}
		
		var start = Sys.time();
		var nodesRaw = htmlparser_parse(neko.Lib.haxeToNeko(str));
		neko.Lib.println("\n\ncall c++: " + (Sys.time() - start));
		
		start = Sys.time();
		var nodes : Array<NativeHtmlNode> = neko.Lib.nekoToHaxe(nodesRaw);
		neko.Lib.println("nekoToHaxe: " + (Sys.time() - start));
		
		start = Sys.time();
		var r = [];
		for (node in nodes)
		{
			r.push(nodeToHaxe(node));
		}
		neko.Lib.println("nodeToHaxe: " + (Sys.time() - start));
		
		return r;
	}
	
	static function attributesToHaxe(attributes:Array<NativeHtmlAttribute>)
	{
		var r = [];
		for (a in attributes) r.push(new HtmlAttribute(a.name, a.value, a.quote));
		return r;
	}
	
	static function nodeToHaxe(node:NativeHtmlNode) : HtmlNode
	{
		if (node.kind == 1)
		{
			var raw : NativeHtmlNodeElement = cast node;
			var element = new HtmlNodeElement(raw.name, attributesToHaxe(raw.attributes));
			for (subNode in raw.nodes) element.addChild(nodeToHaxe(subNode));
			return element;
		}
		else
		if (node.kind == 2)
		{
			var raw : NativeHtmlNodeText = cast node;
			var text = new HtmlNodeText(raw.text);
			return text;
		}
		return null;
	}
}

#end
