#include "HtmlNodeElement.h"
#include "HtmlParser.h"

HtmlNodeElement::HtmlNodeElement(string name, vector<HtmlAttribute> attributes)
{
	this->name = name;
	this->attributes = attributes;
}

HtmlNodeElement::~HtmlNodeElement()
{
}

void HtmlNodeElement::addChild(shared_ptr<HtmlNode> node)
{
	nodes.push_back(node);
}

string HtmlNodeElement::toString() 
{
	string sAttrs;
	for (vector<HtmlAttribute>::iterator a=attributes.begin(); a<attributes.end(); a++)
	{
		sAttrs += " ";
		sAttrs += a->toString();
	}
	
	if (nodes.size() == 0 && (find(HtmlParser::selfClosingTags.begin(), HtmlParser::selfClosingTags.end(), name) != HtmlParser::selfClosingTags.end() || name.find(':') != string::npos))
	{
		return string("<") + name + sAttrs + " />";
	}
	
	string sChildren;
	for (auto &node : nodes)
	{
		sChildren += node->toString();
	}
	
	return name != ""
		? string("<") + name + sAttrs + ">" + sChildren + "</" + name + ">"
		: sChildren;
}

int HtmlNodeElement::getKind()
{
	return HTMLNODE_KIND_ELEMENT;
}

/*
void HtmlNodeElement::hxSerialize(Serializer &s)
{
	s.serialize(name);
	s.serialize(attributes);
	s.serialize(nodes);
}

void HtmlNodeElement::hxUnserialize(Unserializer &s) 
{
	name = s.unserialize();
	attributes = s.unserialize();
	
	nodes = [];
	children = [];
	vector<HtmlNode> ns = s.unserialize();
	for (n in ns)
	{
		addChild(n);
	}
}*/

/*
HtmlNodeElement HtmlNodeElement::getPrevSiblingElement()
{
	if (parent == NULL) return NULL;
	auto n = indexOf(parent.children, this);
	if (n < 0) return NULL;
	if (n > 0) return parent.children[n - 1];
	return NULL;
}

HtmlNodeElement HtmlNodeElement::getNextSiblingElement()
{
	if (parent == NULL) return NULL;
	auto n = indexOf(parent.children, this);
	if (n < 0) return NULL;
	if (n + 1 < parent.children.length) return parent.children[n + 1];
	return NULL;
}

string HtmlNodeElement::getAttribute(string name)
{
	auto nameLC = name.toLowerCase();
	
	for (a in attributes)
	{
		if (a.name.toLowerCase() == nameLC) return a.value;
	}
	
	return NULL;
}

void HtmlNodeElement::setAttribute(string name, string value)
{
	auto nameLC = name.toLowerCase();
	
	for (a in attributes)
	{
		if (a.name.toLowerCase() == nameLC)
		{
			a.value = value;
			return;
		}
	}
	
	attributes.push_back(new HtmlAttribute(name, value, '"'));
}

void HtmlNodeElement::removeAttribute(string name)
{
	auto nameLC = name.toLowerCase();
	
	for (i in 0...attributes.length)
	{
		auto a = attributes[i];
		if (a.name.toLowerCase() == nameLC)
		{
			attributes.splice(i, 1);
			return;
		}
	}
}

bool HtmlNodeElement::hasAttribute(string name)
{
	auto nameLC = name.toLowerCase();
	
	for (a in attributes)
	{
		if (a.name.toLowerCase() == nameLC) return true;
	}
	
	return false;
}

string HtmlNodeElement::set_innerHTML(string value)
{
	auto newNodes = HtmlParser.parse(value);
	nodes = [];
	children = [];
	for (node in newNodes) addChild(node);
	return value;
}

string HtmlNodeElement::get_innerHTML()
{
	auto r = new StringBuf();
	for (node in nodes)
	{
		r.add(node.toString());
	}
	return r.toString();
}

vector<HtmlNodeElement> HtmlNodeElement::find(string selector)
{
	vector<vector<CssSelector>> parsedSelectors = HtmlParser.parseCssSelector(selector);

	vector<HtmlNodeElement> resNodes;
	for (s in parsedSelectors)
	{
		for (node in children)
		{
			auto nodesToAdd = node.findInner(s);
			for (nodeToAdd in nodesToAdd)
			{
				if (indexOf(resNodes, nodeToAdd) < 0)
				{
					resNodes.push_back(nodeToAdd);
				}
			}
		}
	}
	return resNodes;
}

vector<HtmlNodeElement> HtmlNodeElement::findInner(vector<CssSelector> &selectors)
{
	vector<HtmlNodeElement> nodes;
	
	if (selectors.length == 0) return nodes;
	
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
			if (this->parent != NULL)
			{
				nodes.push_back(this);
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

void HtmlNodeElement::isSelectorTrue(CssSelector selector)
{
	for (tag in selector.tags) if (this->name.toLowerCase() != tag) return false;
	for (id in selector.ids) if (this->getAttribute("id") != id) return false;
	for (clas in selector.classes) 
	{
		auto reg = new EReg("(?:^|\\s)" + clas + "(?:$|\\s)", "");
		auto classAttr = getAttribute("class");
		if (classAttr == NULL || !reg.match(classAttr)) return false;
	}
	return true;
}

void HtmlNodeElement::replaceChild(HtmlNodeElement node, HtmlNode newNode)
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
	
	auto newNodeClass = Type.getClass(newNode);
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

void HtmlNodeElement::replaceChildWithInner(HtmlNodeElement node,  HtmlNodeElement nodeContainer)
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
			auto lastNodes = nodes.slice(i + 1, nodes.length);
			nodes = (i != 0 ? nodes.slice(0, i) : []).concat(nodeContainer.nodes).concat(lastNodes);
			break;
		}
	}
	
	for (i in 0...children.length)
	{
		if (children[i] == node)
		{
			auto lastChildren = children.slice(i + 1, children.length);
			children = (i != 0 ? children.slice(0, i) : []).concat(nodeContainer.children).concat(lastChildren);
			break;
		}
	}
}

void HtmlNodeElement::removeChild(HtmlNode node)
{
	auto n = indexOf(nodes, node);
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

Map<string, string> HtmlNodeElement::getAttributesAssoc()
{
	auto attrs = new Map();
	for (attr in attributes)
	{
		attrs.set(attr.name, attr.value); 
	}
	return attrs;
}

Dynamic<string> HtmlNodeElement::getAttributesObject()
{
	auto attrs = {};
	for (attr in attributes)
	{
		Reflect.setField(attrs, attr.name, attr.value);
	}
	return attrs;
}

void HtmlNodeElement::setInnerText(text)
{
	nodes = [];
	children = [];
	addChild(new HtmlNodeText(text));
}
*/
