package htmlparser;

class CssSelector
{
	static var reID = "[a-z](?:-?[_a-z0-9])*";
	static var reNamespacedID = reID + "(?::" + reID + ")?";
	
	public var type(default, null) : String;
	public var tags(default, null) = new Array<String>();
	public var ids(default, null) = new Array<String>();
	public var classes(default, null) = new Array<String>();
	
	function new(type:String)
	{
		this.type = type;
	}
	
	public static function parse(selector:String) : Array<Array<CssSelector>>
	{
        var r = [];
		
        var selectors = ~/\s*,\s*/g.split(selector);
        for (s in selectors)
        {
            if (s != "") r.push(parseInner(s));
        }
        
		return r;
	}
	
    static function parseInner(selector:String) : Array<CssSelector>
    {
        var r = [];
        
		var reSubSelector = "[.#]?" + reNamespacedID;
		
		var reg = new EReg("([ >])((?:" + reSubSelector + ")+|[*])", "i");
		
		var strSelector = " " + selector;
        while (reg.match(strSelector))
        {
			var sel = new CssSelector(reg.matched(1));
			
			if (reg.matched(2) != "*")
			{
				var subreg : EReg = new EReg(reSubSelector, "i");
				var substr = reg.matched(2);
				try
				{
					while(subreg.match(substr))
					{
						var s = subreg.matched(0);
						if      (s.substr(0, 1) == "#") sel.ids.push(s.substr(1));
						else if (s.substr(0, 1) == ".") sel.classes.push(s.substr(1));
						else                            sel.tags.push((s.toLowerCase()));
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
			
			r.push(sel);
			
			strSelector = reg.matchedRight();
        }
		
        return r;
    }
	
	static inline function getMatched(re:EReg, n:Int) return try re.matched(n) catch (_:Dynamic) null;
}
