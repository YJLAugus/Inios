; haribote-os
; TAB=4

		ORG		0xc200			; 这个程序将要装载的地址。

		MOV		AL,0x13			; VGA显卡，320 * 200 * 8 位色彩。
		MOV		AH,0x00
		INT		0x10
fin:
		HLT
		JMP		fin
