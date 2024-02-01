import haxe.Serializer;
import haxe.Unserializer;
import htmlparser.HtmlParser;
import htmlparser.HtmlNodeElement;
import htmlparser.HtmlNodeText;
import htmlparser.HtmlDocument;
import htmlparser.XmlDocument;
import utest.Assert;

#if sys
import sys.io.File;
#end

class HtmlTest extends utest.Test
{
    public function getParsedAsString(str:String, tolerant=false) : String
    {
        var nodes = HtmlParser.run(str, tolerant);
        return nodes.join("");
    }
    
	public function testText()
    {
		var nodes = HtmlParser.run("abc");
        Assert.equals(1, nodes.length);

        var node = nodes[0];
		Assert.isTrue(Type.getClass(node) == HtmlNodeText);
        Assert.equals('abc', cast(node, HtmlNodeText).text);
    }

    public function testTagWithClose()
    {
		var nodes = HtmlParser.run("<br p=2 />");
        Assert.equals(1, nodes.length);

		Assert.isTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
        
		var node : HtmlNodeElement = cast nodes[0];
        Assert.equals('br', node.name);
		
		Assert.equals("String", Type.getClassName(Type.getClass("abc")));
    }

    public function testTagAndText()
    {
        var nodes = HtmlParser.run("<a>abc</a>");
        Assert.equals(1, nodes.length);

		Assert.isTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
		
        var node : HtmlNodeElement = cast nodes[0];
        Assert.equals('a', node.name);
    }

    public function testSimpleConvertDeconvert()
    {
        Assert.equals("<a>abc</a>", this.getParsedAsString("<a>abc</a>"));
        Assert.equals("<a p=2>abc</a>", this.getParsedAsString("<a p=2>abc</a>"));
        Assert.equals("<a p=2>abc</a>", this.getParsedAsString("<a p = 2>abc</a>"));
        Assert.equals("<a p='2'>abc</a>", this.getParsedAsString("<a p = '2'>abc</a>"));
        Assert.equals('<a p="2">abc</a>', this.getParsedAsString('<a p = "2">abc</a>'));
        Assert.equals('<br />', this.getParsedAsString('<br/>'));
        Assert.equals('<br />', this.getParsedAsString('<br />'));
        Assert.equals("<a href='http://ya.ru?a=5'>Все на Яндекс!</a>", this.getParsedAsString("<a href='http://ya.ru?a=5'>Все на Яндекс!</a>"));
    }

    public function testComplexConvertDeconvert()
    {
        Assert.equals(this.getParsedAsString("<p><a>abc</a></p>"), "<p><a>abc</a></p>");
    }

    public function testManyRootNodes()
    {
        Assert.equals(this.getParsedAsString("<p>abc</p>TEXT<a>def</a>"), "<p>abc</p>TEXT<a>def</a>");
    }

    public function testComment()
    {
        var nodes = HtmlParser.run("<a><!-- comment<p></p> --></a>");
        Assert.equals(1, nodes.length);
        Assert.isTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
        
        var node : HtmlNodeElement = cast nodes[0];
        var subnodes = node.nodes;
        Assert.equals(1, subnodes.length);
        Assert.isTrue(Type.getClass(subnodes[0]) == HtmlNodeText);
    }
    
    #if sys
	public function testComplexParseA()
    {
		var s = File.getContent('assets/inputA.html');
        var r = getParsedAsString(s);
		Assert.equals(s, r);
    }
	
	public function testComplexParseB()
    {
		var s = File.getContent('assets/inputB.html');
		var r = getParsedAsString(s, true);
		Assert.isTrue(r != null && r != "");
    }
	#end
	
	public function testTolerantA()
    {
        Assert.equals("<div><form></form></div>", getParsedAsString("<div><form></div>", true));
    }
	
	public function testTolerantB()
    {
        Assert.equals("<div></div>", getParsedAsString("<div></form></div>", true));
    }
	
	public function testTolerantC()
    {
        Assert.equals("<form><div></div></form>", getParsedAsString("<form><div></form></div>", true));
    }
	
