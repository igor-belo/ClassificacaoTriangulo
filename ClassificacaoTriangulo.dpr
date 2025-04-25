program ClassificacaoTriangulo;

uses
  Vcl.Forms,
  ClassificacaoTriangulo.View.Main in 'src\View\ClassificacaoTriangulo.View.Main.pas' {frmTriangulo},
  uConexao in 'src\View\uConexao.pas' {DMConexao: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDMConexao, DMConexao);
  Application.CreateForm(TfrmTriangulo, frmTriangulo);

  Application.Run;
end.

