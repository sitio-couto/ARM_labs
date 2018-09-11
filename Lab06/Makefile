run:
	arm-eabi-as ra188115.s -o ra188115.o
	arm-eabi-ld ra188115.o -o ra188115 -Ttext=0x77802000 -Tdata=0x77803000
	mksd.sh --so /home/specg12-1/mc404/simulador/dummyos.elf --user ra188115
	arm-sim --rom=/home/specg12-1/mc404/simulador/dumboot.bin --sd=disk.img

clean:
	rm -f disk.img ra188115 ra188115.o
