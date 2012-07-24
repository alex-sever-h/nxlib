# 9 Dec 2010
#
# NXLIB library makefile - X11 Conversion Library for Nano-X
# Greg Haerr <greg@censoft.com>
#
# Note: if build fails, rebuild keysymstr.h by "make distclean", then "make"
#

# set to Y for big endian architecture (should be automatic)
#
BIGENDIAN=N

# comment out to stop debug printfs
CFLAGS += -DDEBUG=1 -g

# Compile-time nano-X include and lib directories. (relative paths ok)
#
MWIN_INCLUDE=../microwin/src/include
MWIN_LIB=../microwin/src/lib

# Compile-time X11 include directory
#
# Although X11 headers haven't changed structurally in years,
# these locations should match headers on target system.
# NXLIB includes local X11R6 headers in case X11 isn't installed
# on the cross-compiling host.
#
# if X11 not installed:
#	X11_INCLUDE=.
# if X11 installed:
#	X11_INCLUDE=/usr/include/X11
#
X11_INCLUDE=.
#X11_INCLUDE=/usr/include/X11

# Run-time font directory and rgb.txt file location:
# For testing, relative paths are ok, default is local rgb.txt and fonts
# Modify FONT_DIR_LIST in fontlist.c to add font search directories
#
# For release, full paths are required matching target system locations
#	X11_RGBTXT=/usr/share/X11/rgb.txt
#
#X11_RGBTXT=fonts/rgb.txt
X11_RGBTXT=/usr/share/X11/rgb.txt

# NXLIB library name and installation directory for "make install"
# Installation is only required when wanting to completely
# create a libX11.so that allows unmodified changes to X11
# application makefiles. In the normal case, and when
# cross-compiling on a system with X11, no installation
# is possible (as libX11.so would be replaced), and
# the link command is changed from '-lX11' to '-lNX11 -lnano-X'
LIBNAME=NX11
xINSTALL_DIR=.
INSTALL_DIR=/usr/local/lib

# set to Y to make shared libNX11.so library, shared lib dependencies
SHAREDLIB=N
SOLIBREV=0.47
SOEXTRALIBS = -L$(MWIN_LIB) -lnano-X

# set to Y to include (unmodifed X11) Xrm routines
INCLUDE_XRM=Y

# compiler flags
CC = gcc
LN = ln -s
AR = ar
MV = mv
CP = cp -p
RM = rm -f
CFLAGS += -Wall
CFLAGS += -I$(MWIN_INCLUDE) -I$(X11_INCLUDE)
CFLAGS += -DX11_FONT_DIR1=\"$(X11_FONT_DIR1)\"
CFLAGS += -DX11_FONT_DIR2=\"$(X11_FONT_DIR2)\"
CFLAGS += -DX11_FONT_DIR3=\"$(X11_FONT_DIR3)\"
CFLAGS += -DX11_RGBTXT=\"$(X11_RGBTXT)\"
xCFLAGS += -O2 -fno-strength-reduce
CFLAGS += -O3

OBJS = DestWind.o MapWindow.o NextEvent.o OpenDis.o ClDisplay.o\
	Window.o CrGC.o FreeGC.o StName.o Sync.o Flush.o CrWindow.o\
	Text.o DrLine.o DrLines.o DrPoint.o DrRect.o DrArc.o\
	MapRaised.o RaiseWin.o LowerWin.o FillRct.o CrPixmap.o Clear.o\
	MoveWin.o ClearArea.o UnmapWin.o RepWindow.o\
	ChWindow.o Backgnd.o BdrWidth.o Border.o PmapBgnd.o\
	fontlist.o font_find.o UnloadFont.o QueryFont.o\
	DefCursor.o UndefCurs.o CrCursor.o FontCursor.o\
	CrBFData.o CrPFBData.o Region.o SelInput.o Atom.o\
	QueryTree.o Image.o WindowProperty.o Misc.o SetWMProps.o Bell.o\
	Copy.o SetClip.o Visual.o StrToText.o SetAttributes.o FillPolygon.o\
	StrKeysym.o ChProperty.o QueryPointer.o ErrorHandler.o\
	ListPix.o GetGeom.o SetIFocus.o Shape.o\
	ClassHint.o Text16.o TextExt.o\
	AllocColor.o ParseColor.o QueryColor.o Colormap.o Colorname.o\
	Selection.o XMisc.o Free.o stub.o

