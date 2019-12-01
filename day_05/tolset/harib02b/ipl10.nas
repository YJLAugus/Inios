; haribote-ipl
; TAB=4
CYLS	EQU		10

		ORG		0x7c00			; 指明程序的装载地址

; 以下这段是标准FAT12格式软盘专用的代码

		JMP		entry
		DB		0x90
		DB		"HELLOIPL"		;	启动区的名称可以是任意的字符串（8字节）
		DW		512				;	每个扇区（sector）的大小（必须为512字节）
		DB 		1				;	簇（cluster）的大小（必须为1个扇区）
		DW		1				;	FAT的起始位置（一般从第一个扇区开始）
		DB		2				;	FAT的个数（必须为2）
		DW		224				;	根目录的大小（一般设成224项）
		DW		2880			;	该磁盘的大小（必须是2880扇区）
		DB		0xf0			;	磁盘的种类（必须是0xf0）
		DW		9				;	FAT的长度（必须是9扇区）
		DW		18				;	1个磁道（track）有几个扇区（必须是18）
		DW		2				;	磁头数（必须是2）
		DD		0				;	不适用分区，必须是0
		DD		2880			;	重写一次磁盘大小
		DB		0,0,0x29		;	意义不明，固定
		DD		0xffffffff		;	(可能是) 卷标号码
		DB		"HELLO-OS   "	;	磁盘的名称（11字节）
		DB		"FAT12   "		;	磁盘格式名称（8字节）
		RESB	18				;	先空出18字节

; 程序主体

entry:
		MOV		AX,0			;  初始化寄存器
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; 读盘

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; 柱面0
		MOV		DH,0			; 磁头0
		MOV		CL,2			; 扇区2，第一个扇区用作制作启动区了

readloop:
		
	    MOV		SI,0			; 记录失败次数的寄存器
		
		
	   
retry:
		MOV		AH,0x02			; AH=0x02 : 读入磁盘 
		MOV		AL,1			; 1个扇区
		MOV		BX,0			
		MOV		DL,0x00			; A驱动器
		INT		0x13			; 调用磁盘BIOS 判断是否发生错误
		JNC		next			; 没出错的话就跳转到next
		ADD		SI,1			; 往SI 加 1
		CMP		SI,5			; 比较SI 和 5
		JAE		error			; SI >= 5时，跳转到error
		MOV		AH,0x00
		MOV		DL,0x00			; A 驱动器
		INT		0x13			; 重置驱动器
		JMP		retry
next:
		MOV		AX,ES			; 把内存地址后移0x200,往后移动一个扇区512B换成16进制是0x200
		ADD		AX,0x0020
		MOV		ES,AX			; 扇区移动了,同样的缓冲地址也需要更新，因为没有ADD ES,
								; 0x200指令，所以这里以这种方式实现累加ES（更新ES）的目的
		ADD		CL,1			; 往CL里加1,扇区是第二个扇区了鸭
		CMP		CL,18			; 比较CL与18
		JBE		readloop		; 如果CL <= 18 跳转至readloop
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; 如果DH < 2,则跳转到readloop
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; 如果CH < CYLS,则跳转到readloop
		
; ipl的结束地址告诉haribote.sys

		MOV		[0x0ff0],CH		; IPL的结束地址(将CYLS的值写到内存地址0x0ff0中)
		JMP		0xc200
error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; 把SI地址的一个字节的内容读入AL中
		CMP		AL,0            ; 比较AL是否等于0
		JE		fin				; 如果比较的结果成立，则跳转到fin,fin是一个标号，表示“结束”
		MOV		AH,0x0e			; 显示一个文字
		MOV		BX,15			; 指定字符颜色
		INT		0x10			; 调用显卡BIOS，INT 是一个中断指令，这里可以暂时理解为“函数调用”
		JMP		putloop
		
fin:
		HLT						; 让CPU停止，等待指令，让CPU进入待机
		JMP		fin				; 无限循环
msg:
		DB		0x0a, 0x0a		; 换行两次
		DB		"load error"
		DB		0x0a			; 换行
		DB		0

		RESB	0x7dfe-$		; 从0x7dfe地址开始用0x00填充

		DB		0x55, 0xaa
