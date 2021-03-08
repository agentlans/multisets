;;;; package.lisp

(defpackage #:multisets
  (:use #:cl)
  (:export
   :list->vector
   :vector->list
   :s-union
   :s-intersection
   :s-difference
   :s-sum
   :s-subset
   :s-contains
   :s-count))
