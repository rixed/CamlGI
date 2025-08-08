# CamlGI
# Copyright (C) 2005: Christophe TROESTLER
#
PKGNAME = $(shell grep name META | sed -e "s/.*\"\([^\"]*\)\".*/\1/")
PKGVERSION = $(shell grep version META | sed -e "s/.*\"\([^\"]*\)\".*/\1/")

include Makefile.config

OCAMLFLAGS = -annot -I +threads
OCAMLOPTFLAGS = -inline 2 -I +threads
OCAMLDOCFLAGS =

SOURCES = $(wildcard *.ml)
INTERFACES = $(wildcard *.mli)

ARCHIVE = cgi.cma
XARCHIVE = cgi.cmxa

.PHONY: all byte opt install install-byte install-opt doc
all: byte opt
byte: $(ARCHIVE)
opt: $(XARCHIVE)
doc: html

cgi.cma: $(SOURCES:.ml=.cmo) $(INTERFACES:.mli=.cmi)
	$(OCAMLC) -a -o $@ $(OCAMLFLAGS) $(SOURCES:.ml=.cmo)

cgi.cmxa: $(SOURCES:.ml=.cmx) $(INTERFACES:.mli=.cmi)
	$(OCAMLOPT) -a -o $@ $(OCAMLOPTFLAGS) $(SOURCES:.ml=.cmx)

ifdef OCAMLLIBDIR
OCAMLFIND_DESTDIR=-destdir $(OCAMLLIBDIR)
else
OCAMLFIND_DESTDIR=
endif
# The install rule is separate because "ocamlfind" cannot install
# incrementally
install: byte opt
	$(OCAMLFIND) remove  $(PKGNAME) || true
	$(OCAMLFIND) install $(OCAMLFIND_DESTDIR) $(PKGNAME) META \
	  $(ARCHIVE) $(XARCHIVE) $(ARCHIVE:.cma=.o) $(ARCHIVE:.cma=.cmi) $(ARCHIVE:.cma=.mli)

install-byte: byte
	$(OCAMLFIND) remove  $(PKGNAME) || true
	$(OCAMLFIND) install $(OCAMLFIND_DESTDIR) $(PKGNAME) META \
	  $(ARCHIVE) $(ARCHIVE:.cma=.cmi) $(ARCHIVE:.cma=.mli)

install-opt: opt
	$(OCAMLFIND) remove  $(PKGNAME) || true
	$(OCAMLFIND) install $(OCAMLFIND_DESTDIR) $(PKGNAME) META \
	  $(XARCHIVE) $(ARCHIVE:.cma=.o) $(ARCHIVE:.cmxa=.cmi) $(ARCHIVE:.cmxa=.mli)

install-doc: doc
	[ -d "$(DOCDIR)" ] || mkdir -p "$(DOCDIR)"
	cp html/* "$(DOCDIR)"

uninstall:
	$(OCAMLFIND) remove $(PKGNAME)
	$(RM) -r "$(DOCDIR)"

# Documentation
.PHONY: html
html: html/index.html

html/index.html: $(INTERFACES) $(INTERFACES:.mli=.cmi)
	[ -d html/ ] || mkdir html
	$(OCAMLDOC) -d html -html $(OCAMLDOCFLAGS) $(INTERFACES)

# Caml general dependencies
.SUFFIXES: .ml .mli .cmo .cmi .cmx
%.cmi: %.mli
	$(OCAMLC) $(OCAMLFLAGS) -c $<
%.cmo: %.ml
	$(OCAMLC) $(OCAMLFLAGS) -c $<
%.cma: # Dependencies to be set elsewhere
	$(OCAMLC) -a -o $@ $(OCAMLFLAGS) $(filter %.cmo, $^)
%.cmx: %.ml
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c $<
%.cmxa: # Dependencies to be set elsewhere
	$(OCAMLOPT) -a -o $@ $(OCAMLOPTFLAGS) $(filter %.cmx, $^)

.PHONY: depend dep
dep: .depend
depend: .depend
.depend: $(wildcard *.ml) $(wildcard *.mli)
	$(OCAMLDEP) $^ > $@

include .depend

########################################################################

.PHONY: clean dist-clean
clean:
	$(RM) *~ .*~ *.{o,a} *.cm[aiox] *.cmxa *.annot *.css

dist-clean: clean
	$(RM) .depend
