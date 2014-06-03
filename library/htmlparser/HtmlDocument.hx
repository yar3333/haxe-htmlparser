package htmlparser;

class HtmlDocument extends HtmlNodeElement
{
    public function new(str="") : Void
    {
        super("", []);
        var nodes = HtmlParser.run(str);
        for (node in nodes)
		{
			addChild(node);
		}
    }
}
