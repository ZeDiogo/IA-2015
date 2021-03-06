;;;    Projecto de Inteligencia Artificial     ;;;
;;;              2a Entrega                    ;;;
;;;               Grupo 54                     ;;;
;;;             Ana Galvao 75312               ;;;
;;;       Jose Diogo Oliveira 75255            ;;;
;;;             Andre Silva 75455              ;;;

(defconstant T-NLINHAS 18)  ; 0 a 17
(defconstant T-NCOLUNAS 10) ; 0 a 9

;;; cria-accao: inteiro x array -> accao
(defun cria-accao (pos_esq config)
    ; cria par com (posicao da peca, configuracao da peca)
    (cons pos_esq config)
)

;;; accao-coluna: accao-coluna: accao -> inteiro
(defun accao-coluna (accao)
    ; mostra posicao da peca a contar da esquerda
    (car accao)
)

;;; accao-peca: accao -> array
(defun accao-peca(accao)
    ; mostra configuracao da peca
    (cdr accao)
)

;;; cria-tabuleiro {} -> tabuleiro
(defun cria-tabuleiro ()
    ; criar o tabuleiro
    ; devolve tabuleiro vazio
    ; (make-array (list T-NLINHAS T-NCOLUNAS) :initial-element nil)
    ; criar a hash primeiro e depois iterar pelo numero de linhas e colunas
    ; umas hash e uma "lista" de pares key->value, portanto, vamos guardar a key
    ; sendo um cons da linha coluna e o value sendo nil ou true.
    ; eg.  "0 5" -> t , na linha zero coluna cinco existe uma peca
    (let ((tab (make-hash-table :test 'equal)))
        (dotimes (lin T-NLINHAS tab)
            (dotimes (col T-NCOLUNAS tab)
                (setf (gethash (cons lin col) tab) nil)
            )
        )
    )
)

;;; tabuleiro-preenchido-p: tabuleiro x inteiro x inteiro -> logico
(defun tabuleiro-preenchido-p (tabuleiro nlinha ncoluna)
    ; devolve true se tiver preenchida
    ; nil caso contrario
    ; (not (null (aref tabuleiro nlinha ncoluna)))
    (not (null (gethash (cons nlinha ncoluna) tabuleiro)))
)

;;; tabuleiro-altura-coluna: tabuleiro x inteiro -> inteiro
(defun tabuleiro-altura-coluna (tabuleiro ncoluna)
    ; devolve a posicao mais alta que esteja preenchida
    ; da coluna em questao
    ; devolve zero caso nao esteja preenchida
    ; altura iniciar a ZERO no let, para devolver 0 e nao nil
    ; quando a coluna nao tiver nenhuma peca
    (let ((altura 0))
        (dotimes (lin T-NLINHAS altura)  ; vou percorrer as linhas todas e returnar a altura
            (if (tabuleiro-preenchido-p tabuleiro lin ncoluna)  ; se a current altura nao for nil
                (setf altura (+ lin 1))  ; actualizo a var altura para a mais actual
            )
        )
    )
)

;;; tabuleiro-linha-completa-p: tabuleiro x inteiro -> logico
(defun tabuleiro-linha-completa-p (tabuleiro nlinha)
    ; devolve true se todas as posicoes da linha inteira
    ; estiverem preenchidas
    ; false, otherwise
    (dotimes (col T-NCOLUNAS t)
        (if (not (tabuleiro-preenchido-p tabuleiro nlinha col))
            (return nil)
        )
    )
)

;;; dentro-limites: nlinha x ncoluna -> logico
(defun dentro-limites (nlinha ncoluna)
    ; recebe numero de linha e coluna
    ; devolve True se posicao dentro dos limites
    ; limite das linhas [0, 17]
    ; limite das colunas [0, 9]
    ; ESTAA A FUNCIONAR
    (cond
        ((AND (>= nlinha 0)(< nlinha T-NLINHAS)(>= ncoluna 0)(< ncoluna T-NCOLUNAS)) T)
        (t nil)
    )
)

;;; peca-dentro-limites: linha x accao -> logico
(defun peca-dentro-limites (linha accao)
    ;Verifica se a peca a ser colocada est dentro do limites do tabuleiro
    ; se nao estiver devolve NIL da funcao resultad
    (let (
        (coluna (accao-coluna accao))  ; 0
        (numlinhaspeca (first (array-dimensions (accao-peca accao))))
        (numcolunaspeca (second (array-dimensions (accao-peca accao))))
        )

        (dotimes (l numlinhaspeca)
            (dotimes (c numcolunaspeca)
                (if (not (dentro-limites (+ linha l) (+ coluna c)))
                    (return-from peca-dentro-limites nil)
                )
            )
        )
        (return-from peca-dentro-limites t)
    )
)

;;; tabuleiro-preenche!: tabuleiro x inteiro x inteiro -> {}
(defun tabuleiro-preenche! (tabuleiro nlinha ncoluna)
    ; altera o tabuleiro recebido na pos nlinha ncoluna
    ; para ficar preenchido
    ; valida de os valores da nlinha e ncoluna sao validos
    ; (se estao dentro dos limites do campo)
    ; nao interessa o valor devolvido
    (cond
        ((not (dentro-limites nlinha ncoluna)) nil)
        (t (setf (gethash (cons nlinha ncoluna) tabuleiro) t))
    )
)

;;; tabuleiro-remove-linha!: tabuleiro x inteiro -> {}
(defun tabuleiro-remove-linha! (tabuleiro nlinha)
    ; remove a nlinha do tabuleiro
    ; fazendo com que as linhas consecutivas, descam
    ; nao interessa o valor devolvido (deve devolver nada)??
    (let ((linha-de-cima nil))
        (dotimes (col T-NCOLUNAS t)
            (loop for lin from nlinha to (- T-NLINHAS 1) do
                (progn
                    (cond
                        ((< lin (- T-NLINHAS 1)) (setf linha-de-cima (gethash (cons (+ lin 1) col) tabuleiro)))
                        (t (setf linha-de-cima nil))
                    )
                    (setf (gethash (cons lin col) tabuleiro) linha-de-cima)
                )
            )
        )
    )
)

;;; tabuleiro-topo-preenchido-p: tabuleiro -> logico
(defun tabuleiro-topo-preenchido-p (tabuleiro)
    ; devolve true se existir uma coluna preenchida
    ; na linha 17 do tabuleiro
    (dotimes (col T-NCOLUNAS nil)
        ;(format t "(aref tabuleiro (1- T-NLINHAS) col) = ~d ~%" (aref tabuleiro (1- T-NLINHAS) col))
        (if (tabuleiro-preenchido-p tabuleiro (1- T-NLINHAS) col)
            (return t)
        )
    )
)

;;; tabuleiros-iguais-p: tabuleiro x tabuleiro -> logico
(defun tabuleiros-iguais-p (tabuleiro1 tabuleiro2)
    ; devolve true se os 2 tabuleiros tiverem valores iguais
    (equalp tabuleiro1 tabuleiro2)
)

;;; tabuleiro->array: tabuleiro -> array
(defun tabuleiro->array (tabuleiro)
    ; recebe um tabuleiro e devolve um novo array com 18
    ; linhas e 10 colunas que em cada linha e coluna dever conter
    ; o valor logico
    ; o tabuleiro retornado e um novo objecto ( nao o mesmo que o tabuleiro)
    (let ((array (make-array (list T-NLINHAS T-NCOLUNAS) :initial-element nil)) )
        (maphash
            #'(lambda (key val) (setf (aref array (car key) (cdr key)) val))
            tabuleiro
        )
        (return-from tabuleiro->array array)
    )
)

;;; array->tabuleiro: array->tabuleiro
(defun array->tabuleiro (array)
    ; da a entrada do array com 18 linhas e 10 colunas
    ; devolve um tabuleiro object
    ; novo objecto (nao o mesmo que o array)
    (let ( (newtab (cria-tabuleiro)) )
        (dotimes (lin T-NLINHAS)
            (dotimes (col T-NCOLUNAS)
                (setf (gethash (cons lin col) newtab) (aref array lin col))
            )
        )
        (return-from array->tabuleiro newtab)
    )
)

;;; copia-tabuleiro: tabuleiro -> tabuleiro
(defun copia-tabuleiro (tabuleiro)
    ;funcao para copiar o antigo tabuleiro para um novo
    (let ((newtab (cria-tabuleiro)))
        (dotimes (lin T-NLINHAS)
            (dotimes (col T-NCOLUNAS)
                (setf (gethash (cons lin col) newtab) (gethash (cons lin col) tabuleiro))
            )
        )
    (return-from copia-tabuleiro newtab)
    )
)

;;; creates type Estado
(defstruct estado
    pontos              ; #num de pontos conseguidos ate ao momento
    pecas-por-colocar   ; lista de pecas ainda por colocar, com ordem de colocacao, letras da peca
    pecas-colocadas     ; lista de pecas ja colocadas, repr pelo simbolo, ordenada pela peca mais antiga
    tabuleiro           ; tabuleiro com as posicoes actualmente preechindas
)

;;; copia-estado: estado->estado
(defun copia-estado (estado)
    ; devolve novo estado cujo conteudo sera copiado do arg
    ; devolve novo objecto, nao destrutivo do antigo
    (make-estado
        :pontos (estado-pontos estado)
        :pecas-por-colocar (copy-list (estado-pecas-por-colocar estado))
        :pecas-colocadas (copy-list (estado-pecas-colocadas estado))
        :tabuleiro (copia-tabuleiro (estado-tabuleiro estado))
    )
)

;;; estados-iguais-p: estado x estado -> logico
(defun estados-iguais-p (estado1 estado2)
    ; devolve true se os 2 estados forem iguais
    (equalp estado1 estado2)
)

;;; estado-final-p: estado -> logico
(defun estado-final-p (estado)
    ; devolve true caso seja um estado final
    ; (jogador nao pode fazer mais jogadas) (pecas por colocar zerop)
    ; false caso contrario
    ; tiver atingido o topo ou nao tiver mais pecas por colocar
    (OR (zerop (length (estado-pecas-por-colocar estado)))          ; se nao tiver pecas por colocar
        (tabuleiro-topo-preenchido-p (estado-tabuleiro estado)))    ; se tiver o topo preenchido
)

;;;  creates type Problema
(defstruct problema
    estado-inicial  ; estado do problema de procura
    solucao         ; funcao recebe estado e devolve true se for a solucao, nil cc
    accoes          ; funcao recebe estado e devolve lista com acoes que sao possiveis para esse estado
    resultado       ; funcao que dado um estado devolve o estado sucessor  ?? ainda nao percebo ??
    custo-caminho   ; funcao que dado um estado devolve o custo do caminho desde o estado inicial
)

;;; solucao: estado -> logico
(defun solucao (estado)
    ; recebe um estado e devolve true se o estado
    ; recebido for solucao, nil otherwise
    ; solucao (true) se o topo nao tiver preenchido e se nao
    ; existirem pecas por colocar.
    ; (ter pontos nao interessa)
    (AND (zerop (length (estado-pecas-por-colocar estado)))             ;se nao tiver pecas por colocar
         (not (tabuleiro-topo-preenchido-p (estado-tabuleiro estado)))  ;se o topo nao estiver preenchido
    )
)

;;; peca-i: {} -> lista de accoes
; (
;     (0 . #2A((T) (T) (T) (T)))
;     (1 . #2A((T) (T) (T) (T)))
;     (2 . #2A((T) (T) (T) (T)))
;     (3 . #2A((T) (T) (T) (T)))
;     (4 . #2A((T) (T) (T) (T)))  ; T
;     (5 . #2A((T) (T) (T) (T)))  ; T
;     (6 . #2A((T) (T) (T) (T)))  ; T
;     (7 . #2A((T) (T) (T) (T)))  ; T
;     (8 . #2A((T) (T) (T) (T)))
;     (9 . #2A((T) (T) (T) (T)))
;     (0 . #2A((T T T T)))
;     (1 . #2A((T T T T)))
;     (2 . #2A((T T T T))) ;
;     (3 . #2A((T T T T))) ;  T T T T
;     (4 . #2A((T T T T))) ;
;     (5 . #2A((T T T T))) ;
;     (6 . #2A((T T T T)))
; )
(defun peca-i ()
    ; devolve uma lista de accoes correspondentes a peca i
    ; cria uma lista vazia e vai adicionando accoes com as colunas
    ; possiveis para esta peca especifica e com a sua configuracao
    (let (( lista (list) ))
        (dotimes (n T-NCOLUNAS)
            (setf lista (append lista (list (cria-accao n peca-i0))))
        )
        (dotimes (n (- T-NCOLUNAS 3) lista)
            (setf lista (append lista (list (cria-accao n peca-i1))))
        )
    )
)

;;; peca-l: {} -> lista de accoes
; (
;     (0 . #2A((T T) (T NIL) (T NIL)))
;     (1 . #2A((T T) (T NIL) (T NIL)))
;     (2 . #2A((T T) (T NIL) (T NIL)))  ; # Nil
;     (3 . #2A((T T) (T NIL) (T NIL)))  ; # Nil
;     (4 . #2A((T T) (T NIL) (T NIL)))  ; # #
;     (5 . #2A((T T) (T NIL) (T NIL)))
;     (6 . #2A((T T) (T NIL) (T NIL)))
;     (7 . #2A((T T) (T NIL) (T NIL)))
;     (8 . #2A((T T) (T NIL) (T NIL)))
;     (0 . #2A((T NIL NIL) (T T T)))
;     (1 . #2A((T NIL NIL) (T T T)))
;     (2 . #2A((T NIL NIL) (T T T)))
;     (3 . #2A((T NIL NIL) (T T T)))   ; #  #  #
;     (4 . #2A((T NIL NIL) (T T T)))   ; # nil nil
;     (5 . #2A((T NIL NIL) (T T T)))
;     (6 . #2A((T NIL NIL) (T T T)))
;     (7 . #2A((T NIL NIL) (T T T)))
;     (0 . #2A((NIL T) (NIL T) (T T)))
;     (1 . #2A((NIL T) (NIL T) (T T)))
;     (2 . #2A((NIL T) (NIL T) (T T)))  ;   # #
;     (3 . #2A((NIL T) (NIL T) (T T)))  ; nil #
;     (4 . #2A((NIL T) (NIL T) (T T)))  ; nil #
;     (5 . #2A((NIL T) (NIL T) (T T)))
;     (6 . #2A((NIL T) (NIL T) (T T)))
;     (7 . #2A((NIL T) (NIL T) (T T)))
;     (8 . #2A((NIL T) (NIL T) (T T)))
;     (0 . #2A((T T T) (NIL NIL T)))
;     (1 . #2A((T T T) (NIL NIL T)))
;     (2 . #2A((T T T) (NIL NIL T)))
;     (3 . #2A((T T T) (NIL NIL T)))   ; nil nil #
;     (4 . #2A((T T T) (NIL NIL T)))   ; #   #   #
;     (5 . #2A((T T T) (NIL NIL T)))
;     (6 . #2A((T T T) (NIL NIL T)))
;     (7 . #2A((T T T) (NIL NIL T)))
; )
(defun peca-l ()
    ; devolve uma lista de accoes correspondentes a peca l
    ; cria uma lista vazia e vai adicionando accoes com as colunas
    ; possiveis para esta peca especifica e com a sua configuracao
    ; A escolha da orientacao comecar em l0 e passar para l3, l2 e l1,
    ; esta descrito no enunciado que a lista deve comecar pela orientacao inicial da peca
    ; e ir alterando a orientacao rodando a peca 90 graus no sentido horario,
    ; passando para l3 -> l2 -> l1
    (let (( lista (list) ))
        (dotimes (n (1- T-NCOLUNAS))
            (setf lista (append lista (list (cria-accao n peca-l0))))
        )
        (dotimes (n (- T-NCOLUNAS 2))
            (setf lista (append lista (list (cria-accao n peca-l1))))
        )
        (dotimes (n (1- T-NCOLUNAS))
            (setf lista (append lista (list (cria-accao n peca-l2))))
        )
        (dotimes (n (- T-NCOLUNAS 2) lista)
            (setf lista (append lista (list (cria-accao n peca-l3))))
        )
    )
)

;;; peca-j: {} -> lista de accoes
; (
;     (0 . #2A((T T) (NIL T) (NIL T)))
;     (1 . #2A((T T) (NIL T) (NIL T)))
;     (2 . #2A((T T) (NIL T) (NIL T)))
;     (3 . #2A((T T) (NIL T) (NIL T)))  ; Nil #
;     (4 . #2A((T T) (NIL T) (NIL T)))  ; nil #
;     (5 . #2A((T T) (NIL T) (NIL T)))  ;   # #
;     (6 . #2A((T T) (NIL T) (NIL T)))
;     (7 . #2A((T T) (NIL T) (NIL T)))
;     (8 . #2A((T T) (NIL T) (NIL T)))
;     (0 . #2A((T T T) (T NIL NIL)))
;     (1 . #2A((T T T) (T NIL NIL)))
;     (2 . #2A((T T T) (T NIL NIL)))   ; # nil nil
;     (3 . #2A((T T T) (T NIL NIL)))   ; #  #  #
;     (4 . #2A((T T T) (T NIL NIL)))
;     (5 . #2A((T T T) (T NIL NIL)))
;     (6 . #2A((T T T) (T NIL NIL)))
;     (7 . #2A((T T T) (T NIL NIL)))
;     (0 . #2A((T NIL) (T NIL) (T T)))
;     (1 . #2A((T NIL) (T NIL) (T T)))
;     (2 . #2A((T NIL) (T NIL) (T T)))  ; # #
;     (3 . #2A((T NIL) (T NIL) (T T)))  ; # nil
;     (4 . #2A((T NIL) (T NIL) (T T)))  ; # nil
;     (5 . #2A((T NIL) (T NIL) (T T)))
;     (6 . #2A((T NIL) (T NIL) (T T)))
;     (7 . #2A((T NIL) (T NIL) (T T)))
;     (8 . #2A((T NIL) (T NIL) (T T)))
;     (0 . #2A((NIL NIL T) (T T T)))
;     (1 . #2A((NIL NIL T) (T T T)))
;     (2 . #2A((NIL NIL T) (T T T)))   ;   #  #  #
;     (3 . #2A((NIL NIL T) (T T T)))   ; nil nil #
;     (4 . #2A((NIL NIL T) (T T T)))
;     (5 . #2A((NIL NIL T) (T T T)))
;     (6 . #2A((NIL NIL T) (T T T)))
;     (7 . #2A((NIL NIL T) (T T T)))
; )
(defun peca-j ()
    ; devolve uma lista de accoes correspondentes a peca j
    ; cria uma lista vazia e vai adicionando accoes com as colunas
    ; possiveis para esta peca especifica e com a sua configuracao
    ; A escolha da orientacao comecar em j0 e passar para j3, j2 e j1,
    ; esta descrito no enunciado que a lista deve comecar pela orientacao inicial da peca
    ; e ir alterando a orientacao rodando a peca 90 graus no sentido horario,
    ; passando para j3 -> j2 -> j1
    (let (( lista (list) ))
        (dotimes (n (1- T-NCOLUNAS))
            (setf lista (append lista (list (cria-accao n peca-j0))))
        )
        (dotimes (n (- T-NCOLUNAS 2))
            (setf lista (append lista (list (cria-accao n peca-j1))))
        )
        (dotimes (n (1- T-NCOLUNAS))
            (setf lista (append lista (list (cria-accao n peca-j2))))
        )
        (dotimes (n (- T-NCOLUNAS 2) lista)
            (setf lista (append lista (list (cria-accao n peca-j3))))
        )
    )
)

;;; peca-o: {} -> lista de accoes
; (
;     (0 . #2A((T T) (T T)))
;     (1 . #2A((T T) (T T)))
;     (2 . #2A((T T) (T T)))
;     (3 . #2A((T T) (T T))) ; # #
;     (4 . #2A((T T) (T T))) ; # #
;     (5 . #2A((T T) (T T)))
;     (6 . #2A((T T) (T T)))
;     (7 . #2A((T T) (T T)))
;     (8 . #2A((T T) (T T)))
; )
(defun peca-o ()
    ; devolve uma lista de accoes correspondentes a peca o
    ; cria uma lista vazia e vai adicionando accoes com as colunas
    ; possiveis para esta peca especifica e com a sua configuracao
    (let (( lista (list) ))
        (dotimes (n (1- T-NCOLUNAS) lista)
            (setf lista (append lista (list (cria-accao n peca-o0))))
        )
    )
)

;;; peca-s: {} -> lista de accoes
; (
;     (0 . #2A((T T NIL) (NIL T T)))
;     (1 . #2A((T T NIL) (NIL T T)))
;     (2 . #2A((T T NIL) (NIL T T)))
;     (3 . #2A((T T NIL) (NIL T T)))  ; nil # #
;     (4 . #2A((T T NIL) (NIL T T)))  ;   # # Nil
;     (5 . #2A((T T NIL) (NIL T T)))
;     (6 . #2A((T T NIL) (NIL T T)))
;     (7 . #2A((T T NIL) (NIL T T)))
;     (0 . #2A((NIL T) (T T) (T NIL)))
;     (1 . #2A((NIL T) (T T) (T NIL)))
;     (2 . #2A((NIL T) (T T) (T NIL)))
;     (3 . #2A((NIL T) (T T) (T NIL))) ;   # nil
;     (4 . #2A((NIL T) (T T) (T NIL))) ;   # #
;     (5 . #2A((NIL T) (T T) (T NIL))) ; nil #
;     (6 . #2A((NIL T) (T T) (T NIL)))
;     (7 . #2A((NIL T) (T T) (T NIL)))
;     (8 . #2A((NIL T) (T T) (T NIL)))
; )
(defun peca-s ()
    ; devolve uma lista de accoes correspondentes a peca s
    ; cria uma lista vazia e vai adicionando accoes com as colunas
    ; possiveis para esta peca especifica e com a sua configuracao
    (let (( lista (list) ))
        (dotimes (n (- T-NCOLUNAS 2))
            (setf lista (append lista (list (cria-accao n peca-s0))))
        )
        (dotimes (n (1- T-NCOLUNAS) lista)
            (setf lista (append lista (list (cria-accao n peca-s1))))
        )
    )
)

;;; peca-z: {} -> lista de accoes
; (
;     (0 . #2A((NIL T T) (T T NIL)))
;     (1 . #2A((NIL T T) (T T NIL)))
;     (2 . #2A((NIL T T) (T T NIL)))
;     (3 . #2A((NIL T T) (T T NIL)))  ;   # # nil
;     (4 . #2A((NIL T T) (T T NIL)))  ; nil # #
;     (5 . #2A((NIL T T) (T T NIL)))
;     (6 . #2A((NIL T T) (T T NIL)))
;     (7 . #2A((NIL T T) (T T NIL)))
;     (0 . #2A((T NIL) (T T) (NIL T)))
;     (1 . #2A((T NIL) (T T) (NIL T)))
;     (2 . #2A((T NIL) (T T) (NIL T)))
;     (3 . #2A((T NIL) (T T) (NIL T))) ; nil #
;     (4 . #2A((T NIL) (T T) (NIL T))) ;   # #
;     (5 . #2A((T NIL) (T T) (NIL T))) ;   # nil
;     (6 . #2A((T NIL) (T T) (NIL T)))
;     (7 . #2A((T NIL) (T T) (NIL T)))
;     (8 . #2A((T NIL) (T T) (NIL T)))
; )
(defun peca-z ()
    ; devolve uma lista de accoes correspondentes a peca z
    ; cria uma lista vazia e vai adicionando accoes com as colunas
    ; possiveis para esta peca especifica e com a sua configuracao
    (let (( lista (list) ))
        (dotimes (n (- T-NCOLUNAS 2))
            (setf lista (append lista (list (cria-accao n peca-z0))))
        )
        (dotimes (n (1- T-NCOLUNAS) lista)
            (setf lista (append lista (list (cria-accao n peca-z1))))
        )
    )
)

;;; peca-t: {} -> lista de accoes
; (
;     (0 . #2A((T T T) (NIL T NIL)))
;     (1 . #2A((T T T) (NIL T NIL)))
;     (2 . #2A((T T T) (NIL T NIL)))
;     (3 . #2A((T T T) (NIL T NIL))) ; nil # nil
;     (4 . #2A((T T T) (NIL T NIL))) ;   # # #
;     (5 . #2A((T T T) (NIL T NIL)))
;     (6 . #2A((T T T) (NIL T NIL)))
;     (7 . #2A((T T T) (NIL T NIL)))
;     (0 . #2A((T NIL) (T T) (T NIL)))
;     (1 . #2A((T NIL) (T T) (T NIL)))
;     (2 . #2A((T NIL) (T T) (T NIL)))
;     (3 . #2A((T NIL) (T T) (T NIL))) ; # nil
;     (4 . #2A((T NIL) (T T) (T NIL))) ; # #
;     (5 . #2A((T NIL) (T T) (T NIL))) ; # nil
;     (6 . #2A((T NIL) (T T) (T NIL)))
;     (7 . #2A((T NIL) (T T) (T NIL)))
;     (8 . #2A((T NIL) (T T) (T NIL)))
;     (0 . #2A((NIL T NIL) (T T T)))
;     (1 . #2A((NIL T NIL) (T T T)))
;     (2 . #2A((NIL T NIL) (T T T)))
;     (3 . #2A((NIL T NIL) (T T T)))  ;   # # #
;     (4 . #2A((NIL T NIL) (T T T)))  ; nil # nil
;     (5 . #2A((NIL T NIL) (T T T)))
;     (6 . #2A((NIL T NIL) (T T T)))
;     (7 . #2A((NIL T NIL) (T T T)))
;     (0 . #2A((NIL T) (T T) (NIL T)))
;     (1 . #2A((NIL T) (T T) (NIL T)))
;     (2 . #2A((NIL T) (T T) (NIL T)))
;     (3 . #2A((NIL T) (T T) (NIL T))) ; nil #
;     (4 . #2A((NIL T) (T T) (NIL T))) ;   # #
;     (5 . #2A((NIL T) (T T) (NIL T))) ; nil #
;     (6 . #2A((NIL T) (T T) (NIL T)))
;     (7 . #2A((NIL T) (T T) (NIL T)))
;     (8 . #2A((NIL T) (T T) (NIL T)))
;)
(defun peca-t ()
    ; devolve uma lista de accoes correspondentes a peca t
    ; cria uma lista vazia e vai adicionando accoes com as colunas
    ; possiveis para esta peca especifica e com a sua configuracao
    ; A escolha da orientacao comecar em t0 e passar para t3, t2 e t1,
    ; esta descrito no enunciado que a lista deve comecar pela orientacao inicial da peca
    ; e ir alterando a orientacao rodando a peca 90 graus no sentido horario,
    ; passando para t3 -> t2 -> t1
    (let (( lista (list) ))
        (dotimes (n (- T-NCOLUNAS 2))
            (setf lista (append lista (list (cria-accao n peca-t0))))
        )
        (dotimes (n (1- T-NCOLUNAS))
            (setf lista (append lista (list (cria-accao n peca-t1))))
        )
        (dotimes (n (- T-NCOLUNAS 2))
            (setf lista (append lista (list (cria-accao n peca-t2))))
        )
        (dotimes (n (1- T-NCOLUNAS) lista)
            (setf lista (append lista (list (cria-accao n peca-t3))))
        )
    )
)

;;; accoes: estado -> lista de acoes
(defun accoes (estado)
    ; recebe estado devolve lista de accoes validas
    ; acao valida mesmo que faca o jogador perder
    ; acao invalida se nao for fisicamente possivel (< 0 > 10)
    ; !! ordem e importante frente na lista deve estar a order
    ; com que a peca deve estar virada, (orientacao)
    (cond
        ((estado-final-p estado) nil)
        ((eq (first (estado-pecas-por-colocar estado)) 'i) (peca-i))
        ((eq (first (estado-pecas-por-colocar estado)) 'l) (peca-l))
        ((eq (first (estado-pecas-por-colocar estado)) 'j) (peca-j))
        ((eq (first (estado-pecas-por-colocar estado)) 'o) (peca-o))
        ((eq (first (estado-pecas-por-colocar estado)) 's) (peca-s))
        ((eq (first (estado-pecas-por-colocar estado)) 'z) (peca-z))
        ((eq (first (estado-pecas-por-colocar estado)) 't) (peca-t))
        (t nil)
    )
)

;;; detecta-colisao: tabuleiro x linha x accao-> logico
(defun detecta-colisao (tabuleiro nlinha accao)
    ; recebe accao, estado e numero da linha
    ; devolve
    ; true caso a peca esteja a coincidir com alguma posicao do tabuleiro(True)
    ; false caso a peca nao coincida com nenhuma posicao preenchida do tabuleiro
    (let ((ncoluna (accao-coluna accao))
          (peca (accao-peca accao))
          (numlinhaspeca (first (array-dimensions (accao-peca accao))))
          (numcolunaspeca (second (array-dimensions (accao-peca accao))))
         )
        (dotimes (l numlinhaspeca nil)
            (dotimes (c numcolunaspeca)
                ;#1 verifica se a posicao que se ira comparar esta dentro dos limites do tabuleiro
                ;#2 verifica se alguma posicao da peca (a True) coincide com alguma posicao do tabuleiro (a True)
                ;#3 se a peca esta preenchida nessa posicao
                (if (AND
                        (dentro-limites (+ nlinha l) (+ ncoluna c))  ; #1
                        (tabuleiro-preenchido-p tabuleiro (+ nlinha l) (+ ncoluna c)) ; #2
                        (aref peca l c) ; #3
                    ) (return-from detecta-colisao t)
                )
            )
        )
    )
)

;;; insere-peca: tabuleiro x peca x nlinha x ncoluna -> {}
(defun insere-peca (tabuleiro peca nlinha ncoluna)
    ; recebe linha e coluna a partir das quais se insere a peca no tabuleiro
    ; nao devolve nada
    (let (
        (numlinhaspeca (first (array-dimensions peca)))
        (numcolunaspeca (second (array-dimensions peca)))
        (lin 0)
        (col 0))
        (dotimes (l numlinhaspeca)
            (dotimes (c numcolunaspeca)
                (setf lin (+ nlinha l))
                (setf col (+ ncoluna c))
                ;NAO e lin e col mas sim l e c porque lin e col percorrem o tabuleiro e neste if percorre-se a peca
                (if (aref peca l c)
                    (tabuleiro-preenche! tabuleiro lin col)
                )
            )
        )
    )
)

;;; resultado: estado x accao -> estado
(defun resultado (estado accao)
    ; recebe estado e acao e devolve o novo estado que
    ; resulta de aplicar a acao ao estado original
    ; NAO e destrutivo, ou seja, novo objecto e gerado
    (let* (
        (new (copia-estado estado))
        (tabuleiro (estado-tabuleiro new))

        (coluna (accao-coluna accao))
        (peca (accao-peca accao))
        (numcolunaspeca (second (array-dimensions peca)))

        (colunamaior 0)
        (alturacoluna 0)
        (nlinhasremovidas 0)
        (pos_mais_esquerda 0)
        (altura_desta_posicao 0)
        )
        ;CICLO DESCOBRIR COLUNA MAIOR DO TABULEIRO (ONDE A PECA PUDERA COLIDIR)
        (dotimes (c numcolunaspeca)
            ;verifica qual das colunas do tabuleiro que estao por baixo da peca e maior
            (setf pos_mais_esquerda (+ c coluna))
            (setf altura_desta_posicao (tabuleiro-altura-coluna tabuleiro pos_mais_esquerda))
            (if (> altura_desta_posicao alturacoluna)
                (progn
                    (setf alturacoluna altura_desta_posicao)
                    (setf colunamaior pos_mais_esquerda)
                )
            )
        )
        ;CICLO DE DECREMENTO DAS POSICOES DA PECA NA TABELA ATE COLISAO
        (loop for linha from alturacoluna downto 0 do
            (progn
                (cond
                    ;Se nao detectar nenhuma colisao e estiver no fundo do tabuleiro (a peca) -> coloca-a nessa posicao
                    ((AND (not (detecta-colisao tabuleiro linha accao)) (eq linha 0)) (insere-peca tabuleiro peca linha coluna) (return)) ;ESTAVA AQUI O BUG TESTE 15
                    ;Se detectar uma colisao -> coloca a peca na posicao anterior
                    ((AND (detecta-colisao tabuleiro linha accao) (peca-dentro-limites (1+ linha) accao)) (insere-peca tabuleiro peca (1+ linha) coluna) (return))
                )
            )
        )
        ;ACTUALIZAR A LISTA DE PECAS COLOCADAS PELA LISTA DE PECAS POR COLOCAR
        (setf (estado-pecas-colocadas new) (append (list (first (estado-pecas-por-colocar new))) (estado-pecas-colocadas new)))
        ;ACTUALIZAR A LISTA DE PECAS POR COLOCAR (RETIRANDO O PRIMEIRO ELEMENTO DA LISTA)
        (setf (estado-pecas-por-colocar new) (rest (estado-pecas-por-colocar new)))
        ;VERIFICA SE ACABOU O JOGO (TOPO PREENCHIDO)
        (if (tabuleiro-topo-preenchido-p tabuleiro)
            (return-from resultado new) ;Se true: devolve o estado
            (progn ;Se nil: remove linhas e calc pontos calc pontos
                (dotimes (l (1- T-NLINHAS))
                    (cond
                        (
                            (tabuleiro-linha-completa-p tabuleiro l)
                            (progn
                            ;remover as linhas (podemos arranjar forma de nao procurar o tabuleiro todo por uma linha preenchida)
                            (tabuleiro-remove-linha! tabuleiro l)
                            ; incrementa contador de linhas removidas
                            (setf nlinhasremovidas (1+ nlinhasremovidas))
                            ;decrementa o contador porque quando se remove uma linha as outras descem,
                            ;o que provoca um bug se duas linhas completas estiverem juntas.
                            ;exemplo: na linha 0 e na 1 existem linhas completas,
                            ;l=0 -> remove linha -> linhas descem -> a linha 1 que estava completa passa para a linha 0
                            ;contador incrementa -> l=1 -> nao existe...
                            ;LOGO cada vez que se remove uma linha, decrementa-se para apanhar esse caso
                            (setf l (1- l))
                            )
                        )
                        (t ())
                    )
                )
                (cond  ;atribuicao da respectiva pontuacao consoante o numero de linhas removidas
                    ((eq nlinhasremovidas 1) (setf (estado-pontos new) (+ (estado-pontos new) 100)))
                    ((eq nlinhasremovidas 2) (setf (estado-pontos new) (+ (estado-pontos new) 300)))
                    ((eq nlinhasremovidas 3) (setf (estado-pontos new) (+ (estado-pontos new) 500)))
                    ((eq nlinhasremovidas 4) (setf (estado-pontos new) (+ (estado-pontos new) 800)))
                    (t 0)
                    )
                ;Tambem tem de se devolver o estado no caso do topo do tabuleiro nao estar preenchido (nao e explicito no enunciado)
                (return-from resultado new)
            )
        )
    )
)

;;; qualidade: estado -> inteiro
(defun qualidade (estado)
    ; recebe estado e devolve inteiro que corresponde
    ; ao valor de pontos ganhos ate ao momento em valor negativo.
    (* -1 (estado-pontos estado))
)

;;; custo-oportunidade: estado -> inteiro
(defun custo-oportunidade (estado)
    ; recebe estado e devolve inteiro que corresponde
    (let ((efectivament-conseguido (estado-pontos estado))
          (maximo-possivel 0)
          (todas-pecas (estado-pecas-colocadas estado))
          (custos (make-array (list 7) :initial-element 0)))  ; each position corresponds to a letter
        ; acumular todos os custos de todas as acoes ja feitas ate a data
        (dolist (peca todas-pecas)
            (cond  ;atribuicao da respectiva pontuacao consoante o numero de linhas removidas
                ((eq peca 'i) (setf (aref custos 0) (+ 800 (aref custos 0))))
                ((eq peca 'j) (setf (aref custos 1) (+ 500 (aref custos 1))))
                ((eq peca 'l) (setf (aref custos 2) (+ 500 (aref custos 2))))
                ((eq peca 's) (setf (aref custos 3) (+ 300 (aref custos 3))))
                ((eq peca 'z) (setf (aref custos 4) (+ 300 (aref custos 4))))
                ((eq peca 't) (setf (aref custos 5) (+ 300 (aref custos 5))))
                ((eq peca 'o) (setf (aref custos 6) (+ 300 (aref custos 6))))
                (t 0)
                )
            )
        ; descobrir o maior custo
        (setf maximo-possivel (reduce #'max custos))
        ; return difference
        (return-from custo-oportunidade (- maximo-possivel efectivament-conseguido))
    )
)

#|Algoritmos de Procura (2' parte do projecto)|#

(defun procura-pp (problema)
    ; usa procura em profundidade primeiro em arvore
    ; para obter solucao para o problema
    ; devolve lsita de acoes que se executa pela ordem especifica
    ; leva de um estado inicial ao objectivo
    ; deve utilizar LIFO (last in first out)
    ; ultimo n a ser colocado na fronteira dever ser o primeiro a ser explorado.
    ; generico.. nao so para o tetris mas para qualquer problema
    (let ((output (list))
          (explorados (list (list)))
          (por-explorar (list (list problema nil nil)))
          (aux (list))
          (newprob nil)
          (var)
          (prob)
        )

        (loop while (not (null por-explorar)) do
            (setf prob (first (first por-explorar)))
            (setf explorados (append (list (first por-explorar)) explorados))
            (setf por-explorar (rest por-explorar))
            (cond
                ((funcall (problema-solucao prob) (problema-estado-inicial prob)) (return))
                (t
                    (setf var (funcall (problema-accoes prob) (problema-estado-inicial prob)))
                    (dolist (acao var)
                        (setf newprob (make-problema :estado-inicial (funcall (problema-resultado prob) (problema-estado-inicial prob) acao)
                                                           :solucao (problema-solucao prob)
                                                           :accoes (problema-accoes prob)
                                                           :resultado (problema-resultado prob)
                                                           :custo-caminho (problema-custo-caminho prob)))
                        (setf por-explorar (append (list (list newprob acao prob)) por-explorar))
                    )
                    (if (null por-explorar) (return-from procura-pp nil)) ;Devolve NIL no caso de nao encontrar solucao e nao ter mais nada por explorar
                )
            )
        )
        (setf aux (first explorados))           ;lista
        (setf explorados (rest explorados))     ;lista com listas
        (loop while (not (null (third aux))) do
            (if (equalp (problema-estado-inicial (third aux)) (problema-estado-inicial (first (first explorados))))
                ;iguais
                (progn
                    (setf output (append (list (second aux)) output))
                    (setf aux (first explorados))
                    (setf explorados (rest explorados))
                )
                ;diferentes
                (progn
                    (setf explorados (rest explorados))
                )
            )
        )
        (setf output (append (list (second aux)) output))
        (setf output (rest output))
        (return-from procura-pp output)
    )
)

(defstruct node
    problema
    acao)

(defun cria-node (problema &optional acao)
    (make-node :problema problema :acao acao)
)

(defun constroi-caminho (path-hash current)
    (let ((path (list))
          (next current)
          (next-action nil))
        (setf next-action (node-acao next))
        ;(format t "path = ~d ~%" path)
        (loop while (not (null next-action)) do
            (setf path (append path (list next-action)))
            (setf next (gethash next path-hash))
            (setf next-action (node-acao next))
        ;    (format t "while path= ~d ~%" path)
        )
        (return-from constroi-caminho (reverse path))
    )
)

(defun procura-A* (problema heuristica)
    ; usa o algo procura A* em arvore para determinar a seq de acoes
    ; de modo a maximizar os pontos obtidos
    ; a funcao euristica corresponde a uma func que recebe um estado
    ; e devolve um numero que corresponde a uma estimativa do custo/qualidade
    ; apartir desse estado ate ao melhor objectivo
    ; em caso de empate entre dois nos com igual valor de f
    ; deve ser escolhido o ultimo a ser colocado
    ; generico.. nao so para o tetris mas para qualuer problema
    (let* (
        (startnode (cria-node problema))

        (closeSet (list))
        (openSet (list startnode))

        (cameFrom (make-hash-table))
        (g_score (make-hash-table))
        (f_score (make-hash-table))

        ; aux variables
        (infinty 100000000)
        (h_cost 0)
        (acoes)
        (val)
        (skip_update nil)
        (new-problem)
        (tentative_g_score)
        (children-node)
        (current-node nil)
        (lowest-node-val infinty) ; set this varibale as "infinty" to be changed for the lowers key in the f_score
    )

    (setf (gethash startnode g_score) 0)
    (setf h_cost (funcall heuristica (problema-estado-inicial (node-problema startnode))))
    (setf (gethash startnode f_score) (+ (gethash startnode g_score) h_cost))
    ;(format t "is open set not empty? = ~d (length = ~d)~%" (not (eq 0 (list-length openSet))) (list-length openSet))
    (loop while (not (eq 0 (list-length openSet))) do
        ; get the lowers node from open set with lowest fscore
        ;(format t "get lowest node from open set~%")
        (setf current-node nil)
        (setf lowest-node-val infinty)

        (dolist (abc openSet)
           (setf val (gethash abc f_score))
           (if (<= val lowest-node-val)
               (progn
                   (setf lowest-node-val val)
                   (setf current-node abc)
               )
            )
        )
        ; check if this node is the goal
        ;(format t "is current-node the goal one? ~d ~%" (funcall (problema-solucao (node-problema current-node)) (problema-estado-inicial (node-problema current-node))))
        (if (funcall (problema-solucao        (node-problema current-node))
                     (problema-estado-inicial (node-problema current-node)))
            (return-from procura-A* (constroi-caminho cameFrom current-node))
        )
        ;(format t "remove current-node from open set~%(openSet before size = ~d)~%" (list-length openSet))
        ; remove node from open set
        (setf openSet (remove current-node openSet))
        ;(format t "(openSet after size = ~d)~%add current-node to close set~%(closeSet before size = ~d)~%" (list-length openSet) (list-length closeSet))
        ; and add it to the close set
        (setf closeSet (append closeSet (list current-node)))
        ;(format t "(closeSet after size = ~d)~%" (list-length closeSet))
        ; generate children
        (setf acoes (funcall (problema-accoes (node-problema current-node)) (problema-estado-inicial (node-problema current-node))))
        ;(format t "~d Possiveis acoes ~%" (list-length acoes))
        ;(format t "~d ~%" acoes)
        (dolist (acao acoes)
            (setf new-problem (make-problema
                                :estado-inicial (funcall (problema-resultado (node-problema current-node)) (problema-estado-inicial (node-problema current-node)) acao)
                                :accoes         (problema-accoes (node-problema current-node))
                                :solucao        (problema-solucao (node-problema current-node))
                                :resultado      (problema-resultado (node-problema current-node))
                                :custo-caminho  (problema-custo-caminho (node-problema current-node))))
            (setf children-node (cria-node new-problem acao))
            (setf (gethash children-node f_score) infinty)
            (setf (gethash children-node g_score) infinty)
            ; se esta nova child ainda nao foi visitada, entao adiciona a priority queue
            (if (not (member children-node closeSet))
                (progn
                    ;(setf tentative_g_score (1+ (gethash current-node g_score)))
                    (setf tentative_g_score (+ (gethash current-node g_score) (funcall (problema-custo-caminho (node-problema children-node)) (problema-estado-inicial (node-problema children-node)))))
                    (if (not (member children-node openSet))
                        (setf openSet (append openSet (list children-node)))
                        (progn
                            (if (>= tentative_g_score (gethash children-node g_score))
                                (setf skip_update t)
                            )
                        )
                    )
                    (if (not skip_update)
                        (progn
                            (setf (gethash children-node cameFrom) current-node)
                            ;(format t "children g_score ~d -> ~d ~%" (gethash children-node g_score) tentative_g_score)
                            (setf (gethash children-node g_score) tentative_g_score)
                            (setf h_cost (funcall heuristica (problema-estado-inicial (node-problema children-node))))
                            ;(format t "children f_score ~d -> ~d + ~d ~%" (gethash children-node f_score) (gethash children-node g_score) h_cost)
                            (setf (gethash children-node f_score) (+ (gethash children-node g_score) h_cost))
                        )
                    )
                )
            )
        )
        (remhash current-node f_score)
        (remhash current-node g_score)
        )
    (return-from procura-A* nil)
    )
)

;;; procura-best: array x listapecas -> lista de acoes
(defun procura-best (array lista-pecas)
    (let* (
        (tabuleiro (array->tabuleiro array))
        (estado (make-estado
                            :pontos 0
                            :pecas-por-colocar lista-pecas
                            :pecas-colocadas (list)
                            :tabuleiro tabuleiro))
        (problema (make-problema
                                :estado-inicial estado
                                :solucao #'solucao
                                :accoes #'accoes
                                :resultado #'resultado
                                :custo-caminho #'custo-oportunidade))
        )
        (return-from procura-best (procura-A* problema #'qualidade))
    )
)

(load "utils.fas")
;(load (compile-file "utils.lisp"))
