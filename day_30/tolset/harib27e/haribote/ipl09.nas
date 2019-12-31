; haribote-ipl
; TAB=4

CYLS	EQU		9				

		ORG		0x7c00			

; 

		JMP		entry
		DB		0x90
		DB		"HARIBOTE"		
		DW		512				
		DB		1				
		DW		1				
		DB		2				
		DW		224				
		DW		2880			
		DB		0xf0			
		DW		9				
		DW		18				
		DW		2				
		DD		0				
		DD		2880			
		DB		0,0,0x29		
		DD		0xffffffff		
		DB		"HARIBOTEOS "	
		DB		"FAT12   "		
		RESB	18				



entry:
		MOV		AX,0			
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX



		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			
		MOV		DH,0			
		MOV		CL,2			
		MOV		BX,18*2*CYLS-1	
		CALL	readfast		



		MOV		BYTE [0x0ff0],CYLS	
		JMP		0xc200

error:
		MOV		AX,0
		MOV		ES,AX
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			
		MOV		BX,15			
		INT		0x10			
		JMP		putloop
fin:
		HLT						
		JMP		fin				
msg:
		DB		0x0a, 0x0a		
		DB		"load error"
		DB		0x0a			
		DB		0

readfast:	

		MOV		AX,ES			
		SHL		AX,3			
		AND		AH,0x7f			
		MOV		AL,128			
		SUB		AL,AH

		MOV		AH,BL			
		CMP		BH,0			
		JE		.skip1
		MOV		AH,18
.skip1:
		CMP		AL,AH			
		JBE		.skip2
		MOV		AL,AH
.skip2:

		MOV		AH,19			
		SUB		AH,CL			
		CMP		AL,AH			
		JBE		.skip3
		MOV		AL,AH
.skip3:

		PUSH	BX
		MOV		SI,0			
retry:
		MOV		AH,0x02			
		MOV		BX,0
		MOV		DL,0x00			
		PUSH	ES
		PUSH	DX
		PUSH	CX
		PUSH	AX
		INT		0x13			
		JNC		next			
		ADD		SI,1			
		CMP		SI,5			
		JAE		error			
		MOV		AH,0x00
		MOV		DL,0x00			
		INT		0x13			
		POP		AX
		POP		CX
		POP		DX
		POP		ES
		JMP		retry
next:
		POP		AX
		POP		CX
		POP		DX
		POP		BX				
		SHR		BX,5			
		MOV		AH,0
		ADD		BX,AX			
		SHL		BX,5			
		MOV		ES,BX			
		POP		BX
		SUB		BX,AX
		JZ		.ret
		ADD		CL,AL			
		CMP		CL,18			
		JBE		readfast		
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readfast		
		MOV		DH,0
		ADD		CH,1
		JMP		readfast
.ret:
		RET

		RESB	0x7dfe-$		

		DB		0x55, 0xaa
