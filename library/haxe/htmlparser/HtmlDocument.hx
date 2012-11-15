package haxe.htmlparser;

class HtmlDocument extends HtmlNodeElement
{
    public function new(str="") : Void
    {
        super("", []);
        var nodes = HtmlParser.parse(str);
        for (node in nodes)
		{
			addChild(node);
		}
    }
}
