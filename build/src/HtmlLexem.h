#ifndef HTMLLEXEM_H
#define HTMLLEXEM_H

#include "common.h"

struct HtmlLexem
{
	string all;
	int allPos;
	string script;
	string scriptAttrs;
	string scriptText;
	string style;
	string styleAttrs;
	string styleText;
	string elem;
	string tagOpen;
	string attrs;
	string tagEnd;
	string close;
	string tagClose;
	string comment;
};

#endif