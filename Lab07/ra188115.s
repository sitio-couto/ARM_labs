@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ VINICIUS COUTO ESPINDOLA @
@ RA: 188115		   @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.globl _start

.data

input_buffer:   .skip 32
output_buffer:  .skip 32
linha_1:        .skip 3068	@ Espaco para linha do triangulo pascal
linha_2:        .skip 3068      @ Espaco para linha do triangulo pascal
    
.text
.align 4

@ Funcao inicial
_start:
    @ Chama a funcao "read" para ler 4 caracteres da entrada padrao
    ldr r0, =input_buffer
    mov r1, #4             @ 3 caracteres + '\n'
    bl  read

    @ Chama a funcao "atoi" para converter a string para um numero
    bl  atoi

@ Legendas das funcoes essenciais dos registradores utilizados na funcao
@ de criacao do trangulo pascal.
@ r0 = Numero de linhas a serem impressas.
@ r1 = Endereco da linha anterior.
@ r2 = Endereco da linha atual.
@ r3 = Indice da linha atual.	
@ r4 = Indice maximo (size-1) da linha atual.
@ r5 = valor do novo dado a ser armazenado.
@ r10 = Auxiliar para armazenar valores.
    
    ldr r1, =linha_1	        @ Iniciliza "linhaAnterior" com o vetor linha_1
    ldr r2, =linha_2		@ Inicializa "linhaAtual" com o vetor linha_2
    mov r3, #0			@ Inicializa o indice da linha atual como 0
    mov r4, #-1			@ Inicializa r4 como indice maximo (size-1) da linha atual
    
triangulo_pascal:
    cmp r0, #0			@ Testa se ja imprimiu todas as linhas.
    beq terminar	
     
    sub r0, r0, #1		@ Atualiza numero de linhas restantes
    add r4, r4, #1 		@ Atualiza numero de elementos da linha atual

