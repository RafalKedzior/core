/*
 * Document generator - HTML output
 *
 * Copyright 2009 April White <bright.tigra gmail.com>
 * Copyright 1999-2003 Luiz Rafael Culik <culikr@uol.com.br> (Portions of this project are based on hbdoc)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file LICENSE.txt.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA (or visit https://www.gnu.org/licenses/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include "hbclass.ch"
#include "hbver.ch"

#define EXTENSION  ".html"

#define STYLEFILE  "hbdoc.css"

CREATE CLASS GenerateHTML INHERIT TPLGenerate

   HIDDEN:

   METHOD RecreateStyleDocument( cStyleFile )
   METHOD OpenTagInline( cText, ... )
   METHOD OpenTag( cText, ... )
   METHOD Tagged( cText, cTag, ... )
   METHOD CloseTagInline( cText )
   METHOD CloseTag( cText )
   METHOD AppendInline( cText, cFormat, lCode )
   METHOD Append( cText, cFormat, lCode )
   METHOD Space() INLINE ::cFile += ", ", Self
   METHOD Spacer() INLINE ::cFile += hb_eol(), Self
   METHOD Newline() INLINE ::cFile += "<br>" + hb_eol(), Self
   METHOD NewFile()

   CLASS VAR lCreateStyleDocument AS LOGICAL INIT .T.
   VAR TargetFilename AS STRING INIT ""

   EXPORTED:

   METHOD NewIndex( cDir, cFilename, cTitle, cLang )
   METHOD NewDocument( cDir, cFilename, cTitle, cLang )
   METHOD AddEntry( oEntry )
   METHOD AddReference( oEntry, cReference, cSubReference )
   METHOD BeginSection( cSection, cFilename )
   METHOD EndSection( cSection, cFilename )
   METHOD Generate()

   METHOD WriteEntry( cField, cContent, lPreformatted ) HIDDEN

   VAR nStart INIT hb_MilliSeconds()
   VAR nIndent INIT 0

ENDCLASS

METHOD NewFile() CLASS GenerateHTML

   ::cFile += "<!DOCTYPE html>" + hb_eol()

   ::OpenTag( "html", "lang", StrTran( ::cLang, "_", "-" ) )
   ::Spacer()

   ::OpenTag( "meta", "charset", "utf-8" )
   ::OpenTag( "meta", "name", "referrer", "content", "origin" )
   ::OpenTag( "meta", "name", "viewport", "content", "initial-scale=1" )
   ::Spacer()

   ::OpenTag( "meta", "name", "generator", "content", "hbdoc" )
   ::OpenTag( "meta", "name", "keywords", "content", ;
      "Harbour, Clipper, xBase, database, Free Software, GPL, compiler, cross-platform, 32-bit, 64-bit" )
   ::Spacer()

   IF ::lCreateStyleDocument
      ::lCreateStyleDocument := .F.
      ::RecreateStyleDocument( STYLEFILE )
   ENDIF

   ::Append( ::cTitle, "title" )
   ::Spacer()

   ::OpenTag( "link", "rel", "stylesheet", "href", STYLEFILE )
   ::Spacer()

   ::OpenTag( "body" )
   ::Spacer()

   ::OpenTag( "header" )
   ::Append( ::cTitle, "h1" )
   ::CloseTag( "header" )
   ::Spacer()

   ::OpenTag( "main" )

   RETURN Self

STATIC FUNCTION GitRev()

   LOCAL cStdOut := ""

   hb_processRun( "git rev-parse --short HEAD",, @cStdOut )

   RETURN hb_StrReplace( cStdOut, Chr( 13 ) + Chr( 10 ) )

METHOD Generate() CLASS GenerateHTML

   LOCAL cRevision := GitRev()

   ::Spacer()
   ::CloseTag( "main" )

   ::Spacer()
   ::OpenTag( "footer" )
   ::Append( "Generated by hbdoc on " + hb_TToC( hb_DateTime() - ( hb_UTCOffset() / 86400 ), "yyyy-mm-dd", "hh:mm" ) + " UTC", "div" )

   ::OpenTagInline( "div" )
   ::AppendInline( "Based on commit " )
   #if defined( HB_VERSION_URL_BASE )
      ::OpenTagInline( "a", "href", hb_Version( HB_VERSION_URL_BASE ) + "tree/" + cRevision )
   #endif
   ::AppendInline( cRevision )
   #if defined( HB_VERSION_URL_BASE )
      ::CloseTagInline( "a" )
   #endif
   ::CloseTag( "div" )

   ::CloseTag( "footer" )

   ::super:Generate()

#if 0
   ? Round( ( hb_MilliSeconds() - ::nStart ) / 1000, 3 )
#endif

   RETURN Self

METHOD NewDocument( cDir, cFilename, cTitle, cLang ) CLASS GenerateHTML

   ::super:NewDocument( cDir, cFilename, cTitle, EXTENSION, cLang )
   ::NewFile()

   RETURN Self

METHOD NewIndex( cDir, cFilename, cTitle, cLang ) CLASS GenerateHTML

   ::super:NewIndex( cDir, cFilename, cTitle, EXTENSION, cLang )
   ::NewFile()

   RETURN Self

METHOD BeginSection( cSection, cFilename ) CLASS GenerateHTML

   cSection := SymbolToHTMLID( cSection )

   IF ::IsIndex()
      IF cFilename == ::cFilename
         ::OpenTagInline( "div", "id", cSection ):AppendInline( cSection, "h" + hb_ntos( ::Depth + 2 ) ):CloseTag( "div" )
      ELSE
         ::OpenTag( "a", "href", cFilename + ::cExtension + "#" + cSection ):Append( cSection, "h" + hb_ntos( ::Depth + 2 ) ):CloseTag( "a" )
      ENDIF
   ELSE
      ::OpenTagInline( "div", "id", cSection ):AppendInline( cSection, "h" + hb_ntos( ::Depth + 2 ) ):CloseTag( "div" )
   ENDIF
   ::TargetFilename := cFilename
   ::Depth++

   RETURN Self

METHOD EndSection( cSection, cFilename ) CLASS GenerateHTML

   HB_SYMBOL_UNUSED( cSection )
   HB_SYMBOL_UNUSED( cFilename )
   ::Depth--

   RETURN Self

METHOD AddReference( oEntry, cReference, cSubReference ) CLASS GenerateHTML

   IF HB_ISOBJECT( oEntry ) .AND. oEntry:ClassName() == "ENTRY"
      ::OpenTag( "a", "href", ::TargetFilename + ::cExtension + "#" + oEntry:_filename ):Append( oEntry:fld[ "NAME" ] ):CloseTag( "a" ):Append( oEntry:fld[ "ONELINER" ] ):Newline()
   ELSE
      IF HB_ISSTRING( cSubReference )
         ::OpenTag( "a", "href", cReference + ::cExtension + "#" + cSubReference ):Append( oEntry ):CloseTag( "a" ):Newline()
      ELSE
         ::OpenTag( "a", "href", cReference + ::cExtension /* + "#" + oEntry:_filename */ ):Append( oEntry ):CloseTag( "a" ):Newline()
      ENDIF
   ENDIF

   RETURN Self

