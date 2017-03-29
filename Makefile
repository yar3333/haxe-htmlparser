PACKAGE = htmlparser
LIBRARY = htmlparser

SRC_DIR = library
HXNODEJS_DEST_DIR = hxnodejs
NODE_MOD_DEST_DIR = node_module

HXFLAGS = -lib stdlib

build:	build-hxnodejs \
		build-node-module

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
build-hxnodejs:	$(HXNODEJS_DEST_DIR)/$(PACKAGE) \
				$(HXNODEJS_DEST_DIR)/$(PACKAGE)/XmlAttribute.hx \
				$(HXNODEJS_DEST_DIR)/$(PACKAGE)/XmlNode.hx \
				$(HXNODEJS_DEST_DIR)/$(PACKAGE)/XmlNodeText.hx

$(HXNODEJS_DEST_DIR)/$(PACKAGE):	$(SRC_DIR)/**
	haxe \
		-cp $(SRC_DIR) \
		-D js-es5 \
		$(HXFLAGS) \
		-js dummy.js \
		-lib codegen \
		--macro "CodeGen.set('outPath', '$(HXNODEJS_DEST_DIR)')" \
		--macro "CodeGen.set('applyNatives', false)" \
		--macro "CodeGen.include('$(PACKAGE)')" \
		--macro "CodeGen.set('includePrivate', true)" \
		--macro "CodeGen.set('requireNodeModule', '$(LIBRARY)')" \
		--macro "CodeGen.generate('haxeExtern')" \
		--macro "include('$(PACKAGE)')"

$(HXNODEJS_DEST_DIR)/%.hx: $(SRC_DIR)/%.hx
	cp $< $@
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
build-node-module:  $(NODE_MOD_DEST_DIR)/index.js \
					$(NODE_MOD_DEST_DIR)/index.d.ts

$(NODE_MOD_DEST_DIR)/index.js: $(SRC_DIR)/**
	haxe \
		-cp $(SRC_DIR) \
		-D js-es5 \
		$(HXFLAGS) \
		-js $@ \
		-lib stdlib --macro "stdlib.Macro.expose('$(PACKAGE)','')" \
		--macro "include('$(PACKAGE)')"
			
$(NODE_MOD_DEST_DIR)/index.d.ts: $(SRC_DIR)/**
	haxe \
		-cp $(SRC_DIR) \
		-D js-es5 \
		$(HXFLAGS) \
		-js dummy.js \
		-lib codegen \
		--macro "CodeGen.set('outPath', '$@')" \
		--macro "CodeGen.set('applyNatives', false)" \
		--macro "CodeGen.include('$(PACKAGE)')" \
		--macro "CodeGen.set('includePrivate', true)" \
		--macro "CodeGen.map('$(PACKAGE)', '')" \
		--macro "CodeGen.generate('typescriptExtern')" \
		--macro "include('$(PACKAGE)')"
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.PHONY = build-hxnodejs build-node-module
