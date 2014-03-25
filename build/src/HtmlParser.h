#ifndef HTMLPARSER_H
#define HTMLPARSER_H

#include "common.h"
#include "HtmlNode.h"
#include "HtmlNodeElement.h"
#include "CssSelector.h"
#include "EReg.h"
#include "HtmlLexem.h"

class HtmlParser
{
    public: static vector<const char *> selfClosingTags;
	public: static vector<shared_ptr<HtmlNode>> parse(string str);
    
	protected: static EReg reMain;
	protected: static EReg reParseAttrs;
	
	protected: static void getMatched(EReg &re, int n);
	
	protected: static vector<shared_ptr<HtmlNode>> parseInner(string str, vector<HtmlLexem> &matches, int &i);

    protected: static shared_ptr<HtmlNodeElement> parseElement(string str, vector<HtmlLexem> &matches, int &i);

    protected: static vector<HtmlAttribute> parseAttrs(string str);
    
    public: static vector<vector<CssSelector>> parseCssSelector(string &selector);
    
    protected: static vector<CssSelector> parseCssSelectorInner(string &selector);
};

#endif