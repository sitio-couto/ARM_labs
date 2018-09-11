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

@ Cria e Salva os elementos na memoria.
@ r0 = Numero de linhas a serem impressas.
@ r1 = Endereco da linha anterior.
@ r2 = Endereco da linha atual.
@ r3 = Indice da linha atual.	
@ r4 = Numero de valores da linha.
@ r5 = valor do novo dado a ser armazenado.
@ r10 = Auxiliar para armazenar valores.
    
    ldr r1, =linha_1
    ldr r2, =linha_2 
    mov r3, #0
    mov r4, #-1
    
triangulo_pascal:
    @ Testa se ja imprimiu todas as linhas.
    cmp r0, #0
    beq terminar
    
    sub r0, r0, #1
    add r4, r4, #1 

linha_do_triangulo:
    @ Testa se eh o primeiro ou ultimo elemento da linha.
    cmp r3, #0
    beq valor_um
    cmp r3, r4
    beq valor_um
            
    @ Recupera os valores da linha anterior.
    ldr r10, [r1, r3, lsl #2] @ Valor sobre o atual
    sub r3, r3, #1
    ldr r5, [r1, r3, lsl #2] @ Valor anterior do atual acima
    add r3, r3, #1

    ldr r7, [r1, #0]
    ldr r8, [r1, #4]
    ldr r9, [r1, #8]    
    ldr r10, [r1, #12]

    add r5, r7, r10

    str r5, [r2, r3, lsl #2]

    b imprimir 

valor_um:
    mov r5, #1 
    str r5, [r2, r3, lsl #2]

imprimir:
    push {r0, r1, r2, r3, r4, r5}

    @ Verifica se deve colocar um espaco ou um fim de linha.
    ldr r0, =output_buffer
    cmp r3, r4
    movne r10, #' '
    moveq r10, #'\n'
    strb r10, [r0, #8]
    ldrb r11, [r0, #8]

    @ Chama a funcao "itoa" para converter o valor codificado
    @ para uma sequencia de caracteres alfanumericos.
    ldr r0, =output_buffer
    mov r1, #8
    mov r2, r5
    bl  itoa
    
    @ Chama a funcao write para escrever a linha atual
    @ do triangulo pascal. 
    ldr r0, =output_buffer    @ Endereco dos valores de saida
    mov r1, #9        @ 8 caracteres + ' ' ou '\n'
    bl  write

    pop {r0, r1, r2, r3, r4, r5}
    	
    add r3, r3, #1
    cmp r3, r4
    bls linha_do_triangulo

    mov r10, r1
    mov r1, r2
    mov r2, r10
    mov r3, #0
    b triangulo_pascal
    
terminar:
    @ Chama a funcao exit para finalizar processo.
    mov r0, #0
    bl  exit



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
@ parametros:
@  r0: endereco do buffer de memoria que armazena a sequencia de caracteres.
@  r1: numero de caracteres a ser considerado na conversao
@  r2: numero binario
@  r3: auxiliar
@ retorno:
@  r0: numero binario
atoi:
    ldr r0, =input_buffer
    mov r1, #0
    mov r2, #0

atoi_loop:
    mov r2, r2, lsl #4 @ Desloca um Byte para nao sobrescrever valores
    ldrb r3, [r0, r1]  @ Carrega o char em r3
    add r1, r1, #1     @ indice++ 

    cmp r3, #55        @ Compara com tabela ascii
    subhs r3, r3, #55  @ Se for uma letra maiuscula
    sublo r3, r3, #48  @ Se for um numero 
    orr r2, r3, r2     @ Salva o valor em r2 

    cmp r1, #3         @ se indice != tamanho maximo
    bne atoi_loop      @ volta para o loop.

    mov r0, r2	       @ Salva o valor desejado em r0
    mov pc, lr	       @ Retorna para a funcao _start

@ Converte um numero binario em uma sequencia de caracteres alfanumericos
@ Parametros:
@  r2: numero binario
@ Variaveis:
@  r0: endereco do buffer de memoria que recebera a sequencia de caracteres.
@  r1: numero de caracteres a ser considerado na conversao.
@  r3: auxiliar
@  r4: auxiliar
itoa:
    ldr r0, =output_buffer
    mov r1, #7

itoa_loop:
    mov r3, #0b1111	@ Cria mascara
    and r3, r3, r2	@ Pega o Hexa menos significativo
    mov r2, r2, lsr #4  @ Desloca um meio Byte do valor original
 
    cmp r3, #10         @ Compara com tabela ascii
    addhs r3, r3, #55   @ Se for uma letra maiuscula    
    addlo r3, r3, #48   @ Se for um numero

    strb r3, [r0, r1]    @ Armazena o valor
    
    cmp r1, #0          @ verifica se ainda ha bits a serem lidos    
    sub r1, r1, #1      @ decremento do indice
    bne itoa_loop

itoa_end:
    mov pc, lr








