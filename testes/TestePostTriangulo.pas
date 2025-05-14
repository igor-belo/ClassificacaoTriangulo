unit TestePostTriangulo;

interface

uses
  TestFramework, System.SysUtils, System.JSON,
  TriangulosController, LogTesteHelper;

type
  TTestPostTriangulo = class(TTestCase)
  published
    procedure TestarEquilatero;
    procedure TestarEscaleno;
    procedure TestarLadosInvalidos;
  end;

implementation

procedure TTestPostTriangulo.TestarEquilatero;
var
  json: TJSONObject;
  a, b, c: Double;
  tipo, esperado: string;
begin
  json := TJSONObject.Create;
  try
    json.AddPair('lado_a', '5');
    json.AddPair('lado_b', '5');
    json.AddPair('lado_c', '5');
    esperado := 'Equilátero';

    ValidarTriangulo(json, a, b, c, tipo);

    LogResultadoDetalhado('TestarEquilatero', 'POST', '/triangulos', json, esperado, tipo);
    CheckEquals(esperado, tipo);
  finally
    json.Free;
  end;
end;

procedure TTestPostTriangulo.TestarEscaleno;
var
  json: TJSONObject;
  a, b, c: Double;
  tipo, esperado: string;
begin
  json := TJSONObject.Create;
  try
    json.AddPair('lado_a', '3');
    json.AddPair('lado_b', '4');
    json.AddPair('lado_c', '5');
    esperado := 'Escaleno';

    ValidarTriangulo(json, a, b, c, tipo);

    LogResultadoDetalhado('TestarEscaleno', 'POST', '/triangulos', json, esperado, tipo);
    CheckEquals(esperado, tipo);
  finally
    json.Free;
  end;
end;

procedure TTestPostTriangulo.TestarLadosInvalidos;
var
  json: TJSONObject;
  a, b, c: Double;
  tipo, esperado: string;
begin
  json := TJSONObject.Create;
  try
    json.AddPair('lado_a', '1');
    json.AddPair('lado_b', '2');
    json.AddPair('lado_c', '50');
    esperado := 'Invalido';

    ValidarTriangulo(json, a, b, c, tipo);

    LogResultadoDetalhado('TestarLadosInvalidos', 'POST', '/triangulos', json, esperado, tipo);
    CheckEquals(esperado, tipo);
  finally
    json.Free;
  end;
end;

initialization
  RegisterTest(TTestPostTriangulo.Suite);

end.

