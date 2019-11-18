/* 告诉编译器,有一个函数在别的文件里 */
void io_hlt(void);
void write_mem8(int addr,int data);
/* 是函数声明，却没有函数体，这表示的意思是：函数在别的文件里，你这个编译器自己去找啊！ */

void HariMain(void)
{
	int i;//声明变量：i是一个32位整数
	
	for(i=0xa0000;i<=0xaffff;i++)
	{
		write_mem8(i,15);//VRAM全部写入15
	}
	for(;;)
	{
		io_hlt();
	}

}
