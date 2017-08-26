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
32 constant Lmax
variable fileid
create   line  Lmax allot
variable #line
variable lastpos  \ position of start last line

: dat  s" TIMESFILE" getenv r/w ;

: new
  dat create-file
  if ." failed to create data file" cr drop bye then ;

: fileid!  dat open-file if drop new then fileid ! ;
: file   fileid @ ;

: line!
  line Lmax file read-line throw drop
  dup if dup #line ! then ;

: file!  ( a n -- )
  file write-file throw
  file flush-file throw ;

: position file file-position throw d>s ;

( Record fetching )
4 constant DTLEN

: date@
  0 8 0 do line i + c@ c>n + 10 * loop 10 / ; 

: dt   1- DTLEN 1+ * 9 + ;
: dt@  line +  dup cc>n >r  2 + cc>n r> ;
: dt?  dt #line @ DTLEN - < ;
: lastdt  1 begin dup dt? while 1+ repeat 1- dt ;

( Record storing )
: sp!    bl here c!  here 1 file! ;
: date!  day date>s file! sp! ;
: mh!    here nn>s file!  here nn>s file! sp! ;


( Commands )
: total
  drop 0 >r
  1 begin dup dt? while
    dup dup dt dt@ mh>m . cr
    1+
  repeat rdrop ;

: open  ( n -- )  m>mh mh! ;

: close ( n -- )
  lastdt dup >r  dt@ mh>m - m>mh
  lastpos @ r> + s>d file reposition-file throw
  mh! ;

( Initialization )

: today?  date@ day = ;

: read   begin position line! while lastpos ! repeat drop ;
: init?  read today? 0= ;

: setup
  line Lmax erase
  fileid!
  init? if date! then ;

: usage  ." usage: " sourcefilename type ."  command " cr bye ;

: run
  argc @ 2 < if usage then
  next-arg sfind
  if now swap execute
  else ." command error: " type cr then ;

setup run bye
