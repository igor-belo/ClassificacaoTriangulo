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
  // Garante que o FDQuery exista e esteja vinculado
  if not Assigned(FDQuery) then
  begin
    FDQuery := TFDQuery.Create(Self);
    FDQuery.Name := 'FDQuery'; // sem conflito de nomes
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
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  try
    Host    := Ini.ReadString('BD', 'Host', 'localhost');
    DB      := Ini.ReadString('BD', 'Database', 'TRIANGULOS');
    Usuario := Ini.ReadString('BD', 'Usuario', 'postgres');
    Senha   := Ini.ReadString('BD', 'Senha', 'Gutts@1120');
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
begin
  FDQuery.Connection := FDConnection;

  // Verifica existência da tabela 'triangulos'
  FDQuery.SQL.Clear;
  FDQuery.SQL.Add('SELECT EXISTS (');
  FDQuery.SQL.Add('  SELECT 1 FROM information_schema.tables');
  FDQuery.SQL.Add('  WHERE table_schema = ''public'' AND table_name = ''triangulos''');
  FDQuery.SQL.Add(') AS existe;');
  FDQuery.Open;

  if not FDQuery.FieldByName('existe').AsBoolean then
  begin
    FDQuery.Close;
    FDQuery.SQL.Clear;
    FDQuery.SQL.Add('CREATE TABLE triangulos (');
    FDQuery.SQL.Add('  id SERIAL PRIMARY KEY,');
    FDQuery.SQL.Add('  lado_a FLOAT,');
    FDQuery.SQL.Add('  lado_b FLOAT,');
    FDQuery.SQL.Add('  lado_c FLOAT,');
    FDQuery.SQL.Add('  tipo VARCHAR(20),');
    FDQuery.SQL.Add('  datahora TIMESTAMP');
    FDQuery.SQL.Add(');');
    FDQuery.ExecSQL;
  end;
end;

end.


