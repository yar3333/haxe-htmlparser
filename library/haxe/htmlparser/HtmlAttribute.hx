package haxe.htmlparser;

class HtmlAttribute
{
    public var name : String;
    public var value : String;
    public var quote : String;

    public function new(name:String, value:String, quote:String) : Void
    {
        this.name = name;
        this.value = value;
        this.quote = quote;
    }
    
	public function toString()
    {
        return name + "=" + quote + value + quote;
    }
}
