#lang racket/base

(require racket/contract/base)
(provide (contract-out
          [assoc-lens
           (->* (any/c) (#:is-equal? (-> any/c any/c boolean?))
                (lens/c (listof pair?) any/c))]
          [assv-lens
           (-> any/c (lens/c (listof pair?) any/c))]
          [assq-lens
           (-> any/c (lens/c (listof pair?) any/c))]
          ))

(require fancy-app
         lens/private/base/main)

(module+ test
  (require rackunit lens/private/test-util/test-lens)
  (define assoc-list '((a . 1) (b . 2) (c . 3))))


(define (assoc-get assoc-list key #:is-equal? [equal? equal?])
  (define assoc-pair (assoc key assoc-list equal?))
  (and assoc-pair (cdr assoc-pair)))

(module+ test
  (check-equal? (assoc-get assoc-list 'b) 2))


(define (assoc-set assoc-list key value #:is-equal? [equal? equal?])
  (define (set-assoc-pair assoc-pair)
    (if (equal? (car assoc-pair) key)
        (cons (car assoc-pair) value)
        assoc-pair))
  (map set-assoc-pair assoc-list))

(module+ test
  (check-equal? (assoc-set assoc-list 'b 200) '((a . 1) (b . 200) (c . 3))))


(define (assoc-lens key #:is-equal? [equal? equal?])
  (define get (assoc-get _ key #:is-equal? equal?))
  (define set (assoc-set _ key _ #:is-equal? equal?))
  (make-lens get set))

(module+ test
  (define assoc-b-lens (assoc-lens 'b))
  (check-lens-view assoc-b-lens assoc-list 2)
  (check-lens-set assoc-b-lens assoc-list 200
                  '((a . 1) (b . 200) (c . 3))))


(define (assv-lens assv-key)
  (assoc-lens assv-key #:is-equal? eqv?))

(module+ test
  (define assv-2-lens (assv-lens 2))
  (define assv-list '((1 . a) (2 . b) (3 . c)))
  (check-lens-view assv-2-lens assv-list 'b)
  (check-lens-set assv-2-lens assv-list 'FOO
                  '((1 . a) (2 . FOO) (3 . c))))


(define (assq-lens assq-key)
  (assoc-lens assq-key #:is-equal? eq?))

(module+ test
  (define assq-a-lens (assq-lens 'a))
  (define assq-list '((a . 1) (b . 2) (c . 3)))
  (check-lens-view assq-a-lens assq-list 1)
  (check-lens-set assq-a-lens assq-list 100
                  '((a . 100) (b . 2) (c . 3))))

