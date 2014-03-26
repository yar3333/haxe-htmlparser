#ifndef HTMLNODE_H
#define HTMLNODE_H

#include "common.h"
#include "Serializer.h"
#include "Unserializer.h"
#include "ISerializable.h"

#define HTMLNODE_KIND_ELEMENT 1
#define HTMLNODE_KIND_TEXT 2

class HtmlNode : public ISerializable
{
	/*
	public: class HtmlNodeElement parent;
    public: void remove();
    public: HtmlNode getPrevSiblingNode();
    public: HtmlNode getNextSiblingNode();
	*/
	
	public: virtual ~HtmlNode();

	public: virtual string toString() = 0;
	
	public: virtual int getKind() = 0;
	
	//public: void hxSerialize(Serializer &s) = 0;
	//public: void hxUnserialize(Unserializer &s) = 0;
};

#endif