program ClassificacaoTriangulo;

uses
  Vcl.Forms,
  frmPrincipal in 'src\Main\frmPrincipal.pas' {frmTriangulo},
  TriangulosController in 'src\Controller\TriangulosController.pas',
  Vcl.Themes,
  Vcl.Styles,
  Server in 'src\Server\Server.pas',
  uConexao in 'src\Config\uConexao.pas' {DMConexao: TDataModule},
  TestePostTriangulo in 'testes\TestePostTriangulo.pas',
  LogTesteHelper in 'testes\LogTesteHelper.pas',
  TesteConfiguracao in 'testes\TesteConfiguracao.pas',
  TesteGetTriangulos in 'testes\TesteGetTriangulos.pas',
  TesteMain in 'testes\TesteMain.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Light');

  Application.CreateForm(TDMConexao, DMConexao);
  Application.CreateForm(TfrmTriangulo, frmTriangulo);
  Application.Run;
end.

