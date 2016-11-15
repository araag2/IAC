;criacao da rotina que faz o espaco de jogo

        ORIG 0000h
        MOV R1,FFFFh
        MOV M[FFFCh],R1  ;inicializaçao janela de texto
        MOV R1,0
        MOV R2,0 ;registo que vai alterando R1 pq vai ser usado o seu bit mais e menos significativo
        MOV R3,'#'  ;caractere que vai ser escrito na janela de texto

linha1: MVBL R1,R2  ;vai atualizando o cursor para passar a proxima posicao da linha
        MOV M[FFFCh],R1    ;aponta posicao na linha
        MOV M[FFFEh],R3    ;escreve # na posicao
        ADD R2,1
        CMP R2,0050h ;verifica se ja terminou a primeira linha 
        BR.Z proximo
        CMP R2,1750h  ;verifica se ja terminou a segunda linha
        BR.Z Nave ;
        BR linha1
		
proximo: MOV R2,1700h;atualiza o valor de R2 para a proxima coluna
         MOV R1,R2
         BR linha1

Nave: MOV R1,0303h       ;Coordenadas da nave, quarta linha terceira coluna  
      MOV R2,0403h       ;Coordenadas da nave, quinta linha terceira coluna
	  MOV R3,'\'
      MOV R4,')'
      MOV R5,'>'	  
      MOV R6,'/'
      MOV M[FFFCh],R1
	  MOV M[FFFEh],R3
	  MOV M[FFFCh],R2
	  MOV M[FFFEh],R4
	  MOV R1,0503h    ;Coordenadas da nave, sexta linha terceira coluna
	  MOV R2,0404h    ;Coordenadas da nave, quinta linha quarta coluna
	  MOV M[FFFCh],R1
	  MOV M[FFFEh],R6
	  MOV M[FFFCh],R2
	  MOV M[FFFEh],R5
	  MOV R1,0303h
	  MOV R2,0403h
	  MOV R3,0503h
	  MOV R4,0404h
	  MOV R5,"\"
	  ENI
Fim:  BR Fim

       ;Nesta parte do codigo e importante referir que R1 esta com a asa de cima, R2 com a parte de tras, R3 com a asa de baixo e R4 com o canhao 
	   
Cima:  MOV R6, 0
       MVBH R6,R1           ;Temos de Decrementar uma linha R1,R2,R3 e R4
       SUB R6, 0100h          
	   BR.Z FicaNoSítio     ;Verificar que nao vai sair da janela 
	   SUB R1, 0100h
	   M[FFFCh], R1
	   M[FFFEh], R5
	   MOV R5,")"
       SUB R2, 0100h	   
	   M[FFFCh], R2
	   M[FFFEh], R5
	   SUB R3, 0100h
	   MOV R5,"/" 
	   M[FFFCh], R3
	   M[FFFEh], R5
	   MOV R5,">"
       SUB R4, 0100h	   
	   M[FFFCh],R1
	   M[FFFEh],R5
	   MOV R5,"/" 
FicaNoSítio:	   RTI
	   
	   
	   
	   
Baixo: ;Incrementar uma linha R1,R2,R3,R4

Esquerda: ;Decrementar uma coluna R1,R2,R3,R4

Direita: ;Incrementar uma coluna R1,R2,R3,R4
	 