#! /usr/bin/env gforth

warnings off
include cf.f

( Number-string convertion )
: n>c  48 + ;
: c>n  48 - ;

: cc>n  ( a -- n )
  a! c@+ c>n 10 *  c@ c>n + ;

: nn>s  ( n a -- )
  a! dup 10 <
  if    '0' c!+
  else  10 /mod n>c c!+
  then  n>c c! ;

: date>s  ( n -- )
  100 /mod swap here 6 + nn>s
  100 /mod swap here 4 + nn>s
  100 /mod swap here 2 + nn>s
  here nn>s ;


( Time )
: day     time&date 100 * +  100 * + >r  drop drop drop  r> ;
: hour    time&date drop drop drop >r drop drop r> ;
: minute  time&date drop drop drop drop nip ;

: now  hour 60 * minute + ;

: mh>m  60 * + ;
: m>mh  60 /mod ;


( File )
256 constant Lmax
variable fileid
create   line  Lmax allot
variable #line
variable line#

: dat  s" TIMESFILE" getenv r/w ;

: new
  dat create-file
  if ." failed to create data file" cr drop bye then ;

: fileid!  dat open-file if drop new then fileid a! ! ;
: file   fileid a! @ ;

: >file  ( a n -- )  file write-file throw ;

: 0line  line Lmax erase ;

: line!
  line Lmax file read-line throw drop
  dup if dup #line a! ! then ;

: line>s  ( -- a n )  line #line a! @ ;

: .line  line>s type ;

: cur  ( -- a )  line line# a! @ + ;

: >line  ( a n -- )
  push cur r@ move
  pop line# a! +!
  @ #line a! ! ;

: c>line  ( c -- )  here a! c!  here 1 >line ;

variable commitoff
: commit
  commitoff a! @ s>d file reposition-file throw
  line>s  >file
  10 here a! c!  here 1 >file
  file flush-file throw ;

: position  file file-position throw d>s ;

( Record fetching )
4 constant DTLEN

: date@  ( -- n )
  line a! 0 7
  for  c@+ c>n + 10 *
  next 10 / ;

: mh@  ( a -- n n )
  dup cc>n >r  2 + cc>n r> ;

: status  ( n -- a )  1- 5 * 8 +  line + ;
: status?  status line>s DTLEN - +  < ;

: dt  ( n -- a )  status 1+ ;
: dt>m  ( n -- m )  dt mh@ mh>m ;

( Record storing )
: sp!    bl c>line ;
: date!  day date>s  here 8 >line ;
: mh!
  here nn>s here 2 >line
  here nn>s here 2 >line ;

( Commands )
: open  ( n -- )  '+' c>line  m>mh mh! .line ;

: close  ( n -- )
  line# a! -5 +!  sp!
  cur mh@  mh>m - m>mh  mh! .line ;

: opendt?  ( n -- f )  status a! c@ '+' = ;

: #  ( -- n )
  0 >r 1
  begin  dup status?
  while  dup dt>m  over opendt? if now swap - then r> + >r 1+
  repeat drop r> m>mh . . ;

( Initialization )

: today?  date@ day = ;
: init?   today? 0= ;

: read
  begin  position line!
  while  commitoff a! !
  repeat drop ;


: setup
  0line fileid! read init?
  if date! position commitoff a! !
  else #line a! @ line# a! !
  then ;

: usage  ." usage: " sourcefilename type ."  command " cr bye ;

: run
  argc a! @ 2 < if usage then
  next-arg sfind
  if now swap execute
  else ." command error: " type cr then ;

setup \ run bye
