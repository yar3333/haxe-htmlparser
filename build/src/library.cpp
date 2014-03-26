#include "common.h"
#include "HtmlParser.h"
#include "HtmlNodeText.h"
#include "nekotools.h"

value nodeToObject(shared_ptr<HtmlNode> node)
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
				auto name = element->name.c_str();
				alloc_field(o, val_id("name"), alloc_string(name));
			}
			break;
	}
	
	return o;
}

value nodeVectorToArray(vector<shared_ptr<HtmlNode>> v)
{
	cout << "nodeVectorToArray v.size() = " << v.size() << endl;
	
	value r = alloc_array(v.size());
	value *p = getArrayPtr(r);
	for (auto item : v)
	{
		*p = nodeToObject(item);
		p++;
	}
	return r;
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
