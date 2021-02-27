# tacc
Tacc is a command-line tool for accounting time. You tell it when you start
doing something and again when you stop/pause doing it. Tacc will keep record
so you can check how much time has been spent in total.

The thing to be tracked can be anything: a task, a project, a study session,
work hours. The author has used it for all of these, some of them
simultaneously.

## Prerequisites
Tacc is written in nop [1] and needs the interpreter to be found in $PATH. Also
make sure nop can find its own libraries.

## Install
Copy `tacc.ns` to a directory in your $PATH. For example,
```
% cp /path/to/tacc.ns ~/bin/tacc
```

## Run
Records of time are kept in files, and each thing to be tracked has its own
separate file. Tacc checks the TACCFILE environment variable to know which file
to work on at each invocation. If the file does not exist, tacc will create it.

There are two modes of operation, interactive and batch. Interactive mode
presents a shell in which to execute commands. To enter such mode, run
```
% TACCFILE=project1.tacc tacc
ok 
```
The `ok` prompt shows that tacc is ready.

Batch mode expects commands to be passed directly on tacc invocation:
```
% TACCFILE=work.tacc tacc now start  now 35 + stop  commit
20210227+1752
20210227 0035
```

## Commands
Tacc uses postfix notation to interpret commands and their arguments. The `+`
command, for example, expects the two numbers to be added to appear before
itself, as in `1240 32 +`.

Some commands operate on time values. A time value is a 4-digit number
formatted as `HHmm`, where `HH` represents the hours in 24h format and `mm`
represents the minutes, e.g. 1520 is 20 minutes past 15h/3pm. When a time value
represents only minutes, the two digits of the hour may be omitted, e.g. 35
means 35 minutes.

### start
`start` expects a time value to mark the start of a period. On success it
prints the current record.

To start a period at 0248,
```
ok 0248 start
20210227+0248
```

### stop
`stop` expects a time value to mark the end of a period. On success it prints
the current record.

Supposing the previous period started at 0248, to stop at 0300,
```
ok 0300 stop
20210227 0012
```

### +
`+` expects two time values, sums them, and leave the resulting time value
avaliable to commands that need one. On success it doesn't output anything.

To add half an hour to 1328,
```
ok 1328 30 +
```

### -
`-` expects two time values, subtracts the second from the first, and leave the
resulting time value avaliable to commands that need one. On success it
doesn't output anything.

To subtract half an hour from 1328,
```
ok 1328 30 -
```

### now
`now` provides a time value representing the current time. On success it
doesn't output anything.

To start a period now,
```
ok now start
```

### commit
In interactive mode, changes to the current record are not saved to TACCFILE
automatically. `commit` saves the current state of the record to TACCFILE.

In batch mode, `commit` is always executed after processing all the commands
passed, and doesn't need to be explicitly used.

On success it doesn't output anything.

### revert
In case you made a mistake in a command, `revert` restores the state of the
current record to the one saved in TACCFILE. On success it prints the current
record after reverting.

To revert a mistaken start,
```
ok now start
20210227+1940
ok revert
20210227
```

### `#`
`#` outputs the total time spent today.

## References
[1] https://github.com/iru-/nopforth

