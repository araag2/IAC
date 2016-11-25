;=============================================
;I- Criacao da rotina que faz o espaco de jogo
;=============================================
       IO_WRITE      EQU FFFEh
	   IO_READ       EQU FFFCh
	   INT_MASK_ADDR EQU FFFAh
       INT_MASK      EQU 1100000000001111b 
	  INT_BEGIN_MASK EQU 0100000000000000b
	   AcabaString   EQU '@'
	   IniciaClock   EQU FFF7h
	 VelocidadeClock EQU FFF6h
;=============================================
;I.I- Definição de Strings
;=============================================
      ORIG 8000h
	  Baixo_F        WORD  0
	  Cima_F         WORD  0
	  Esquerda_F     WORD  0
	  Direita_F      WORD  0
	  Clock_F        WORD  0
	  InitialMessage  STR 'Prepare-se@'
	  InitialMessage2 STR 'Prima o botao IE@'
	   ESCR_LCD		 EQU	FFF5h
	  APONT_LCD		 EQU	FFF4h
	  Pos_nave		 EQU	5000h  ;sitio onde vamos estar constantemente a atualizar a pos
 	   
;=============================================
;II-Tabela referente a cada interrupcao
;=============================================	   
	                 ORIG FE00h
INT0                 WORD Baixo
INT1                 WORD Cima
INT2                 WORD Esquerda
INT3                 WORD Direita
					 ORIG FE0Eh
INT14                WORD Restart 
INT15                WORD Tempo
;==============================================
;III- Criar a Janela, as linhas e a Nave
;==============================================	   
		ORIG 0000h
		MOV R6, FDFFh
		MOV SP, R6
        MOV R3,FFFFh
        MOV M[IO_READ],R3  ;inicializacao janela de texto
 GameRestart: MOV	R7,INT_BEGIN_MASK
		      MOV	M[INT_MASK_ADDR],R7
              ENI
              CALL StartScreen
 GameStart:   CMP R7,5
		      BR.Z GameStart2
              BR GameStart
			
			
			
 GameStart2: CALL LimparJanela
             BR EscreverJanela
 
 EscreverJanela:       MOV	R7,INT_MASK
		               MOV	M[INT_MASK_ADDR],R7
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
	  MOV R2,'\'
      MOV R3,')'
      MOV R4,'>'	  
      MOV R5,'/'
      CALL CriaNave
	  MOV R6,' '
	  MOV R7,0
	  CALL ComecaRelog
      JMP Ciclo
	  
StartScreen:         MOV R2, 0A1Fh
                     MOV R3, InitialMessage
ContinuaAEscrever:   MOV M[IO_READ],R2
                     MOV R4,M[R3]
					 CMP R4, AcabaString
					 BR.Z ContinuaAEscrever2
					 MOV M[IO_WRITE],R4
					 INC R2
					 INC R3
                     BR ContinuaAEscrever
ContinuaAEscrever2:  MOV R2, 0C1Bh
                     MOV R3, InitialMessage2
ContinuaAEscrever3: MOV M[IO_READ],R2
                     MOV R4,M[R3]
					 CMP R4, AcabaString
					 BR.Z Acaba
					 MOV M[IO_WRITE],R4
					 INC R2
					 INC R3
					 BR ContinuaAEscrever3
Acaba:               RET

LimparJanela:   PUSH R1
                PUSH R2				 
	            MOV R1,0000h
				MOV R2,' '
LimparJanela2:	MOV M[IO_READ], R1
				MOV M[IO_WRITE], R2
				INC R1
				CMP R1, 1750h
				BR.Z Next
				BR LimparJanela2
Next:			POP R2
				POP R1
				RET
				
;====================================
; Começa o Relógio
;====================================	

ComecaRelog: PUSH R1
             MOV		R1,1
			 MOV		M[IniciaClock],R1
			 MOV		R1,1
			 MOV		M[VelocidadeClock],R1
			 POP R1
			 RET

				
