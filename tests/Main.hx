package ;

#if php
import php.Web;
import php.Lib;
#elseif neko
import neko.Web;
import neko.Lib;
#end

class Main
{
    static function main()
	{
		#if sys
		Sys.setCwd(Web.getCwd());
		#end
		
		var r = new haxe.unit.TestRunner();
		r.add(new HtmlTest());
		
		#if sys
		Lib.println("<pre>");
		#end
		
		r.run();
		
		#if sys
		Lib.println("</pre>");
		#end
	}
}
