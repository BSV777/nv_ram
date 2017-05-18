#include <stdio.h>
#pragma inline //Подключение TASM
void WriteRAM (unsigned int Addr, unsigned char Data);
unsigned char ReadRAM (unsigned int Addr);
unsigned int Base, Addr = 0x0000, ConstAddr = 0xFFFF;
unsigned char Status, Code, HighAddr, LowAddr, Data, Mask, bit, Inf;
float Parity=0;
FILE *fp;
int main(argc, argv) //Получаем параметры из командной строки
int argc;
char *argv[];
{
clrscr();
textcolor(3);
cputs (" ┌──────────────────────────────────────────────────────────────┐");
printf ("\n"); cputs (" │");
printf ("   The driver of cartridge programmer with nonvolatile RAM.   ");
cputs ("│"); printf ("\n"); cputs (" │");
printf ("    Драйвер программатора картриджа с энергонезависимым ОЗУ.  ");
cputs ("│"); printf ("\n"); cputs (" │");
printf (" (c) НЛМК Ремонтно-монтажный цех. Бюро АСУ B.S.V. 01.02.2000. ");
cputs ("│"); printf ("\n");
cputs (" └──────────────────────────────────────────────────────────────┘");
printf ("\n"); textcolor(7);
//Выбор режима работы
switch (argc)
       {
       case 1:
       break;
       case 2:
       if (*argv[1]=='/')
	  {
	  *(argv[1]+1) = tolower(*(argv[1]+1));
	  if (*(argv[1]+1)=='?')
	  {
printf("\n           К р а т к а я   х а р а к т е р и с т и к а\n");
printf("      Данная программа является частью специализированного  прог-\n");
printf("   раммно-аппаратного комплекса,  предназначенного для  обеспече-\n");
printf("   ния обмена информацией между компьютером типа IBM PC  и  стан-\n");
printf("   ком с ЧПУ, имеющим интерфейс фотосчитывающего устройства.  Но-\n");
printf("   сителем информации является картридж с ОЗУ  объемом  8  Кбайт.\n");
printf("   Формат записи - ISO-7bit с контролем четности. Для подключения\n");
printf("   программатора используется порт принтера.            \n");
printf("      Для записи файла в картридж необходимо передать  через  ко-\n");
printf("   мандную строку имя файла. Программа проверяет наличие картрид-\n");
printf("   жа в разъеме и обнуляет его.  При записи первые и последние 16\n");
printf("   байт не используются и заполняются кодом  FFh.  Информация из \n");
printf("   файла инвертируется, дополняется битом четности. Из нее удаля-\n");
printf("   ется  код 0Dh. При запуске программы без параметров содержимое\n");
printf("   картриджа записывается в файл nv_ram с нулевым битом четности.\n");
	  exit(0);
	  }
       }
       }
//Определение базового адреса порта и контроль наличия картриджа
asm {
    mov AX, 40h
    mov ES, AX       //ES указывает на область данных BIOS
    mov DX, ES:[8]   //получаем базовый адрес порта LPT1
    mov Base, DX     //сохраняем базовый адрес в Base
    }
Status = inportb (Base + 1); //Читаем регистр состояния

if ((Status & 0x80) == 0)
  {
  printf("  Картридж отсутствует.\n");
  exit(0);
  }
if (argc==1) //Чтение информации из картриджа в файл nvram
{
char *fname = "nv_ram";
outportb (Base + 2, 0x0D); //Включить питание
delay(500); //Задержка на установление питания
if(!(fp=fopen(fname,"wb")))
   {
   printf("Файл nv_ram не может быть откpыт\n");
   exit(0);
   }
printf("   Запись в файл nv_ram.");
for (Addr = 0x0000; Addr < 0x1FFF; Addr++)
	{
	Code = ReadRAM(Addr);
	Code = Code & 0x7F;
	if (Code==0x0A) fputc(0x0D, fp);
	fputc(Code, fp);
	}
fclose(fp); //Закрыть файл
delay(500); //Задержка для перехода схемы в Z-состояние
outportb (Base + 2, 0x0C); //Выключить питание
exit (0);
}

//Проверка доступа к файлу
if (!(fp=fopen(argv[1],"rb")))
{
printf("Файл не может быть откpыт\n");
exit(0);
}
outportb (Base + 2, 0x0D); //Включить питание
delay(500); //Задержка на установление питания
printf("Очистка картриджа.\n");
for (Addr = 0x0000; Addr < 0x1FFF; Addr++) WriteRAM(Addr,0x00);
printf("Запись информации:");
Addr = 0x0010;
Code = getc(fp);
do
{
if (Code == 0x0D) Code = getc(fp);
Parity=0; // Установка бита четности
for (Mask = 0x01;  Mask < 0x80; Mask = Mask <<1 )
    {
    bit = Code & Mask;
    if (bit != 0) Parity++;
    }
if (Parity/2.0 != (int)(Parity/2.0)) Code = Code | 0x80;
WriteRAM(Addr,Code);
Addr++;
if (Addr==0x1FF0)
{
printf("  Файл слишком большой !\n");
break;
}
Code = getc(fp);
} while (!feof(fp)); //Контроль конца файла
fclose(fp); //Закрыть файл
printf (" %d байт.\n", Addr - 16);
printf("Контроль: ");
fp=fopen(argv[1],"rb");
Addr = 0x0010;
Code = getc(fp);
do
{
if (Code == 0x0D) Code = getc(fp);
Parity=0; // Установка бита четности
for (Mask = 0x01;  Mask < 0x80; Mask = Mask <<1 )
    {
    bit = Code & Mask;
    if (bit != 0) Parity++;
    }
if (Parity/2.0 != (int)(Parity/2.0)) Code = Code | 0x80;
Inf = ReadRAM(Addr);
if (Inf != Code)
{
printf ("Ошибка по адресу %Xh.\n", Addr);
printf ("В файле %Xh. В картридже %Xh.\n", Code, Inf);
if (Inf==0xFF) printf ("Проверьте питание на картридже !\n");
break;
}
Addr++;
Code = getc(fp);
} while (!feof(fp)); //Контроль конца файла
printf ("OK\n");
fclose(fp); //Закрыть файл
delay(500); //Задержка для перехода схемы в Z-состояние
outportb (Base + 2, 0x0C); //Выключить питание
return 0;
}
/*------------ Процедура записи байта --------------------------*/
void WriteRAM(unsigned int Addr, unsigned char Data)
{
Data = Data^0xFF;  // Инверсия данных
LowAddr = Addr & 0xDF; //Выделение младшей части адреса, установка
HighAddr = Addr>>5; //Выделение старшей части адреса

if (HighAddr != ConstAddr)
{
outportb (Base + 2, 0x0B); //Строб записи старшей части адреса
outportb (Base + 2, 0x0B);
outportb (Base + 2, 0x0B);
outportb (Base + 2, 0x0B);
outportb (Base, HighAddr); //Запись старшей части адреса
outportb (Base, HighAddr);
ConstAddr = HighAddr;
}

outportb (Base + 2, 0x09); //Строб записи младшей части адреса
outportb (Base + 2, 0x09);
outportb (Base + 2, 0x09);
outportb (Base + 2, 0x09);
outportb (Base, LowAddr);  //Запись младшей части адреса
outportb (Base, LowAddr);

outportb (Base + 2, 0x0F); //Строб записи данных
outportb (Base + 2, 0x0F);
outportb (Base + 2, 0x0F);
outportb (Base + 2, 0x0F);
outportb (Base, Data);     //Запись данных
outportb (Base, Data);

outportb (Base + 2, 0x05); //Снятие стробирующих сигналов
outportb (Base + 2, 0x05);
outportb (Base + 2, 0x05);
outportb (Base + 2, 0x05);
outportb (Base + 2, 0x05);

return;
}
/*-------- Процедура чтения байта ---------------------*/
unsigned char ReadRAM(unsigned int Addr)
{
unsigned char HighData, LowData;
LowAddr = Addr | 0x60;
HighAddr = Addr>>5;

if (HighAddr != ConstAddr)
{
outportb (Base + 2, 0x0B); //Строб записи старшей части адреса
outportb (Base + 2, 0x0B);
outportb (Base + 2, 0x0B);
outportb (Base + 2, 0x0B);
outportb (Base, HighAddr); //Запись старшей части адреса
outportb (Base, HighAddr);
ConstAddr = HighAddr;
}

outportb (Base + 2, 0x09); //Строб записи младшей части адреса
outportb (Base + 2, 0x09);
outportb (Base + 2, 0x09);
outportb (Base + 2, 0x09);
outportb (Base, LowAddr);  //Запись младшей части адреса
outportb (Base, LowAddr);

outportb (Base + 2, 0x0F); //Строб чтения данных
outportb (Base + 2, 0x0F);
outportb (Base + 2, 0x0F);
outportb (Base + 2, 0x0F);
HighData = inportb (Base + 1); //Чтение старшей тетрады данных

LowAddr = LowAddr & 0xBF;

outportb (Base + 2, 0x09); //Строб записи младшей части адреса
outportb (Base + 2, 0x09);
outportb (Base + 2, 0x09);
outportb (Base + 2, 0x09);
outportb (Base, LowAddr);  //Запись младшей части адреса
outportb (Base, LowAddr);

outportb (Base + 2, 0x0F); //Строб чтения данных
outportb (Base + 2, 0x0F);
outportb (Base + 2, 0x0F);
outportb (Base + 2, 0x0F);

LowData = inportb (Base + 1); //Чтение младшей тетрады данных

outportb (Base + 2, 0x05); //Снятие стробирующих сигналов
outportb (Base + 2, 0x05);
outportb (Base + 2, 0x05);
outportb (Base + 2, 0x05);
Data = (HighData <<1 & 0xF0) | (LowData >>3 & 0x0F);
Data = Data^0xFF;  // Инверсия
return Data;
}
/*----------------- Конец программы -------------------*/

