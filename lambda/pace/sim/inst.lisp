;;; -*- Mode:LISP; Package:SIM; Readtable:CL; Base:10 -*-

(defvar *registers-per-frame* 16.)
(defvar *total-frames* 256.)


(defconst %%i-src-1-offset (byte 4 0))
(defprop %%i-src-1-offset t constant)
(defconst %%i-src-1-base (byte 3 4))
(defprop %%i-src-1-base t constant)
(defconst %%i-src-2-offset (byte 4 7))
(defprop %%i-src-2-offset t constant)
(defconst %%i-src-2-base (byte 3 11.))
(defprop %%i-src-2-base t constant)
(defconst %%i-dest-offset (byte 4 14.))
(defprop %%i-dest-offset t constant)
(defconst %%i-dest-base (byte 3 18.))
(defprop %%i-dest-base t constant)
(defconst %%i-immediate (byte 8 21.))
(defprop %%i-immediate t constant)

(defconst %%i-jump-adr (byte 24. 32.))
(defprop %%i-jump-adr t constant)
(defconst %%i-aluf (byte 24. 32.))
(defprop %%i-aluf t constant)

(defconst %%i-continuation (byte 3 64.))
(defprop %%i-continuation t constant)
(defconst %%i-jump-cond (byte 4 67.))
(defprop %%i-jump-cond t constant)
(defconst %%i-opcode (byte 4 71.))
(defprop %%i-opcode t constant)
(defconst %%i-stat (byte 4 75.))
(defprop %%i-stat t constant)
(defconst %%i-halt (byte 1 79.))
(defprop %%i-halt t constant)
(defconst %%i-noop-next-bit (byte 1 80.))
(defprop %%i-noop-next-bit t constant)
(defconst %%i-uses-alu (byte 1 81.))
(defprop %%i-uses-alu t constant)
(defconst %%i-unboxed-dest (byte 1 82.))
(defprop %%i-unboxed-dest t constant)

(defmacro def-sim-const (name val &optional documentation)
  `(progn 'compile
          (putprop ',name t 'constant)
          (defconst ,name ,val ,documentation)))

(def-sim-const %i-op-alu 0)
(def-sim-const %i-op-jump 1)
(def-sim-const %i-op-sim 2)
(def-sim-const %i-op-open 3)
(def-sim-const %i-op-tail-recursive-open 4)
(def-sim-const %i-op-call 5)
(def-sim-const %i-op-tail-recursive-call 6)
(def-sim-const %i-op-return 7)
(def-sim-const %i-op-store-immediate 8)
(def-sim-const %i-op-tail-recursive-call-indirect 9)

(def-sim-const %i-base-open 0)
(def-sim-const %i-base-active 1)
(def-sim-const %i-base-return 2)
(def-sim-const %i-base-global 3)
(def-sim-const %i-base-func 4)

(def-sim-const %i-jump-cond-unc 0)
(def-sim-const %i-jump-cond-less-than 1)
(def-sim-const %i-jump-cond-equal 2)
(def-sim-const %i-jump-cond-not-equal 3)
(def-sim-const %i-jump-cond-greater-than 4)
(def-sim-const %i-jump-cond-greater-or-equal 5)
(def-sim-const %i-jump-cond-data-type-equal 6)
(def-sim-const %i-jump-cond-data-type-not-equal 7)

(defvar *current-regadr*)
(defvar ra-commands-to-addresses)
(defvar ra-addresses-to-commands)

(defmacro def-reg-adr (name command size &optional printout-mode)
  (let ((o (intern (string-append "RA-" name "-O") 'sim))
        (e (intern (string-append "RA-" name "-E") 'sim))
        (read (intern (string-append "READ-" name) 'keyword))
        (write (intern (string-append "WRITE-" name) 'keyword)))
    `(progn 'compile
            (decf *current-regadr* ,size)
            (defconst ,o *current-regadr*)
            (defconst ,e (+ *current-regadr* ,size))
            (push (cons ',command *current-regadr*) ra-commands-to-addresses)
            (push (list *current-regadr* ',command ',read ',write ',printout-mode) ra-addresses-to-commands)
            ,(when (or (eq size 1)
                       (eq name 'opc))
               `(add-register ',command *current-regadr*))
            )))

(progn
  (clear-register-table)
  (setq *current-regadr* -1024.)
  (setq ra-commands-to-addresses nil)
  (setq ra-addresses-to-commands nil)
  (def-reg-adr |unused| |u| 1024.)
  (def-reg-adr open o *registers-per-frame*)
  (def-reg-adr active a *registers-per-frame*)
  (def-reg-adr return r *registers-per-frame*)
  (def-reg-adr frames f (* *registers-per-frame* *total-frames*))
  (def-reg-adr h-open ho *total-frames*)
  (def-reg-adr h-active ha *total-frames*)
  (def-reg-adr h-pc hpc *total-frames*)
  (def-reg-adr free-list-ptr flp 1)
  (def-reg-adr free-list fl *total-frames*)
  (def-reg-adr vma vma 1)
  (def-reg-adr md md 1)
  (def-reg-adr opc opc (* *pages-of-opcs* 256.) :opc)
  )