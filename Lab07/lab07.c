#include<stdio.h>
#include<stdlib.h>
#include<string.h>

int main(void){
	unsigned int *aux = NULL;
	unsigned int *linhaAnterior = calloc(767, sizeof(int)), *linhaAtual = calloc(767, sizeof(int));
	unsigned int index = 0, tamanho = -1, linhas = 0;
	char hex[4];
	
	scanf("%s", hex);
	linhas = strtol(hex, 0, 16);
	
	for(; linhas > 0; --linhas){
		++tamanho;
		
		for(index = 0; index <= tamanho; ++index){
			if((index == 0)||(index == tamanho)){
				linhaAtual[index] = 1;
			}else{
				linhaAtual[index] = linhaAnterior[index] + linhaAnterior[index - 1]; 
			}
		}
		 
		for(int i = 0; i <= tamanho; ++i){
			printf("%08X", linhaAtual[i]);
			
			if(i != tamanho) printf(" ");
			else printf("\n");
		} 
	
	    aux = linhaAtual;
	    linhaAtual = linhaAnterior;
	    linhaAnterior = aux;
	}

    printf("\n");
    
    free(linhaAnterior);
    free(linhaAtual);

	return 0;
}
