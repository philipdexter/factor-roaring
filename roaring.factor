! Copyright (C) 2018 Philip Dexter.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors binary-search kernel locals math math.order sequences
typed sorting.quick variants vectors bit-sets sequences.extras ;

IN: roaring

VARIANT: chunk
    bs-container: { { bs bit-set } } ! TODO use this
    vector-container: { { vector vector } }
    ! TODO run-container
    ;

<PRIVATE

GENERIC: (index) ( key chunk -- ? )
GENERIC: (set) ( key chunk -- )

M: vector-container (index) vector>> index >boolean ;
M: vector-container (set) vector>> swap suffix! [ <=> ] sort! ; ! TODO remove this sort

PRIVATE>

TUPLE: part { bucket fixnum } { chunk chunk initial: T{ vector-container f V{ } } } ;
C: <part> part

TUPLE: roaring { parts vector } ;
: <roaring> ( -- roaring ) 0 1 <vector> <vector-container> <part> 1vector roaring boa ; inline

TYPED: high43 ( x: fixnum -- y: fixnum ) -16 shift ; inline

TYPED: low16 ( x: fixnum -- y: fixnum ) 0xFFFF bitand ; inline

ERROR: no-buckets ;

TYPED:: search-bucket ( bucket: fixnum parts: vector -- part/?: maybe{ part } )
    parts [ bucket>> bucket [ >fixnum ] bi@ <=> ] search [
        swap drop
        dup bucket>> bucket = [ drop f ] unless
    ] [ no-buckets throw ] if* ; inline

TYPED:: insert ( n: fixnum roaring: roaring -- )
    n high43 :> bucket
    n low16 :> key
    bucket roaring parts>> search-bucket [
        chunk>> :> chunk
        key chunk (set)
    ] [
        roaring parts>> [ bucket>> bucket [ >fixnum ] bi@ <=> ] search
        bucket>> bucket > [ 1 + ] [ ] if :> index
        bucket key 1vector <vector-container> <part>
        index
        roaring parts>>
        insert-nth!
    ] if* ;

TYPED:: query ( n: fixnum roaring: roaring -- ?: boolean )
    n high43 :> bucket
    bucket roaring parts>> search-bucket [
        chunk>> :> chunk
        n low16 :> key
        key chunk (index)
    ] [ f ] if* ;
