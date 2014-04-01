#include "common.h"
#include "HtmlParser.h"
#include "HtmlNodeText.h"
#include "HtmlAttribute.h"
#include "nekotools.h"

value nodeVectorToArray(vector<shared_ptr<HtmlNode>> &v);
value nodeToObject(shared_ptr<HtmlNode> &node);
value attributeVectorToArray(vector<HtmlAttribute> &v);
value attributeToObject(HtmlAttribute &attribute);

value nodeVectorToArray(vector<shared_ptr<HtmlNode>> &v)
{
	//cout << "nodeVectorToArray v.size() = " << v.size() << endl;
	
	value r = alloc_array(v.size());
	value *p = getArrayPtr(r);
	for (auto item : v)
	{
		*p = nodeToObject(item);
		p++;
	}
	return r;
}

value nodeToObject(shared_ptr<HtmlNode> &node)
{
	value o = alloc_object(NULL);
	
	int kind = node->getKind();
	alloc_field(o, val_id("kind"), alloc_int(kind));
	
	switch (kind)
	{
		case HTMLNODE_KIND_TEXT:
			{
				auto textNode = static_pointer_cast<HtmlNodeText>(node);
				auto text = textNode->text.c_str();
				alloc_field(o, val_id("text"), alloc_string(text));
			}
			break;
			
		case HTMLNODE_KIND_ELEMENT:
			{
				auto element = static_pointer_cast<HtmlNodeElement>(node);
				alloc_field(o, val_id("name"), alloc_string(element->name.c_str()));
				alloc_field(o, val_id("attributes"), attributeVectorToArray(element->attributes));
				alloc_field(o, val_id("nodes"), nodeVectorToArray(element->nodes));
			}
			break;
	}
	
	return o;
}

value attributeVectorToArray(vector<HtmlAttribute> &v)
{
	//cout << "attributeVectorToArray v.size() = " << v.size() << endl;
	
	value r = alloc_array(v.size());
	value *p = getArrayPtr(r);
	for (auto &item : v)
	{
		*p = attributeToObject(item);
		p++;
	}
	return r;
}

value attributeToObject(HtmlAttribute &attribute)
{
	value o = alloc_object(NULL);
	alloc_field(o, val_id("name"), alloc_string(attribute.name.c_str()));
	alloc_field(o, val_id("value"), alloc_string(attribute.value.c_str()));
	alloc_field(o, val_id("quote"), alloc_string(attribute.quote.c_str()));
	return o;
}

///////////////////////////////////////////////////////////////////

value htmlparser_parse(value str)
{
	val_check(str, string);
	
	vector<shared_ptr<HtmlNode>> nodes = HtmlParser::parse(val_string(str));
	value r = nodeVectorToArray(nodes);
	return r;
}
DEFINE_PRIM(htmlparser_parse, 1);
