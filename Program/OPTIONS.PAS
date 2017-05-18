unit Options;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, SysUtils, Dialogs;

type
  TfrmOptions = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    GroupBox1: TGroupBox;
    btnLPT1: TRadioButton;
    btnLPT2: TRadioButton;
    btnLPT3: TRadioButton;
    GroupBox2: TGroupBox;
    btnAk: TRadioButton;
    btn2k: TRadioButton;
    btn8k: TRadioButton;
    btn16k: TRadioButton;
    GroupBox3: TGroupBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox1: TCheckBox;
    GroupBox4: TGroupBox;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    RadioButton11: TRadioButton;
    RadioButton12: TRadioButton;
    GroupBox5: TGroupBox;
    Edit1: TEdit;
    Label1: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    btnLPTA: TRadioButton;
    Label3: TLabel;
    Label4: TLabel;
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
     FreeTop: Byte = 16;
     FreeBot: Byte = 16;
     PortNumber: Byte = 1;
     KVolume: Word = 2048;
var
  frmOptions: TfrmOptions;

implementation

{$R *.DFM}



procedure TfrmOptions.OKBtnClick(Sender: TObject);
begin
FreeTop:= StrToInt(Edit1.Text);
FreeBot:= StrToInt(Edit2.Text);
if btnLPT1.Checked=True then PortNumber:=1;
if btnLPT2.Checked=True then PortNumber:=2;
if btnLPT3.Checked=True then PortNumber:=3;
if btn2k.Checked=True then KVolume:=2048;
if btn8k.Checked=True then KVolume:=8192;
if btn16k.Checked=True then KVolume:=16384;
if btnAk.Checked=True then KVolume:=1024;
end;

end.
