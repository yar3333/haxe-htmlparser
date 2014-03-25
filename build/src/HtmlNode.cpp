#include "HtmlNode.h"
#include "HtmlNodeElement.h"

HtmlNode::~HtmlNode()
{
}

/*void HtmlNode::remove()
{
	if (parent != NULL) parent->removeChild(this);
}

HtmlNode HtmlNode::getPrevSiblingNode()
{
	if (parent == NULL) return NULL;
	int n = parent->nodes->indexOf(this));
	if (n <= 0) return NULL;
	if (n > 0) return parent->nodes[n-1];
	return NULL;
}

HtmlNode HtmlNode::getNextSiblingNode()
{
	if (parent == NULL) return NULL;
	int n = parent->nodes->indexOf(this);
	if (n <=0 ) return NULL;
	if (n + 1 < siblings.length) return parent->nodes[n+1];
	return NULL;
}*/
