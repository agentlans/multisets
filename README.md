# Multisets

Library of set operations on multisets

Includes union, intersection, difference, sum, and subset of multisets.
Multisets are expressed as vectors of sorted elements.

## Install

1. Clone this repository
2. Copy the whole directory to `~/common-lisp/` or to another [ASDF](https://common-lisp.net/project/asdf/)-accessible place

## Use

:heavy_exclamation_mark: **Important:** multisets are represented as sorted vectors.
You must sort your vectors before calling the functions in this library!
   There is no input validation.

Elements in the multisets are sorted and compared using the generic functions `X=` and `X<`, respectively.
These compare numeric values, characters, and strings (case-sensitive).

To load the library:

```lisp
(asdf:load-system :multisets)
(in-package :multisets)
```

Set operations

| Function | Description |
| --- | --- |
|`(S-UNION set1 set2)` | for each element, the max number of times it appears in both sets |
|`(S-INTERSECTION set1 set2)` | for each element, the minimum number of times it appears in both sets |
|`(S-DIFFERENCE set1 set2)` | how many more of each element is in set1 than set2 |
|`(S-SUM set1 set2)` | multiset with all elements in set1 and set2 |
|`(S-SUBSET set1 set2)` | returns T if set2 has as least as many copies of each element in set1 |

Query operations

| Function | Description |
| --- | --- |
| `(S-CONTAINS s x)` | returns whether x is in multiset s and the index at which x is supposed to appear |
| `(S-COUNT s x)` | returns the number of times x is present in multiset s |

## Frequently Asked Questions

**Why not use Common Lisp's functions like UNION or SET-DIFFERENCE?**

They compare sequence elements pairwise so they run in O(n^2) time.
The functions in this library run in O(n) time or better.

**Why use sorted vectors to represent sets instead of hash tables?**

1. The keys are kept in order.
2. It's easier to compare and serialize vectors than hash tables.

Known issues:

- It's possible to have distinct Lisp objects that are equal under comparison.
	If that happens, the algorithm will choose the first object it sees
	and replace all other objects that are equal to it in the output.
	For set theory purposes, those equal objects are considered interchangeable.

- This library isn't optimal for querying the same sets repeatedly.
	There are faster algorithms using hash tables or tables of counts
	rather than sorted vectors.

Future directions

- custom comparators `=` and `<` for each function

## Author, License

Copyright :copyright: 2021 Alan Tseng

MIT License

