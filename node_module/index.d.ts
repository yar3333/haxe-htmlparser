export class CssSelector
{
	private constructor(type:string);
	type : string;
	tagNameLC : string;
	id : string;
	classes : string[];
	index : number;
	private static reID : string;
	private static reNamespacedID : string;
	private static reSelector : string;
	static parse(selector:string) : CssSelector[][];
	private static parseInner(selector:string) : CssSelector[];
}

export class HtmlAttribute
{
	constructor(name:string, value:string, quote:string);
	name : string;
	value : string;
	quote : string;
	toString() : string;
}

export class HtmlNode
{
	parent : HtmlNodeElement;
	remove() : void;
	getPrevSiblingNode() : HtmlNode;
	getNextSiblingNode() : HtmlNode;
	toString() : string;
	toText() : string;
	private hxSerialize(s:{ serialize(d:any) : void; }) : void;
	private hxUnserialize(s:{ unserialize() : any; }) : void;
}

export class HtmlNodeElement extends htmlparser.HtmlNode
{
	constructor(name:string, attributes:HtmlAttribute[]);
	name : string;
	attributes : HtmlAttribute[];
	nodes : HtmlNode[];
	children : HtmlNodeElement[];
	getPrevSiblingElement() : HtmlNodeElement;
	getNextSiblingElement() : HtmlNodeElement;
	addChild(node:HtmlNode, beforeNode?:HtmlNode) : void;
	addChildren(nodesToAdd:HtmlNode[], beforeNode?:HtmlNode) : void;
	toString() : string;
	getAttribute(name:string) : string;
	setAttribute(name:string, value:string) : void;
	removeAttribute(name:string) : void;
	hasAttribute(name:string) : boolean;
	get_innerHTML() : string
 	set_innerHTML(v:string) : string;
	private get_innerHTML() : string;
	private set_innerHTML(value:string) : string;
	get_innerText() : string
 	set_innerText(v:string) : string;
	private get_innerText() : string;
	private set_innerText(text:string) : string;
	/**
	 * Replace all inner nodes to the text node w/o escaping and parsing.
	 */
	fastSetInnerHTML(html:string) : void;
	toText() : string;
	find(selector:string) : HtmlNodeElement[];
	private findInner(selectors:CssSelector[]) : HtmlNodeElement[];
	private isSelectorTrue(selector:CssSelector) : boolean;
	replaceChild(node:HtmlNodeElement, newNode:HtmlNode) : void;
	replaceChildWithInner(node:HtmlNodeElement, nodeContainer:HtmlNodeElement) : void;
	removeChild(node:HtmlNode) : void;
	getAttributesAssoc() : Map<string, string>;
	getAttributesObject() : any;
	private isSelfClosing() : boolean;
	private hxSerialize(s:{ serialize(d:any) : void; }) : void;
	private hxUnserialize(s:{ unserialize() : any; }) : void;
}

export class HtmlDocument extends htmlparser.HtmlNodeElement
{
	constructor(str?:string, tolerant?:boolean);
}

export class HtmlNodeText extends htmlparser.HtmlNode
{
	constructor(text:string);
	text : string;
	toString() : string;
	toText() : string;
	private hxSerialize(s:{ serialize(d:any) : void; }) : void;
	private hxUnserialize(s:{ unserialize() : any; }) : void;
}

export class HtmlParser
{
	private constructor();
	private tolerant : boolean;
	private matches : HtmlLexem[];
	private str : string;
	private i : number;
	parse(str:string, tolerant?:boolean) : HtmlNode[];
	private processMatches(openedTagsLC:string[]) : { closeTagLC : string; nodes : HtmlNode[]; };
	private parseElement(openedTagsLC:string[]) : { closeTagLC : string; element : HtmlNodeElement; };
	private isSelfClosingTag(tag:string) : boolean;
	private newElement(name:string, attributes:HtmlAttribute[]) : HtmlNodeElement;
	private getPosition(matchIndex:number) : { column : number; length : number; line : number; };
	static SELF_CLOSING_TAGS_HTML : any;
	private static reID : string;
	private static reNamespacedID : string;
	private static reCDATA : string;
	private static reScript : string;
	private static reStyle : string;
	private static reElementOpen : string;
	private static reAttr : string;
	private static reElementEnd : string;
	private static reElementClose : string;
	private static reComment : string;
	private static reMain : EReg;
	private static reParseAttrs : EReg;
	static run(str:string, tolerant?:boolean) : HtmlNode[];
	private static parseAttrs(str:string) : HtmlAttribute[];
}

export class HtmlParserException
{
	constructor(message:string, pos:{ column : number; length : number; line : number; });
	message : string;
	line : number;
	column : number;
	length : number;
	toString() : string;
}

export class HtmlParserTools
{
	static getAttr(node:HtmlNodeElement, attrName:string, defaultValue?:any) : any;
	static getAttrString(node:HtmlNodeElement, attrName:string, defaultValue?:string) : string;
	static getAttrInt(node:HtmlNodeElement, attrName:string, defaultValue?:number) : number;
	static getAttrFloat(node:HtmlNodeElement, attrName:string, defaultValue?:number) : number;
	static getAttrBool(node:HtmlNodeElement, attrName:string, defaultValue?:boolean) : boolean;
	static findOne(node:HtmlNodeElement, selector:string) : HtmlNodeElement;
	private static parseValue(value:string, defaultValue?:any) : any;
}

export class HtmlTools
{
	private static get_htmlUnescapeMap() : Map<string, string>;
	private static get_htmlUnescapeMap() : Map<string, string>;
	static escape(text:string, chars?:string) : string;
	static unescape(text:string) : string;
}

type XmlAttribute = HtmlAttribute;

export class XmlBuilder
{
	constructor(indent?:string, newLine?:string);
	private indent : string;
	private newLine : string;
	private cur : XmlNodeElement;
	private level : number;
	xml : XmlDocument;
	begin(tag:string, attrs?:{ value : any; name : string; }[]) : XmlBuilder;
	end() : XmlBuilder;
	attr(name:string, value:any, defValue?:any) : XmlBuilder;
	content(s:string) : XmlBuilder;
	toString() : string;
}

export class XmlNodeElement extends htmlparser.HtmlNodeElement
{
	constructor(name:string, attributes:HtmlAttribute[]);
	private isSelfClosing() : boolean;
	private set_innerHTML(value:string) : string;
}

export class XmlDocument extends htmlparser.XmlNodeElement
{
	constructor(str?:string);
}

type XmlNode = HtmlNode;

type XmlNodeText = HtmlNodeText;

export class XmlParser extends htmlparser.HtmlParser
{
	private constructor();
	private isSelfClosingTag(tag:string) : boolean;
	private newElement(name:string, attributes:HtmlAttribute[]) : XmlNodeElement;
	static run(str:string) : HtmlNode[];
}