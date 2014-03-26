#ifndef HTMLNODEELEMENT_H
#define HTMLNODEELEMENT_H

#include "common.h"
#include "HtmlNode.h"
#include "HtmlAttribute.h"
#include "CssSelector.h"

class HtmlNodeElement : public HtmlNode
{
    public: string name;
    public: vector<HtmlAttribute> attributes;
    public: vector<shared_ptr<HtmlNode>> nodes;
    
	public: HtmlNodeElement(string name, vector<HtmlAttribute> attributes);
	public: virtual ~HtmlNodeElement();
    public: void addChild(shared_ptr<HtmlNode> node);
    public: virtual string toString();
	public: virtual int getKind();
    
	//public: void hxSerialize(Serializer &s);
	//public: void hxUnserialize(Unserializer &s);
	
	/*public: HtmlNodeElement getPrevSiblingElement();
    public: HtmlNodeElement getNextSiblingElement();
    
	public: string getAttribute(string name);
    public: void setAttribute(string name, string value);
    public: void removeAttribute(string name);
    public: bool hasAttribute(string name);
    
	public: string set_innerHTML(string value);
	public: string get_innerHTML();
    
    public: vector<HtmlNodeElement> find(string selector);
    protected: vector<HtmlNodeElement> findInner(vector<CssSelector> &selectors);
    
    protected: void isSelectorTrue(CssSelector &selector);
    
    public: void replaceChild(HtmlNodeElement node, HtmlNode newNode);
    public: void replaceChildWithInner(HtmlNodeElement node, HtmlNodeElement nodeContainer);
	
	public: void removeChild(HtmlNode node);
	
    public: void setInnerText(string text);*/
};

#endif