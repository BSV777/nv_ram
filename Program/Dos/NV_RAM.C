#include <stdio.h>
#pragma inline //������祭�� TASM
void WriteRAM (unsigned int Addr, unsigned char Data);
unsigned char ReadRAM (unsigned int Addr);
unsigned int Base, Addr = 0x0000, ConstAddr = 0xFFFF;
unsigned char Status, Code, HighAddr, LowAddr, Data, Mask, bit, Inf;
float Parity=0;
FILE *fp;
int main(argc, argv) //����砥� ��ࠬ���� �� ��������� ��ப�
int argc;
char *argv[];
{
clrscr();
textcolor(3);
cputs (" ��������������������������������������������������������������Ŀ");
printf ("\n"); cputs (" �");
printf ("   The driver of cartridge programmer with nonvolatile RAM.   ");
cputs ("�"); printf ("\n"); cputs (" �");
printf ("    �ࠩ��� �ணࠬ���� ����ਤ�� � ���࣮������ᨬ� ���.  ");
cputs ("�"); printf ("\n"); cputs (" �");
printf (" (c) ���� �����⭮-���⠦�� ��. ��� ��� B.S.V. 01.02.2000. ");
cputs ("�"); printf ("\n");
cputs (" ����������������������������������������������������������������");
printf ("\n"); textcolor(7);
//�롮� ०��� ࠡ���
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
printf("\n           � � � � � � �   � � � � � � � � � � � � � �\n");
printf("      ������ �ணࠬ�� ���� ����� ᯥ樠����஢������  �ண-\n");
printf("   ࠬ���-�����⭮�� ��������,  �।�����祭���� ���  ���ᯥ�-\n");
printf("   ��� ������ ���ଠ樥� ����� �������஬ ⨯� IBM PC  �  �⠭-\n");
printf("   ��� � ���, ����騬 ����䥩� �����뢠�饣� ���ன�⢠.  ��-\n");
printf("   �⥫�� ���ଠ樨 ���� ����ਤ� � ���  ��ꥬ��  8  �����.\n");
printf("   ��ଠ� ����� - ISO-7bit � ����஫�� �⭮��. ��� ������祭��\n");
printf("   �ணࠬ���� �ᯮ������ ���� �ਭ��.            \n");
printf("      ��� ����� 䠩�� � ����ਤ� ����室��� ��।���  �१  ��-\n");
printf("   ������� ��ப� ��� 䠩��. �ணࠬ�� �஢���� ����稥 ����ਤ-\n");
printf("   �� � ࠧꥬ� � ������ ���.  �� ����� ���� � ��᫥���� 16\n");
printf("   ���� �� �ᯮ������� � ����������� �����  FFh.  ���ଠ�� �� \n");
printf("   䠩�� �����������, ���������� ��⮬ �⭮��. �� ��� 㤠��-\n");
printf("   ����  ��� 0Dh. �� ����᪥ �ணࠬ�� ��� ��ࠬ��஢ ᮤ�ন���\n");
printf("   ����ਤ�� �����뢠���� � 䠩� nv_ram � �㫥�� ��⮬ �⭮��.\n");
	  exit(0);
	  }
       }
       }
//��।������ �������� ���� ���� � ����஫� ������ ����ਤ��
asm {
    mov AX, 40h
    mov ES, AX       //ES 㪠�뢠�� �� ������� ������ BIOS
    mov DX, ES:[8]   //����砥� ������ ���� ���� LPT1
    mov Base, DX     //��࠭塞 ������ ���� � Base
    }
Status = inportb (Base + 1); //��⠥� ॣ���� ���ﭨ�

if ((Status & 0x80) == 0)
  {
  printf("  ����ਤ� ���������.\n");
  exit(0);
  }
if (argc==1) //�⥭�� ���ଠ樨 �� ����ਤ�� � 䠩� nvram
{
char *fname = "nv_ram";
outportb (Base + 2, 0x0D); //������� ��⠭��
delay(500); //����প� �� ��⠭������� ��⠭��
if(!(fp=fopen(fname,"wb")))
   {
   printf("���� nv_ram �� ����� ���� ��p��\n");
   exit(0);
   }
printf("   ������ � 䠩� nv_ram.");
for (Addr = 0x0000; Addr < 0x1FFF; Addr++)
	{
	Code = ReadRAM(Addr);
	Code = Code & 0x7F;
	if (Code==0x0A) fputc(0x0D, fp);
	fputc(Code, fp);
	}
fclose(fp); //������� 䠩�
delay(500); //����প� ��� ���室� �奬� � Z-���ﭨ�
outportb (Base + 2, 0x0C); //�몫���� ��⠭��
exit (0);
}