;========================================================
; IV-Ciclo De Jogo
;=======================================================	
   Ciclo: CMP M[Baixo_F],R0
          CALL.NZ Baixo_Rotina
		  CMP M[Cima_F],R0
		  CALL.NZ Cima_Rotina
		  CMP M[Esquerda_F],R0
		  CALL.NZ Esquerda_Rotina
		  CMP M[Direita_F],R0
		  CALL.NZ Direita_Rotina
		  CMP R7,5
		  CALL.Z RestartGame
		  JMP Ciclo
;======================================================
; V-Rotinas referentes a cada interrupcao 
;=======================================================

;=========================
;Restarta o jogo
;=========================	   
Restart: MOV R7,5
         RTI
;=========================
;Mexe a Nave para baixo
;=========================

Baixo:       INC M[Baixo_F]
             RTI 
			 
Baixo_Rotina:DEC M[Baixo_F]
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

Cima:        INC M[Cima_F]
             RTI 

Cima_Rotina: DEC M[Cima_F]
             MVBH R7,R1           
             SUB R7, 0100h          
	         JMP.Z FicaNoSitio     ;Verificar que nao vai sair da janela
             CALL DestroiNave
             SUB R1,0100h
             CALL CriaNave
   			 RET
			 
;===========================
;Mexe a Nave para a esquerda
;===========================

Esquerda:    INC M[Esquerda_F]
             RTI 


Esquerda_Rotina:DEC M[Esquerda_F]
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
Direita:     INC M[Direita_F]
             RTI 

Direita_Rotina:DEC M[Direita_F]
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
			  MOV M[Pos_nave], R1 ;atualiza a memoria das coordenadas 
	          MOV M[IO_READ],R1
	          MOV M[IO_WRITE],R4
              ADD R1, 00FFh	   
	          MOV M[IO_READ],R1
	          MOV M[IO_WRITE],R5
		      SUB R1, 0200h
			  MOV R7,0
			  CALL EscLCD
			  RET
			  
;====================================
; Recomeça o jogo
;====================================	     			  
RestartGame: CALL LimparJanela
             MOV R7,0
             JMP GameRestart
			 
;====================================
; Passa um ciclo de Relógio
;====================================
Tempo:      PUSH	R1
			MOV		R1,1
			MOV		M[IniciaClock],R1
			MOV		R1,1
			MOV		M[VelocidadeClock],R1
			INC 	M[Clock_F]
			POP		R1 
            RTI 			
					
			
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
	                MOV R5,'/'     ;ISTO NÃO RESULTA AINDA, É NORMAL QUE NÃO SE PERCEBA  
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
;LCD - Rotina que escreve no LCD a 
;posicao da nave
;====================================
EscLCD: PUSH R4
		PUSH R3
		PUSH R2
		PUSH R1
		MOV R4,M[Pos_nave]
		MOV R3,0010h  ;pelo qual vamos sempre dividir para sacar digitos
		MOV R1,FFC3h
SacaDigito:	MOV R2,R4
		DIV R2,R3
		CMP R3,1010b
		JMP.Z HexaEspecial
		CMP R3,1011b
		JMP.Z HexaEspecial
		CMP R3,1100b
		JMP.Z HexaEspecial
		CMP R3,1101b
		JMP.Z HexaEspecial
		CMP R3,1110b
		JMP.Z HexaEspecial
		CMP R3,1111b
		JMP.Z HexaEspecial
		ADD R3,0030h
		BR Escreve

Escreve:MOV M[APONT_LCD],R1 
		MOV M[ESCR_LCD],R3
		BR AtualizaPont

AtualizaPont:	CMP R1,FFC0h  ;update do ponteiro 
		BR.Z AcabouEsc
		DEC R1
		BR AtualizaRegisto
AtualizaRegisto: SHR R4,4
				 MOV R3,0010h
				 JMP SacaDigito
HexaEspecial: ADD R3,0037h
				  BR Escreve
AcabouEsc: POP R1	
		   POP R2
		   POP R3
		   POP R4
		   RET