#!/bin/sh
#******************************************************************************
#
#       Copyright (C)1998,1999 by Eric Sunshine <sunshine@sunshineco.com>
#
# The contents of this file are copyrighted by Eric Sunshine.  You may use
# this file in your own projects provided that this copyright notice is
# retained verbatim.
#
#******************************************************************************
#------------------------------------------------------------------------------
# make.sh                                             (1999-06-09, version 1.1)
#
#       A cross-platform compatibility build script which allows a project to
#       be built for both YellowBox and OpenStep for Microsoft Windows without
#       maintaining a distinct PB.project file for each environment.
#
#       In OpenStep for Windows, the "make" utility was located in
#       $(NEXT_ROOT)/NextDeveloper/Executables.  In YellowBox, "make" moved to
#       $(NEXT_ROOT)/Developer/Executables.  Since the path to "make" is
#       stored in the PB.project file, this generally means that the developer
#       is forced to maintain two versions of PB.project; one for each
#       environment.
#
#       This script (make.sh) bridges the gap between the old directory
#       structure and the new by dynamically determining the correct path for
#       "make" at build time.
#
#       To insert this script into the build process, follow these steps:
#
#       a) If the project is currently open in ProjectBuilder.app, close it.
#       b) Open the project's top-level PB.project file in a text editor.
#       c) Find the line which defines WINDOWS_BUILDTOOL.  Its definition will
#          be either $NEXT_ROOT/NextDeveloper/Executables/make or
#          $NEXT_ROOT/Developer/Executables/make depending upon whether it
#          was generated by OpenStep 4.x or YellowBox.
#       d) Change the value of WINDOWS_BUILDTOOL to "./make.sh".
#       e) Place this script (make.sh) in the project's main directory.
#       f) Ensure that the script is executable: chmod a+x make.sh
#
#       Project Builder uses the value of WINDOWS_BUILDTOOL to locate the
#       program which builds the project.  By changing the value of
#       WINDOWS_BUILDTOOL to "./make.sh", this script is used to build the
#       project instead.
#
#       Once in control, this script dynamically determines the correct path
#       to the "make" utility and then executes it on behalf of Project
#       Builder.
#
# Please send comments to Eric Sunshine <sunshine@sunshineco.com>
# MIME, NeXT, and ASCII mail accepted.
#------------------------------------------------------------------------------

if [ -x ${NEXT_ROOT}/Developer/Executables/make.exe ]; then
    exec ${NEXT_ROOT}/Developer/Executables/make ${1+"$@"}

elif [ -x ${NEXT_ROOT}/NextDeveloper/Executables/make.exe ]; then
    exec ${NEXT_ROOT}/NextDeveloper/Executables/make ${1+"$@"}

elif [ -x ${NEXT_ROOT}/bin/gnumake ]; then
    exec ${NEXT_ROOT}/bin/gnumake ${1+"$@"}
    fi

echo "Unable to determine location of 'make' utility."
exit 1
