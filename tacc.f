#! /usr/bin/gforth

warnings off
require mf/mf.f

( Formatter )
8 constant /date
5 constant /frame

: d>c  48 + ;
: c>d  48 - ;

: ten@  ( a - n )  a!  c@+ c>d 10 *  c@+ c>d  + ;
: ten!  ( n a - )  a!  10 /mod  d>c c!+  d>c c!+ ;

: frame@  ( a - time status ) a! c@+ push  a ten@ 100 * a ten@ +  pop ;
: frame!  ( time status a )   a! c!+ 100 /mod  a ten! a ten! ;

: date@  ( a - n )   push 0. pop /date >number  drop drop d>s ;
: date!  ( date a )  a!  3 for 100 /mod next  a ten! a ten! a ten! a ten! ;

( Time )
: time>min  ( time - n )  100 /mod  60 *  + ;
: min>time  ( n - time )  60 /mod  100 *  + ;

: timeop  ( t1 t2 op - t3 )
  push  time>min swap time>min swap  pop execute  min>time ;

: t-  ( t t' - t-t' )  ['] - timeop ;
: t+  ( t t' - t+t' )  ['] + timeop ;

: day     ( - date )  time&date 100 * +  100 * +  push drop drop drop pop ;
: hour    ( - time )  time&date drop drop drop push drop drop pop 100 * ;
: minute  ( - time )  time&date drop drop drop drop nip ;
: now     ( - time )  hour minute + ;

( File )
0 value file

: open   ( a n - fd )
  2dup r/w open-file 0= if nip nip exit then
  drop r/w create-file throw ;

: setup  ( a n )      open to file ;
: read   ( a n - n )  file read-line throw drop ;
: write  ( a n )      file write-line throw ;
: position@  ( - n )  file file-position throw d>s ;
: position!  ( n )    s>d file reposition-file throw ;

( Line )
64 constant /line
variable #line
create line  /line allot
variable offset

: >line    ( a n )  push line pop move ;
: >offset  ( n )    1+ position@ swap -  offset ! ;

: line!  ( - n )  \ only overwrite line if something was read
  here /line read dup 0= if exit then
  dup #line !  here over >line  dup >offset ;

: .line   line #line @ type ;
: commit  offset @ position!  line #line @ write ;
: ff      begin line! 0= until ;

: #frames  #line @  /date -  /frame / ;
: .frames  begin line! while cr #frames . repeat ;

: 'frame  ( n - a )            /frame *  /date + line + ;
: frame   ( n - time status )  'frame frame@ ;
: last    ( - n )              #frames 1- ;

( User commands )
char + constant opentag
    bl constant closetag
 
: open?    ( status - f )  opentag = ;
: closed?  ( status - f )  closetag = ;

: close  ( time )
  #frames 0= if exit then
  last frame closed? if drop exit then
  t-  closetag  last 'frame frame!
  .line ;

: open  ( time )
  last frame open? abort" Frame open, close it first" drop
  opentag  #frames 'frame frame!  /frame #line +!
  .line ;

: #  ( - time )
  0  #frames 1- for r@ 1- frame drop t+ next
  last frame closed? if t+ exit then
  now swap t- + . ;

( Initialization )
: 0line  line /line erase  0 #line ! ;

: init
  line date@ day = if exit then
  0line  day line date!  /date #line +! ;

: used  ( a n )  setup ff init ;
: use  bl word count used ;
: go   s" TACCFILE" getenv dup 0= if 2drop exit then used ;
go