	public function testTolerantD()
    {
        Assert.equals
		(
			                  "<div><dl><dd>D</dd></dl><a>A</a></div>",
			getParsedAsString("<div><dl><dd>D</dl><a>A</a></div>", true)
		);
    }
	
	public function testNotTolerantA()
    {
        try getParsedAsString("<div><form></div>")
		catch (_:Dynamic) { Assert.isTrue(true); return; }
		Assert.isTrue(false);
    }
	
	public function testNotTolerantB()
    {
        try getParsedAsString("<div></form></div>")
		catch (_:Dynamic) { Assert.isTrue(true); return; }
		Assert.isTrue(false);
    }
	
	public function testNotTolerantC()
    {
        try getParsedAsString("<form><div></form></div>")
		catch (_:Dynamic) { Assert.isTrue(true); return; }
		Assert.isTrue(false);
    }
    
    public function testSelectors()
    {
        var xml = new HtmlDocument("<div class='first second'><p id='myp' class='first'><a href='b'>cde</a></p></div>");
        
        var nodes = xml.find('');
        Assert.equals(0, nodes.length);
        
        var nodes = xml.find('div');
        Assert.equals(1, nodes.length);
        
        var divs = xml.find('div');
        nodes = divs[0].find('div');
        Assert.equals(0, nodes.length);
        
        nodes = divs[0].find('*');
        Assert.equals(2, nodes.length);
        
        nodes = xml.find('#no');
        Assert.equals(0, nodes.length);

        nodes = xml.find('.no');
        Assert.equals(0, nodes.length);
        
        nodes = xml.find('a');
        Assert.equals(1, nodes.length);
        Assert.equals('a', nodes[0].name);
        Assert.equals('b', nodes[0].getAttribute('href'));
        
        nodes = xml.find('.first');
        Assert.equals(2, nodes.length);
        Assert.equals('p', nodes[0].name);
        Assert.equals('div', nodes[1].name);
        
        nodes = xml.find('.first.second');
        Assert.equals(1, nodes.length);
        Assert.equals('div', nodes[0].name);
        
        nodes = xml.find('#myp');
        Assert.equals(1, nodes.length);
        Assert.equals('p', nodes[0].name);
        
        nodes = xml.find('.first#myp');
        Assert.equals(1, nodes.length);
        
        nodes = xml.find('.second#myp');
        Assert.equals(0, nodes.length);
        
        nodes = xml.find('.first.second a');
        Assert.equals(1, nodes.length);
        
        nodes = xml.find('.first.second>a');
        Assert.equals(0, nodes.length);
        
        nodes = xml.find('.first.second >a');
        Assert.equals(0, nodes.length);
        
        nodes = xml.find('.second>a');
        Assert.equals(0, nodes.length);
        
        nodes = xml.find('.second a');
        Assert.equals(1, nodes.length);
        
        nodes = xml.find('.first>a');
        Assert.equals(1, nodes.length);
        
        nodes = xml.find('div>p>a');
        Assert.equals(1, nodes.length);
        
        nodes = xml.find('div>a');
        Assert.equals(0, nodes.length);
        
        nodes = xml.find('div>*>a');
        Assert.equals(1, nodes.length);
        
        nodes = xml.find('*');
        Assert.equals(3, nodes.length);
        
        nodes = xml.find('a,p');
        Assert.equals(2, nodes.length);
        
        nodes = xml.find('a , p');
        Assert.equals(2, nodes.length);
        
        nodes = xml.find('a, a');
        Assert.equals(1, nodes.length);
        
		nodes = xml.find('div>p>a[0]');
        Assert.equals(0, nodes.length);
		
		nodes = xml.find('div>p>a[1]');
        Assert.equals(1, nodes.length);
		
		nodes = xml.find('div>p>a[2]');
        Assert.equals(0, nodes.length);
		
		nodes = xml.find('div>p>a[3]');
        Assert.equals(0, nodes.length);
    }

