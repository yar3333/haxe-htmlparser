#ifndef HTMLATTRUBUTE_H
#define HTMLATTRUBUTE_H

#include "common.h"

class HtmlAttribute
{
    public: string name;
    public: string value;
    public: string quote;

    public: HtmlAttribute(const string &name, const string &value, const string &quote);
    
	public: string toString();
};

#endif