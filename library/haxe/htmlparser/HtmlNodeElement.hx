package haxe.htmlparser;

import haxe.Serializer;
import haxe.Unserializer;

class HtmlNodeElement extends HtmlNode
{
    public var name : String;
    public var attributes : Array<HtmlAttribute>;
    public var nodes : Array<HtmlNode>;
    public var children : Array<HtmlNodeElement>;
    
    public function getPrevSiblingElement() : HtmlNodeElement
    {
        if (parent == null) return null;
        var n = indexOf(parent.children, this);
        if (n < 0) return null;
        if (n > 0) return parent.children[n - 1];
        return null;
    }

    public function getNextSiblingElement() : HtmlNodeElement
    {
        if (parent == null) return null;
        var n = indexOf(parent.children, this);
        if (n < 0) return null;
        if (n + 1 < parent.children.length) return parent.children[n + 1];
        return null;
    }
    
	public function new(name:String, attributes:Array<HtmlAttribute>)
    {
        this.name = name;
        this.attributes = attributes;
        this.nodes = [];
        this.children = [];
    }

    public function addChild(node:HtmlNode, beforeNode:HtmlNode=null) : Void
    {
        node.parent = this;
        
		if (beforeNode == null)
        {
            nodes.push(node);
            if (Type.getClass(node) == HtmlNodeElement)
            {
                children.push(cast(node, HtmlNodeElement));
            }
        }
        else
        {
            var n = indexOf(nodes, beforeNode);
            if (n >= 0)
            {
                nodes.insert(n, node);
                if (Type.getClass(node) == HtmlNodeElement)
                {
                    n = indexOf(children, beforeNode);
                    if (n >= 0)
                    {
                        children.insert(n, cast(node, HtmlNodeElement));
                    }
                }
            }
        }
    }
	
	public override function toString() : String
    {
		return toStringWithSelfClosingTags(HtmlParser.SELF_CLOSING_TAGS_HTML);
    }
	
    inline function toStringWithSelfClosingTags(selfClosingTags:Dynamic) : String
	{
        var sAttrs = new StringBuf();
		for (a in attributes)
		{
			sAttrs.add(" ");
			sAttrs.add(a.toString());
		}
        
        if (nodes.length == 0 && (Reflect.hasField(selfClosingTags, name) || name.indexOf(':') >= 0))
		{
			return "<" + name + sAttrs.toString() + " />";
		}
		
		var sChildren = new StringBuf();
		for (node in nodes)
		{
			sChildren.add(node.toString());
		}
		
        return name != null && name != ''
            ? "<" + name + sAttrs.toString() + ">" + sChildren.toString() + "</" + name + ">"
            : sChildren.toString();
		
	}
	
	public function getAttribute(name:String) : String
	{
		var nameLC = name.toLowerCase();
		
		for (a in attributes)
		{
			if (a.name.toLowerCase() == nameLC) return a.value;
		}
		
		return null;
	}

    public function setAttribute(name:String, value:String)
    {
		var nameLC = name.toLowerCase();
		
		for (a in attributes)
		{
			if (a.name.toLowerCase() == nameLC)
			{
				a.value = value;
				return;
			}
		}
        
        attributes.push(new HtmlAttribute(name, value, '"'));
    }

    public function removeAttribute(name:String)
    {
		var nameLC = name.toLowerCase();
		
		for (i in 0...attributes.length)
		{
			var a = attributes[i];
			if (a.name.toLowerCase() == nameLC)
			{
				attributes.splice(i, 1);
				return;
			}
		}
    }

    public function hasAttribute(name:String) : Bool
    {
		var nameLC = name.toLowerCase();
		
		for (a in attributes)
		{
			if (a.name.toLowerCase() == nameLC) return true;
		}
		
		return false;
    }
    
    public var innerHTML(get_innerHTML, set_innerHTML) : String;
	
	function set_innerHTML(value:String) : String
	{
		var newNodes = HtmlParser.run(value);
		nodes = [];
		children = [];
		for (node in newNodes) addChild(node);
		return value;
	}
	
	function get_innerHTML() : String
    {
		var r = new StringBuf();
		for (node in nodes)
		{
			r.add(node.toString());
		}
		return r.toString();
    }
    
