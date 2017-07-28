MAKO := $(patsubst %.txt,%.mako,$(wildcard *.txt))
CWD = $(shell pwd)
WEB = $w/
AMHELP = ../mob/AnkiMobile/Resources/HTML/help.html
TOC_FILES = manual.mako am-manual.mako changes.mako addons.mako \
    am-changes.mako manual.fr.mako manual.pl.mako manual.es.mako

all: build
	@echo "remember to run 'make commit' to commit changes"
	rsync -a img $(WEB)/docs/

commit: save build

save:
	-git commit -a -m update && git push
	git pull
	git push

build: $(MAKO)
	@echo building mako
	@rsync -a *.mako $(WEB)/docs/
	@rsync -a *.png $(WEB)/docs/

$(TOC_FILES): TOC := 1

%.mako: %.txt asciidoc.conf
	@echo asciidoc $<
	@asciidoc -s -b html5 -o $@ $<
	@echo '<%inherit file="/base.inc"/>' > $@.tmp
	@cat style.inc >> $@.tmp
	@if [ x$(TOC) != x ]; then cat toc.pre >> $@.tmp; fi
	@cat $@ >> $@.tmp
	@if [ x$(TOC) != x ]; then cat toc.post >> $@.tmp; fi
	@mv $@.tmp $@

clean:
	touch *.txt	
