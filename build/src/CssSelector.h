#ifndef CSSSELECTOR_H
#define CSSSELECTOR_H

#include "common.h"

struct CssSelector
{
	string type;
	vector<string> tags;
	vector<string> ids; 
	vector<string> classes;
};

#endif