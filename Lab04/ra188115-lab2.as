.org 0x000
	LOAD MQ,M(x)
	MUL M(var)
	LOAD MQ
	STOR M(var)
	LOAD M(var)
	RSH
	STOR M(k)
laco:
	LOAD M(var)
	DIV M(k)
	LOAD MQ
	ADD M(k)
	RSH
	STOR M(k)
	LOAD M(contador)
	SUB M(decresimo)
	STOR M(contador)
	JUMP+ M(laco)
	LOAD M(k)
	JUMP M(0x400)
.org 0x101
decresimo:
    .word 0x0000000001
contador:
    .word 0x0000000009
k:
    .word 0x0000000000
var:
    .word 0x000000000A
x:
    .word 0x0000000000
