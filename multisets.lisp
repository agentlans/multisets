;; Multisets
;; 
;; MIT License
;; 
;; Copyright (c) 2021 Alan Tseng
;; 
;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject
;; to the following conditions:
;; 
;; The above copyright notice and this permission notice (including
;; the next paragraph) shall be included in all copies or substantial
;; portions of the Software.
;; 
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
;; KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
;; WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

(in-package #:multisets)

(defgeneric x= (x y)
  (:documentation "Generic equality to compare two elements."))

(defmethod x= ((x number) (y number))
  (= x y))
;; (x-equal 1 1)

(defmethod x= ((x character) (y character))
  (char= x y))

(defmethod x= ((x string) (y string))
  (string= x y))

(defmethod x= ((x symbol) (y symbol))
  (equal x y))

(defgeneric x< (x y)
  (:documentation "Generic less than to compare two elements of the same type."))

(defmethod x< ((x number) (y number))
  (< x y))

(defmethod x< ((x character) (y character))
  (char< x y))

(defmethod x< ((x string) (y string))
  (string< x y))

(defmethod x< ((x symbol) (y symbol))
  (string< (string x) (string y)))
;; (x< "a" "b")

(defun list->vector (lst)
  (make-array (length lst)
	      :initial-contents lst))

(defun counts (vec &key (as-list t))
  "Returns association list of elements of vec and the number of
times they appear, in order."
  (let ((i 0)
	(len (length vec))
	(out nil))
    (loop while (< i len)
	  do (let ((x (svref vec i))
		   (x-count 0))
	       ;; For each run of identical elements
	       (loop while (and (< i len)
				(x= (svref vec i) x))
		     do (progn
			  (incf x-count)
			  (incf i)))
	       ;; Write the item and the number of times it appears
	       (push (cons x x-count) out)))
    (let ((out2 (reverse out)))
      (if as-list
	  out2
	  (list->vector out2)))))
;; (counts #(a a b c c c))
;; (counts #("Hello" "world"))
;; (counts #(a b b c) :as-list nil)

(defun to-set (count-list)
  "Returns vector containing the keys of count-list
repeated by the number of times they occur."
  (list->vector
   (loop for (x . x-count) in count-list
	 append (loop for i from 1 to x-count
		      collect x))))
;; (to-set (counts #(a a b c c c)))

(defun vector->list (vec)
  "Returns list with same contents as the given vector."
  (loop for x across vec
	collect x))
;; (vector->list #(0 1 2))

(defmacro s-body (not-ss1 not-ss2 xs-equal x1-less x2-less)
  `(let* ((s1 (counts set1))
	  (s2 (counts set2))
	  (out nil))
     (declare (ignorable out))
     (labels ((tread (ss1 ss2)
		(cond ((not ss1) ,not-ss1)
		      ((not ss2) ,not-ss2)
		      (t (destructuring-bind (x1 . m1)
			     (car ss1)
			   (destructuring-bind (x2 . m2)
			       (car ss2)
			     (cond ((x= x1 x2)
				    (progn
				      ,xs-equal
				      (tread (cdr ss1) (cdr ss2))))
				   ((x< x1 x2)
				    (progn
				      ,x1-less
				      (tread (cdr ss1) ss2)))
				   (t (progn
					,x2-less
					(tread ss1 (cdr ss2)))))))))))
       (to-set (tread s1 s2)))))

(defun s-union (set1 set2)
  (s-body (append (reverse out) ss2)
	  (append (reverse out) ss1)
	  (let ((m (max m1 m2)))
	    (push (cons x1 m) out))
	  (push (cons x1 m1) out)
	  (push (cons x2 m2) out)))

(defun s-intersection (set1 set2)
  (s-body (reverse out)
	  (reverse out)
	  (let ((m (min m1 m2)))
	    (push (cons x1 m) out))
	  nil
	  nil))
;; (s-intersection #(a a b b c) #(a b b b d))

(defun s-difference (set1 set2)
  (s-body (reverse out)
	  (append (reverse out) ss1)
	  ;; Count of x1 in output = count of x1 in set1 - count of x1 in set2
	  (let ((m (- m1 m2)))
	    (if (> m 0)
		(push (cons x1 m) out))
	    nil)
	  (push (cons x1 m1) out)
	  nil))
;; (s-difference #(a a b c c d f) #(b c d e e))

(defun s-sum (set1 set2)
  (s-body (append (reverse out) ss2)
	  (append (reverse out) ss1)
	  (let ((m (+ m1 m2)))
	    (push (cons x1 m) out))
	  (push (cons x1 m1) out)
	  (push (cons x2 m2) out)))
;; (s-sum #(a b b) #(a b c))

(defun s-subset (set1 set2)
  (block nil
    (s-body (return t)
	    (return nil)
	    (when (not (<= m1 m2))
	      (return nil))
	    (return nil) ; set1 has element not in set2
	    nil))) ; set2 has element not in set1. Do nothing.
;; (s-subset #(a b b c d) #(a b b b c d))
;; (s-subset #() #(a b))

(defun s-contains (s x)
  "Returns T or NIL if x is an element of s. Also returns the index 
that x would've occupied in s."
  (cond ((= (length s) 0) (values nil 0)) ; empty set
	((x< x (svref s 0)) (values nil 0)) ; on left end
	((x< (svref s (- (length s) 1)) x)
	 (values nil (length s))) ; on right end
	(t (labels ((binary-search (a b)
		      (if (= b (+ a 1))
			  (if (x= (svref s b) x)
			      (values t b) ; Return first index where item matches
			      (values nil b)) ; or return nil
			  (let* ((c (floor (/ (+ a b) 2)))
				 (cx (svref s c)))
			    ;; Keep invariant s[a] < x <= s[b]
			    (if (or (x< x cx) (x= x cx))
				(binary-search a c)
				(binary-search c b))))))
	     (binary-search -1 (- (length s) 1))))))
;; (s-contains #(a a a b b b c e) 'd)

(defun s-count (s x)
  "Returns the number of times x appears in s."
  (multiple-value-bind (found index)
      (s-contains s x)
    (if (not found)
	0
	(let ((x-count 0))
	  (loop for i from index below (length s)
		while (x= (svref s i) x)
		do (incf x-count))
	  x-count))))
;; (s-count #(a b b c c c d) 'd)

