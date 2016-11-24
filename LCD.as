ESCR_LCD	EQU	FFF5h
APONT_LCD	EQU	FFF4h
Pos_nave	EQU	5000h  ;sitio onde vamos estar constantemente a atualizar a pos

MOV R3,1D17h  ;exemplo de uma posicao da nave possivel so para testar o lcd esta e a linha de baixo saiem
MOV M[5000h],R3
MOV R4,M[5000h]
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
		ADD R3,0030h
		BR Escreve

Escreve:MOV M[APONT_LCD],R1 
	MOV M[ESCR_LCD],R3
	BR AtualizaPont

AtualizaPont:	CMP R1,FFC0h  ;update do ponteiro 
		BR.Z Fim
		DEC R1
		BR AtualizaRegisto
AtualizaRegisto: SHR R4,4
		 MOV R3,0010h
		 JMP SacaDigito
HexaEspecial: ADD R3,0037h
		BR Escreve
Fim: BR Fim
			


