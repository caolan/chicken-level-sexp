# level-sexp

Read and write s-expressions to a level implementation.

```scheme
(use leveldb level level-sexp)

(define db
  (level-sexp (open-db "testdb")))

(db-put db "key" '((name . "test")))
(db-get db "key") ;; => ((name . "test"))
```
