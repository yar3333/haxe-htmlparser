#ifndef EREG_H
#define	EREG_H

#include "common.h"

struct ERegPos
{
	int pos;
	int len;
};

class EReg
{
	protected: string re;
	protected: string options;
	
	public: EReg(const string &re, const string &options);
	
	public: BOOL matchSub(const string &str, int pos);
	public: ERegPos matchedPos();
	public: string matched(int n);
	public: vector<string> split(const string &sep);
	public: BOOL match(const string &str);
	public: string matchedRight();


};

#endif	/* EREG_H */