    public function testSiblings()
    {
        var xml = new HtmlDocument("<br />\n        <div id='m'>test</div>");
        var nodes = xml.find("#m");
		
        Assert.equals(1, nodes.length);
		Assert.isTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
        
		var node = nodes[0];
        Assert.equals("m", node.getAttribute('id'));
        
		var prev = node.getPrevSiblingNode();
		Assert.isTrue(Type.getClass(prev) == HtmlNodeText);
        Assert.equals("\n        ", cast(prev, HtmlNodeText).text);
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
		Assert.equals(2, xml.children.length);
        
		var nodes = xml.find("#n");
        Assert.equals(1, nodes.length);
		Assert.isTrue(Type.getClass(nodes[0]) == HtmlNodeElement);
	}
	
	public function testReplaceChildWithInner()
	{
		var xml = new HtmlDocument("b<ph>c</ph>d<con>e</con>");
		
		var nodesPH = xml.find("ph");
		Assert.equals(1, nodesPH.length);
		Assert.equals(0, nodesPH[0].children.length);
		
		var nodesCON = xml.find("con");
		Assert.equals(1, nodesCON.length);
		Assert.equals(0, nodesCON[0].children.length);
		
		xml.replaceChild(nodesPH[0], nodesCON[0].nodes);
		Assert.equals("bed<con>e</con>", xml.innerHTML);
		Assert.equals(1, xml.children.length);
	}
	
	public function testRemove()
	{
		var xml = new HtmlDocument("<a></a><b></b><c></c>");
		Assert.equals(3, xml.children.length);
		Assert.equals(3, xml.nodes.length);
		
		var nodes = xml.find(">b");
		Assert.isTrue(nodes != null);
		Assert.isTrue(nodes.length == 1);
		nodes[0].remove();
		
		Assert.equals(2, xml.children.length);
		Assert.equals(2, xml.nodes.length);
	}
	
	public function testHeader()
	{
		var xml = new HtmlDocument("<?xml version='1.0' encoding='UTF-8'?><doc>abc</doc>");
		Assert.equals(1, xml.children.length);
		Assert.equals(2, xml.nodes.length);
		Assert.isOfType(xml.nodes[0], HtmlNodeText);
		Assert.isOfType(xml.nodes[1], HtmlNodeElement);
	}
	
	public function testNamespacedAttr()
	{
		var xml = new HtmlDocument("<S:Envelope xmlns:S=\"abc\"><S:Body><ns2:OperationHistoryData xmlns:ns2=\"def\"/></S:Body></S:Envelope>");
		Assert.equals(1, xml.children.length);
		Assert.equals(1, xml.nodes.length);
	}
	
	public function testTagCase()
	{
		var xml = new HtmlDocument("<A />");
		
		var r = xml.find("A");
		Assert.equals(1, r.length);
		
		r = xml.find("a");
		Assert.equals(1, r.length);
	}
	
	public function testBadXmlA()
	{
		try
		{
			new HtmlDocument("<root><link></link></root>");
		}
		catch (_:Dynamic)
		{
			Assert.isTrue(true);
			return;
		}
		Assert.isTrue(false);
	}
	
	public function testBoolAttrA()
	{
		var doc = new HtmlDocument("<a><b disabled></b></a>");
		var bb = doc.find(">a>b");
		Assert.equals(1, bb.length);
		Assert.isTrue(bb[0].hasAttribute("disabled"));
		Assert.equals(null, bb[0].getAttribute("disabled"));
	}
	
	public function testBoolAttrB()
	{
		var doc = new HtmlDocument("<a><b disabled new-attr></b></a>");
		var bb = doc.find(">a>b");
		Assert.equals(1, bb.length);
		Assert.isTrue(bb[0].hasAttribute("disabled"));
		Assert.isTrue(bb[0].hasAttribute("new-attr"));
		Assert.equals(null, bb[0].getAttribute("disabled"));
		Assert.equals(null, bb[0].getAttribute("new-attr"));
	}
	
	/*
	#if sys
	public function testSpeed()
    {
        var str = File.getContent('support/input.html');
        var loops = 1000;
        
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
		
		Assert.isTrue(true);
    }
	#end
	*/
}
