; hello-os
; TAB=4

		ORG		0x7c00			; 指明程序的装?地址

; 以下?述?于?准FAT格式??

		JMP		entry
		DB		0x90
		DB		"HELLOIPL"		; ??区的名称可以是任意的字符串（8字?）
		DW		512				; ?个扇区（sector）的大小（必??512字?）
		DB		1				; 簇（cluster）的大小（必??1个扇区）
		DW		1				; FAT的起始位置（一般从第一个扇区?始）
		DB		2				; FAT的个数（必??2）
		DW		224				; 根目?的大小（一般?成224?）
		DW		2880			; ?磁?的大小（必?是2880扇区）
		DB		0xf0			; 磁?的??（必?是0xf0）
		DW		9				; FAT的?度（必?是9扇区）
		DW		18				; 1个磁道（track）有几个扇区（必?是18）
		DW		2				; 磁?数（必?是2）
		DD		0				; 不?用分区，必?是0
		DD		2880			; 重写一次磁?大小
		DB		0,0,0x29		; 意?不明，固定
		DD		0xffffffff		; (可能是) 卷?号?
		DB		"HELLO-OS   "	; 磁?的名称（11字?）注意：引号里的空格可不是随便填写的，而是?了?充字?
		DB		"FAT12   "		; 磁?格式名称（8字?）
		RESB	18				; 先空出18字?

; 程序核心

entry:
		MOV		AX,0			; 初始化寄存器
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX
		MOV		ES,AX

		MOV		SI,msg
putloop:						; 循?
		MOV		AL,[SI]			; 把SI地址的一个字?的内容?入AL中
		ADD		SI,1			; ?SI加1
		CMP		AL,0			; 比?AL是否等于0
		JE		fin				; 如果比?的?果成立，?跳?到fin,fin是一个?号，表示“?束”
		MOV		AH,0x0e			; ?示一个文字
		MOV		BX,15			; 指定字符?色
		INT		0x10			; ?用??BIOS，INT 是一个中断指令，?里可以??理解?“函数?用”
		JMP		putloop
fin:
		HLT						; ?CPU停止，等待指令，?CPU?入待机状?
		JMP		fin				; 无限循?

msg:
		DB		0x0a, 0x0a		; ?行?次
		DB		"hello,Inios"
		DB		0x0a			; ?行
		DB		0

		RESB	0x7dfe-$		; 从0x7dfe地址?始用0x00填充

		DB		0x55, 0xaa