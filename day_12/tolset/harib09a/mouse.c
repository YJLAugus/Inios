
#include "bootpack.h"

struct FIFO8 mousefifo;

void inthandler2c(int *esp)
/* 来自PS/2鼠标的中断 */
{
	unsigned char data;
	io_out8(PIC1_OCW2, 0x64);	/* 通知PIC1 IRQ-12的受理已经完成 */
	io_out8(PIC0_OCW2, 0x62);	/* 通知PIC0 IRQ-02的受理已经完成 */
	data = io_in8(PORT_KEYDAT);
	fifo8_put(&mousefifo, data);
	return;
}

#define KEYCMD_SENDTO_MOUSE		0xd4
#define MOUSECMD_ENABLE			0xf4


void enable_mouse(struct MOUSE_DEC *mdec)
{
	/* 鼠标有效 */
	wait_KBC_sendready();
	io_out8(PORT_KEYCMD, KEYCMD_SENDTO_MOUSE);
	wait_KBC_sendready();
	io_out8(PORT_KEYDAT, MOUSECMD_ENABLE);
	/* 顺利的话,ACK(0xfa)会被送过来 */
	mdec->phase = 0; /* 等待0xfa的阶段 */
	return;
}

int mouse_decode(struct MOUSE_DEC *mdec, unsigned char dat)
{
	if (mdec->phase == 0) {
		/* 等待鼠标的0xfa的阶段 */
		if (dat == 0xfa) {
			mdec->phase = 1;
		}
		return 0;
	}
	if (mdec->phase == 1) {
		/* 等待鼠标的0xfa的阶段 */
		if ((dat & 0xc8) == 0x08) {
			/* 如果第一字节正确 */
			mdec->buf[0] = dat;
			mdec->phase = 2;
		}
		return 0;
	}
	if (mdec->phase == 2) {
		/* 等待鼠标第二个字节的阶段 */
		mdec->buf[1] = dat;
		mdec->phase = 3;
		return 0;
	}
	if (mdec->phase == 3) {//鼠标键的状态在butf[0]的低三位
		/* 等待鼠标第二字节的阶段 */
		mdec->buf[2] = dat;
		mdec->phase = 1;
		mdec->btn = mdec->buf[0] & 0x07;
		mdec->x = mdec->buf[1];
		mdec->y = mdec->buf[2];
		if ((mdec->buf[0] & 0x10) != 0) {
			mdec->x |= 0xffffff00;
		}
		if ((mdec->buf[0] & 0x20) != 0) {
			mdec->y |= 0xffffff00;
		}
		mdec->y = - mdec->y; /* 鼠标的y方向与画面符号相反 */
		return 1;
	}
	return -1; /* 应该不可能到这里来 */
}
