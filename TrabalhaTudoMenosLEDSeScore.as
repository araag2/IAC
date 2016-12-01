;=============================================
;I- Criacao da rotina que faz o espaco de jogo
;=============================================
       IO_WRITE     				 EQU FFFEh
	   IO_READ       				 EQU FFFCh
	   INT_MASK_ADDR 		 EQU FFFAh
       INT_MASK     				 EQU 1100000000011111b 
	  INT_BEGIN_MASK		 EQU 0100000000000000b
	   AcabaString   				 EQU '@'
	   IniciaClock   				 EQU FFF7h
	 VelocidadeClock			 EQU FFF6h
	 TiroFisico						 EQU  '-'
	 Vazio							 EQU  ' '
	 Asteroide						 EQU  '*'
	 BuracoNegro	 			 EQU 'O'
	 Mascara_Random           EQU            1000000000010110b
	 Porto_LED						 EQU			FFF8h

;=============================================
;I.I- Definição de Strings
;=============================================
      ORIG 8000h
	  Baixo_F       				WORD   0
	  Cima_F         				WORD  0
	  Esquerda_F  				WORD  0
	  Direita_F         			WORD  0
	  Clock_F1          			WORD  0
	  Clock_F2          			WORD  0
	  Tiros_F		    			WORD  0
	  Tiro_Existe                 WORD  0
	  Pontuacao         			WORD  0
	  RandomORG   				WORD 0
	  NumeroAsteroides 		WORD 0
	  NumeroBuracosNegros WORD 0
	  Ciclos                          WORD 5
      Object_Spawn		        WORD	0100h
	  ContadorBuracoNegro  WORD  4
	  ContadorMoveAsteroide WORD 10
	  ContadorEscreveAsteroide WORD 10
	  Asteroides        			TAB    30
	  BuracosNegros 			TAB    30
	  POS_Tiro                       WORD 0 
	  Game_Over_F             WORD  0
	  InitialMessage  			STR 'Prepare-se@'
	  InitialMessage2 			STR 'Prima o botao IE@'
	  GameOverMessage1     STR 'GameOver Pontuacao:@'
	  GameOverMessage2     STR 'Prima IE Para recomecar@'
	   ESCR_LCD		 			EQU	FFF5h
	  APONT_LCD	 			EQU	FFF4h
	  Pos_nave					EQU	5000h  ;sitio onde vamos estar constantemente a atualizar a pos
 	   
;=============================================
;II-Tabela referente a cada interrupcao
;=============================================	   
	                     ORIG FE00h
INT0                  WORD Baixo
INT1                 WORD Cima
INT2                  WORD Esquerda
INT3                 WORD Direita
INT4			  	     WORD Tiro
					     ORIG FE0Eh
INT14                WORD Restart 
INT15                WORD Tempo
;==============================================
;III- Criar a Janela, as linhas e a Nave
;==============================================
;==============================================
;Inicia a Janela de Testo
;==============================================	  	   
		ORIG 0000h
		MOV R6, FDFFh
		MOV SP, R6
        MOV R3,FFFFh
        MOV M[IO_READ],R3  ;inicializacao janela de texto
		
;==============================================
;Começa ou recomeça o Jogo
;==============================================	  		
 GameRestart: MOV	R7,INT_BEGIN_MASK
					  MOV	M[INT_MASK_ADDR],R7
					  MOV M[Pontuacao],R0 ;reeinicia a pontuacao
					  ENI
					  CALL StartScreen
GameOverStart: CALL LimpaObjectos
 GameStart:    CMP R7,5
		              BR.Z GameStart2
				      INC M[RandomORG]
             	      BR GameStart
					  
GameOver: INC M[Game_Over_F]			  
                  RET
				  
GameOver2: CALL LimparJanela
                   MOV M[Game_Over_F],R0
                   JMP GameRestart2				  
			
GameRestart2:MOV	R7,INT_BEGIN_MASK
					  MOV	M[INT_MASK_ADDR],R7
					  MOV M[Pontuacao],R0 ;reeinicia a pontuacao
					  ENI
                      CALL GameOverScreen
                      JMP GameOverStart					  
			
 GameStart2:  CALL LimparJanela
                      BR EscreverJanela
					  
