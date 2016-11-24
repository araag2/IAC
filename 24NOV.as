;=============================================
;I- Criacao da rotina que faz o espaco de jogo
;=============================================
       IO_WRITE      EQU FFFEh
	   IO_READ       EQU FFFCh
	   INT_MASK_ADDR EQU FFFAh
       INT_MASK      EQU 1000000000001111b 
	   EnablerTimer	 EQU 0001h
	   CadenciaTimer EQU 0001h ;0,5 segundos de cadencia
	   TimerValue	 EQU FFF6h ;endereco do Temporizador
	   TimerControl  EQU FFF7h ;endereco que para ou comeca o temporizador
	   CountTimer	 EQU 0000h ;variavel.permite escrever de 1 em 1 seg
	   Tiro			 EQU '-'
	   Apaga		 EQU ' '  ;constante utilizada para limpar ecra
;=============================================
;II-Tabela referente a cada interrupcao
;=============================================	   
	                 ORIG FE00h
INT0                 WORD Baixo
INT1                 WORD Cima
INT2                 WORD Esquerda
INT3                 WORD Direita
INT15				 WORD Temporizador                 
;==============================================
;III- Criar a Janela, as linhas e a Nave
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
	  MOV R7,0
      BR Ciclo
	  
========================================================
; IV-Ciclo De Jogo
;=======================================================	
   Ciclo: CMP R7,1
          CALL.Z Baixo_Rotina
		  CMP R7,2
		  CALL.Z Cima_Rotina
		  CMP R7,3
		  CALL.Z Esquerda_Rotina
		  CMP R7,4
		  CALL.Z Direita_Rotina
		  CMP R7,5
		  CALL.Z Tiros
		  JMP Ciclo
;======================================================
; V-Rotinas referentes a cada interrupcao 
;=======================================================	   

;=========================
;Mexe a Nave para baixo
;=========================

Baixo:       MOV R7,1
             RTI 
			 
Baixo_Rotina:MOV R7,0
             MVBH R7,R1
             ADD R7,0300h			 
             SUB R7, 1700h          
	         JMP.Z FicaNoSitio     ;Verificar que nao vai sair da janela
             CALL DestroiNave
             ADD R1,0100h
             CALL CriaNave			 
FicaNoSitio: MOV R7,0			 
             RET
			 
;=========================
; Mexe a Nave para cima
;=========================

Cima:        MOV R7,2
             RTI 

Cima_Rotina: MOV R7,0
             MVBH R7,R1           
             SUB R7, 0100h          
	         JMP.Z FicaNoSitio     ;Verificar que nao vai sair da janela
             CALL DestroiNave
             SUB R1,0100h
             CALL CriaNave
             MOV R7,0				 
             RET
			 
;===========================
;Mexe a Nave para a esquerda
;===========================

Esquerda:    MOV R7,3
             RTI 


Esquerda_Rotina:    MOV R7,0
             MVBL R7,R1           
             SUB R7, 0001h		 
	         JMP.Z FicaNoSitio     ;Verificar que nao vai sair da janela
             CALL DestroiNave
             SUB R1,0001h
             CALL CriaNave		 
             RET

;=========================
;Mexe a Nave para a direita
;=========================
Direita:     MOV R7,4
             RTI 

Direita_Rotina:     MOV R7,0
             MVBL R7,R1
             ADD R7,0002h			 
             SUB R7, 0050h          
	         JMP.Z FicaNoSitio     ;Verificar que nao vai sair da janela
             CALL DestroiNave
             ADD R1,0001h
             CALL CriaNave			 
             RET		 
;=========================
;Destroi a Nave atual
;=========================
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
			  
;===========================
;Cria a Nave na nova posição
;===========================

CriaNave:     MOV M[IO_READ],R1  ;Criar a nave
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
			  MOV R7,0
			  RET
			  
;====================================
; Tira as peças	e repõe-as mais tarde   
;====================================	     
  
  Componentes_Nave: PUSH R2
                    MOV R2,'\'
					PUSH R3
	                MOV R3,')'
					PUSH R4
	                MOV R4,'>'
					PUSH R5
	                MOV R5,'/'     ;ISTO NÃO RESULTA AINDA, É NORMAL QUE NÃO SE PERCEBA ;) 
					PUSH R6
	                MOV R6,' '
					RET
	
        Recoloca:  POP R6
                   POP R5	
                   POP R4	 				   
	               POP R3	
				   POP R2
				   RET
;====================================
;Tiro -rotina responsavel pela criacao
;de tiros
=====================================
Tiro: ADD R1,   ;000000000000000000000000000000000000falta por as coordenadas da nave neste registo
	  MOV M[FFFCh],R1
	  MOV M[FFFEh],Tiro
	  CALL CountTimerTiro 
Progressao:	MOV R1, ;coordenadas do tiro antigo
			MOV M[IO_READ],R1 ;aponta para onde vai apagar
			MOV R1,M[Apaga]
			MOV M[IO_WRITE],R1 ;apaga o antigo tiro
			CMP M[IO_READ+1],Asteroide  ;compara se a posicao que tem a frente e para destruir ou nao
			BR.Z Colisao  ;000000000000000000000000000000000por escrever
			MOV M[CountTimerTiro], RO ;reinicio do timer do tiro
			BR Tiro 


;====================================
;Temporizador
=====================================
IniciaTimer:	MOV R1,M[CadenciaTimer]
				MOV M[TimerValue],R1 ;poe a cadencia de 0,5 seg a contar
				MOV R1,M[EnablerTimer]
				MOV M[TimerControl],R1
				INC M[CountTimer]
				RET
CountTimerTiro: MOV R2,M[CountTimer]
				CMP R2,0032h
				BR.Z Progressao
				INC M[CountTimer] 
				BR  CountTimerTiro