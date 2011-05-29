# $Id: Makefile,v 1.13 2010/09/22 06:09:49 Stevan_White Exp $

ADMIN=LICENSE
DATE=$(shell date +"%Y%m%d")
RELEASE=slavfonts-$(DATE)
BUILDDIR=$(PWD)
TMPDIR=$(BUILDDIR)/$(RELEASE)
OTFZIPFILE=slavfonts-otf-$(DATE).zip
TTFZIPFILE=slavfonts-ttf-$(DATE).zip
OTFTARFILE=slavfonts-otf-$(DATE).tar.gz
TTFTARFILE=slavfonts-ttf-$(DATE).tar.gz
SRCTARFILE=slavfonts-sfd-$(DATE).tar.gz
ZIPSIG=slavfonts-ttf-$(DATE).zip.sig
TARSIG=slavfonts-ttf-$(DATE).tar.gz.sig
SRCTARSIG=slavfonts-sfd-$(DATE).tar.gz.sig
SIGS=$(ZIPSIG) $(TARSIG) $(SRCTARSIG)

SFDS=Glagoli.sfd
MSFDS=Glagoli.sfd
TTFS=$(SFDS:.sfd=.ttf)
OTFS=$(SFDS:.sfd=.otf)
FF=fontforge -lang=ff -script 
FFPY=fontforge -lang=py -script 

ffversion=`fontforge --version 2> /dev/null | grep '^fontforge' | sed -e 's/^fontforge //'`

TESTFF=if test -z ${ffversion}; then echo Fontforge program is required to build FreeFont; exit 1; fi; if test `fontforge --version 2> /dev/null | grep '^fontforge' | sed -e 's/^fontforge //'` -lt 20080429 ; then echo FontForge version too old; exit 1; fi

.SUFFIXES: $(SUFFIXES) .sfd .ttf .otf

%.otf : %.sfd
	@ $(TESTFF)
	@ ( $(FFPY) tools/GenerateOpenType $< 2>/dev/stdout 1>/dev/stderr | tail -n +4 ) 2>&1 

%.ttf : %.sfd
	@ $(TESTFF)
	@ ( $(FFPY) tools/GenerateTrueType $< 3>&1 1>&2 2>&3 | tail -n +4 ) 3>&1 1>&2 2>&3 2>&1 

all: ttf

ttf: $(TTFS)

otf: $(OTFS)

package: ttftar otfzip otftar srctar

ttfzip: ttf
	rm -rf $(TMPDIR) $(TTFZIPFILE)
	mkdir $(TMPDIR)
	cp -a $(ADMIN) sfd/*.ttf $(TMPDIR)
	zip -r $(TTFZIPFILE) $(RELEASE)/

otfzip: otf
	rm -rf $(TMPDIR) $(OTFZIPFILE)
	mkdir $(TMPDIR)
	cp -a $(ADMIN) sfd/*.otf $(TMPDIR)
	zip -r $(OTFZIPFILE) $(RELEASE)/

ttftar: ttf
	rm -rf $(TMPDIR) $(TTFTARFILE)
	mkdir $(TMPDIR)
	cp -a $(ADMIN) sfd/*.ttf $(TMPDIR)
	tar czvf $(TTFTARFILE) $(RELEASE)/

otftar: otf
	rm -rf $(TMPDIR) $(OTFTARFILE)
	mkdir $(TMPDIR)
	cp -a $(ADMIN) sfd/*.otf $(TMPDIR)
	tar czvf $(OTFTARFILE) $(RELEASE)/

srctar:
	rm -rf $(TMPDIR) $(SRCTARFILE)
	mkdir $(TMPDIR)
	cp -a $(ADMIN) sfd/*.sfd $(TMPDIR)
	tar czvf $(SRCTARFILE) $(RELEASE)/

tests:
	@ $(TESTFF)
	@ ( $(FFPY) tools/isMonoMono.py $(MSFDS) 3>&1 1>&2 2>&3 | tail -n +4 ) 3>&1 1>&2 2>&3 2>&1
	@ tools/checkGlyphNumbers.py 2>&1
	@ tools/validate.py 2>&1

clean:
	rm -rf $(TMPDIR) 
	rm -f $(TTFZIPFILE) $(TTFTARFILE) $(OTFTARFILE) $(SRCTARFILE) $(SIGS) 
	( cd sfd; $(MAKE) clean )
	rm -f $(TTFS) $(OTFS) build.log

distclean:
	rm -rf $(TMPDIR) 
	rm -f $(ZIPFILE) $(TARFILE) $(SRCTARFILE) $(SIGS)
	( cd sfd; $(MAKE) distclean )
	rm -f $(TTFS) $(OTFS) build.log
