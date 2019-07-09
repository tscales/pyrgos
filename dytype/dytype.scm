(module dytype (check synthesize repl)
  (import scheme)
  (define check
    (lambda (gamma expr type)
      (equal? type (synthesize gamma expr))
    )
  )
  (define synth-symbol
    (lambda (gamma expr)
      (let ((judgment (assq expr gamma))) (if judgment (cdr judgment) #f))
    )
  )
  (define func-type?
    (lambda (type)
      (if (and type (list? type) (eq? '-> (car type)) (list? (cdr type))) (cdr type) #f)
    )
  )
  (define synth-appl
    (lambda (gamma expr)
      (let* ((type (synthesize gamma (car expr)))
             (i-and-o (func-type? type))
            )
        (if (and i-and-o (check gamma (cdr expr) (cdr i-and-o)))
            (cdr i-and-o)
            #f
        )
      )
    )
  )
  (define synthesize
    (lambda (gamma expr)
      (cond ((number? expr) '*)
            ((symbol? expr) (synth-symbol gamma expr))
            ((pair? expr) (cond ((eq? 'lambda (car expr)) #f)
                                (else (synth-appl gamma expr))
                          )
            ) (else #f)
      )
    )
  )

  (define repl-with
    (lambda (gamma)
      (display "2-t> ")
      (let [(x [read])]
        (cond [(equal? x ',q) '()]
              (else (display (synthesize gamma x))
                    (newline)
                    (repl-with gamma))
        )
      )
    )
  )
  (define repl
    (lambda ()
      (display ">> dytype\n")
      (repl-with '((+ (* -> *))))
      (display "dytype >>\n")
    )
  )
)
