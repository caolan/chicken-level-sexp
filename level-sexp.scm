(module level-sexp

;; exports
(level-sexp)

(import scheme chicken)
(use level interfaces lazy-seq ports)


(define (read-value x)
  (with-input-from-string x read))

(define (write-value x)
  (call-with-output-string (cut write x <>)))


(define level-sexp-implementation
  (implementation level-api

    (define (level-get resource key)
      (read-value (db-get resource key)))

    (define (level-get/default resource key default)
      (condition-case (read-value (db-get resource key))
        ((exn level not-found) default)))

    (define (level-put resource key value #!key (sync #f))
      (db-put resource key (write-value value) sync: sync))

    (define (level-delete resource key #!key (sync #f))
      (db-delete resource key sync: sync))

    (define (level-batch resource ops #!key (sync #f))
      (db-batch
       resource
       (map (lambda (op)
              (let ((method (car op)))
                (if (eq? 'put method)
                    `(put ,(cadr op) ,(write-value (caddr op)))
                    op)))
            ops)
       sync: sync))

    (define (level-keys resource #!key start end limit reverse fillcache)
      (db-keys resource
               start: start
               end: end
               limit: limit
               reverse: reverse
               fillcache: fillcache))

    (define (level-values resource #!key start end limit reverse fillcache)
      (lazy-map read-value
                (db-values resource
                           start: start
                           end: end
                           limit: limit
                           reverse: reverse
                           fillcache: fillcache)))

    (define (level-pairs resource #!key start end limit reverse fillcache)
      (lazy-map
       (lambda (p)
         (cons (car p) (read-value (cdr p))))
       (db-pairs resource
                 start: start
                 end: end
                 limit: limit
                 reverse: reverse
                 fillcache: fillcache)))
    ))

(define (level-sexp db)
  (make-level 'level-sexp level-sexp-implementation db))

)
