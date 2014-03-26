#include "HtmlNodeText.h"

HtmlNodeText::HtmlNodeText(const string &text)
{
	this->text = text;
}

string HtmlNodeText::toString()
{
	return this->text;
}

int HtmlNodeText::getKind()
{
	return HTMLNODE_KIND_TEXT;
}

/*void HtmlNodeText::hxSerialize(Serializer &s)
{
	s.serialize(text);
}

void HtmlNodeText::hxUnserialize(Unserializer &s)
{
	text = s.unserialize();
}
*/