METHOD AddEntry( oEntry ) CLASS GenerateHTML

   LOCAL item
   LOCAL cEntry

   ::Spacer()
   ::OpenTag( "section", "id", SymbolToHTMLID( oEntry:_filename ) )

   FOR EACH item IN FieldIDList()
      IF item == "NAME"
         cEntry := oEntry:fld[ "NAME" ]
         IF "(" $ cEntry .OR. Upper( cEntry ) == cEntry  // guess if it's code
            ::OpenTagInline( "h4" ):OpenTagInline( "code" ):AppendInline( cEntry ):CloseTagInline( "code" ):CloseTag( "h4" )
         ELSE
            ::OpenTagInline( "h4" ):AppendInline( cEntry ):CloseTag( "h4" )
         ENDIF
      ELSEIF oEntry:IsField( item ) .AND. oEntry:IsOutput( item ) .AND. Len( oEntry:fld[ item ] ) > 0
         ::WriteEntry( item, oEntry:fld[ item ], oEntry:IsPreformatted( item ) )
      ENDIF
   NEXT

   ::CloseTag( "section" )

   RETURN Self

METHOD PROCEDURE WriteEntry( cField, cContent, lPreformatted ) CLASS GenerateHTML

   STATIC s_class := { ;
      "NAME"     => "d-na", ;
      "ONELINER" => "d-ol", ;
      "EXAMPLES" => "d-ex", ;
      "TESTS"    => "d-te" }

   LOCAL cTagClass
   LOCAL cCaption
   LOCAL lFirst
   LOCAL tmp, tmp1
   LOCAL cLine
   LOCAL lCode, lTable, lTablePrev, cHeaderClass

   IF ! Empty( cContent )

      cTagClass := hb_HGetDef( s_class, cField, "d-it" )

      IF ! HB_ISNULL( cCaption := FieldCaption( cField ) )
         ::Tagged( cCaption, "div", "class", "d-d" )
      ENDIF

      DO CASE
      CASE lPreformatted  /* EXAMPLES, TESTS */

         ::OpenTag( "pre", "class", cTagClass )
         ::Append( cContent,, .T. )
         ::CloseTag( "pre" )

      CASE cField == "SEEALSO"

         ::OpenTagInline( "div", "class", cTagClass )
         lFirst := .T.
         FOR EACH tmp IN hb_ATokens( cContent, "," )
            tmp := AllTrim( tmp )
            IF ! HB_ISNULL( tmp )
               // TOFIX: for multi-file output
               tmp1 := Parse( tmp, "(" )
               IF lFirst
                  lFirst := .F.
               ELSE
                  ::Space()
               ENDIF
               ::OpenTagInline( "code" ):OpenTagInline( "a", "href", "#" + SymbolToHTMLID( tmp1 ) ):AppendInline( tmp ):CloseTagInline( "a" ):CloseTagInline( "code" )
            ENDIF
         NEXT
         ::CloseTag( "div" )

      CASE cField == "SYNTAX"

         ::OpenTagInline( "div", "class", cTagClass )
         DO WHILE ! HB_ISNULL( cContent )
            ::OpenTagInline( "code" )
            ::AppendInline( Indent( Parse( @cContent, hb_eol() ), 0, -1,, .T. ),, .F. )
            ::CloseTagInline( "code" )
         ENDDO
         ::CloseTag( "div" )

      OTHERWISE

         ::OpenTag( "div", "class", cTagClass )
         ::nIndent++

         lTable := .F.

         DO WHILE ! HB_ISNULL( cContent )

            lCode := .F.
            lTablePrev := lTable

            tmp1 := ""
            DO WHILE ! HB_ISNULL( cContent )

               cLine := Parse( @cContent, hb_eol() )

               DO CASE
               CASE hb_LeftEq( LTrim( cLine ), "```" )
                  IF lCode
                     EXIT
                  ELSE
                     lCode := .T.
                  ENDIF
               CASE cLine == "<fixed>"
                  lCode := .T.
               CASE cLine == "</fixed>"
                  IF lCode
                     EXIT
                  ENDIF
               CASE hb_LeftEq( cLine, "<table" )
                  lTable := .T.
                  DO CASE
                  CASE cLine == "<table-noheader>"     ; cHeaderClass := ""
                  CASE cLine == "<table-doubleheader>" ; cHeaderClass := "d-t1 d-t2"
                  OTHERWISE                            ; cHeaderClass := "d-t1"
                  ENDCASE
               CASE cLine == "</table>"
                  lTable := .F.
               OTHERWISE
                  tmp1 += cLine + hb_eol()
                  IF ! lCode
                     EXIT
                  ENDIF
               ENDCASE
            ENDDO

            IF lTable != lTablePrev
               IF lTable
                  ::OpenTag( "div", "class", "d-t" + iif( HB_ISNULL( cHeaderClass ), "", " " + cHeaderClass ) )
               ELSE
                  ::CloseTag( "div" )
               ENDIF
            ENDIF

            DO CASE
            CASE lCode
               ::OpenTag( "pre" )
               ::Append( tmp1,, .T. )
            CASE lTable
               ::OpenTagInline( "div" )
               ::AppendInline( iif( lTable, StrTran( tmp1, " ", hb_UChar( 160 ) ), tmp1 ),, .T. )
            OTHERWISE
               ::OpenTagInline( "div" )
               IF cField $ "DESCRIPTION|"
                  ::OpenTagInline( "p" )
               ENDIF
               ::AppendInline( iif( lTable, StrTran( tmp1, " ", hb_UChar( 160 ) ), tmp1 ),, .F. )
            ENDCASE
            IF lCode
               ::CloseTag( "pre" )
            ELSE
               ::CloseTag( "div" )
            ENDIF
         ENDDO

         ::nIndent--
         ::CloseTag( "div" )

      ENDCASE
   ENDIF

   RETURN