ifeq ($(INCLUDE_XRM), Y)
OBJS += Quarks.o Xrm.o
xOBJS += xrm/Xrm.o xrm/ParseCmd.o xrm/Misc.o xrm/Quarks.o xrm/lcWrap.o \
    xrm/lcInit.o xrm/lcGenConv.o xrm/SetLocale.o xrm/lcConv.o xrm/lcUTF8.o \
    xrm/lcDefConv.o xrm/lcPubWrap.o xrm/lcDynamic.o xrm/lcCharSet.o \
    xrm/lcDB.o xrm/lcGeneric.o xrm/lcUtil.o xrm/lcCT.o xrm/lcFile.o \
    xrm/lcPublic.o xrm/lcRM.o xrm/imInt.o
CFLAGS += -I.
endif

LIBS = lib$(LIBNAME).a

ifeq ($(BIGENDIAN), Y)
CFLAGS += -DCPU_BIG_ENDIAN=1
endif

ifeq ($(SHAREDLIB), Y)
CFLAGS += -fPIC
LIBS += lib$(LIBNAME).so.$(SOLIBREV)
endif

all: $(LIBS)

# static NXLIB library
lib$(LIBNAME).a: keysymstr.h $(OBJS)
	$(AR) r lib$(LIBNAME).a $(OBJS)

# shared X11 library
lib$(LIBNAME).so.$(SOLIBREV): $(OBJS)
	$(RM) $@~
	@SONAME=`echo $@ | sed 's/\.[^\.]*$$//'`; set -x; \
	$(CC) -o ./$@~ -shared -Wl,-soname,$$SONAME $(OBJS) $(SOEXTRALIBS) -lc;
#	$(RM) $$SONAME; $(LN) $@ $$SONAME;
#	$(RM) $@
	$(MV) $@~ $@
#	$(RM) lib$(LIBNAME).so; $(LN) $@ lib$(LIBNAME).so
	$(MV) $@ lib$(LIBNAME).so

install: $(LIBS)
	$(RM) $(INSTALL_DIR)/lib$(LIBNAME).so; \
	$(CP) lib$(LIBNAME).so $(INSTALL_DIR)
#	@MAJREV=`expr $(SOLIBREV) : '\(.*\)\.'`; set -x; \
#	$(RM) $(INSTALL_DIR)/lib$(LIBNAME).so.$$MAJREV; \
	$(MV) lib$(LIBNAME).so.$$MAJREV $(INSTALL_DIR)
#	$(RM) $(INSTALL_DIR)/lib$(LIBNAME).so.$(SOLIBREV); \
	$(MV) lib$(LIBNAME).so.$(SOLIBREV) $(INSTALL_DIR)
#	$(MV) lib$(LIBNAME).a $(INSTALL_DIR)

clean: cleanlibs
	$(RM) *.o *~

cleanlibs:
	$(RM) lib$(LIBNAME).a
	$(RM) lib$(LIBNAME).so
	@MAJREV=`expr $(SOLIBREV) : '\(.*\)\.'`; \
	set -x; $(RM) lib$(LIBNAME).so.$$MAJREV
	$(RM) lib$(LIBNAME).so.$(SOLIBREV)

distclean: clean
	$(RM) -f keysymstr.h

keysymstr.h: 
	perl ./keymap.pl $(X11_INCLUDE)/X11 > ./keysymstr.h

tt: tt.o $(LIBS)
	$(CC) -o tt tt.c -L. -lnx11 $(SOEXTRALIBS)

.SUFFIXES:
.SUFFIXES: .c .o

.c.o:
	$(CC) $(CFLAGS) -o $@ -c $<
