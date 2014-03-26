#ifndef EREG_H
#define	EREG_H

#include <boost/regex.hpp>

using namespace std;

struct ERegPos
{
	int pos;
	int len;
};

class EReg
{
	protected: boost::regex re;
	protected: boost::cmatch matches;
	protected: int startPos;
	
	public: EReg(const string re, const string options);
	
	public: bool match(const char *str);
	public: bool matchSub(const char *str, int pos);
	public: ERegPos matchedPos();
	public: string matched(int n);
	public: vector<string> split(const char *str);
	public: string matchedLeft();
	public: string matchedRight();
};

#endif	/* EREG_H */

