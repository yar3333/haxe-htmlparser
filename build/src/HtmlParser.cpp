#include "HtmlParser.h"
#include "HtmlNodeText.h"

#define RE_ID				"[a-z](?:-?[_a-z0-9])*"
#define RE_NAMESPACED_ID	RE_ID "(?::" RE_ID ")?"
#define RE_SCRIPT			"[<]\\s*script\\s*([^>]*)>([\\s\\S]*?)<\\s*/\\s*script\\s*>"
#define RE_STYLE			"<\\s*style\\s*([^>]*)>([\\s\\S]*?)<\\s*/\\s*style\\s*>"
#define RE_ELEMENT_OPEN		"<\\s*(" RE_NAMESPACED_ID ")"
#define RE_ATTR				RE_NAMESPACED_ID "\\s*=\\s*(?:'[^']*'|\"[^\"]*\"|[-_a-z0-9]+)"
#define RE_ELEMENT_END		"(/)?\\s*>"
#define RE_ELEMENT_CLOSE	"<\\s*/\\s*(" RE_NAMESPACED_ID ")\\s*>"
#define RE_COMMENT			"<!--[\\s\\S]*?-->"

vector<const char *> HtmlParser::selfClosingTags = { "img","br","input","meta","link","hr","base","embed","spacer","source" };
	
string itoa(int n)
{
	stringstream ss;
	ss << n;
	return ss.str();	
}

string strToLowerCase(string s)
{
	std::locale loc;
	
	auto r = s;
	//transform(r.begin(), r.end(), r.begin(), tolower);
	r = tolower(r, locale());
	return r;
}

EReg HtmlParser::reMain("(" RE_SCRIPT ")|(" RE_STYLE ")|(" RE_ELEMENT_OPEN "((?:\\s+" RE_ATTR ")*)\\s*" RE_ELEMENT_END ")|(" RE_ELEMENT_CLOSE ")|(" RE_COMMENT ")", "i");
EReg HtmlParser::reParseAttrs("(" RE_ID ")\\s*=\\s*('[^']*'|\"[^\"]*\"|[-_a-z0-9]+)" , "i");

vector<shared_ptr<HtmlNode>> HtmlParser::parse(const char *str)
{
	cout << "HtmlParser::parse" << endl;
	
	vector<HtmlLexem> matches;
	
	auto pos = 0; while (*(str+pos) && reMain.matchSub(str, pos))
	{
		cout << "str+pos = " << str+pos << endl;
		
		auto p = reMain.matchedPos();
		
		HtmlLexem r;
		r.all = reMain.matched(0);
		r.allPos = p.pos;
		r.script = reMain.matched(1);
		r.scriptAttrs = reMain.matched(2);
		r.scriptText = reMain.matched(3);
		r.style = reMain.matched(4);
		r.styleAttrs = reMain.matched(5);
		r.styleText = reMain.matched(6);
		r.elem = reMain.matched(7);
		r.tagOpen = reMain.matched(8);
		r.attrs = reMain.matched(9);
		r.tagEnd = reMain.matched(10);
		r.close = reMain.matched(11);
		r.tagClose = reMain.matched(12);
		r.comment = reMain.matched(13);
		
		matches.push_back(r);
		
		pos = p.pos + p.len;
	}
	
	if (matches.size() > 0)
	{
		auto i = 0;
		auto nodes =  parseInner(str,  matches, i);
		if (i < matches.size())
		{
			throw string("Error parsing XML at ") + itoa(i) + ":\n" + str;
		}
		return nodes;
	}
	
	if (str != "")
	{
		shared_ptr<HtmlNode> p(make_shared<HtmlNodeText>(str));
		vector<shared_ptr<HtmlNode>> r = { p };
		return r;
	}
	
	return vector<shared_ptr<HtmlNode>>();
}

