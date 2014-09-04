# HtmlParser haxe library #

Light and fast html/xml parser wich jQuery-like find methods.

### Working with HTML ###
In HTML mode parser ignore DOCTYPE and assume some tags self-closed (for example, <img> parsed as <img />).
```
#!haxe
var html = new HtmlDocument(File.getContent("c:\\myfile.html"));
var titles = html.find(">html>head>title");
trace(titles[0].innerHTML);
titles[0].innerHTML = "My New Title";
File.saveContent("c:\\myfile2.html", html.toString());
```

### Working with XML ###
In XML mode parser is more strict: no self-closed tag allowed.
```
#!haxe
var xml = new XmlDocument(File.getContent("c:\\myfile.xml"));
var contents = xml.find(">root>items>content");
trace(contents[0].innerHTML);
contents[0].innerHTML = "My New Content For First Item";
File.saveContent("c:\\myfile2.xml", xml.toString());
```