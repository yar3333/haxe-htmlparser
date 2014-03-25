#ifndef HTMLNODE_H
#define HTMLNODE_H

#include "common.h"
#include "Serializer.h"
#include "Unserializer.h"
#include "ISerializable.h"

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
	
	//public: void hxSerialize(Serializer &s) = 0;
	//public: void hxUnserialize(Unserializer &s) = 0;
};

#endif