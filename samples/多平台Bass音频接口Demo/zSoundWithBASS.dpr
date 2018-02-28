program zSoundWithBASS;

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  zSoundMainFrm in 'zSoundMainFrm.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