METHOD OpenTagInline( cText, ... ) CLASS GenerateHTML

   LOCAL aArgs := hb_AParams()
   LOCAL idx

   FOR idx := 2 TO Len( aArgs ) STEP 2
      cText += " " + aArgs[ idx ] + "=" + '"' + aArgs[ idx + 1 ] + '"'
   NEXT

   IF ! cText $ "pre"
      ::cFile += Replicate( "  ", ::nIndent )
   ENDIF
   ::cFile += "<" + cText + ">"

   RETURN Self

METHOD OpenTag( cText, ... ) CLASS GenerateHTML

   ::OpenTagInline( cText, ... )

   ::cFile += hb_eol()

   RETURN Self

METHOD Tagged( cText, cTag, ... ) CLASS GenerateHTML

   LOCAL aArgs := hb_AParams()
   LOCAL cResult := ""
   LOCAL idx

   FOR idx := 3 TO Len( aArgs ) STEP 2
      cResult += " " + aArgs[ idx ] + "=" + '"' + aArgs[ idx + 1 ] + '"'
   NEXT

   ::cFile += "<" + cTag + cResult + ">" + cText + "</" + cTag + ">" + hb_eol()

   RETURN Self

METHOD CloseTagInline( cText ) CLASS GenerateHTML

   ::cFile += "</" + cText + ">"

   RETURN Self

