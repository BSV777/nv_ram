program Nv_ram;

uses
  Forms,
  Main in 'MAIN.PAS' {frmMain},
  About in 'ABOUT.PAS' {frmAbout},
  Diag in 'DIAG.PAS' {frmDiag},
  Options in 'OPTIONS.PAS' {frmOptions};

{$R *.RES}

begin
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmDiag, frmDiag);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.Run;
end.
