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
	protected: static EReg reMain;
	protected: static EReg reParseAttrs;
    
	public: static vector<const char *> selfClosingTags;
	public: static vector<shared_ptr<HtmlNode>> parse(const char *str);
	
	protected: static vector<shared_ptr<HtmlNode>> parseInner(const char *str, vector<HtmlLexem> &matches, int &i);
    protected: static shared_ptr<HtmlNodeElement> parseElement(const char *str, vector<HtmlLexem> &matches, int &i);

    protected: static vector<HtmlAttribute> parseAttrs(const char *str);
    public:    static vector<vector<CssSelector>> parseCssSelector(string &selector);
    protected: static vector<CssSelector> parseCssSelectorInner(string &selector);
};

#endif