METHOD CloseTag( cText ) CLASS GenerateHTML

   ::cFile += "</" + cText + ">" + hb_eol()

   RETURN Self

STATIC FUNCTION StrEsc( cString )

   STATIC s_html := { ;
      "&" => "&amp;", ;
      '"' => "&quot;", ;
      "<" => "&lt;", ;
      ">" => "&gt;" }

   RETURN hb_StrReplace( cString, s_html )

METHOD AppendInline( cText, cFormat, lCode ) CLASS GenerateHTML

   LOCAL idx

   LOCAL cChar, cPrev, cNext, cOut, tmp, tmp1, nLen
   LOCAL lEM, lIT, lPR
   LOCAL nEM, nIT, nPR
   LOCAL cdp

   IF ! HB_ISNULL( cText )

      hb_default( @lCode, .F. )

      IF lCode
         cText := StrEsc( cText )
      ELSE
         cdp := hb_cdpSelect( "EN" )  /* make processing loop much faster */

         lEM := lIT := lPR := .F.
         cOut := ""
         nLen := Len( cText )
         FOR tmp := 1 TO nLen

            cPrev := iif( tmp > 1, SubStr( cText, tmp - 1, 1 ), "" )
            cChar := SubStr( cText, tmp, 1 )
            cNext := SubStr( cText, tmp + 1, 1 )

            DO CASE
            CASE ! lPR .AND. cChar == "\" .AND. tmp < Len( cText )
               tmp++
               cChar := cNext
            CASE ! lPR .AND. cChar == "*" .AND. ! lIT .AND. ;
                 iif( lEM, ! Empty( cPrev ) .AND. Empty( cNext ), Empty( cPrev ) .AND. ! Empty( cNext ) )
               lEM := ! lEM
               IF lEM
                  nEM := Len( cOut ) + 1
               ENDIF
               cChar := iif( lEM, "<strong>", "</strong>" )
            CASE ! lPR .AND. cChar == "_" .AND. ! lEM .AND. ;
                 ( ( ! lIT .AND. Empty( cPrev ) .AND. ! Empty( cNext ) ) .OR. ;
                   (   lIT .AND. ! Empty( cPrev ) .AND. Empty( cNext ) ) )
               lIT := ! lIT
               IF lIT
                  nIT := Len( cOut ) + 1
               ENDIF
               cChar := iif( lIT, "<i>", "</i>" )
            CASE cChar == "`" .AND. ;
                 ( ( ! lPR .AND. Empty( cPrev ) .AND. ! Empty( cNext ) ) .OR. ;
                   (   lPR .AND. ! Empty( cPrev ) .AND. Empty( cNext ) ) )
               lPR := ! lPR
               IF lPR
                  nPR := Len( cOut ) + 1
               ENDIF
               cChar := iif( lPR, "<code>", "</code>" )
            CASE ! lPR .AND. SubStr( cText, tmp, 3 ) == "<b>"
               tmp += 2
               cChar := "<strong>"
            CASE ! lPR .AND. SubStr( cText, tmp, 4 ) == "</b>"
               tmp += 3
               cChar := "</strong>"
            CASE ! lPR .AND. ;
               ( SubStr( cText, tmp, 3 ) == "===" .OR. SubStr( cText, tmp, 3 ) == "---" )
               DO WHILE tmp < nLen .AND. SubStr( cText, tmp, 1 ) == cChar
                  tmp++
               ENDDO
               cChar := "<hr>"
            CASE ! lPR .AND. ;
               ( SubStr( cText, tmp, 5 ) == "<URL:" .AND. ( tmp1 := hb_At( ">", cText, tmp + 6 ) ) > 0 )
               tmp1 := SubStr( cText, tmp + 5, tmp1 - tmp - 5 )
               tmp += Len( tmp1 ) + 5
               cChar := "<a href=" + '"' + tmp1 + '"' + ">" + tmp1 + "</a>"
            CASE ! lPR .AND. ;
               ( SubStr( cText, tmp, 3 ) == "==>" .OR. SubStr( cText, tmp, 3 ) == "-->" )
               tmp += 2
               cChar := "&rarr;"
            CASE ! lPR .AND. ;
               ( SubStr( cText, tmp, 2 ) == "->" )
               tmp += 1
               cChar := "&rarr;"
            CASE cChar == "&"
               cChar := "&amp;"
            CASE cChar == '"'
               cChar := "&quot;"
            CASE cChar == "<"
               cChar := "&lt;"
            CASE cChar == ">"
               cChar := "&gt;"
            ENDCASE

            cOut += cChar
         NEXT

         /* Remove these tags if they weren't closed */
         IF lPR
            cOut := Stuff( cOut, nPR, Len( "<code>" ), "`" )
         ENDIF
         IF lEM
            cOut := Stuff( cOut, nEM, Len( "<strong>" ), "*" )
         ENDIF
         IF lIT
            cOut := Stuff( cOut, nIT, Len( "<i>" ), "_" )
         ENDIF

         cText := cOut

         hb_cdpSelect( cdp )
      ENDIF

      FOR EACH idx IN hb_ATokens( hb_defaultValue( cFormat, "" ), "," ) DESCEND
         IF ! Empty( idx )
            cText := "<" + idx + ">" + cText + "</" + idx + ">"
         ENDIF
      NEXT

      DO WHILE Right( cText, Len( hb_eol() ) ) == hb_eol()
         cText := hb_StrShrink( cText, Len( hb_eol() ) )
      ENDDO

      ::cFile += cText
   ENDIF

   RETURN Self

METHOD Append( cText, cFormat, lCode ) CLASS GenerateHTML

   ::AppendInline( cText, cFormat, lCode )
   ::cFile += hb_eol()

   RETURN Self

METHOD RecreateStyleDocument( cStyleFile ) CLASS GenerateHTML

   LOCAL cString

   #pragma __streaminclude "hbdoc.css" | cString := %s

   IF ! hb_MemoWrit( ::cDir + hb_ps() + cStyleFile, cString )
      /* TODO: raise an error, could not create style file */
   ENDIF

   RETURN Self

STATIC FUNCTION SymbolToHTMLID( cID )
   RETURN Lower( hb_StrReplace( cID, { ;
     "%" => "pct", ;
     "_" => "-", ;
     " " => "-" } ) )