LimpaObjectos: PUSH R1
                       PUSH R2
                       PUSH R3
					   MOV M[NumeroAsteroides],R0
					   MOV M[NumeroBuracosNegros],R0
					   MOV M[Tiro_Existe],R0
					   MOV M[POS_Tiro],R0
                       MOV R3,60
					   MOV R2, Asteroides
Limpa2:		   MOV M[R2],R0
					   DEC R3
					   INC R2
					   CMP R3,R0
					   BR.Z AcabaLimpeza
					   BR Limpa2
AcabaLimpeza: POP R3
                       POP R2
                       POP R1
					   RET
					                         					   
;==============================================
;Escrever a Janela de Texto
;==============================================	
 EscreverJanela:	MOV	R7,INT_MASK
							MOV	M[INT_MASK_ADDR],R7
							MOV R1,0
							MOV R2,0 ;registo que vai alterando R1 pq vai ser usado o seu bit mais e menos significativo
							MOV R3,'#'  ;caractere que vai ser escrito na janela de texto
		

linha1: MVBL R1,R2  ;vai atualizando o cursor para passar a proxima posicao da linha
           MOV M[IO_READ],R1    ;aponta posicao na linha
           MOV M[IO_WRITE],R3    ;escreve # na posicao
           ADD R2,1
           CMP R2,004Fh ;verifica se ja terminou a primeira linha 
           BR.Z proximo
           CMP R2,174Fh  ;verifica se ja terminou a segunda linha
           BR.Z Nave ;
           BR linha1
		
proximo: MOV R2,1700h ;atualiza o valor de R2 para a proxima coluna
              MOV R1,R2
              BR linha1
;==============================================
;Escreve a Nave inicialmente
;==============================================	

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
;==============================================
;Escreve a Mensagem Final
;==============================================	
	  
GameOverScreen:             MOV R2, 0A1Fh
							   MOV R3, GameOverMessage1
ContinuaAEscrever4:   MOV M[IO_READ],R2
							   MOV R4,M[R3]
							   CMP R4, AcabaString
							   BR.Z ContinuaAEscrever5
							   MOV M[IO_WRITE],R4
							   INC R2
							   INC R3
							   BR ContinuaAEscrever4
ContinuaAEscrever5: MOV R2, 0C1Bh
							    MOV R3, GameOverMessage2
ContinuaAEscrever6: MOV M[IO_READ],R2
							   MOV R4,M[R3]
							   CMP R4, AcabaString
							   BR.Z Acaba
							   MOV M[IO_WRITE],R4
							   INC R2
							   INC R3
							   BR ContinuaAEscrever6
Acaba:                     RET		 
		 
		 
;==============================================
;Escreve a Mensagem Inicial
;==============================================	
	  
StartScreen:             MOV R2, 0A1Fh
							   MOV R3, InitialMessage
ContinuaAEscrever:   MOV M[IO_READ],R2
							   MOV R4,M[R3]
							   CMP R4, AcabaString
							   BR.Z ContinuaAEscrever2
							   MOV M[IO_WRITE],R4
							   INC R2
							   INC R3
							   BR ContinuaAEscrever
ContinuaAEscrever2: MOV R2, 0C1Bh
							    MOV R3, InitialMessage2
ContinuaAEscrever3: MOV M[IO_READ],R2
							   MOV R4,M[R3]
							   CMP R4, AcabaString
							   BR.Z Acaba2
							   MOV M[IO_WRITE],R4
							   INC R2
							   INC R3
							   BR ContinuaAEscrever3
Acaba2:                     RET
;==============================================
;Limpa a Janela por completo
;==============================================	
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
			 MOV		R1,5
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
		  CMP M[Tiros_F],R0
		  CALL.NZ Tiros
		  CMP R7,5
		  CALL.Z RestartGame
		  CMP M[Clock_F1],R0
		  CALL.NZ CicloClockF1
;         CMP M[Clock_F2],R0
;	      CALL.NZ CicloClockF2
	      CMP M[Game_Over_F],R0
		  JMP.NZ GameOver2
		  JMP Ciclo
