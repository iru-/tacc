#! /usr/bin/env gforth

warnings off

( Number-string convertion )
: n>c  48 + ;
: c>n  48 - ;

: cc>n  ( a -- n )
  dup c@ c>n 10 *
  swap 1+ c@ c>n + ;

: nn>s  ( n a -- a 2 )
  >r dup 10 <
  if    '0' r@ c!
  else  10 /mod n>c r@ c!
  then  n>c r@ 1+ c!  r> 2 ;

: date>s  ( n -- a 8 )
  100 /mod swap here 6 + nn>s drop drop
  100 /mod swap here 4 + nn>s drop drop
  100 /mod swap here 2 + nn>s drop drop
  here nn>s drop 8 ;


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

: fileid!  dat open-file if drop new then fileid ! ;
: file   fileid @ ;

: >file  ( a n -- )  file write-file throw ;

: 0line  line Lmax erase ;

: line!
  line Lmax file read-line throw drop
  dup if dup #line ! then ;

: line>s  ( -- a n )  line #line @ ;

: .line  line>s type ;

: cur  ( -- a )  line line# @ + ;

: >line  ( a n -- )
  >r  cur r@ move
  r> line# +!  line# @ #line ! ;

: c>line  ( c -- )  here c!  here 1 >line ;

variable commitoff
: commit
  commitoff @ s>d file reposition-file throw
  line>s  >file
  10 here c!  here 1 >file
  file flush-file throw ;

: position  file file-position throw d>s ;

( Record fetching )
4 constant DTLEN

: date@  ( -- n )
  0 8 0 do line i + c@ c>n + 10 * loop 10 / ;

: mh@  ( a -- n n )
  dup cc>n >r  2 + cc>n r> ;

: status  ( n -- a )  1- 5 * 8 +  line + ;
: status?  status line>s DTLEN - +  < ;
: laststatus  1 begin dup status? while 1+ repeat 1- status ;

: dt  ( n -- a )  status 1+ ;
: dt>m  ( n -- m )  dt mh@ mh>m ;

( Record storing )
: sp!    bl c>line ;
: date!  day date>s >line ;
: mh!    here nn>s >line  here nn>s >line ;

( Commands )
: open  ( n -- )  '+' c>line  m>mh mh! ;

: close  ( n -- )
  laststatus dup >r 1+  mh@ mh>m - m>mh
  r> line - line# !  sp! mh! ;

: opendt?  ( n -- f )  status c@ '+' = ;

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
  while  commitoff !
  repeat drop ;


: setup
  0line fileid! read
  init? if date! position commitoff ! then ;

: usage  ." usage: " sourcefilename type ."  command " cr bye ;

: run
  argc @ 2 < if usage then
  next-arg sfind
  if now swap execute
  else ." command error: " type cr then ;

setup \ run bye
