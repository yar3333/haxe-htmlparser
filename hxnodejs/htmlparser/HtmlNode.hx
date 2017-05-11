package htmlparser;

@:jsRequire("haxelib/hxnodejs-htmlparser", "HtmlNode") extern class HtmlNode
{
	var parent : htmlparser.HtmlNodeElement;
	function remove() : Void;
	function getPrevSiblingNode() : htmlparser.HtmlNode;
	function getNextSiblingNode() : htmlparser.HtmlNode;
	function toString() : String;
	function toText() : String;
	private function hxSerialize(s:{ function serialize(d:Dynamic) : Void; }) : Void;
	private function hxUnserialize(s:{ function unserialize() : Dynamic; }) : Void;
}