//�஢�ઠ ����㯠 � 䠩��
if (!(fp=fopen(argv[1],"rb")))
{
printf("���� �� ����� ���� ��p��\n");
exit(0);
}
outportb (Base + 2, 0x0D); //������� ��⠭��
delay(500); //����প� �� ��⠭������� ��⠭��
printf("���⪠ ����ਤ��.\n");
for (Addr = 0x0000; Addr < 0x1FFF; Addr++) WriteRAM(Addr,0x00);
printf("������ ���ଠ樨:");
Addr = 0x0010;
Code = getc(fp);
do
{
if (Code == 0x0D) Code = getc(fp);
Parity=0; // ��⠭���� ��� �⭮��
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
printf("  ���� ᫨誮� ����让 !\n");
break;
}
Code = getc(fp);
} while (!feof(fp)); //����஫� ���� 䠩��
fclose(fp); //������� 䠩�
printf (" %d ����.\n", Addr - 16);
printf("����஫�: ");
fp=fopen(argv[1],"rb");
Addr = 0x0010;
Code = getc(fp);
do
{
if (Code == 0x0D) Code = getc(fp);
Parity=0; // ��⠭���� ��� �⭮��
for (Mask = 0x01;  Mask < 0x80; Mask = Mask <<1 )
    {
    bit = Code & Mask;
    if (bit != 0) Parity++;
    }
if (Parity/2.0 != (int)(Parity/2.0)) Code = Code | 0x80;
Inf = ReadRAM(Addr);
if (Inf != Code)
{
printf ("�訡�� �� ����� %Xh.\n", Addr);
printf ("� 䠩�� %Xh. � ����ਤ�� %Xh.\n", Code, Inf);
if (Inf==0xFF) printf ("�஢���� ��⠭�� �� ����ਤ�� !\n");
break;
}
Addr++;
Code = getc(fp);
} while (!feof(fp)); //����஫� ���� 䠩��
printf ("OK\n");
fclose(fp); //������� 䠩�
delay(500); //����প� ��� ���室� �奬� � Z-���ﭨ�
outportb (Base + 2, 0x0C); //�몫���� ��⠭��
return 0;
}
/*------------ ��楤�� ����� ���� --------------------------*/
void WriteRAM(unsigned int Addr, unsigned char Data)
{
Data = Data^0xFF;  // ������� ������
LowAddr = Addr & 0xDF; //�뤥����� ����襩 ��� ����, ��⠭����
HighAddr = Addr>>5; //�뤥����� ���襩 ��� ����

if (HighAddr != ConstAddr)
{
outportb (Base + 2, 0x0B); //��஡ ����� ���襩 ��� ����
outportb (Base + 2, 0x0B);
outportb (Base + 2, 0x0B);
outportb (Base + 2, 0x0B);
outportb (Base, HighAddr); //������ ���襩 ��� ����
outportb (Base, HighAddr);
ConstAddr = HighAddr;
}

outportb (Base + 2, 0x09); //��஡ ����� ����襩 ��� ����
outportb (Base + 2, 0x09);
outportb (Base + 2, 0x09);
outportb (Base + 2, 0x09);
outportb (Base, LowAddr);  //������ ����襩 ��� ����
outportb (Base, LowAddr);

outportb (Base + 2, 0x0F); //��஡ ����� ������
outportb (Base + 2, 0x0F);
outportb (Base + 2, 0x0F);
outportb (Base + 2, 0x0F);
outportb (Base, Data);     //������ ������
outportb (Base, Data);

outportb (Base + 2, 0x05); //���⨥ ��஡������ ᨣ�����
outportb (Base + 2, 0x05);
outportb (Base + 2, 0x05);
outportb (Base + 2, 0x05);
outportb (Base + 2, 0x05);

return;
}
/*-------- ��楤�� �⥭�� ���� ---------------------*/
unsigned char ReadRAM(unsigned int Addr)
{
unsigned char HighData, LowData;
LowAddr = Addr | 0x60;
HighAddr = Addr>>5;

if (HighAddr != ConstAddr)
{
outportb (Base + 2, 0x0B); //��஡ ����� ���襩 ��� ����
outportb (Base + 2, 0x0B);
outportb (Base + 2, 0x0B);
outportb (Base + 2, 0x0B);
outportb (Base, HighAddr); //������ ���襩 ��� ����
outportb (Base, HighAddr);
ConstAddr = HighAddr;
}

outportb (Base + 2, 0x09); //��஡ ����� ����襩 ��� ����
outportb (Base + 2, 0x09);
outportb (Base + 2, 0x09);
outportb (Base + 2, 0x09);
outportb (Base, LowAddr);  //������ ����襩 ��� ����
outportb (Base, LowAddr);

outportb (Base + 2, 0x0F); //��஡ �⥭�� ������
outportb (Base + 2, 0x0F);
outportb (Base + 2, 0x0F);
outportb (Base + 2, 0x0F);
HighData = inportb (Base + 1); //�⥭�� ���襩 ��ࠤ� ������

LowAddr = LowAddr & 0xBF;

outportb (Base + 2, 0x09); //��஡ ����� ����襩 ��� ����
outportb (Base + 2, 0x09);
outportb (Base + 2, 0x09);
outportb (Base + 2, 0x09);
outportb (Base, LowAddr);  //������ ����襩 ��� ����
outportb (Base, LowAddr);

outportb (Base + 2, 0x0F); //��஡ �⥭�� ������
outportb (Base + 2, 0x0F);
outportb (Base + 2, 0x0F);
outportb (Base + 2, 0x0F);

LowData = inportb (Base + 1); //�⥭�� ����襩 ��ࠤ� ������

outportb (Base + 2, 0x05); //���⨥ ��஡������ ᨣ�����
outportb (Base + 2, 0x05);
outportb (Base + 2, 0x05);
outportb (Base + 2, 0x05);
Data = (HighData <<1 & 0xF0) | (LowData >>3 & 0x0F);
Data = Data^0xFF;  // �������
return Data;
}
/*----------------- ����� �ணࠬ�� -------------------*/