;=======================================================
; V-Rotinas referentes a cada interrupcao 
;=======================================================
;=========================
; Ciclo de Clock F1
;=========================
CicloClockF1: DEC M[Ciclos]
                    CMP M[Ciclos],R0
					CALL.Z CriaObjetos
                    CMP	M[NumeroAsteroides],R0
  				    CALL.NZ MexeObjetos
					CMP M[Tiro_Existe],R0
					CALL.NZ MexeTiros
					CALL Colisoes
					MOV M[Clock_F1],R0						
					RET
					
;=========================
; Ciclo de Clock F2
;=========================
CicloClockF2:  CMP M[Tiro_Existe],R0
                     CALL.NZ MexeTiros
                     MOV M[Clock_F2],R0		
					 RET
;=========================
; Colisoes
;=========================
Colisoes:    					PUSH R1
									PUSH R2
									PUSH R3
									PUSH R4
									PUSH R5
									PUSH R6
									MOV R3,61
									MOV R2,Asteroides
CicloColisoes:				CMP R1,M[R2]
									CALL.Z GameOver
									ADD R1,0100h
									CMP R1,M[R2]
									CALL.Z GameOver
									ADD R1,0001h
									CMP R1,M[R2]
									CALL.Z GameOver
									ADD R1,00FFh
									CMP R1,M[R2]
									CALL.Z GameOver
									SUB R1,0200h
									INC R2
									DEC R3
									CMP R3,R0
									BR.Z EndColisoes
									BR CicloColisoes
EndColisoes:					POP R6
									POP R5
									POP R4
									POP R3
									POP R2
									POP R1
									RET
				 
;================================
; Ciclo que mexe os asteroides e os buracos negros
;================================				  
MexeObjetos:PUSH R1
                     PUSH R2
				     PUSH R3
					 PUSH R4
					 PUSH R5
					 PUSH R6
                     MOV R2,Asteroides
                     MOV R1,M[NumeroAsteroides]
MexeObjetos1:CMP R1,0
                      JMP.Z MexeObjetos3
					  CMP M[R2],R0
					  JMP.Z MexeObjetos2
					  MOV R3,0
					  MVBL R3,M[R2]
					  CMP R3,0
					  JMP.Z ApagaAsteroide
					  CALL ResetAsteroide
					  DEC M[R2]
					  CALL DesenhaAsteroide
Rebentou:	  DEC R1
MexeObjetos2: INC R2
                       JMP MexeObjetos1
MexeObjetos3: Call MexeBuracos
                       POP R6
                       POP R5
					   POP R4
					   POP R3
					   POP R2
					   POP R1
                       RET
ResetAsteroide: MOV R4,Vazio
                        MOV R3,M[R2]
                        MOV M[IO_READ],R3
                        MOV M[IO_WRITE],R4
                        RET
ApagaAsteroide: CALL ResetAsteroide
                         MOV M[R2],R0
                         DEC R1
                         DEC M[NumeroAsteroides]
						 BR MexeObjetos2
						 
ApagaBuraco:  CALL ResetAsteroide
					  MOV M[R2],R0
                      DEC R1
                      DEC M[NumeroBuracosNegros]
                      JMP MexeBuracos2					  
						 
MexeBuracos: MOV R2,BuracosNegros
                     MOV  R1,M[NumeroBuracosNegros]
MexeBuracos1:CMP R1,0
                      JMP.Z MexeBuracosFim
                      CMP M[R2],R0	
                      JMP.Z MexeBuracos2
					  MOV R3,0
					  MVBL R3,M[R2]
					  CMP R3,0
					  JMP.Z ApagaBuraco
					  CALL ResetAsteroide
					  DEC M[R2]
					  CALL DesenhaBuraco
					  DEC R1
MexeBuracos2: INC R2
                      JMP MexeBuracos1
MexeBuracosFim: RET					  
;=========================
; Cria os Objetos do Ecrã
;=========================
CriaObjetos:  PUSH R1
                    PUSH R2
					PUSH R3
					PUSH R4
					PUSH R5
					PUSH R6
                    MOV R3,5
					MOV M[Ciclos],R3
					MOV R3,R0
					MOV M[Object_Spawn],R0
					MOV R2,R0
					MOV R1,R0
					CALL Randomize
					CALL CriaAsteroide
