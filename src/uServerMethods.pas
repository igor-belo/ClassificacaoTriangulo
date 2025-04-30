unit uServerMethods;

interface

procedure StartServer;

implementation

uses
  Horse,
  Horse.Jhonson,
  System.SysUtils,
  System.JSON,
  FireDAC.Comp.Client,
  uConexao;

procedure PostTriangulo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  a, b, c: Double;
  tipo: string;
  datahora: TDateTime;
  q: TFDQuery;
  json: TJSONObject;
begin
  try
    json := Req.Body<TJSONObject>;

    if not json.TryGetValue<Double>('lado_a', a) then
      raise Exception.Create('Campo "lado_a" ausente ou inválido');
    if not json.TryGetValue<Double>('lado_b', b) then
      raise Exception.Create('Campo "lado_b" ausente ou inválido');
    if not json.TryGetValue<Double>('lado_c', c) then
      raise Exception.Create('Campo "lado_c" ausente ou inválido');
    if not json.TryGetValue<string>('tipo', tipo) then
      raise Exception.Create('Campo "tipo" ausente ou inválido');
    datahora := Now;

    q := TFDQuery.Create(nil);
    try
      q.Connection := DMConexao.FDConnection;
      q.SQL.Text :=
        'INSERT INTO triangulos (lado_a, lado_b, lado_c, tipo, datahora) ' +
        'VALUES (:a, :b, :c, :tipo, :datahora)';
      q.ParamByName('a').AsFloat := a;
      q.ParamByName('b').AsFloat := b;
      q.ParamByName('c').AsFloat := c;
      q.ParamByName('tipo').AsString := tipo;
      q.ParamByName('datahora').AsDateTime := datahora;
      q.ExecSQL;


      Res.Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('mensagem', 'Triângulo registrado com sucesso')
      );
    finally
      q.Free;
    end;

  except
    on E: Exception do
      Res.Status(400).Send<TJSONObject>(
        TJSONObject.Create
          .AddPair('erro', E.Message)
      );
  end;
end;

procedure StartServer;
begin
  THorse.Use(Jhonson);
  THorse.Post('/triangulos', PostTriangulo);
  THorse.Listen(9000);
end;

end.

