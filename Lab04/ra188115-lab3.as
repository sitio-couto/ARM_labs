.org 0x000
    LOAD M(0x3FF) 
    SUB M(0x011)
laco:
    STOR M(0x3FF)
    LOAD M(0x3FD)
    STA M(0x005,28:39)
    ADD M(decresimo)
    STOR M(0x3FD)
    LOAD M(0x3FE)
    STA M(0x006,8:19)
    ADD M(decresimo)
    STOR M(0x3FE)
    LOAD MQ,M(0x000)
    MUL M(0x000)
    LOAD MQ
    ADD M(produto)
    STOR M(produto)
    LOAD M(0x3FF)
    SUB M(decresimo)
    STOR M(0x3FF)
    JUMP+ M(laco,20:39)
    LOAD M(produto)
    JUMP M(0x400,0:19)
.org 0x010
produto:
    .word 0x0000000000
decresimo:
    .word 0x0000000001
