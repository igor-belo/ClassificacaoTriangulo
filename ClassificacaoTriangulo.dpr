program ClassificacaoTriangulo;

uses
  Vcl.Forms,
  ClassificacaoTriangulo.View.Main in 'src\ClassificacaoTriangulo.View.Main.pas' {frmTriangulo},
  uConexao in 'src\uConexao.pas' {DMConexao: TDataModule},
  uServerMethods in 'src\uServerMethods.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Light');
  Application.CreateForm(TDMConexao, DMConexao);
  Application.CreateForm(TfrmTriangulo, frmTriangulo);
  Application.Run;
end.

