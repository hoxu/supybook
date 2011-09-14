PARAMS=-a toc -a toclevels=3 -a date=$(shell date +%Y-%m-%d) -a numbered -d book
ifdef VERSION
REVISION=$(VERSION)
endif
ifdef REVISION
PARAMS+=-a revision=$(REVISION)
else
PARAMS+=-a revision=$(shell git describe)$(shell git diff-index HEAD |grep '' > /dev/null && echo '+dirty')
endif

# local optional makefile for deploying
# WEBDIR=/path/to/supybook.fealdia.org/
WEBDIR=
-include Makefile.local

DISTFILES=index.txt index.html Makefile index.pdf

all: html deploy

html: index.html

pdf: index.pdf

have-version:
ifndef VERSION
	@echo "Usage: make release VERSION=x"
	@false
else
	@echo "Version: $(VERSION)"
endif

have-webdir:
ifeq ($(WEBDIR),)
	@echo "No Makefile.local, skipping deploy"
	@false
else
	@echo "Using WEBDIR $(WEBDIR)"
endif

release: have-version clean html pdf
	tar --owner=0 --group=0 --transform 's!^!supybook-$(VERSION)/!' -zcf supybook-$(VERSION).tar.gz $(DISTFILES)

%.html: %.txt
	asciidoc $(PARAMS) $<

%.pdf: %.txt
	a2x $(PARAMS) -f pdf $<

clean:
	@$(RM) index.html index.pdf

deploy: have-webdir html
	@echo "Deploying to $(WEBDIR)"
	cp index.html $(WEBDIR)/devel/index.html

deploy-release: have-webdir release
	mkdir $(WEBDIR)/$(VERSION)
	cp -t $(WEBDIR)/$(VERSION)/ $(DISTFILES)
	cp supybook-$(VERSION).tar.gz $(WEBDIR)/download/
	@echo "Remember to modify $(WEBDIR)/index.html manually"

.PHONY: all deploy have-version have-webdir pdf release release-tar
