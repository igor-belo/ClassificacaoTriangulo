unit uConexao;

interface

uses
  System.SysUtils, System.Classes, Data.DB, IniFiles,
  Vcl.Dialogs, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.DApt, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Phys.PGDef, FireDAC.Phys.PG;

type
  TDMConexao = class(TDataModule)
    FDConnection: TFDConnection;
    FDPhysPgDriverLink: TFDPhysPgDriverLink;
    FDQuery: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  public
    procedure Conectar;
    procedure VerificarOuCriarTabela;
  end;

var
  DMConexao: TDMConexao;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

procedure TDMConexao.DataModuleCreate(Sender: TObject);
begin
  if not Assigned(FDQuery) then
  begin
    FDQuery := TFDQuery.Create(Self);
    FDQuery.Name := 'FDQuery';
  end;
  FDQuery.Connection := FDConnection;

  try
    Conectar;
    VerificarOuCriarTabela;
  except
    on E: Exception do
      ShowMessage('Erro ao inicializar conexão/tabela: ' + E.Message);
  end;
end;

procedure TDMConexao.Conectar;
var
  Ini: TIniFile;
  Host, DB, Usuario, Senha: string;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'connection.ini');
  try
    Host    := Ini.ReadString('BD', 'Host', 'localhost');
    DB      := Ini.ReadString('BD', 'Database', 'TRIANGULOS');
    Usuario := Ini.ReadString('BD', 'Usuario', 'postgres');
    Senha   := Ini.ReadString('BD', 'Senha', '#abc123#');
  finally
    Ini.Free;
  end;

  FDConnection.Close;
  FDConnection.Params.Clear;
  FDConnection.DriverName := 'PG';
  FDConnection.Params.Add('Server=' + Host);
  FDConnection.Params.Add('Database=' + DB);
  FDConnection.Params.Add('User_Name=' + Usuario);
  FDConnection.Params.Add('Password=' + Senha);
  FDConnection.Params.Add('Port=5432');
  FDConnection.Connected := True;
end;

procedure TDMConexao.VerificarOuCriarTabela;
var
  lQuery: TFDQuery;
begin
  lQuery := TFDQuery.Create(nil);
  try
    lQuery.Connection := FDConnection;

    // Verifica existência da tabela 'triangulos'
    lQuery.SQL.Text :=
      'SELECT EXISTS (' +
      '  SELECT 1 FROM information_schema.tables' +
      '  WHERE table_schema = ''public'' AND table_name = ''triangulos''' +
      ') AS existe;';
    lQuery.Open;

    if not lQuery.FieldByName('existe').AsBoolean then
    begin
      lQuery.Close;
      lQuery.SQL.Text :=
        'CREATE TABLE triangulos (' +
        '  id SERIAL PRIMARY KEY,' +
        '  lado_a FLOAT,' +
        '  lado_b FLOAT,' +
        '  lado_c FLOAT,' +
        '  tipo VARCHAR(20),' +
        '  datahora TIMESTAMP' +
        ');';
      lQuery.ExecSQL;
    end;
  finally
    lQuery.Free;
  end;
end;

end.
