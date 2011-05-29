#!/usr/bin/fontforge -script 
__license__ = """
This file has been got from the Gnu FreeFont project.

"""
__author__ = "Stevan White"
__email__ = "stevan.white@googlemail.com"
__copyright__ = "Copyright 2009, 2010, Stevan White"
__date__ = "$Date: 2010/09/14 13:02:02 $"
__version__ = "$Revision: 1.5 $"

__doc__ = """
For most unicode ranges, glyph slot numbers should be the same as the
Unicode value.
The Private Use ranges are the exception: those characters should have a
definate non-Unicode number: -1

This script checks that this is the case, and prints out a warning
whenever it isn't.
"""

import fontforge
import sys

problem = False

def inPrivateUseRange( glyph ):
	e = glyph.encoding

	return ( ( e >= 0xE800 and e <= 0xF8FF )
	    or ( e >= 0xFF000 and e <= 0xFFFFD )
	    or ( e >= 0x100000 and e <= 0x10FFFD ) )

def isSpecialTrueType( glyph ):
	""" Fontforge treats three control characters as the special 
	TrueType characters recommended by that standard
	"""
	e = glyph.encoding

	return e == 0 or e == 1 or e == 0xD

def checkGlyphNumbers( dir, fontFile ):
	print "Checking slot numbers in " + fontFile
	font = fontforge.open( dir + fontFile )

	g = font.selection.all()
	g = font.selection.byGlyphs

	valid = True
	for glyph in g:
		if isSpecialTrueType( glyph ):
			# FIXME really should complain if it DOESNT exist
			pass
		elif inPrivateUseRange( glyph ):
			if glyph.unicode != -1:
				print "Glyph at slot " + str( glyph.encoding ) \
					+ " is Private Use but has Unicode"
				problem = True
		else:
			if glyph.encoding != glyph.unicode:
				print "Glyph at slot " + str( glyph.encoding ) \
					+ " has wrong Unicode"
				problem = True

checkGlyphNumbers( './', 'Glagoli.sfd' )

if problem:
	sys.exit( 1 )
