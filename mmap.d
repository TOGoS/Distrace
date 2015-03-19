#!/usr/bin/env rdmd

import std.string : format;
import std.conv : octal;
import std.stdio : writeln;

import core.sys.posix.sys.mman;
import core.sys.posix.fcntl : fcntl_open = open, O_CREAT;

class MMapped {
    int fd;
    void *begin;
    void *end;
    
    this(int fd, void *begin, void *end) {
        this.fd = fd;
        this.begin = begin;
        this.end = end;
    }
    
    @property size_t size() { return end-begin; }
    
    static MMapped open(string filename, int openFlags, int openMode, int prot, int flags) {
        int fd = fcntl_open(cast(const char*)filename, openFlags, openMode);
        void *begin = MAP_FAILED;
        size_t length = 1<<31;

      attemptMmap:
        begin = mmap(null, length, prot, flags, fd, 0);
        if( begin == MAP_FAILED && length >= 0x200000 ) {
            length >>= 1;
            goto attemptMmap;
        }
        
        if( begin == MAP_FAILED ) throw new Exception(format("Failed to mmap '%s' from 0 to 0x%x", filename, length));
        void *end = begin + length;
        return new MMapped(fd, begin, end);
    }
    
    void *at(long offset) {
        if( offset > end-begin ) {
            return null;
        } else {
            return begin + offset;
        }
    }
}

struct Foo {
    ulong blemish;
}

void main() {
    MMapped mmap = MMapped.open("file.dat", O_CREAT, octal!644, PROT_READ, MAP_SHARED);
    writeln(format("Mmaped memory begins at 0x%x and is 0x%x bytes long.",
                   cast(long)mmap.begin, cast(long)mmap.size));
    Foo *theFoo = cast(Foo*)mmap.at(0);
    writeln("Blemish=", theFoo.blemish);
}
