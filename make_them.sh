#!/bin/sh
make && (cd ../git-1.2.6; rm git; make) && (cd ../nitfol-0.5 ; rm newnitfol ; make newnitfol) && (cd ../garglk-read-only/terps/agility/; rm glkagil; make -f Makefile.glk glkagil)