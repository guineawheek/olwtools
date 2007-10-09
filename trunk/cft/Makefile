# cft installation

PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
MANDIR=$(PREFIX)/man/man1
SHAREDIR=$(PREFIX)/share/cft

all: printenv

install:
	install -D -m 755 cft $(BINDIR)
	install -D -m 644 cft.1.gz $(MANDIR)
	install -D -d $(SHAREDIR)
	install -D -m 644 editor $(SHAREDIR)
	install -D -m 644 tmpl/* $(SHAREDIR)

printenv:
	@echo "PREFIX = $(PREFIX)"
	@echo "BINDIR = $(BINDIR)"
	@echo "MANDIR = $(MANDIR)"
	@echo "SHAREDIR = $(SHAREDIR)"

uninstall:
	rm $(BINDIR)/cft
	rm $(MANDIR)/cft.1.gz
	rm -rf $(SHAREDIR)
