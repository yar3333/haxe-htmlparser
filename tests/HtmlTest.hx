package;

import haxe.Serializer;
import haxe.Unserializer;
import php.io.File;
import haxe.htmlparser.HtmlParser;
import haxe.htmlparser.HtmlNodeElement;
import haxe.htmlparser.HtmlNodeText;
import haxe.htmlparser.HtmlDocument;

class HtmlTest extends haxe.unit.TestCase
{
    public function testText()
    {
		var nodes = HtmlParser.parse("abc");
        this.assertEquals(1, nodes.length);

        var node = nodes[0];
		this.assertTrue(Type.getClass(node) == HtmlNodeText);
        this.assertEquals('abc', cast(node, HtmlNodeText).text);
    }

    public function testTagWithClose()
    {
		var nodes = HtmlParser.parse("<br p=2 />");
        this.assertEquals(1, nodes.length);

		this.assertTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
        
		var node : HtmlNodeElement = cast nodes[0];
        this.assertEquals('br', node.name);
		
		this.assertEquals("String", Type.getClassName(Type.getClass("abc")));
    }

    public function testTagAndText()
    {
        var nodes = HtmlParser.parse("<a>abc</a>");
        this.assertEquals(1, nodes.length);

		this.assertTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
		
        var node : HtmlNodeElement = cast nodes[0];
        this.assertEquals('a', node.name);
    }

    public function getParsedAsString(str:String) : String
    {
        var nodes = HtmlParser.parse(str);
        return Lambda.fold(nodes, function(node, s) return s + node.toString(), "");
    }

    public function testSimpleConvertDeconvert()
    {
        this.assertEquals("<a>abc</a>", this.getParsedAsString("<a>abc</a>"));
        this.assertEquals("<a p=2>abc</a>", this.getParsedAsString("<a p=2>abc</a>"));
        this.assertEquals("<a p=2>abc</a>", this.getParsedAsString("<a p = 2>abc</a>"));
        this.assertEquals("<a p='2'>abc</a>", this.getParsedAsString("<a p = '2'>abc</a>"));
        this.assertEquals('<a p="2">abc</a>', this.getParsedAsString('<a p = "2">abc</a>'));
        this.assertEquals('<br />', this.getParsedAsString('<br/>'));
        this.assertEquals('<br />', this.getParsedAsString('<br />'));
        this.assertEquals("<a href='http://ya.ru?a=5'>Все на Яндекс!</a>", this.getParsedAsString("<a href='http://ya.ru?a=5'>Все на Яндекс!</a>"));
    }

    public function testComplexConvertDeconvert()
    {
        this.assertEquals(this.getParsedAsString("<p><a>abc</a></p>"), "<p><a>abc</a></p>");
    }

    public function testManyRootNodes()
    {
        this.assertEquals(this.getParsedAsString("<p>abc</p>TEXT<a>def</a>"), "<p>abc</p>TEXT<a>def</a>");
    }

    public function testComment()
    {
        var nodes = HtmlParser.parse("<a><!-- comment<p></p> --></a>");
        this.assertEquals(1, nodes.length);
        this.assertTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
        
        var node : HtmlNodeElement = cast nodes[0];
        var subnodes = node.nodes;
        this.assertEquals(1, subnodes.length);
        this.assertTrue(Type.getClass(subnodes[0]) == HtmlNodeText);
    }
    
    public function testComplexParse()
    {
		var s = php.io.File.getContent('support/input.html');
		php.io.File.putContent("support/output.html", getParsedAsString(s));
		assertEquals(s, php.io.File.getContent('support/output.html'));
    }
    
