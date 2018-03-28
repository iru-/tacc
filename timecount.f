#! /usr/bin/env sf

include /Users/iru/src/4utils/cf.f
include /Users/iru/src/4utils/unix.f

( Number-string conversion )
: n>c  48 + ;
: c>n  48 - ;

: cc>n  ( a -- n )
  a! c@+ c>n 10 *  c@ c>n + ;

: nn>s  ( n a -- )
  a! dup 10 <
  if    drop [char] 0 c!+
  else  drop 10 /mod n>c c!+
  then  n>c c! ;

: date>s  ( n -- )
  100 /mod swap here 6 + nn>s
  100 /mod swap here 4 + nn>s
  100 /mod swap here 2 + nn>s
  here nn>s ;


( Time )
: day     ( -- n )  time&date 100 * +  100 * + >r  drop drop drop  r> ;
: hour    ( -- n )  time&date drop drop drop >r drop drop r> ;
: minute  ( -- n )  time&date drop drop drop drop nip ;
: now     ( -- n )  hour 60 *  minute + ;

: mh>m    ( m h -- m )  60 * + ;
: m>mh    ( m -- m h )  60 /mod ;


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

: fileid!  dat open-file if nip new swap then drop fileid a! ! ;
: file   fileid a! @ ;

: >file  ( a n -- )  file write-file throw ;

: 0line  line Lmax erase ;

: line!  ( -- n )
  line Lmax file read-line throw drop
  if dup #line a! ! then  nip ;

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

: position  ( -- n )  file-position throw d>s ;

( Record fetching )
4 constant DTLEN

: date@  ( -- n )
  line a!
  0 8 for  c@+ c>n + 10 *  next
  10 / ;

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
: >number  ( a -- n )
  push 0. pop count >number drop drop d>s ;

: get-time  ( -- m )
  [char] : word count 2 < abort" Invalid hours" cc>n
  bl word count 2 < abort" Invalid minutes" cc>n
  swap mh>m ;

: open  ( n -- )
  get-time [char] + c>line  m>mh mh! .line ;

: close  ( n -- )
  get-time
  line# a! -5 +!  sp!
  cur mh@  mh>m - m>mh  mh! .line ;

: opendt?  ( n -- f )  status a! c@ [char] + = ;

: #  ( -- n )
  0 >r 1
  begin  dup status?
  while  dup dt>m  over opendt? if now swap - then r> + >r 1+
  repeat drop r> m>mh . . ;

( Initialization )

: today?  date@ day = ;
: init?   today? 0= ;

: read
  begin
    file position line! dup
  while
    commitoff a! !
  repeat drop ;

: setup
  0line fileid! read init?
  if    drop date! file position commitoff a! !
  else  drop #line a! @ line# a! !
  then ;

setup
