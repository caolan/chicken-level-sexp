(use test level-sexp level leveldb lazy-seq)

(define db (level-sexp (open-db "testdb")))

(test-group "level-sexp"
  (db-put db "foo" '((name . "test")))
  (test "put and get"
        '((name . "test"))
        (db-get db "foo"))
  (test "get/default exists"
        '((name . "test"))
        (db-get/default db "foo" 'DEFAULT))
  (test "get/default missing"
        'DEFAULT
        (db-get/default db "asdf" 'DEFAULT))
  (db-delete db "foo")
  (test "delete then get aborts with not-found condition"
        'MISSING
        (condition-case (db-get db "foo")
          ((exn level not-found) 'MISSING)))
  (db-batch db
            '((put "foo" 123)
              (put "bar" ((name . "test")))
              (put "baz" (a b c))))
  (test "get keys after batch"
        '("bar" "baz" "foo")
        (lazy-seq->list (db-keys db)))
  (test "get values after batch"
        '(((name . "test")) (a b c) 123)
        (lazy-seq->list (db-values db)))
  (test "get pairs after batch"
        '(("bar" . ((name . "test")))
          ("baz" . (a b c))
          ("foo" . 123))
        (lazy-seq->list (db-pairs db)))
  )

(test-exit)
