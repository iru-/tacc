variable reg-a

: old@  @ ;
: old!  ! ;
: oldc@  c@ ;
: oldc!  c! ;
: old+!  +! ;

: a!  reg-a old! ;
: a   reg-a old@ ;
: @   a old@ ;
: !   a old! ;
: @+  @  a 4 + a! ;
: !+  !  a 4 + a! ;
: c@  a oldc@ ;
: c!  a oldc! ;
: c@+  c@  a 1 + a! ;
: c!+  c!  a 1 + a! ;
: +!  @ + ! ;

: push  postpone >r ; immediate
: pop   postpone r> ; immediate