    public function testSelectors()
    {
        var xml = new HtmlDocument("<div class='first second'><p id='myp' class='first'><a href='b'>cde</a></p></div>");
        
        var nodes = xml.find('');
        this.assertEquals(0, nodes.length);
        
        var nodes = xml.find('div');
        this.assertEquals(1, nodes.length);
        
        var divs = xml.find('div');
        nodes = divs[0].find('div');
        this.assertEquals(0, nodes.length);
        
        nodes = divs[0].find('*');
        this.assertEquals(2, nodes.length);
        
        nodes = xml.find('#no');
        this.assertEquals(0, nodes.length);

        nodes = xml.find('.no');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('a');
        this.assertEquals(1, nodes.length);
        this.assertEquals('a', nodes[0].name);
        this.assertEquals('b', nodes[0].getAttribute('href'));
        
        nodes = xml.find('.first');
        this.assertEquals(2, nodes.length);
        this.assertEquals('p', nodes[0].name);
        this.assertEquals('div', nodes[1].name);
        
        nodes = xml.find('.first.second');
        this.assertEquals(1, nodes.length);
        this.assertEquals('div', nodes[0].name);
        
        nodes = xml.find('#myp');
        this.assertEquals(1, nodes.length);
        this.assertEquals('p', nodes[0].name);
        
        nodes = xml.find('.first#myp');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('.second#myp');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('.first.second a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('.first.second>a');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('.first.second >a');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('.second>a');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('.second a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('.first>a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('div>p>a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('div>a');
        this.assertEquals(0, nodes.length);
        
        nodes = xml.find('div>*>a');
        this.assertEquals(1, nodes.length);
        
        nodes = xml.find('*');
        this.assertEquals(3, nodes.length);
        
        nodes = xml.find('a,p');
        this.assertEquals(2, nodes.length);
        
        nodes = xml.find('a , p');
        this.assertEquals(2, nodes.length);
        
        nodes = xml.find('a, a');
        this.assertEquals(1, nodes.length);
    }

    public function testSiblings()
    {
        var xml = new HtmlDocument("<br />\n        <div id='m'>test</div>");
        var nodes = xml.find("#m");
		
        this.assertEquals(1, nodes.length);
		this.assertTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
        
		var node = nodes[0];
        this.assertEquals("m", node.getAttribute('id'));
        
		var prev = node.getPrevSiblingNode();
		this.assertTrue(Type.getClass(prev) == HtmlNodeText);
        this.assertEquals("\n        ", cast(prev, HtmlNodeText).text);
    }
	
	public function testStyle()
	{
		var html = "
<style>
    .randnum
    {
        color: blue;
    }
</style>

<div id='n'>0</div>
";

		var xml = new HtmlDocument(html);
		assertEquals(2, xml.children.length);
        
		var nodes = xml.find("#n");
        assertEquals(1, nodes.length);
		assertTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
	}
	
	public function testReplaceChildWithInner()
	{
		var xml = new HtmlDocument("b<ph>c</ph>d<con>e</con>");
		
		var nodesPH = xml.find("ph");
		assertEquals(1, nodesPH.length);
		assertEquals(0, nodesPH[0].children.length);
		
		var nodesCON = xml.find("con");
		assertEquals(1, nodesCON.length);
		assertEquals(0, nodesCON[0].children.length);
		
		xml.replaceChildWithInner(nodesPH[0], nodesCON[0]);
		assertEquals("bed<con>e</con>", xml.innerHTML);
		assertEquals(1, xml.children.length);
	}
    
	public function testSpeed()
    {
        var str = File.getContent('support/input.html');
        var loops = 10;
        
        var start = Date.now();
		for (i in 0...loops)
        {
            var xml = new HtmlDocument(str);
        }
        var parseTime = (Date.now().getTime() - start.getTime()) / loops;
		
        var xml = new HtmlDocument(str);
        var ser = new Serializer();
		ser.useCache = true;
		ser.serialize(xml);
		var saved = ser.toString();
        start = Date.now();
        for (i in 0...loops)
        {
            xml = Unserializer.run(saved);
        }
        var unserializeTime = (Date.now().getTime() - start.getTime()) / loops;
        
		print("[time parse/unserialize: " + parseTime + "/" + unserializeTime + "]");
		
		assertTrue(true);
    }
}