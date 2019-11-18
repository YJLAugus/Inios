/* 告诉编译器,有一个函数在别的文件里 */
void io_hlt(void);
/* 是函数声明，却没有函数体，这表示的意思是：函数在别的文件里，你这个编译器自己去找啊！ */
void HariMain(void)
{
	int i;//声明变量：i是一个32位整数
	char * p; //指针变量,用来存放BYTE型地址
	p = (char *) 0xa0000;//指针变量赋值
	for(i=0;i<=0xaffff;i++)
	{
		p[i] = i & 0x0f;
		
	}
	for(;;)
	{
		io_hlt();
	}

}
