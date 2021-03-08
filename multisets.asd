;;;; multisets.asd

(asdf:defsystem #:multisets
  :description "Set operations on multisets"
  :author "Alan Tseng"
  :license  "MIT License"
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "multisets")))
