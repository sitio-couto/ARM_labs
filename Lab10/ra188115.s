@ VINICIUS COUTO ESPINDOLA
@ RA: 188115

.org 0x0
.section .iv,"a"

interrupt_vector:
    b RESET_HANDLER
.org 0x18
    b IRQ_HANDLER

.data
CONTADOR: .skip 8
IRQ_SP: .skip 100
USER_SP: .skip 100

.org 0x100
.text

RESET_HANDLER:

    @ Zera o contador
    ldr r2, =CONTADOR  @lembre-se de declarar esse contador em uma secao de dados!
    mov r0, #0
    str r0, [r2]

    @Faz o registrador que aponta para a tabela de interrup��es apontar para a tabela interrupt_vector
    ldr r0, =interrupt_vector
    mcr p15, 0, r0, c12, c0, 0

    @ Ajustar a pilha do modo IRQ.
    @ Voc� deve iniciar a pilha do modo IRQ aqui. Veja abaixo como usar a instru��o MSR para chavear de modo.
    msr CPSR_c, #0b11010010
    ldr sp, =IRQ_SP

    msr CPSR_c, #0b00010011	@ Retorna ao modo SUPERVISOR.

    bl SET_GPT 			
    bl SET_TZIC

    msr CPSR_c, #0b00010000   @ Modo USER com interrupcoes ativas.
    ldr sp, =USER_SP

laco:
    add r0, r0, #0	
    b laco

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

SET_GPT:
    .set GPT_BASE, 		0x53FA0000
    .set GPT_CR,  		0x0000
    .set GPT_PR,	   	0x0004
    .set GPT_SR,		  0x0008
    .set GPT_IR,		  0x000C
    .set GPT_OCR1,		0x0010

    ldr r0, =GPT_BASE

    mov r1, #0x00000041
    str r1, [r0, #GPT_CR]	@ Configura o modo clock_src para perifericos
				                  @ e seta o EN bit para ativar o gpt.

    mov r1, #0
    str r1, [r0, #GPT_PR]	@ Seta o divisor do relogio como PR+1 = 1

    mov r1, #100
    str r1, [r0, #GPT_OCR1]     @ Define o valor que dispara um evento no output channel 1

    mov r1, #1
    str r1, [r0, #GPT_IR]	@ Seta o IR para lancar interrupcao de acordo com o OCR1

    mov pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

SET_TZIC:
    @ Constantes para os enderecos do TZIC
    .set TZIC_BASE,             0x0FFFC000
    .set TZIC_INTCTRL,          0x0000
    .set TZIC_INTSEC1,          0x0084
    .set TZIC_ENSET1,           0x0104
    .set TZIC_PRIOMASK,         0x000C
    .set TZIC_PRIORITY9,        0x0424

    @ Liga o controlador de interrupcoes
    @ R1 <= TZIC_BASE

    ldr	r1, =TZIC_BASE

    @ Configura interrupcao 39 do GPT como nao segura
    mov	r0, #(1 << 7)
    str	r0, [r1, #TZIC_INTSEC1]

    @ Habilita interrupcao 39 (GPT)
    @ reg1 bit 7 (gpt)

    mov	r0, #(1 << 7)
    str	r0, [r1, #TZIC_ENSET1]

    @ Configure interrupt39 priority as 1
    @ reg9, byte 3

    ldr r0, [r1, #TZIC_PRIORITY9]
    bic r0, r0, #0xFF000000
    mov r2, #1
    orr r0, r0, r2, lsl #24
    str r0, [r1, #TZIC_PRIORITY9]

    @ Configure PRIOMASK as 0
    eor r0, r0, r0
    str r0, [r1, #TZIC_PRIOMASK]

    @ Habilita o controlador de interrupcoes
    mov	r0, #1
    str	r0, [r1, #TZIC_INTCTRL]

    @instrucao msr - habilita interrupcoes
    msr  CPSR_c, #0x13       @ SUPERVISOR mode, IRQ/FIQ enabled (THUMB disable)

    mov pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

IRQ_HANDLER:
    ldr r0, =GPT_BASE

    mov r1, #1
    str r1, [r0, #GPT_SR]	@ Sinaliza ao GPT que o processador identificou o interrupt do OC1

    @ incrementa contador do relogio.
    ldr r0, =CONTADOR
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]

    sub lr, lr, #4		@ Ajusta o endereco de retorno.
    movs pc, lr			  @ A FLAG "S" RECUPERA O SPSR NO CPSR (IMPORTANTE PARA MUDANCAS DE ESTADO)

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
