@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ VINICIUS COUTO ESPINDOLA @@
@@ RA: 188115		    @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ NOTA IMPORTANTE:
@@ A maneira de representar a matriz/mapa nao fora bem
@@ especificada: as funcoes em "c" tratam as linhas como
@@ valor X e as colunas Y, todavia, no exemplo da pagina
@@ do lab, as colunas sao representadas por X e as linhas
@@ por Y.   A incerteza da representacao correta me levou
@@ a utilizar X para colunas e Y para linhas, como fora
@@ feitos nas funcoes em "c".


.global ajudaORobinson
.global imprimir
.global exit
.global imprimirNoWay

.data

noWay:  .asciz "Não existe um caminho!\n"
output_buffer: .skip 10

.text
.align 4
ajudaORobinson:
	bl inicializaVisitados	@ Inicializa a matriz das posicoes visitadas

	@ Inicializa valores das posicoes
	bl posicaoYLocal
	push {r0}
	bl posicaoXLocal
	push {r0}
	bl posicaoYRobinson
	push {r0}
	bl posicaoXRobinson
	push {r0}

	pop {r0-r3}		@ Carrega as posicoes (argumentos) em [r0-r3]
	bl dfsRecursivo		@ Entra na recursao de busca

	cmp r9, #1		@ Caso nao encontrou um caminho
	blne imprimirNoWay	@ Imprime que o caminho nao existe

terminar:
    @ Chama a funcao exit para finalizar processo.
    mov r0, #0
    bl  exit


@ Realiza uma busca por caminhos usando recursao
@ Parametros:
@ r0 = valor X do local atual
@ r1 = valor Y do local atual
@ r2 = valor do X destino
@ r3 = valor do Y destino
@ r9 = Flag que identifica se achou caminho.
@ r10 = Flag de teste.
dfsRecursivo:
	push {r0, r1, lr}	@ Salva endereco da posicao x e y atuais

	push {r0-r4}
	bl visitaCelula		@ Marca a celula atual como visitada
	pop {r0-r4}

	bl comparaComDestino	@ Testa se chegou ao destino

	add r5, r0, #1		@ Limite de X (x+1)
	add r6, r1, #1		@ Limite de Y (x+1)
	sub r0, r0, #1		@ (x-1)
	sub r1, r1, #1		@ (y-1)

loop_xy:
	push {r0-r7}
	bl testaNovaPosicao	@ Testa se a nova posicao e valida
	cmp r0, #1		@ Verifica se retornou true
	pop {r0-r7}

	push {r0-r7}
	bleq dfsRecursivo  	@ Se posicao valida, entra no novo no
	pop {r0-r7}

	cmp r9, #1		@ Testa se encontrou o local
	beq dfsRecursivo_end	@ Se sim, finaliza.

	cmp r0, r5		@ Compara com o limite
	add r0, r0, #1		@ Incremente iterador de X
	bne loop_xy		@ Se limite, sai do loop

	sub r0, r0, #3		@ Reseta iterador de X
	cmp r1, r6 		@ Compara com o limite
	add r1, r1, #1		@ Incrementa iterador de Y
	bne loop_xy		@ Se limite, sai do loop

dfsRecursivo_end:
	pop {r0, r1}		@ Recupera X,Y atual do no

	cmp r9, #1		@ Verifica se encontrou o local
	mov r2, r1
	mov r1, r0
	ldr r0, =output_buffer
	bleq imprimir		@ Imprime coord do no

	pop {lr}
	mov pc, lr

@ Verifica se se a posicao atual e o local
@ sendo buscado.
@ r0 = X atual
@ r1 = Y atual
@ r2 = X do destino
@ r3 = X do destino
@ Retorno:
@ r0 = 1 se for o destino.
comparaComDestino:
	mov r4, #0		@ Inicializa como false
	mov r5, #0

	cmp r0, r2		@ Compara xAtual com xLoc
 	orreq r4, r4, #1	@ True se iguais
	cmp r1, r3 		@ Compara yAtual com yLoc
	orreq r5, r5, #1 	@ True se iguais

	and r4, r4, r5		@ Verifica se ambos sao veridicos
	cmp r4, #1		@ Se verdadeiros
	moveq r9, #1		@ Inicializa a flag
	beq dfsRecursivo_end	@ Finaliza a posicao

	mov pc, lr		@ Se falso volta a funcao


@ Verifica se eh uma posicao valida e que ainda
@ nao foi visitada.
@ Parametros:
@ r0 (r0) = X da nova posicao
@ r1 (r1) = Y da nova posicao
testaNovaPosicao:
	push {lr}
	mov r2, r0	@ muda o X para r2
	mov r3, r1	@ muda o Y para r3
	mov r4, #0	@ zera a flag de teste

	bl daParaPassar
	mov r4, r0	@ Atualiza a flag de acordo com o retorno

	mov r0, r2	@ Recupera X e seta como argumento
	mov r1, r3	@ Recupera Y e seta como argumento
	bl foiVisitado
	eor r0, r0, #1	@ Nega o retorno (negR0 -> 1 se nao foi visitado)

	and r0, r0, r4	@ Verifica se ambas condicoes (daPraPassar && !foiVisitado)
									@ Guarda o retorno em r0.
	pop {lr}
	mov pc, lr

@ Converter e imprimir valores x & y passados
@ Parametros:
@ r0 = endereco do buffer de saida
@ r1 = tamanho do buffer
imprimir:
	push {r4-r7, lr}

	add r1, r1, #48		@ Converte o numero para char
	add r2, r2, #48		@ funciona para o intervalo [0,9]

	strb r1, [r0, #0]	@ Insere X (char) no output
	strb r2, [r0, #2]	@ Insere Y (char) no output

	@ Insere caracteres especiais
	mov r4, #' '
	strb r4, [r0, #1]
	mov r4, #'\n'
	strb r4, [r0, #4]

	mov r1, r0
	mov r2, #5	@ tamanho do buffer.
	mov r0, #1	@ stdout file descriptor = 1
	mov r7, #4	@ write
	svc 0x0

 	pop {r4-r7, lr}
	mov pc, lr

imprimirNoWay:
	push {r4-r7, lr}
	mov r0, #1	@ stdout file descriptor = 1
	ldr r1, =noWay	@ endereco do buffer.
	mov r2, #24	@ tamanho do buffer.
	mov r7, #4	@ write
	svc 0x0

	pop {r4-r7, lr}
	mov pc, lr

@ Finaliza a execucao de um processo.
@  r0: codigo de finalizacao (Zero para finalizacao correta)
exit:
    mov r7, #1         @ syscall number for exit
    svc 0x0
