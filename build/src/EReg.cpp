#include "EReg.h"

EReg::EReg(const string &re, const string &options)
{
	this->re = re;
	this->options = options;
}

BOOL EReg::matchSub(const string &str, int pos)
{
	return FALSE;
}

ERegPos EReg::matchedPos()
{
	ERegPos r;
	r.len = 0;
	r.pos = 0;
	return r;
}

string EReg::matched(int n)
{
	return "";
}

vector<string> EReg::split(const string &sep)
{
	return vector<string>();
}

BOOL EReg::match(const string &str)
{
	return FALSE;
}

string EReg::matchedRight()
{
	return "";
}
