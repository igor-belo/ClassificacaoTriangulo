unit TesteGetTriangulos;

interface

uses
  TestFramework, System.JSON, System.SysUtils, LogTesteHelper;

type
  TTestGetTriangulos = class(TTestCase)
  published
    procedure TestarSimulacaoConsulta;
  end;

implementation

procedure TTestGetTriangulos.TestarSimulacaoConsulta;
var
  jsonRetorno, jsonEntrada: TJSONArray;
  esperado, obtido: string;
begin
  jsonRetorno := TJSONArray.Create;
  jsonEntrada := TJSONArray.Create;
  try
    jsonRetorno.AddElement(
      TJSONObject.Create
        .AddPair('id', '1')
        .AddPair('lado_a', '3')
        .AddPair('lado_b', '4')
        .AddPair('lado_c', '5')
        .AddPair('tipo', 'Escaleno')
        .AddPair('datahora', DateTimeToStr(Now))
    );

    esperado := 'Consulta simulada de 1 registro';
    obtido := 'Consulta simulada de ' + jsonRetorno.Count.ToString + ' registro';
    jsonEntrada := TJSONArray.Create;
    jsonEntrada.AddElement(TJSONObject.Create
      .AddPair('filtro', 'nenhum')
    );

    LogResultadoDetalhado(
      'TestarSimulacaoConsulta',
      'GET',
      '/triangulos',
      TJSONObject.Create.AddPair('filtros', jsonEntrada),
      esperado,
      obtido
    );

    CheckEquals(esperado, obtido);
  finally
    jsonRetorno.Free;
    jsonEntrada.Free;
  end;
end;

initialization
  RegisterTest(TTestGetTriangulos.Suite);

end.

