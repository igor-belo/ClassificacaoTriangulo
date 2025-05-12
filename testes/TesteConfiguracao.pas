unit TesteConfiguracao;

interface

uses
  TestFramework, uConexao, LogTesteHelper, System.SysUtils, System.JSON;

type
  TTestConfiguracao = class(TTestCase)
  published
    procedure TestarConexao;
  end;

implementation

procedure TTestConfiguracao.TestarConexao;
var
  esperado, retorno: string;
  json: TJSONObject;
begin
  esperado := 'Conex�o bem-sucedida';
  json := nil;

  try
    DMConexao.Conectar;
    retorno := 'Conex�o bem-sucedida';
  except
    on E: Exception do
      retorno := 'Erro: ' + E.Message;
  end;

  LogResultadoDetalhado('TestarConexao', 'CONFIG', 'Conex�o ao banco', json, esperado, retorno);
  CheckEquals(esperado, retorno);
end;

initialization
  RegisterTest(TTestConfiguracao.Suite);

end.

