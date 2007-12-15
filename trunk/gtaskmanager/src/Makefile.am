# $Id: Makefile.am 2350 2007-01-13 10:12:31Z nick $

INCLUDES =								\
	-I$(top_srcdir)/include						\
	-DG_LOG_DOMAIN=\"gtaskmanager\"				\
	-DPACKAGE_LOCALE_DIR=\"$(localedir)\"

bin_PROGRAMS =								\
	gtaskmanager

gtaskmanager_SOURCES =						\
	main.c								\
	callbacks.c							\
	callbacks.h							\
	functions.c							\
	functions.h							\
	interface.c							\
	interface.h							\
	xfce-taskmanager-linux.c					\
	xfce-taskmanager-linux.h					\
	types.h								\
	gcs-i18n.h

gtaskmanager_CFLAGS =						\
	$(GTK_CFLAGS)
	
gtaskmanager_LDADD = 						\
	$(GTK_LIBS)

# vi:set ts=8 sw=8 noet ai nocindent syntax=automake:
