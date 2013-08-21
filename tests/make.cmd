@echo off
call "c:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"
mingw32-make -f Makefile.win %*