EndCycle:	    POP R6
                    POP R5
					POP R4
					POP R3
					POP R2
					POP R1
                    RET
					
;=========================
; Cria os Asteroides 
;=========================					
 CriaAsteroide:       MOV R4,R0
                    MVBH R4,M[Object_Spawn]
                    ADD R4, 78
					DEC		M[ContadorBuracoNegro]
			        CMP		M[ContadorBuracoNegro],R0
			        JMP.Z	CriaBuraco
					MOV R2,Asteroides
CriaAsteroideNext:CMP M[R2],R0
                       BR.Z CriaAsteroideEnd
                       INC R2
                       BR CriaAsteroideNext
CriaAsteroideEnd:	MOV M[R2],R4
                       CALL DesenhaAsteroide
                       INC M[NumeroAsteroides]					   
				       RET
					
DesenhaAsteroide: MOV R3,M[R2]
                            MOV R5,Asteroide
                            MOV M[IO_READ],R3
							MOV M[IO_WRITE],R5
                            RET
;=========================
; Cria os Buracos Negros
;=========================											
DesenhaBuraco:  MOV R3,M[R2]
                            MOV R5,BuracoNegro
                            MOV M[IO_READ],R3
							MOV M[IO_WRITE],R5
                            RET							
							
 CriaBuraco: 				    MOV R2,BuracosNegros
CreateBuracoNext:   		CMP M[R2],R0
									BR.Z CreateBuracoEnd
									INC R2
									BR CreateBuracoNext
CreateBuracoEnd: 			MOV M[R2],R4
                                    CALL DesenhaBuraco
                                    INC M[NumeroBuracosNegros]
                                    MOV R1,4
                                    MOV M[ContadorBuracoNegro],R1
                                    RET									
;=========================
; Ciclo Random
;=========================
Randomize:   MOV		R1,M[RandomORG]
			        MOV		R2,M[RandomORG]
			        AND		R2,0001h
			        CMP 	R2,R0
			        BR.Z	    Randomize1
			        MOV		R2,Mascara_Random
			        XOR		R1,R2
Randomize1:	ROR		R1,1
			        MOV		M[RandomORG],R1
			        MOV		R2,1600h
			        DIV		R1,R2
			        ADD		R2,0100h
			        MOV		M[Object_Spawn],R2
			        RET
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
			 CALL Colisoes
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
			 CALL Colisoes
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
			 CALL Colisoes
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
			 CALL Colisoes
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
			     MOV	R1,1
                 MOV	M[IniciaClock],R1
			     MOV	R1,5
			     MOV	M[VelocidadeClock],R1
				 INC 	M[Clock_F1]
			     INC      M[Clock_F2]
			     POP		R1 
                 RTI 			
							   
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
;==============================================================
;Tiros - Rotina que trata dos disparos
;compara se o espaco e branco. se nao for
;ve se destroi o asteroide ou se desaparece com o buraco negro
;==============================================================
Tiro: INC M[Tiros_F]
        RTI

Tiros:  CMP M[Tiro_Existe],R0
          CALL.Z CriaTiro
		  MOV M[Tiros_F],R0
		  RET
		  
CriaTiro: PUSH R1
              PUSH R2
              ADD R1,0102h
              MOV M[IO_READ],R1
              MOV R2, TiroFisico
              MOV M[IO_WRITE],R2
			  MOV M[POS_Tiro],R1
			  MOV R1,1
			  MOV M[Tiro_Existe],R1
              POP R2
			  POP R1
              RET

ApagaTiro: PUSH R1
                 PUSH R2
                 MOV R1,M[POS_Tiro]
                 MOV M[IO_READ],R1
                 MOV R2,Vazio
                 MOV M[IO_WRITE],R2
                 POP R2
                 POP R1				 
			     RET
				 
