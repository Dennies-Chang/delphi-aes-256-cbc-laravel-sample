program DEC_LaravelSample;

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitMainForm in 'UnitMainForm.pas' {Form2},
  MainForm in 'C:\Users\Dennies64\Documents\Embarcadero\Studio\22.0\CatalogRepository\DelphiEncryptionCompendium\Demos\Cipher_FMX\MainForm.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
