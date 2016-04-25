# dysp-d017

A C64 demo effect, as published on [codebase64](http://codebase64.org/).

A D.Y.S.P. using $d017
======================

A simple d.y.s.p. using $d017 to keep the timing in the side border-loop
constant. I wrote this to get my old VIC-tricks up to speed again. It is most
likely the first technique I used to do a d.y.s.p.

For an explanation of the code, look at the source, or read
[the article](http://codebase64.org/doku.php?id=base:dysp_d017).


Assembling the code
-------------------

The code can be assembled using
[64tass](https://sourceforge.net/projects/tass64/):
`64tass -C -a -o demo.prg main.asm`.
Or simple invoke `make`.

There's an additional target: `make x64`, which will assemble the code and
then run VICE's x64 binary. Currently it references `/usr/local/bin/x64` my
copy of the VICE current build, adjust accordingly.


SID tune
--------

Currently the code references a tune from the
[High Voltage SID Collection](http://www.hvsc.c64.org/), located in my home
directory, so you'll have to comment that out, or alter the reference to point
to your local copy of the HVSC.


TODO
----

* Make the sid tune optional (using conditional assembly)
* Don't hardcode the x64 binary in the Makefile

