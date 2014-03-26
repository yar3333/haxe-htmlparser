#include <string>

#include "EReg.h"

EReg::EReg(const string restr, const string options)
	: re(restr, options.find("i") != string::npos ? boost::regex_constants::icase : 0)
{
}

bool EReg::match(const char *str)
{
	startPos = 0;
	return regex_search(str, matches, re);
}

bool EReg::matchSub(const char *str, int pos)
{
	startPos = pos;
	return regex_search(str + pos, matches, re);
}

ERegPos EReg::matchedPos()
{
	ERegPos r;
	r.len = matches.length();
	r.pos = startPos + matches.position();
	return r;
}

string EReg::matched(int n)
{
	return matches[n];
}

vector<string> EReg::split(const char *str)
{
	vector<string> r;
	while (regex_search(str, matches, re))
	{
		r.push_back(matches.prefix());
		str += matches.position() + matches.length();
	}
	r.push_back(string(str));
	return r;
}

string EReg::matchedLeft()
{
	return matches.prefix();
}

string EReg::matchedRight()
{
	return matches.suffix();
}