vector<shared_ptr<HtmlNode>> HtmlParser::parseInner(const char *str, vector<HtmlLexem> &matches, int &i)
{
	vector<shared_ptr<HtmlNode>> nodes;
	
	auto prevEnd = i > 0 ? matches[i - 1].allPos + matches[i - 1].all.length() : 0;
	auto curStart = matches[i].allPos;
	
	if (prevEnd < curStart)
	{
		nodes.push_back(make_shared<HtmlNodeText>(string(str + prevEnd, curStart - prevEnd)));
	}

	while (i < matches.size())
	{
		auto m = matches[i];
		
		if (m.elem != "")
		{
			nodes.push_back(parseElement(str, matches, i));
		}
		else
		if (m.script != "")
		{
			auto scriptNode = make_shared<HtmlNodeElement>("script", parseAttrs(m.scriptAttrs.c_str()));
			scriptNode->addChild(make_shared<HtmlNodeText>(m.scriptText));
			nodes.push_back(scriptNode);
		}
		else
		if (m.style != "")
		{
			auto styleNode = make_shared<HtmlNodeElement>("style", parseAttrs(m.styleAttrs.c_str()));
			styleNode->addChild(make_shared<HtmlNodeText>(m.styleText));
			nodes.push_back(styleNode);
		}
		else
		if (m.close != "") break;
		else
		if (m.comment != "")
		{
			nodes.push_back(make_shared<HtmlNodeText>(m.comment));
		}
		else
		{
			throw "Error";
		}
		
		auto curEnd = matches[i].allPos + matches[i].all.length();
		auto nextStart = i + 1 < matches.size() ? matches[i + 1].allPos : strlen(str);
		if (curEnd < nextStart)
		{
			nodes.push_back(make_shared<HtmlNodeText>(string(str + curEnd, nextStart - curEnd)));
		}
		
		i++;
	}
	
	return nodes;
}

shared_ptr<HtmlNodeElement> HtmlParser::parseElement(const char *str, vector<HtmlLexem> &matches, int &i)
{
	auto tag = matches[i].tagOpen;
	auto attrs = matches[i].attrs;
	auto isWithClose = matches[i].tagEnd != "" || find(selfClosingTags.begin(), selfClosingTags.end(), tag) != selfClosingTags.end();
	
	auto elem = make_shared<HtmlNodeElement>(tag, parseAttrs(attrs.c_str()));
	if (!isWithClose)
	{
		i++;
		auto nodes = parseInner(str, matches, i);
		for (auto &node :  nodes) elem->addChild(node);
		if (matches[i].close == "" || matches[i].tagClose != tag)
		{
			throw("XML parse error: tag <" + tag + "> not closed. ParsedText = \n<pre>" + str + "</pre>\n");
		}
	}

	return elem;
}

vector<HtmlAttribute> HtmlParser::parseAttrs(const char *str)
{
	vector<HtmlAttribute> attributes;

	auto pos = 0; while (*(str+pos) && reParseAttrs.matchSub(str, pos))
	{
		auto name = reParseAttrs.matched(1);
		auto value = reParseAttrs.matched(2);
		auto quote = value.substr(0, 1);
		if (quote == "\"" || quote == "\'")
		{
			value = value.substr(1, value.length() - 2);
		}
		else
		{
			quote = "";
		}
		attributes.push_back(HtmlAttribute(name, value, quote));
		
		auto p = reParseAttrs.matchedPos();
		pos = p.pos + p.len;
	}

	return attributes;
}

vector<vector<CssSelector>> HtmlParser::parseCssSelector(string selector)
{
	EReg reg("\\s*,\\s*", "");
	auto selectors = reg.split(selector.c_str());
	vector<vector<CssSelector>> r;
	for (auto &s : selectors)
	{
		if (s != "")
		{
			r.push_back(parseCssSelectorInner(s));
		}
	}
	return r;
}

vector<CssSelector> HtmlParser::parseCssSelectorInner(string selector)
{
	string reSubSelector("[.#]?"); reSubSelector+=RE_ID; reSubSelector+="(?::"; reSubSelector+=RE_ID; reSubSelector+=")?";
	
	vector<CssSelector> parsedSelectors;
	EReg reg(string("([ >])((?:" + reSubSelector + ")+|[*])"), "i");
	
	auto strSelector = string(" ") + selector;
	while (reg.match(strSelector.c_str()))
	{
		vector<string> tags;
		vector<string> ids;
		vector<string> classes;
		if (reg.matched(2) != "*")
		{
			EReg subreg(reSubSelector, "i");
			auto substr = reg.matched(2);
			while (subreg.match(substr.c_str()))
			{
				auto s = subreg.matched(0);
				if      (s.substr(0, 1) == "#") ids.push_back(s.substr(1));
				else if (s.substr(0, 1) == ".") classes.push_back(s.substr(1));
				else                            tags.push_back(strToLowerCase(s));
				substr = subreg.matchedRight();
			}
		}
		
		CssSelector sel;
		sel.type = reg.matched(1);
		sel.tags = tags; 
		sel.ids = ids;
		sel.classes = classes;
		
		parsedSelectors.push_back(sel);
		
		strSelector = reg.matchedRight();
	}
	return parsedSelectors;
}
