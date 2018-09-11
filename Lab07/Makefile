regular:
	arm-eabi-as ra188115.s -o ra188115.o
	arm-eabi-ld ra188115.o -o ra188115 -Ttext=0x77802000 -Tdata=0x77803000
	mksd.sh --so /home/specg12-1/mc404/simulador/dummyos.elf --user ra188115
	arm-sim --rom=/home/specg12-1/mc404/simulador/dumboot.bin --sd=disk.img

gdb:
	arm-eabi-as ra188115.s -o ra188115.o -g
	arm-eabi-ld ra188115.o -o ra188115 -Ttext=0x77802000 -Tdata=0x77803000 -g
	mksd.sh --so /home/specg12-1/mc404/simulador/dummyos.elf --user ra188115
	arm-sim -g --rom=/home/specg12-1/mc404/simulador/dumboot.bin --sd=disk.img

print: 
	arm-eabi-as ra188115.s -o ra188115.o
	arm-eabi-ld ra188115.o -o ra188115 -Ttext=0x77802000 -Tdata=0x77803000
	mksd.sh --so /home/specg12-1/mc404/simulador/dummyos.elf --user ra188115
	(arm-sim --rom=/home/specg12-1/mc404/simulador/dumboot.bin --sd=disk.img 2>&1) > msa

clean:
	rm -f disk.img ra188115 ra188115.o

debug:
	fuser -k 5000/tcp
	arm-eabi-gdb ra188115

path:
	/home/specg12-1/mc404/simulador/set_path.sh
