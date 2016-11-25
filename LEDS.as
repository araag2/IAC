Porto_LED	EQU	FFF8h

Aciona_Led:	MOV R1,FFFFh
		MOV M[Porto_LED],R1 
		;rotina que aciona todos os LEDS.deve ser acionada quando um asteroide e destruido simultaneamente