linha_do_triangulo:
    cmp r3, #0			@ Testa se eh o primeiro elemento da linha.
    beq valor_um
    cmp r3, r4			@ Testa se eh o ultimo elemento da linha.	
    beq valor_um
            
    ldr r10, [r1, r3, lsl #2] 	@ Recupera valor exatamente acima da posicao atual
    sub r3, r3, #1
    ldr r5, [r1, r3, lsl #2] 	@ Recupera valor exatamente acima da posicao (atual - 1)
    add r3, r3, #1

    add r5, r5, r10		@ Soma os valores recuperados obtendo o novo termo

    str r5, [r2, r3, lsl #2]	@ Armazena o novo valor na linha atual

    b imprimir 			@ Pula para a impressao do novo termo

valor_um:
    mov r5, #1 			@ Recupera o valor um (caso inicio ou fim de linha)
    str r5, [r2, r3, lsl #2]    @ Armazena o novo valor na linha atual

imprimir:
    bl emitir_saida		@ Salta para a funcao de impressao do valor adicionado
    	
    add r3, r3, #1		@ Incrementa indice da linha atual
    cmp r3, r4			@ Testa se eh o ultimo elemento da linha
    bls linha_do_triangulo

    mov r10, r1			@ Este trecho inverte as posicoes nos registradores 
    mov r1, r2			@ fazendo com que a linha atual vire a anterior
    mov r2, r10			@ e a anterior vire a atual.
    mov r3, #0			@ Zera indice para uma nova linha
    b triangulo_pascal
    
terminar:
    @ Chama a funcao exit para finalizar processo.
    mov r0, #0
    bl  exit

@ Convoca serie de comandos para imprimir o novo elemento
@ adicionado no vetor atual.
@ Parametros:
@  r5 = valor em binario a ser impresso.
@  r3 = indice da linha atual.
@  r4 = indice maximo da linha atual (size-1).
@ Variaveis:
@  r0 = endereco dos valores para a saida.
@  r10 = auxiliar.
emitir_saida:
    push {lr, r0-r5}		@ Salva valores essenciais para o algoritimo
    ldr r0, =output_buffer    	@ Endereco dos valores de saida

    ldr r0, =output_buffer
    cmp r3, r4			@ Verifica se deve colocar um espaco ou um fim de linha
    movne r10, #' '
    moveq r10, #'\n'
    strb r10, [r0, #8]		@ Armazena caractere especial depois dos 8 char hexadecimais

    @ para uma sequencia de caracteres alfanumericos.		
    mov r2, r5			@ Salva o o valor a ser traduzido como parametro em r2
    bl  itoa			@ Chama a funcao "itoa" para converter o valor para char
    
    @ Chama a funcao write para escrever a linha atual
    @ do triangulo pascal. 
    mov r1, #9        		@ 8 caracteres + ' ' ou '\n'
    bl  write			@ Escreve o novo valor na saida	

    pop {lr, r0-r5}		@ Recupera valores essenciais para o algoritimo
    mov pc, lr


@ Le uma sequencia de bytes da entrada padrao.
@ parametros:
@  r0: endereco do buffer de memoria que recebera a sequencia de bytes.
@  r1: numero maximo de bytes que pode ser lido (tamanho do buffer).
@ retorno:
@  r0: numero de bytes lidos.
read:
    push {r4,r5, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #0         @ stdin file descriptor = 0
    mov r1, r4         @ endereco do buffer
    mov r2, r5         @ tamanho maximo.
    mov r7, #3         @ read
    svc 0x0
    pop {r4, r5, lr}
    mov pc, lr

@ Escreve uma sequencia de bytes na saida padrao.
@ parametros:
@  r0: endereco do buffer de memoria que contem a sequencia de bytes.
@  r1: numero de bytes a serem escritos
write:
    push {r4,r5, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #1         @ stdout file descriptor = 1
    mov r1, r4         @ endereco do buffer
    mov r2, r5         @ tamanho do buffer.
    mov r7, #4         @ write
    svc 0x0
    pop {r4, r5, lr}
    mov pc, lr

@ Finaliza a execucao de um processo.
@  r0: codigo de finalizacao (Zero para finalizacao correta)
exit:    
    mov r7, #1         @ syscall number for exit
    svc 0x0

@ Converte uma sequencia de caracteres alphanumericos em um numero binario
@ Variaveis:
@  r0: endereco do buffer de memoria que armazena a sequencia de caracteres.
@  r1: numero de caracteres lidos
@  r2: numero binario
@  r3: auxiliar
@ retorno:
@  r0: numero binario
atoi:
    ldr r0, =input_buffer	@ Inicializa r0 com o endereco da entrada
    mov r1, #0			@ Zera o numero de caracteres lidos
    mov r2, #0			@ Limpa o r2 para guardar o valor lido em binario

atoi_loop:
    mov r2, r2, lsl #4		@ Desloca um Byte para nao sobrescrever valores
    ldrb r3, [r0, r1]		@ Carrega o char em r3
    add r1, r1, #1		@ indice++ 

    cmp r3, #65			@ Compara com tabela ascii
    subhs r3, r3, #55		@ Se for uma letra maiuscula
    sublo r3, r3, #48		@ Se for um numero 
    orr r2, r3, r2		@ Salva o valor em r2 
	
    cmp r1, #3			@ se indice != tamanho maximo
    bne atoi_loop		@ volta para o loop.

    mov r0, r2			@ Salva o valor desejado em r0
    mov pc, lr			@ Retorna para a funcao _start

@ Converte um numero binario em uma sequencia de caracteres alfanumericos
@ Parametros:
@  r2: numero binario a ser convertido
@ Variaveis:
@  r0: endereco do buffer de memoria que recebera a sequencia de caracteres.
@  r1: ultimo indice do vetor de caracteres a ser convertido.
@  r3: auxiliar.
@  r4: auxiliar.
itoa:
    ldr r0, =output_buffer
    mov r1, #7			@ Inicializa indice maximo do vetor a ser lido

itoa_loop:
    mov r3, #0b1111		@ Cria mascara
    and r3, r3, r2		@ Pega o Hexa menos significativo
    mov r2, r2, lsr #4  	@ Desloca um meio Byte do valor original
 
    cmp r3, #10         	@ Compara com tabela ascii
    addhs r3, r3, #55   	@ Se for uma letra maiuscula    
    addlo r3, r3, #48   	@ Se for um numero

    strb r3, [r0, r1]    	@ Armazena o valor
    
    cmp r1, #0          	@ verifica se ainda ha bits a serem lidos    
    sub r1, r1, #1      	@ decremento do indice
    bne itoa_loop

itoa_end:
    mov pc, lr








