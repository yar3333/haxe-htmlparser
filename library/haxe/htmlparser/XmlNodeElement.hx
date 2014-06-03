package haxe.htmlparser;

class XmlNodeElement extends HtmlNodeElement
{
	public override function toString() : String
    {
		return toStringWithSelfClosingTags({});
    }
	
	override function set_innerHTML(value:String) : String
	{
		var newNodes = XmlParser.run(value);
		nodes = [];
		children = [];
		for (node in newNodes) addChild(node);
		return value;
	}
}