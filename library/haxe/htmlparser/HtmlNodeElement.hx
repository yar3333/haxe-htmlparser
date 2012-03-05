package haxe.htmlparser;

import haxe.Serializer;
import haxe.Unserializer;

class HtmlNodeElement extends HtmlNode
{
    public var name : String;
    private var attributes : Hash<HtmlAttribute>;
    public var nodes : Array<HtmlNode>;
    public var children : Array<HtmlNodeElement>;
    
    public function getPrevSiblingElement() : HtmlNodeElement
    {
        if (parent == null) return null;
        var n = Lambda.indexOf(parent.children, this);
        if (n < 0) return null;
        if (n > 0) return parent.children[n - 1];
        return null;
    }

    public function getNextSiblingElement() : HtmlNodeElement
    {
        if (parent == null) return null;
        var n = Lambda.indexOf(parent.children, this);
        if (n < 0) return null;
        if (n + 1 < parent.children.length) return parent.children[n + 1];
        return null;
    }
    
	public function new(name:String, attributes:Hash<HtmlAttribute>)
    {
        this.name = name;
        this.attributes = attributes;
        this.nodes = [];
        this.children = [];
    }

    public function addChild(node:HtmlNode, beforeNode=null) : Void
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
            var n = Lambda.indexOf(nodes, beforeNode);
            if (n >= 0)
            {
                nodes.insert(n, node);
                if (Type.getClass(node) == HtmlNodeElement)
                {
                    n = Lambda.indexOf(children, cast(beforeNode, HtmlNodeElement));
                    if (n >= 0)
                    {
                        children.insert(n, cast(node, HtmlNodeElement));
                    }
                }
            }
        }
    }

    public override function toString() 
    {
        var sAttrs = Lambda.fold(attributes, function(a, s) return s + " " + a.toString(), "");
        
        if (nodes.length == 0 && (Reflect.hasField(HtmlParser.selfClosingTags, name) || name.indexOf(':') >= 0))
		{
			return "<" + name + sAttrs + " />";
		}
		
		var sChildren = "";
		for (node in nodes)
		{
			sChildren += node.toString();
		}
		
        return name != null && name != ''
            ? "<" + name + sAttrs + ">" + sChildren + "</" + name + ">"
            : sChildren;
    }

	public function getAttribute(name:String) : String
	{
		var a = attributes.get(name.toLowerCase());
		return a != null ? a.value : null;
	}

    public function setAttribute(name:String, value:String)
    {
        if (hasAttribute(name))
        {
			attributes.get(name.toLowerCase()).value = value;
        }
        else
        {
            attributes.set(name.toLowerCase(), new HtmlAttribute(name, value, '"'));
        }
    }

    public function removeAttribute(name:String)
    {
		attributes.remove(name);
    }

    public function hasAttribute(name:String) : Bool
    {
        return attributes.exists(name.toLowerCase());
    }
    
    public var innerHTML(innerHTML_getter, innerHTML_setter) : String;
	
	function innerHTML_setter(value:String) : String
	{
		nodes = HtmlParser.parse(value);
		this.nodes = [];
		this.children = [];
		for (node in nodes) this.addChild(node);
		return value;
	}
	
	function innerHTML_getter() : String
    {
        return Lambda.fold(nodes, function(node, s) return s + node.toString(), "");
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
                    if (!Lambda.has(resNodes, nodeToAdd))
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
        for (tag in selector.tags) if (this.name != tag) return false;
        for (id in selector.ids) if (this.getAttribute('id') != id) return false;
        for (clas in selector.classes) 
		{
			var reg = new EReg("(?:^|\\s)" + clas + "(?:$|\\s)", "");
            if (!reg.match(getAttribute('class'))) return false;
		}
        return true;
    }
    
    public function replaceChild(node:HtmlNodeElement, newNode:HtmlNode)
    {
		//newNode = Unserializer.run(newNode.serialize());
        
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
        //nodeContainer : HtmlNodeElement = Unserializer.run(nodeContainer.serialize());
        
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
        var n = Lambda.indexOf(nodes, node);
        if (n >= 0) 
        {
            nodes.splice(n, 1);
			if (Type.getClass(node) == HtmlNodeElement)
			{
				n = Lambda.indexOf(children, cast(node, HtmlNodeElement));
				if (n >= 0 )
				{
					children.splice(n, 1);
				}
			}
        }
    }
    
    public function getAttributesAssoc() : Hash<String>
    {
        var attrs = new Hash<String>();
        for (attr in attributes)
        {
            attrs.set(attr.name, attr.value); 
        }
        return attrs;
    }

    public function setInnerText(text) : Void
    {
        this.nodes = [];
        this.children = [];
        this.addChild(new HtmlNodeText(text));
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
}
