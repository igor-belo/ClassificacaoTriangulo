unit TriangulosController;

interface

uses
  Horse, System.JSON;

procedure ValidarTriangulo(json: TJSONObject; out a, b, c: Double; out tipo: string);
procedure PostTriangulo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure GetContagemTriangulos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
procedure GetRegistrosTriangulos(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses
  System.SysUtils,
  FireDAC.Comp.Client,
  uConexao;

procedure ValidarTriangulo(json: TJSONObject; out a, b, c: Double; out tipo: string);
begin
  if not json.TryGetValue<Double>('lado_a', a) then
    raise Exception.Create('Campo "lado_a" ausente ou inválido');
  if not json.TryGetValue<Double>('lado_b', b) then
    raise Exception.Create('Campo "lado_b" ausente ou inválido');
  if not json.TryGetValue<Double>('lado_c', c) then
    raise Exception.Create('Campo "lado_c" ausente ou inválido');
  if not json.TryGetValue<string>('tipo', tipo) then
    tipo := '';

  if (a <= 0) or (b <= 0) or (c <= 0) then
    raise Exception.Create('Os lados devem ser maiores que zero.');

  if (a + b <= c) or (a + c <= b) or (b + c <= a) then
    raise Exception.Create('Os lados não formam um triângulo válido.');

  if tipo = '' then
  begin
    if (a = b) and (b = c) then
      tipo := 'Equilátero'
    else if (a = b) or (b = c) or (a = c) then
      tipo := 'Isósceles'
    else
      tipo := 'Escaleno';
  end;
end;

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

    ValidarTriangulo(json, a, b, c, tipo);
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

      Res.Status(201).Send<TJSONObject>(TJSONObject.Create
        .AddPair('lado_a', a.ToString)
        .AddPair('lado_b', b.ToString)
        .AddPair('lado_c', c.ToString)
        .AddPair('tipo', tipo)
        .AddPair('datahora', DateTimeToStr(datahora))
      );
    finally
      q.Free;
    end;
  except
    on E: Exception do
      Res.Status(400).Send<TJSONObject>(TJSONObject.Create
        .AddPair('erro', E.Message)
      );
  end;
end;

procedure GetContagemTriangulos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  q: TFDQuery;
  jsonResponse: TJSONObject;
  totalGeral: Integer;
begin
  q := TFDQuery.Create(nil);
  try
    q.Connection := DMConexao.FDConnection;
    q.SQL.Text := 'SELECT tipo, COUNT(*) AS quantidade FROM triangulos GROUP BY tipo';
    q.Open;

    jsonResponse := TJSONObject.Create;
    totalGeral := 0;

    while not q.Eof do
    begin
      jsonResponse.AddPair(q.FieldByName('tipo').AsString, q.FieldByName('quantidade').AsString);
      totalGeral := totalGeral + q.FieldByName('quantidade').AsInteger;
      q.Next;
    end;
    jsonResponse.AddPair('total_geral', totalGeral.ToString);

    Res.Send<TJSONObject>(jsonResponse);
  finally
    q.Free;
  end;
end;

procedure GetRegistrosTriangulos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  q: TFDQuery;
  jsonResponse: TJSONArray;
  registro: TJSONObject;
  id, tipo, data_inicio, data_fim: string;
  limit, offset, pagina: Integer;
begin
  id := Req.Query['id'];
  tipo := Req.Query['tipo'];
  data_inicio := Req.Query['data_inicio'];
  data_fim := Req.Query['data_fim'];
  limit := 10;
  pagina := StrToIntDef(Req.Query['pagina'], 1);
  offset := limit * (pagina - 1);

  q := TFDQuery.Create(nil);
  try
    q.Connection := DMConexao.FDConnection;
    q.SQL.Text := 'SELECT id, lado_a, lado_b, lado_c, tipo, datahora FROM triangulos WHERE 1=1';

    if id <> '' then
      q.SQL.Text := q.SQL.Text + ' AND id = :id::integer';
    if tipo <> '' then
      q.SQL.Text := q.SQL.Text + ' AND tipo = :tipo';
    if data_inicio <> '' then
      q.SQL.Text := q.SQL.Text + ' AND datahora >= :data_inicio';
    if data_fim <> '' then
      q.SQL.Text := q.SQL.Text + ' AND datahora <= :data_fim';

    q.SQL.Text := q.SQL.Text + ' ORDER BY id LIMIT :limit OFFSET :offset';

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

    jsonResponse := TJSONArray.Create;

    if q.RecordCount = 0 then
    begin
      Res.Send<TJSONObject>(TJSONObject.Create.AddPair('erro', 'Nenhum registro encontrado.'));
      Exit;
    end;

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

    Res.Send<TJSONArray>(jsonResponse);
  finally
    q.Free;
  end;
end;

end.

