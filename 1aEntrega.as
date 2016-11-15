;=============================================
;I- Criacao da rotina que faz o espaco de jogo
;=============================================
       IO_WRITE      EQU FFFEh
	   IO_READ       EQU FFFCh
	   INT_MASK_ADDR EQU FFFAh
       INT_MASK      EQU 0000000000001111b 
	   
	   
;=============================================
;       Tabela referente a cada interrupcao
;=============================================	   
	                 ORIG FE00h
INT0                 WORD Baixo
INT1                 WORD Cima
INT2                 WORD Esquerda
INT3                 WORD Direita
                  
;==============================================
; Criar a Janela, as linhas e a Nave
;==============================================	   
		ORIG 0000h
		MOV R6, FDFFh
		MOV SP, R6
		MOV	R7,INT_MASK
		MOV	M[INT_MASK_ADDR],R7
		MOV R3,0000h
        MOV R3,FFFFh
        MOV M[IO_READ],R3  ;inicializacao janela de texto
        MOV R1,0
        MOV R2,0 ;registo que vai alterando R1 pq vai ser usado o seu bit mais e menos significativo
        MOV R3,'#'  ;caractere que vai ser escrito na janela de texto
		

linha1: MVBL R1,R2  ;vai atualizando o cursor para passar a proxima posicao da linha
        MOV M[IO_READ],R1    ;aponta posicao na linha
        MOV M[IO_WRITE],R3    ;escreve # na posicao
        ADD R2,1
        CMP R2,0050h ;verifica se ja terminou a primeira linha 
        BR.Z proximo
        CMP R2,1750h  ;verifica se ja terminou a segunda linha
        BR.Z Nave ;
        BR linha1
		
proximo: MOV R2,1700h ;atualiza o valor de R2 para a proxima coluna
         MOV R1,R2
         BR linha1

Nave: MOV R1,0303h       ;Coordenadas da nave, quarta linha terceira coluna  
      MOV R2,0403h       ;Coordenadas da nave, quinta linha terceira coluna
	  MOV R3,'\'
      MOV R4,')'
      MOV R5,'>'	  
      MOV R6,'/'
      MOV M[IO_READ],R1
	  MOV M[IO_WRITE],R3
	  MOV M[IO_READ],R2
	  MOV M[IO_WRITE],R4
	  MOV R1,0503h    ;Coordenadas da nave, sexta linha terceira coluna
	  MOV R2,0404h    ;Coordenadas da nave, quinta linha quarta coluna
	  MOV M[IO_READ],R1
	  MOV M[IO_WRITE],R6
	  MOV M[IO_READ],R2
	  MOV M[IO_WRITE],R5
	  MOV R1,0303h 
	  MOV R2,'\'
	  MOV R3,')'
	  MOV R4,'>'
	  MOV R5,'/'
	  MOV R6,' '
	  ENI
Fim:  BR Fim

        
;======================================================
; Rotinas referentes a cada interrupcao 
;=======================================================	   
Cima:        MOV R7,0
             MVBH R7,R1           
             SUB R7, 0100h          
	         JMP.Z FicaNoSitio     ;Verificar que nao vai sair da janela
             CALL DestroiNave
             SUB R1,0100h
             CALL CriaNave	   
FicaNoSitio: RTI



Baixo:       MOV R7,0
             MVBH R7,R1           
             SUB R7, 1700h          
	         JMP.Z FicaNoSitio2     ;Verificar que nao vai sair da janela
             CALL DestroiNave
             ADD R1,0100h
             CALL CriaNave	   
FicaNoSitio2: RTI





Esquerda:    MOV R7,0
             MVBH R7,R1           
             SUB R7, 0001h          
	         JMP.Z FicaNoSitio3     ;Verificar que nao vai sair da janela
             CALL DestroiNave
             SUB R1,0001h
             CALL CriaNave	   
FicaNoSitio3: RTI





Direita:     MOV R7,0
             MVBH R7,R1           
             SUB R7, 0050h          
	         JMP.Z FicaNoSitio4     ;Verificar que nao vai sair da janela
             CALL DestroiNave
             ADD R1,0001h
             CALL CriaNave	   
FicaNoSitio4: RTI




DestroiNave:  MOV M[IO_READ],R1          ;Destroi a nave
	          MOV M[IO_WRITE],R6
	          ADD R1, 0100h
	          MOV M[IO_READ],R1
	          MOV M[IO_WRITE],R6
	          ADD R1, 0001h
	          MOV M[IO_READ],R1
	          MOV M[IO_WRITE],R6
	          ADD R1,00FFh
	          MOV M[IO_READ],R1
	          MOV M[IO_WRITE],R6
	          SUB R1, 0200h
			  RET
		  
CriaNave:     MOV M[IO_READ],R1 ;Criar a nave
	          MOV M[IO_WRITE],R2
              ADD R1, 0100h	   
	          MOV M[IO_READ],R1
	          MOV M[IO_WRITE],R3
	          ADD R1, 0001h
	          MOV M[IO_READ],R1
	          MOV M[IO_WRITE],R4
              ADD R1, 00FFh	   
	          MOV M[IO_READ],R1
	          MOV M[IO_WRITE],R5
		      SUB R1, 0200h
			  RET
	   
	   
	       
	 