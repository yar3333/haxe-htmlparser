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
		#if (php || neko)
		Sys.setCwd(Web.getCwd());
		#end
		
		var r = new haxe.unit.TestRunner();
		r.add(new HtmlTest());
		
		#if (php || neko)
		Lib.println("<pre>");
		#end
		
		r.run();
		
		#if (php || neko)
		Lib.println("</pre>");
		#end
	}
}
