#!/usr/bin/env rdmd

import std.bitmanip : nativeToBigEndian;
import core.sys.posix.unistd;

void main() {
  float x = 123.5f;
  ubyte[float.sizeof] x_fixed = nativeToBigEndian(x);
  write( 1, x_fixed.ptr, x_fixed.length );
}
