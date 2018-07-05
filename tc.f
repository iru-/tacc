#!/usr/bin/env sf

include /Users/iru/src/4utils/cf.f

( File )
0 value file

: setup  ( a n -- )
  r/w open-file throw  to file ;

: read  ( a n -- n )
  file read-line throw drop ;

: write  ( a n -- )
  file write-line throw ;

: position@  ( -- n )
  file file-position throw d>s ;

: position!  ( n -- )
  s>d file reposition-file throw ;

: position-  ( n -- )
  position@ swap -  position! ;

( Formatter )
8 constant /date
5 constant /frame

: d>c    48 + ;
: c>d    48 - ;

: ten@  ( a -- n )
  a!  c@+ c>d 10 *  c@+ c>d  + ;

: ten!  ( n a -- )
  a!  10 /mod  d>c c!+  d>c c!+ ;

: frame@  ( a -- time status )
  a!  c@+ push
  a ten@ 100 *  a ten@ +
  pop ;

: frame!  ( time status a -- )
  a!  c!+
  100 /mod  a ten!  a ten! ;

: date@  ( a -- n )
  push 0. pop /date >number  drop drop d>s ;

: date!  ( date a -- )
  a!  3 for 100 /mod next
  a ten! a ten!  a ten!  a ten! ;

( Line )
64 constant /line
variable #line
create 'line  /line allot
variable commit-offset
  
: line!  ( -- n )  \ only overwrite 'line if something was read
  here /line read if
    dup #line !
    dup push here 'line pop move
    position@ over 1+ -  commit-offset !
  then ;
  
: +#line  ( n -- )
  #line +! ;

: .line  ( -- )
  'line #line @ type ;

: commit  ( -- )
  commit-offset @ position!
  'line #line @ write ;

: ff  ( -- )
  begin line! while cr .line repeat ;

: #frames  ( -- )
  #line @  /date -  /frame / ;

: .frames  ( -- )
  begin line! while cr #frames . repeat ;

: 'frame  ( n -- a )
  /frame *  /date +  'line + ;
 
: frame  ( n -- time status )
  'frame frame@ ;

: last  ( -- index-of-last-frame )
  #frames 1- ;

( Time )
: time>min  ( time -- n )  100 /mod  60 *  + ;
: min>time  ( n -- time )  60 /mod  100 *  + ;
  
: t-  ( t t' -- t-t' )
  time>min swap time>min swap  -  min>time ;

: t+  ( t t' -- t+t' )
  time>min swap time>min swap  + min>time ;

: day     ( -- date )  time&date 100 * +  100 * +  push drop drop drop pop ;
: hour    ( -- time )  time&date drop drop drop push drop drop pop 100 * ;
: minute  ( -- time )  time&date drop drop drop drop nip ;
: now     ( -- time )  hour minute + ;

( User commands )
char + constant opentag
bl     constant closetag
 
: open?    ( status -- f )  opentag = ;
: closed?  ( status -- f )  closetag = ;

: close  ( time -- )
  last frame closed? if drop drop exit then drop
  t-  closetag  last 'frame frame!
  .line ;

: open  ( time -- )
  last frame open? abort" Frame open, close it first" drop
  opentag  #frames 'frame frame!
  /frame +#line
  .line ;

: #  ( -- time ) 
  0  #frames 1- for 
    r@ 1- frame drop t+
  next
  last frame closed? if drop t+ exit then drop
  now swap t- + ;

