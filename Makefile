
# puppet module install doesn't handle local packages (needs to be in the puppet forge)
# gemspecs don't handle install to other than gemdir
# man 1 install doesn't handle directories
# really...


INSTALLDIR=/usr/share/puppet/modules/

install:
	cp -R qpid ${INSTALLDIR}

uninstall:
	rm -rf ${INSTALLDIR}/qpid

.PHONY: install uninstall
