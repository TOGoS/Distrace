#!/usr/bin/env rdmd
import std.stdio;

import core.sys.posix.sys.mman;
import core.sys.posix.fcntl;
import std.conv : octal;

struct Foo {
  ulong blemish;
}

void main() {
  int fh = open("file.dat", O_CREAT, octal!644);
  Foo *le_map = cast(Foo *)mmap(null, 2<<30, PROT_READ, MAP_SHARED, fh, 0);
  writeln("Hi! ", fh, " ptr=",le_map.blemish);
}
