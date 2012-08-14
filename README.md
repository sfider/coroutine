# coroutine v0.1 #

This project aims to implement coroutines in C++ just for fun of it :)

For now there is only a implementation for iOS arm7 with omission of VFP registers. Works with both LLVM GCC 4.2 and Apple LLVM compiler 4.0, but only with optimizations disabled (-O0).

Additional 'asm' directives allow for placing breakpoints in Xcode.

Tested on iPhone 4 with iOS 5.1.1.

