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
      q.SQL.Text := 'INSERT INTO triangulos (lado_a, lado_b, lado_c, tipo, datahora) ' +
        'VALUES (:a, :b, :c, :tipo, :datahora)';
      q.ParamByName('a').AsFloat := a;
      q.ParamByName('b').AsFloat := b;
      q.ParamByName('c').AsFloat := c;
      q.ParamByName('tipo').AsString := tipo;
      q.ParamByName('datahora').AsDateTime := datahora;
      q.ExecSQL;

      Res.Send<TJSONObject>(TJSONObject.Create.AddPair('mensagem', 'Triângulo registrado com sucesso'));
    finally
      q.Free;
    end;
  except
    on E: Exception do
      Res.Status(400).Send<TJSONObject>(TJSONObject.Create.AddPair('erro', E.Message));
  end;
end;

procedure GetContagemTriangulos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  q: TFDQuery;
  jsonResponse: TJSONObject;
begin
  q := TFDQuery.Create(nil);
  try
    q.Connection := DMConexao.FDConnection;
    q.SQL.Text := 'SELECT tipo, COUNT(*) AS quantidade FROM triangulos GROUP BY tipo';
    q.Open;

    jsonResponse := TJSONObject.Create;
    while not q.Eof do
    begin
      jsonResponse.AddPair(q.FieldByName('tipo').AsString, q.FieldByName('quantidade').AsString);
      q.Next;
    end;

    Res.Send<TJSONObject>(jsonResponse);
  finally
    q.Free;
  end;
end;

procedure GetRegistrosTriangulos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  q: TFDQuery;
  jsonResponse, registro: TJSONArray;
  id, tipo, data_inicio, data_fim: string;
  limit, offset: Integer;
begin
  // Obtendo parâmetros da requisição
  id := Req.Query['id'];
  tipo := Req.Query['tipo'];
  data_inicio := Req.Query['data_inicio'];
  data_fim := Req.Query['data_fim'];
  limit := StrToIntDef(Req.Query['limit'], 10);  // Default 10 itens por página
  offset := StrToIntDef(Req.Query['offset'], 0); // Default primeira página

  // Preparando a query SQL com filtros
  q := TFDQuery.Create(nil);
  try
    q.Connection := DMConexao.FDConnection;
    q.SQL.Text := 'SELECT id, lado_a, lado_b, lado_c, tipo, datahora ' +
                  'FROM triangulos WHERE 1=1';

    // Adicionando filtros
    if id <> '' then
      q.SQL.Text := q.SQL.Text + ' AND id = :id';
    if tipo <> '' then
      q.SQL.Text := q.SQL.Text + ' AND tipo = :tipo';
    if data_inicio <> '' then
      q.SQL.Text := q.SQL.Text + ' AND datahora >= :data_inicio';
    if data_fim <> '' then
      q.SQL.Text := q.SQL.Text + ' AND datahora <= :data_fim';

    q.SQL.Text := q.SQL.Text + ' LIMIT :limit OFFSET :offset';

    // Definindo parâmetros
    if id <> '' then
      q.ParamByName('id').AsString := id;
    if tipo <> '' then
      q.ParamByName('tipo').AsString := tipo;
    if data_inicio <> '' then
      q.ParamByName('data_inicio').AsString := data_inicio;
    if data_fim <> '' then
      q.ParamByName('data_fim').AsString := data_fim;

    q.ParamByName('limit').AsInteger := limit;
    q.ParamByName('offset').AsInteger := offset;

    q.Open;

    // Criando o array de registros
    jsonResponse := TJSONArray.Create;
    while not q.Eof do
    begin
      registro := TJSONObject.Create;
      registro.AddPair('id', q.FieldByName('id').AsString);
      registro.AddPair('lado_a', q.FieldByName('lado_a').AsString);
      registro.AddPair('lado_b', q.FieldByName('lado_b').AsString);
      registro.AddPair('lado_c', q.FieldByName('lado_c').AsString);
      registro.AddPair('tipo', q.FieldByName('tipo').AsString);
      registro.AddPair('datahora', DateTimeToStr(q.FieldByName('datahora').AsDateTime));

      jsonResponse.Add(registro);
      q.Next;
    end;

    Res.Send<TJSONArray>(jsonResponse);  // Envia os registros no formato JSON
  finally
    q.Free;
  end;
end;

procedure StartServer;
begin
  THorse.Use(Jhonson);

  // Definindo as rotas
  THorse.Post('/triangulos', PostTriangulo);  // Rota para registrar triângulos
  THorse.Get('/contagem', GetContagemTriangulos);  // Rota para contar triângulos por tipo
  THorse.Get('/triangulos', GetRegistrosTriangulos);  // Rota para listar registros de triângulos

  THorse.Listen(9000);  // Escutando na porta 9000
end;

end.

