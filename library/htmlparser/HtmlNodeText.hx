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
        return text;
    }
	
	override public function toText() : String
    {
		return HtmlTools.unescape(text);
    }
	
	override function hxSerialize(s:Serializer)
	{
		s.serialize(text);
	}
	
	override function hxUnserialize(s:Unserializer) 
	{
		text = s.unserialize();
    }
}
