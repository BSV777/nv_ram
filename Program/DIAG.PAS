unit Diag;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TfrmDiag = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupCtrl: TGroupBox;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    lblBase: TLabel;
    chkD7: TCheckBox;
    chkD6: TCheckBox;
    chkD5: TCheckBox;
    chkD4: TCheckBox;
    chkD3: TCheckBox;
    chkD2: TCheckBox;
    chkD1: TCheckBox;
    chkD0: TCheckBox;
    Label3: TLabel;
    chkBusy: TCheckBox;
    chkAsk: TCheckBox;
    chkSlct: TCheckBox;
    chkPe: TCheckBox;
    chkError: TCheckBox;
    chkAutoFd: TCheckBox;
    chkInit: TCheckBox;
    chkSlctIn: TCheckBox;
    chkStrobe: TCheckBox;
    GroupBox5: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    SelFileToWr: TButton;
    SelFileToRd: TButton;
    FNameToWr: TLabel;
    FNameToRd: TLabel;
    btnWr: TButton;
    btnRd: TButton;
    btnBinWr: TButton;
    btnBinRd: TButton;
    OpenBinDialog: TOpenDialog;
    SaveBinDialog: TSaveDialog;
    procedure chkStrobeClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure chkAutoFdClick(Sender: TObject);
    procedure chkInitClick(Sender: TObject);
    procedure chkSlctInClick(Sender: TObject);
    procedure btnWrClick(Sender: TObject);
    procedure btnRdClick(Sender: TObject);
    procedure editDataChange(Sender: TObject);
    procedure chkD1Click(Sender: TObject);
    procedure chkD0Click(Sender: TObject);
    procedure chkD2Click(Sender: TObject);
    procedure chkD3Click(Sender: TObject);
    procedure chkD4Click(Sender: TObject);
    procedure chkD5Click(Sender: TObject);
    procedure chkD6Click(Sender: TObject);
    procedure chkD7Click(Sender: TObject);
    procedure SelFileToWrClick(Sender: TObject);
    procedure SelFileToRdClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



const
   FileToRd: string = 'noname';
   FileToWr: string = 'noname';
   Base: Word = 0;
   Status: Word = 0;
   Control: Word = 0;
   Scan: Byte = 1;

var
  frmDiag: TfrmDiag;
  CtrlRG, StateRG: Byte;
implementation

{$R *.DFM}


procedure TfrmDiag.chkStrobeClick(Sender: TObject);
begin
if chkStrobe.Checked = True then CtrlRg:= CtrlRg and $FE
else CtrlRg:= CtrlRg or $01;
btnWr.Enabled:=True;
end;


procedure TfrmDiag.FormActivate(Sender: TObject);
begin
CtrlRg:=0;
chkStrobe.Checked:=True;
btnWrClick(Sender);
lblBase.Caption:=IntToHex(Base, 3)+'h';
end;


procedure TfrmDiag.chkAutoFdClick(Sender: TObject);
begin
if chkAutoFd.Checked = True then CtrlRG:= CtrlRG and $FD
else CtrlRG:= CtrlRG or $02;
btnWr.Enabled:=True;
end;

procedure TfrmDiag.chkInitClick(Sender: TObject);
begin
if chkInit.Checked = True then CtrlRG:= CtrlRG or $04
else CtrlRG:= CtrlRG and $FB;
btnWr.Enabled:=True;
end;

procedure TfrmDiag.chkSlctInClick(Sender: TObject);
begin
if chkSlctIn.Checked = True then CtrlRG:= CtrlRG and $F7
else CtrlRG:= CtrlRG or $08;
btnWr.Enabled:=True;
end;


procedure TfrmDiag.btnWrClick(Sender: TObject);
var
A: Word;
D: Byte;
begin
A:= Control;
D:= CtrlRG;
    asm
    mov AL,D
    mov DX,A
    out DX,AL
    end;
A:= Base;
D:= 0;
if chkD0.Checked= True then D:=D+1;
if chkD1.Checked= True then D:=D+2;
if chkD2.Checked= True then D:=D+4;
if chkD3.Checked= True then D:=D+8;
if chkD4.Checked= True then D:=D+16;
if chkD5.Checked= True then D:=D+32;
if chkD6.Checked= True then D:=D+64;
if chkD7.Checked= True then D:=D+128;
    asm
    mov AL,D
    mov DX,A
    out DX,AL
    end;
btnWr.Enabled:=False;
end;

procedure TfrmDiag.btnRdClick(Sender: TObject);
var
A: Word;
D: Byte;
begin
A:= Status;
	asm
        mov DX, A
        in AL, DX
        mov D, AL
        end;
StateRG:= D;
if (StateRG And $80)<>0 then chkBusy.Checked:=True
else chkBusy.Checked:=False;
if (StateRG And $40)<>0 then chkAsk.Checked:=True
else chkAsk.Checked:=False;
if (StateRG And $20)<>0 then chkError.Checked:=True
else chkError.Checked:=False;
if (StateRG And $10)<>0 then chkPe.Checked:=True
else chkPe.Checked:=False;
if (StateRG And $08)<>0 then chkSlct.Checked:=True
else chkSlct.Checked:=False;
A:= Base;
	asm
        mov DX, A
        in AL, DX
        mov D, AL
        end;
btnRd.Enabled:=True;
end;

procedure TfrmDiag.editDataChange(Sender: TObject);
begin
btnWr.Enabled:=True;
end;

procedure TfrmDiag.chkD1Click(Sender: TObject);
begin
btnWr.Enabled:=True;
end;

procedure TfrmDiag.chkD0Click(Sender: TObject);
begin
btnWr.Enabled:=True;
end;

procedure TfrmDiag.chkD2Click(Sender: TObject);
begin
btnWr.Enabled:=True;
end;

procedure TfrmDiag.chkD3Click(Sender: TObject);
begin
btnWr.Enabled:=True;
end;

procedure TfrmDiag.chkD4Click(Sender: TObject);
begin
btnWr.Enabled:=True;
end;

procedure TfrmDiag.chkD5Click(Sender: TObject);
begin
btnWr.Enabled:=True;
end;

procedure TfrmDiag.chkD6Click(Sender: TObject);
begin
btnWr.Enabled:=True;
end;

procedure TfrmDiag.chkD7Click(Sender: TObject);
begin
btnWr.Enabled:=True;
end;

procedure TfrmDiag.SelFileToWrClick(Sender: TObject);
begin
      if OpenBinDialog.Execute then
         begin
         FileToWr:= OpenBinDialog.Filename;
         FNameToWr.Caption:= FileToWr;
         end;
end;

procedure TfrmDiag.SelFileToRdClick(Sender: TObject);
begin
SaveBinDialog.Filename := FileToRd;
  if SaveBinDialog.Execute then
    begin
    FileToRd := SaveBinDialog.Filename;
    FNameToRd.Caption:= FileToRd;
    end;
end;

end.
