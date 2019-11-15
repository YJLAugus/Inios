/* 告诉编译器,有一个函数在别的文件里 */

void io_hlt(void);

/* 是函数声明，却没有函数体，这表示的意思是：函数在别的文件里，你这个编译器自己去找啊！ */

void HariMain(void)
{

fin:
	io_hlt(); /* 执行naskfunc.nas里的_io_hlt */
	goto fin;

}