MexeTiros: PUSH R1
                 PUSH R2
                 PUSH R3
                 CMP M[Tiro_Existe],R0
                 CALL.Z SemTiro
                 MOV R1,M[POS_Tiro]
                 CALL ApagaTiro
                 CALL ColisaoTiro
				 CMP M[Tiro_Existe],R0
                 CALL.NZ NovoTiro			 				 
SemTiro: 	 POP R3
			     POP R2
			     POP R1
                 RET

ColisaoTiro:			PUSH R1
							PUSH R2
							PUSH R3
							PUSH R4
							PUSH R5
							MOV R4,30
							INC M[POS_Tiro]			;proxima posicao do tiro
							MOV R1,M[POS_Tiro]
							MOV R3,Asteroides			
MoveTiroAst:		 CMP M[R3],R1
							CALL.Z TiroAst
							MOV R5,R1
							ADD R5,0001h
							CMP M[R3],R5
							CALL.Z TiroAst
							ADD R5,0001h
							CMP M[R3],R5
							CALL.Z TiroAst
							ADD R5,0001h
							CMP M[R3],R5
							CALL.Z TiroAst
							INC R3
							DEC R4
							CMP R4,R0
							BR.Z MoveTiroBuraco
							BR MoveTiroAst
MoveTiroBuraco:	MOV R4,30
							MOV R3,BuracosNegros		
MoveTiroBuraco2: CMP M[R3],R1
			               CALL.Z TiroBuraco
						   MOV R5,R1
						   ADD R5,0001h
						   CMP M[R3],R5
				           CALL.Z TiroBuraco
						   ADD R5,0001h
						   CMP M[R3],R5
				           CALL.Z TiroBuraco
				           ADD R5,0001h
				           CMP M[R3],R5
				           CALL.Z TiroBuraco
			               INC R3
			               DEC R4
			               CMP R4,R0
			               BR.Z MoveTiroFim
			               BR MoveTiroBuraco2
MoveTiroFim:      MOV R2,R0
                           MVBL R2,R1
						   CMP R2,004Eh 
                           CALL.Z NoTiro
                           INC R2
                           CMP R2,004Fh 
                           CALL.Z NoTiro
                           INC R2	
						   CMP R2,0050h 
                           CALL.Z NoTiro							   
						   DEC M[POS_Tiro] 
						   POP R5
						   POP R4
                           POP R3
						   POP R2
						   POP R1
                           RET						   

NovoTiro:  		CMP M[Tiro_Existe],R0
						BR.Z NovoTiroEnd	
                        INC M[POS_Tiro]	
                        CALL DesenhaTiro									
 NovoTiroEnd:    RET

DesenhaTiro:PUSH R1
                   PUSH R2
				   INC M[POS_Tiro]
                   MOV R1,M[POS_Tiro]
				   MOV M[IO_READ],R1
				   MOV R2, TiroFisico
				   MOV M[IO_WRITE],R2
                   POP R2
			       POP R1
                   RET  
						   
						   
NoTiro: MOV M[Tiro_Existe],R0
            MOV M[POS_Tiro],R0
            RET

TiroAst: 	 PUSH R1
                 PUSH R2
                 PUSH R3
				 PUSH R4
				 PUSH R5
				 INC M[Pontuacao]
				 CALL AcendeLeds
				 DEC M[NumeroAsteroides]
				 MOV R4,Vazio
                 MOV R5,M[R3]
                 MOV M[IO_READ],R5
                 MOV M[IO_WRITE],R4
				 MOV M[R3],R0
				 MOV M[Tiro_Existe],R0
				 CALL ApagaLeds	
				 POP R5
				 POP R4
                 POP R3
				 POP R2
				 POP R1				 
                 RET
				 
TiroBuraco:PUSH R1
				 MOV M[Tiro_Existe],R0
				 POP R1				 
                 RET
				 
;=======================================
;Display -pontuacao
;=======================================
;=======================================
;LEDS - rotina que e chamada quando ha colisao
;com um asteroide
;=======================================				 
AcendeLeds:	PUSH R1
			MOV R1,FFFFh
			MOV M[Porto_LED],R1 
			POP R1
			RET
ApagaLeds:	PUSH R1
			MOV R1,R0
			MOV M[Porto_LED],R1	
			POP R1
			RET

			  
		  