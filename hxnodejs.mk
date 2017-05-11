##################################################################
# inputs:
#-----------------------------------------------------------------
#	PACKAGE - haxe source package
#	NODEJS_MODULE - dest nodejs module name
#	SRC_DIR - haxe source directory
#	NODEJS_EXTERN_COPY_MODULES - classes to copy to extern as is
#	DEST_DIR = nodejs - dest directory for haxe extern & index.js/indes.d.ts
#	HXFLAGS = read from *.hxproj - haxe compiler options
##################################################################

DEST_DIR = hxnodejs

HXFLAGS = $(shell haxelib run hant compiler-options)

build:	nodejs-extern \
		nodejs-module

##################################################################

ALL_SOURCES := $(shell /bin/find $(shell haxelib run hant path))

.PHONY: build nodejs-extern nodejs-module

.SUFFIXES:

##################################################################

NODEJS_EXTERN_PACK_DIR = $(DEST_DIR)/$(subst .,/,$(PACKAGE))

nodejs-extern: $(NODEJS_EXTERN_PACK_DIR) \
			   $(addsuffix .hx,$(addprefix $(DEST_DIR)/,$(subst .,/,$(NODEJS_EXTERN_COPY_MODULES))))

$(NODEJS_EXTERN_PACK_DIR): $(ALL_SOURCES)
	rm -rf $@
	haxe \
		-cp $(SRC_DIR) \
		-D js-es5 \
		$(HXFLAGS) \
		-js dummy.js \
		-lib codegen \
		--macro "CodeGen.set('outPath', '$(DEST_DIR)')" \
		--macro "CodeGen.set('applyNatives', false)" \
		--macro "CodeGen.include('$(PACKAGE)')" \
		--macro "CodeGen.exclude('$(NODEJS_EXTERN_COPY_MODULES)')" \
		--macro "CodeGen.set('includePrivate', true)" \
		--macro "CodeGen.set('requireNodeModule', '$(NODEJS_MODULE)')" \
		--macro "CodeGen.generate('haxeExtern')" \
		--macro "include('$(PACKAGE)')"

$(DEST_DIR)/%.hx: $(SRC_DIR)/%.hx
	cp $< $@

##################################################################

nodejs-module: $(DEST_DIR)/index.js \
			   $(DEST_DIR)/index.d.ts

$(DEST_DIR)/index.js: $(ALL_SOURCES)
	haxe \
		-cp $(SRC_DIR) \
		-D js-es5 \
		$(HXFLAGS) \
		-js $@ \
		-lib stdlib --macro "stdlib.Macro.expose('$(PACKAGE)','')" \
		-dce full \
			--macro "keep('$(PACKAGE)')" \
			--macro "keep('stdlib.Event')" \
		--macro "include('$(PACKAGE)')"
			
$(DEST_DIR)/index.d.ts: $(ALL_SOURCES)
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
