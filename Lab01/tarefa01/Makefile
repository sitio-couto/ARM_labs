arquivo1.s: arquivo1.c
	gcc -S arquivo1.c -o arquivo1.s
arquivo2.s: arquivo2.c
	gcc -S arquivo2.c -o arquivo2.s
arquivo1.o: arquivo1.s
	as -o arquivo1.o arquivo1.s
arquivo2.o: arquivo2.s
	as -o arquivo2.o arquivo2.s
saida.x: arquivo1.o arquivo2.o
	ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 /usr/lib64/crt1.o /usr/lib64/crti.o -L/usr/lib64 arquivo1.o arquivo2.o -lc /usr/lib64/crtn.o -o saida.x
