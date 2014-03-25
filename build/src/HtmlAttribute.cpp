#include "HtmlAttribute.h"

HtmlAttribute::HtmlAttribute(const string &name, const string &value, const string &quote)
{
	this->name = name;
	this->value = value;
	this->quote = quote;
}
    
string HtmlAttribute::toString()
{
	return name + "=" + quote + value + quote;
}
