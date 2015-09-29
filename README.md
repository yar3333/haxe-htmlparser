# HtmlParser haxe library #

Light and fast HTML/XML parser with a jQuery-like find() method. Also, contains a helper class to XML creating.

### Parsing HTML ###
In HTML mode parser ignore DOCTYPE and assume some tags self-closed (for example, `<img>` parsed as `<img />`).
```haxe
var html = new HtmlDocument(File.getContent("myfile.html"));
var titles = html.find(">html>head>title");
trace(titles[0].innerHTML);
titles[0].innerHTML = "My New Title";
File.saveContent("myfile2.html", html.toString());
```

### Parsing XML ###
In XML mode parser is more strict: there are no self-closed tags allowed.
```haxe
var xml = new XmlDocument(File.getContent("myfile.xml"));
var contents = xml.find(">root>items>content");
trace(contents[0].innerHTML);
contents[0].innerHTML = "New content for first item";
File.saveContent("myfile2.xml", xml.toString());
```

### XML building ###
```haxe
var doc = new XmlBuilder();
doc.begin("html");
    doc.begin("head");
        doc.begin("title").content("This is a title").end();
        doc.begin"meta")
				.attr("content", "text/html; charset=UTF-8")
				.attr("http-equiv", "content-type")
			.end;
    doc.end();
doc.end();

trace(doc.xml.find(">html>head").length); // direct access to created XmlDocument
trace(doc.toString()); // equals to `doc.xml.toString()`
```