    public function find(selector:String) : Array<HtmlNodeElement>
    {
        var parsedSelectors : Array<Array<CssSelector>> = HtmlParser.parseCssSelector(selector);

        var resNodes = new Array<HtmlNodeElement>();
        for (s in parsedSelectors)
        {
            for (node in children)
            {
                var nodesToAdd = node.findInner(s);
                for (nodeToAdd in nodesToAdd)
                {
                    if (indexOf(resNodes, nodeToAdd) < 0)
                    {
                        resNodes.push(nodeToAdd);
                    }
                }
            }
        }
        return resNodes;
    }
    
    private function findInner(selectors:Array<CssSelector>) : Array<HtmlNodeElement>
    {
        if (selectors.length == 0)
		{
			return [];
		}
        
        var nodes = [];
        if (selectors[0].type == ' ') 
        {
            for (child in children) 
            {
                nodes = nodes.concat(child.findInner(selectors));
            }
        }
		
        if (isSelectorTrue(selectors[0]))
        {
            if (selectors.length == 1)
            {
                if (this.parent != null)
				{
					nodes.push(this);
				}

            }
            else
            {
                selectors.shift();
                for (child in children) 
                {
                    nodes = nodes.concat(child.findInner(selectors));
                }                    
            }
        }
        return nodes;
    }
    
    private function isSelectorTrue(selector:CssSelector)
    {
        for (tag in selector.tags) if (this.name.toLowerCase() != tag) return false;
        for (id in selector.ids) if (this.getAttribute('id') != id) return false;
        for (clas in selector.classes) 
		{
			var reg = new EReg("(?:^|\\s)" + clas + "(?:$|\\s)", "");
            var classAttr = getAttribute("class");
			if (classAttr == null || !reg.match(classAttr)) return false;
		}
        return true;
    }
    
    public function replaceChild(node:HtmlNodeElement, newNode:HtmlNode)
    {
		newNode.parent = this;
        
        for (i in 0...nodes.length)
        {
            if (nodes[i] == node)
            {
                nodes[i] = newNode;
                break;
            }
        }
        
        var newNodeClass = Type.getClass(newNode);
		for (i in 0...children.length)
        {
            if (children[i] == node)
            {
                if (newNodeClass == HtmlNodeElement)
				{
					children[i] = cast(newNode, HtmlNodeElement);
				}
				else
				{
					children.splice(i, 1);
				}
                break;
            }
        }
    }
    
    public function replaceChildWithInner(node:HtmlNodeElement,  nodeContainer:HtmlNodeElement)
    {
        for (n in nodeContainer.nodes)
		{
			n.parent = this;
		}
        
        for (i in 0...nodes.length)
        {
            if (nodes[i] == node)
            {
				var lastNodes = nodes.slice(i + 1, nodes.length);
				nodes = (i != 0 ? nodes.slice(0, i) : []).concat(nodeContainer.nodes).concat(lastNodes);
                break;
            }
        }
        
        for (i in 0...children.length)
        {
            if (children[i] == node)
            {
				var lastChildren = children.slice(i + 1, children.length);
				children = (i != 0 ? children.slice(0, i) : []).concat(nodeContainer.children).concat(lastChildren);
                break;
            }
        }
    }
	
	public function removeChild(node:HtmlNode)
    {
        var n = indexOf(nodes, node);
        if (n >= 0) 
        {
            nodes.splice(n, 1);
			if (Type.getClass(node) == HtmlNodeElement)
			{
				n = indexOf(children, node);
				if (n >= 0 )
				{
					children.splice(n, 1);
				}
			}
        }
    }
	
    public function getAttributesAssoc() : Map<String, String>
    {
        var attrs = new Map();
        for (attr in attributes)
        {
            attrs.set(attr.name, attr.value); 
        }
        return attrs;
    }
	
    public function getAttributesObject() : Dynamic<String>
    {
        var attrs = {};
        for (attr in attributes)
        {
            Reflect.setField(attrs, attr.name, attr.value);
        }
        return attrs;
    }

    public function setInnerText(text) : Void
    {
        nodes = [];
        children = [];
        addChild(new HtmlNodeText(text));
    }
	
	override function hxSerialize(s:Serializer)
	{
		s.serialize(name);
		s.serialize(attributes);
		s.serialize(nodes);
	}
	
	override function hxUnserialize(s:Unserializer) 
	{
		name = s.unserialize();
		attributes = s.unserialize();
		
		nodes = [];
		children = [];
		var ns : Array<HtmlNode> = s.unserialize();
		for (n in ns)
		{
			addChild(n);
		}
    }
	
	static function indexOf(array:Array<Dynamic>, item:Dynamic) : Int
	{
		for (i in 0...array.length)
		{
			if (array[i] == item) return i;
		}
		return -1;
	}
}
