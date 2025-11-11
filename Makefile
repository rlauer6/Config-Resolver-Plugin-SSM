#-*- mode: makefile; -*-
#-*- mode: makefile; -*-
SHELL := /bin/bash

.SHELLFLAGS := -ec

MODULE = Config::Resolver::Plugin::SSM

PERL_MODULES = \
    lib/Config/Resolver/Plugin/SSM.pm

VERSION := $(shell cat VERSION)

TARBALL = Config-Resolver-Plugin-SSM-$(VERSION).tar.gz

all: $(TARBALL)

%.pl: %.pl.in
	sed -e 's/[@]PACKAGE_VERSION[@]/$(VERSION)/' $< > $@
	chmod +x $@

%.pm: %.pm.in
	sed -e 's/[@]PACKAGE_VERSION[@]/$(VERSION)/' $< > $@

$(TARBALL): buildspec.yml $(PERL_MODULES) $(BIN_SCRIPTS) requires test-requires README.md
	make-cpan-dist.pl -b $<

README.md: $(PERL_MODULES)
	pod2markdown $< > $@

include version.mk

clean:
	rm -f *.tar.gz
	find . -name '*.p[ml]' -exec rm {} \;

