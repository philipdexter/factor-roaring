! Copyright (C) 2018 Philip Dexter.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel roaring tools.test ;
IN: roaring.tests

{ t } [ <roaring> dup 101 swap insert 101 swap query ] unit-test
{ f } [ <roaring> dup 101 swap insert 0 swap query ] unit-test
{ f } [ <roaring> dup 0b0000000000000100 swap insert 0b10000000000000100 swap query ] unit-test
{ t } [ <roaring> dup 0b00000000000000100 swap insert 0b00000000000000100 swap query ] unit-test
{ t } [ <roaring> dup 0b10000000000000100 swap insert 0b10000000000000100 swap query ] unit-test
{ t } [ <roaring> dup 0b00000000000000001 swap insert dup 0b10000000000000001 swap insert dup 0b110000000000000001 swap insert 0b0000000000000001 swap query ] unit-test
{ t } [ <roaring> dup 0b00000000000000001 swap insert dup 0b10000000000000001 swap insert dup 0b110000000000000001 swap insert 0b10000000000000001 swap query ] unit-test
{ t } [ <roaring> dup 0b00000000000000001 swap insert dup 0b10000000000000001 swap insert dup 0b110000000000000001 swap insert 0b110000000000000001 swap query ] unit-test
