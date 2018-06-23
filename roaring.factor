! Copyright (C) 2018 Philip Dexter.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors binary-search bit-sets kernel locals math math.order
random sequences sequences.extras sorting.quick typed variants vectors
;

IN: roaring

VARIANT: chunk
    bs-container: { { bs bit-set } } ! TODO use this
    vector-container: { { vector vector } }
    ! TODO run-container
    ;

<PRIVATE

GENERIC: (index) ( key chunk -- ? )
GENERIC: (set) ( key chunk -- )

M:: vector-container (index) ( v .vec -- ? )
    .vec vector>> :> vec
    vec [ v swap [ >fixnum ] bi@ <=> ] search [
        swap drop
        v [ >fixnum ] bi@ =
    ] [ ] if* ;

M:: vector-container (set) ( v .vec -- )
    .vec vector>> :> vec
    vec [ v swap [ >fixnum ] bi@ <=> ] search [
        dup v = [ 2drop ] [
            v swap < [ ] [ 1 + ] if :> index
            v index vec insert-nth!
        ] if
    ] [ drop v vec push ] if* ;

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

: random-op ( -- op ) { [ query drop ] [ insert ] } random ; inline

:: bench ( n -- )
    <roaring> :> roaring
    n [ random-32 roaring random-op call( n roaring -- ) ] times
    ; inline

:: same-bucket-bench ( n -- )
    <roaring> :> roaring
    n [ random-32 low16 roaring random-op call( n roaring -- ) ] times
    ; inline
