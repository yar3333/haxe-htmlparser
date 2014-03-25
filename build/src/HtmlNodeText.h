#ifndef HTMLNODETEXT_H
#define HTMLNODETEXT_H

#include "common.h"
#include "HtmlNode.h"

class HtmlNodeText : public HtmlNode
{
    public: string text;
    
	public: HtmlNodeText(const string &text);
	public: string toString();
	//public: void hxSerialize(Serializer &s);
	//public: void hxUnserialize(Unserializer &s);
};

#endif