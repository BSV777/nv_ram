unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, StdCtrls, Buttons,
  About, Diag, Options;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    NewMnu: TMenuItem;
    OpenMnu: TMenuItem;
    SaveMnu: TMenuItem;
    SaveAsMnu: TMenuItem;
    N6: TMenuItem;
    CutMnu: TMenuItem;
    CopyMnu: TMenuItem;
    PasteMnu: TMenuItem;
    DelMnu: TMenuItem;
    N11: TMenuItem;
    SelAllMnu: TMenuItem;
    N12: TMenuItem;
    N14: TMenuItem;
    WriteMnu: TMenuItem;
    ReadMnu: TMenuItem;
    DiagMnu: TMenuItem;
    HelpMnu: TMenuItem;
    AboutMnu: TMenuItem;
    OpenFileDialog: TOpenDialog;
    txtCNC: TMemo;
    SaveFileDialog: TSaveDialog;
    Panel1: TPanel;
    NewBtn: TBitBtn;
    OpenBtn: TBitBtn;
    SaveBtn: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn13: TBitBtn;
    BitBtn14: TBitBtn;
    btnWrite: TBitBtn;
    Panel2: TPanel;
    State: TLabel;
    OptionsMnu: TMenuItem;
    lblProgress: TLabel;
    N2: TMenuItem;
    procedure AboutMnuClick(Sender: TObject);
    procedure DiagMnuClick(Sender: TObject);
    procedure OpenMnuClick(Sender: TObject);
    procedure SaveMnuClick(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
    procedure SaveAsMnuClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure NewBtnClick(Sender: TObject);
    procedure NewMnuClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SelAllMnuClick(Sender: TObject);
    procedure CutMnuClick(Sender: TObject);
    procedure CopyMnuClick(Sender: TObject);
    procedure PasteMnuClick(Sender: TObject);
    procedure DelMnuClick(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure BitBtn13Click(Sender: TObject);
    procedure BitBtn14Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OptionsMnuClick(Sender: TObject);
    procedure WriteMnuClick(Sender: TObject);
    procedure btnWriteClick(Sender: TObject);
    procedure ReadMnuClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
       CNCFilename: string = 'noname';
       ConstAddr: Word = 65535;
var
  frmMain: TfrmMain;
  ATextFile: Text;
  ATextLine, AFileName: String;

implementation

{$R *.DFM}


procedure GetBase(var PortNumber: Byte; var Base: Word);
var
P: Byte;
B: Word;
begin
P:= PortNumber;
case P of
     0: begin
	     asm
             mov AX, 40h
             mov ES, AX
             mov DX, ES:[8]
             mov B, DX
             end;
        end;
     1: begin
	     asm
             mov AX, 40h
             mov ES, AX
             mov DX, ES:[8]
             mov B, DX
             end;
        end;
     2: begin
	     asm
             mov AX, 40h
             mov ES, AX
             mov DX, ES:[0Ah]
             mov B, DX
             end;
        end;
     3: begin
	     asm
             mov AX, 40h
             mov ES, AX
             mov DX, ES:[0Ch]
             mov B, DX
             end;
        end;
end;
   Base:= B;
end;

procedure InPort(var Address: Word; var Data: Byte);
var
A: Word;
D: Byte;
begin
A:= Address;
	asm
        mov DX, A
        in AL, DX
        mov D, AL
        end;
Data:= D;
end;

procedure OutPort(var Address: Word; var Data: Byte);
var
A: Word;
D: Byte;
begin
A:= Address;
D:= Data;
	asm
        mov AL,D
        mov DX,A
        out DX,AL
        end;
end;

procedure WriteByte(var Address: Word; Data: Byte);
var
HighAddr, LowAddr, Signal: Byte;
begin
Data:= Not Data;  {Инверсия данных}
LowAddr:= Lo (Address And $0DF); {Выделение младших бит адреса}
HighAddr:= Lo (Address Shr 5); {Выделение старших бит адреса}
if HighAddr <> ConstAddr then
   begin
   Signal:= $0B;
   OutPort(Control, Signal); {Строб записи старших бит адреса}
   OutPort(Control, Signal);
   OutPort(Control, Signal);
   OutPort(Base, HighAddr); {Запись старших бит адреса}
   ConstAddr:= HighAddr;
   end;
   Signal:= $09;
   OutPort(Control, Signal); {Строб записи младших бит адреса}
   OutPort(Control, Signal);
   OutPort(Control, Signal);
   OutPort(Base, LowAddr);  {Запись младших бит адреса}
   Signal:= $0F;
   OutPort(Control, Signal); {Строб записи данных}
   OutPort(Control, Signal);
   OutPort(Control, Signal);
   OutPort(Base, Data);     {Запись данных}
   Signal:= $05;
   OutPort(Control, Signal); {Снятие стробирующих сигналов}
   OutPort(Control, Signal);
   OutPort(Control, Signal);
   OutPort(Control, Signal);
end;

procedure ReadByte(var Address: Word; var Data: Byte);
var
HighAddr, LowAddr, HighData, LowData, Signal: Byte;
begin
LowAddr:= Lo (Address Or $60);
HighAddr:= Lo (Address Shr 5);
if HighAddr <> ConstAddr then
   begin
   Signal:= $0B;
   OutPort(Control, Signal); {Строб записи старших бит адреса}
   OutPort(Control, Signal);
   OutPort(Control, Signal);
   OutPort(Base, HighAddr); {Запись старших бит адреса}
   ConstAddr:= HighAddr;
   end;
   Signal:= $09;
   OutPort(Control, Signal); {Строб записи младших бит адреса}
   OutPort(Control, Signal);
   OutPort(Control, Signal);
   OutPort(Base, LowAddr);  {Запись младших бит адреса}
   Signal:= $0F;
   OutPort(Control, Signal); {Строб чтения данных}
   OutPort(Control, Signal);
   OutPort(Control, Signal);
   InPort(Status, HighData); {Чтение старшей тетрады данных}
   LowAddr:= LowAddr And $0BF;
   Signal:= $09;
   OutPort(Control, Signal); {Строб записи младших бит адреса}
   OutPort(Control, Signal);
   OutPort(Control, Signal);
   OutPort(Base, LowAddr);  {Запись младших бит адреса}
   Signal:= $0F;
   OutPort(Control, Signal); {Строб чтения данных}
   OutPort(Control, Signal);
   OutPort(Control, Signal);
   InPort(Status, LowData); {Чтение младшей тетрады данных}
   Signal:= $05;
   OutPort(Control, Signal); {Снятие стробирующих сигналов}
   OutPort(Control, Signal);
   OutPort(Control, Signal);
   OutPort(Control, Signal);
   Data:= ((HighData Shl 1) And $0F0) Or ((LowData Shr 3) And $00F);
   Data:= Not Data;  {Инверсия}
end;

procedure Parity(var Code: Byte);
var
Parity: Real;
Mask, bit, Inf, Position: Byte;
begin
Parity:=0;
Mask:=1;
for Position:= 0 to 7 do
    begin
    bit:= Code And Mask;
    if (bit <> 0) then Parity:= Parity + 1;
    Mask:= Mask Shl 1;
    end;
if (Parity/2.0 <> Int(Parity/2.0)) then Code:= Code or $80;
end;

procedure TfrmMain.AboutMnuClick(Sender: TObject);
begin
frmAbout.ShowModal;
end;

procedure TfrmMain.DiagMnuClick(Sender: TObject);
begin
     frmDiag.ShowModal;
end;



procedure TfrmMain.OpenMnuClick(Sender: TObject);
var
  DialogValue: Integer;
begin
if txtCNC.Modified then
   begin
   DialogValue := MessageDlg('Сохранить изменения в файле?', mtWarning,
   [mbYes, mbNo, mbCancel], 0);
   if DialogValue = mrYes then
      begin
      SaveMnuClick(Sender);
      if OpenFileDialog.Execute then
         begin
         CNCFilename:= OpenFileDialog.Filename;
         Caption:= 'Драйвер программоносителя ЧПУ: ' + CNCFilename;
         txtCNC.Lines.LoadFromFile(CNCFilename);
         lblProgress.Caption:='Новый файл.';
         end;
      end;
   if DialogValue = mrNo then
      begin
      if OpenFileDialog.Execute then
         begin
         CNCFilename:= OpenFileDialog.Filename;
         Caption:= 'Драйвер программоносителя ЧПУ: ' + CNCFilename;
         txtCNC.Lines.LoadFromFile(CNCFilename);
         lblProgress.Caption:='Новый файл.';
         end;
      end;
   end
else
      begin
      if OpenFileDialog.Execute then
         begin
         CNCFilename:= OpenFileDialog.Filename;
         Caption:= 'Драйвер программоносителя ЧПУ: ' + CNCFilename;
         txtCNC.Lines.LoadFromFile(CNCFilename);
         lblProgress.Caption:='Новый файл.';
         end;
      end;
end;

procedure TfrmMain.SaveMnuClick(Sender: TObject);
begin
if CNCFilename = 'noname' then
    SaveAsMnuClick(Sender)
  else
  begin
    txtCNC.Lines.SaveToFile(CNCFilename);
    txtCNC.Modified := False;
  end;
end;


procedure TfrmMain.OpenBtnClick(Sender: TObject);
begin
OpenMnuClick(Sender)
end;

procedure TfrmMain.SaveAsMnuClick(Sender: TObject);
begin
SaveFileDialog.Filename := CNCFilename;
  if SaveFileDialog.Execute then
  begin
    CNCFilename := SaveFileDialog.Filename;
    Caption:= 'Драйвер программоносителя ЧПУ: ' + CNCFilename;
    SaveMnuClick(Sender);
  end;
end;

procedure TfrmMain.SaveBtnClick(Sender: TObject);
begin
SaveMnuClick(Sender)
end;

procedure TfrmMain.NewBtnClick(Sender: TObject);
begin
NewMnuClick(Sender)
end;

procedure TfrmMain.NewMnuClick(Sender: TObject);
var
  DialogValue: Integer;
begin
if txtCNC.Modified then
   begin
   DialogValue := MessageDlg('Сохранить изменения в файле?', mtWarning,
   [mbYes, mbNo, mbCancel], 0);
   if DialogValue = mrYes then
      begin
      SaveMnuClick(Sender);
      txtCNC.Text:='';
      CNCFilename := 'noname';
      Caption:= 'Драйвер программоносителя ЧПУ: ' + CNCFilename;
      lblProgress.Caption:='Новый файл.';
      end;
   if DialogValue = mrNo then
      begin
      txtCNC.Text:='';
      CNCFilename := 'noname';
      Caption:= 'Драйвер программоносителя ЧПУ: ' + CNCFilename;
      lblProgress.Caption:='Новый файл.';
      end;
   end
else
      begin
      txtCNC.Text:='';
      CNCFilename := 'noname';
      Caption:= 'Драйвер программоносителя ЧПУ: ' + CNCFilename;
      end;

end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  DialogValue: Integer;
begin
if txtCNC.Modified then
   begin
   DialogValue := MessageDlg('Сохранить изменения в файле?', mtWarning,
   [mbYes, mbNo], 0);
   if DialogValue = mrYes then SaveMnuClick(Sender);
   end;
end;

procedure TfrmMain.SelAllMnuClick(Sender: TObject);
begin
txtCNC.SelectAll;
end;

procedure TfrmMain.CutMnuClick(Sender: TObject);
begin
txtCNC.CutToClipboard;
end;

procedure TfrmMain.CopyMnuClick(Sender: TObject);
begin
txtCNC.CopyToClipboard;
end;

procedure TfrmMain.PasteMnuClick(Sender: TObject);
begin
txtCNC.PasteFromClipboard;
end;

procedure TfrmMain.DelMnuClick(Sender: TObject);
begin
txtCNC.ClearSelection;
end;

procedure TfrmMain.BitBtn12Click(Sender: TObject);
begin
CutMnuClick(Sender)
end;

procedure TfrmMain.BitBtn13Click(Sender: TObject);
begin
CopyMnuClick(Sender)
end;

procedure TfrmMain.BitBtn14Click(Sender: TObject);
begin
PasteMnuClick(Sender)
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
AFileName:='nv_ram.ini';
Assign(ATextFile, AFileName);
Reset(ATextFile);
while not Eof(ATextFile) do begin
      ReadLn(ATextFile, ATextLine);
      if ATextLine='Port=Auto' then PortNumber:=0;
      if ATextLine='Port=LPT1' then PortNumber:=1;
      if ATextLine='Port=LPT2' then PortNumber:=2;
      if ATextLine='Port=LPT3' then PortNumber:=3;
      if ATextLine='Volume=Auto' then KVolume:=1024;
      if ATextLine='Volume=2k' then KVolume:=2048;
      if ATextLine='Volume=8k' then KVolume:=8192;
      if ATextLine='Volume=16k' then KVolume:=16384;
      end;
GetBase(PortNumber, Base);
Control:= Base + 2;
Status:= Base + 1;
if Base=0 then MessageDlg('Порт LPT'+IntToStr(PortNumber)+' отсутствует!',mtWarning,[mbOk],0);
{Close(ATextFile);}
end;

procedure TfrmMain.OptionsMnuClick(Sender: TObject);
begin
frmOptions.ShowModal;
GetBase(PortNumber, Base);
Control:= Base + 2;
Status:= Base + 1;
if Base=0 then MessageDlg('Порт LPT'+IntToStr(PortNumber)+' отсутствует!',mtWarning,[mbOk],0);
lblProgress.Caption:='Изменены настройки.';
end;

procedure TfrmMain.WriteMnuClick(Sender: TObject);
var
Signal, Code, Data, ErrorType: Byte;
Address: Word;
LinesIndex, ColumnsIndex: Integer;
ErrorMessage, Line: String;
Label LErrors;
begin
{Процедура записи в картридж}
     ConstAddr:= 65535;
     LinesIndex:= 0;
     ColumnsIndex:= 1;
     ErrorType:=0;
     InPort(Status, Data);
     if (Data And $80) = 0 then
     begin
     ErrorType:=1;
     goto LErrors;
     end;
     Signal:= $0D;
     OutPort(Control, Signal); {Включить питание}
     Data:=0;
{Очистка картриджа}
     for Address:=0 to KVolume-1 do WriteByte(Address, Data);
{Запись}
     ConstAddr:= 65535;
     Line:=txtCNC.Lines[LinesIndex];
     Address:= FreeTop;
     while Length(Line) <> 0 do
           begin
           for ColumnsIndex:=1 to Length(Line) do
               begin
               Data:= Ord(Line[ColumnsIndex]);
               Parity(Data);
               WriteByte(Address, Data);
               Address:= Address + 1;
               If Address > KVolume-2 then
                     begin
                     ErrorType:=3;
                     goto LErrors;
                     end;
               end;
           Data:= $0A;
           WriteByte(Address, Data);
           Address:= Address + 1;
           LinesIndex:=LinesIndex + 1;
           Line:=txtCNC.Lines[LinesIndex];
           end;
{Проверка}
           ConstAddr:= 65535;
           LinesIndex:= 0;
           Line:=txtCNC.Lines[LinesIndex];
           Address:=FreeTop;
     while Length(Line) <> 0 do
           begin
           for ColumnsIndex:=1 to Length(Line) do
               begin
               Data:= Ord(Line[ColumnsIndex]);
               Parity(Data);
               ReadByte(Address, Code);
               If Data<>Code then
                     begin
                     ErrorType:=2;
                     goto LErrors;
                     end;
               Address:= Address + 1;
               end;
           Data:= $0A;
           ReadByte(Address, Code);
               If Data<>Code then
                     begin
                     ErrorType:=2;
                     goto LErrors;
                     end;
           Address:= Address + 1;
           LinesIndex:=LinesIndex + 1;
           Line:=txtCNC.Lines[LinesIndex];
           end;
LErrors:
     Signal:= $0C;
     OutPort(Control, Signal);  {Выключить питание}
     if ErrorType=1 then MessageDlg('Картридж отсутствует!',mtWarning,[mbOk],0);
     if ErrorType=2 then
     begin
     ErrorMessage:='Ошибка при записи!  A:'+IntToHex(Address,4)+
     'h - '+IntToHex(Code,2)+'h вместо '+IntToHex(Data,2)+'h.';
     if Address=FreeTop then ErrorMessage:=ErrorMessage+Chr(10)+'Проверьте питание...';
     MessageDlg(ErrorMessage, mtWarning, [mbOk], 0);
     end;
     if ErrorType=3 then MessageDlg('Файл слишком большой!',mtWarning,[mbOk],0);
     if ErrorType=0 then lblProgress.Caption:='Записано(байт): '+
     IntToStr(Address-FreeTop)+'. Ошибок нет.';
end;

procedure TfrmMain.btnWriteClick(Sender: TObject);
begin
WriteMnuClick(Sender);
end;

procedure TfrmMain.ReadMnuClick(Sender: TObject);
var
Signal, Code, Data, ErrorType: Byte;
Address: Word;
LinesIndex, ColumnsIndex: Integer;
ErrorMessage, Line: String;
Label LErrors;
begin
      txtCNC.Text:='';
      CNCFilename := 'noname';
      Caption:= 'Драйвер программоносителя ЧПУ: ' + CNCFilename;
{Процедура чтения из картриджа}
     ConstAddr:= 65535;
     LinesIndex:= 0;
     ColumnsIndex:= 1;
     ErrorType:=0;
     InPort(Status, Data);
     if (Data And $80) = 0 then
     begin
     ErrorType:=1;
     goto LErrors;
     end;
     Signal:= $0D;
     OutPort(Control, Signal); {Включить питание}
     Data:=0;
{Чтение}
           ConstAddr:= 65535;
           LinesIndex:= 0;
           Line:=txtCNC.Lines[LinesIndex];
           Address:=0;
     for Address:=FreeTop to KVolume-1 do
           begin
           ReadByte(Address, Code);
           Code:= Code and $7F;
           if ((Code>=Ord(' '))and(Code<=Ord('z')))then Line:= Line + Chr(Code);
           if Code=10 then
               begin
                  txtCNC.Lines.Add(Line);
                  Line:='';
               end;
           end;
LErrors:
     Signal:= $0C;
     OutPort(Control, Signal);  {Выключить питание}
     if ErrorType=1 then MessageDlg('Картридж отсутствует!',mtWarning,[mbOk],0);
     lblProgress.Caption:='Выполнено чтение из картриджа.';
end;

end.
