unit uConexao;

interface

uses
  System.SysUtils, System.Classes, Data.DB, IniFiles,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.DApt, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Phys.PGDef, FireDAC.Phys.PG,
  Vcl.Forms, Vcl.Controls, Vcl.Dialogs;

type
  TDMConexao = class(TDataModule)
    FDConnection: TFDConnection;
    FDPhysPgDriverLink: TFDPhysPgDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    procedure FDPhysPgDriverLinkDriverCreated
    (Sender: TObject);
  public
    procedure Conectar;
    procedure VerificarOuCriarTabela;
  end;

var
  DMConexao: TDMConexao;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}
{$SCOPEDENUMS OFF}

procedure TDMConexao.DataModuleCreate(Sender: TObject);
begin
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
  Host, DB, Usuario, Senha, CaminhoIni: string;
  CriarDB, ExisteDB: Boolean;
  ConnTemp: TFDConnection;
  QryCheck: TFDQuery;
begin
  CaminhoIni := ExtractFilePath(ParamStr(0)) + 'connection.ini';

  // Cria arquivo .ini padrão se não existir
  if not FileExists(CaminhoIni) then
  begin
    Ini := TIniFile.Create(CaminhoIni);
    try
      Ini.WriteString('BD', 'Host', 'localhost');
      Ini.WriteString('BD', 'Database', 'DB_TRIANGULO');
      Ini.WriteString('BD', 'Usuario', 'postgres');
      Ini.WriteString('BD', 'Senha', '#abc123#');
    finally
      Ini.Free;
    end;
  end;

  // Lê configurações
  Ini := TIniFile.Create(CaminhoIni);
  try
    Host    := Ini.ReadString('BD', 'Host', 'localhost');
    DB      := Ini.ReadString('BD', 'Database', 'DB_TRIANGULO');
    Usuario := Ini.ReadString('BD', 'Usuario', 'postgres');
    Senha   := Ini.ReadString('BD', 'Senha', '#abc123#');
  finally
    Ini.Free;
  end;

  // Verifica se o banco existe
  ConnTemp := TFDConnection.Create(nil);
  QryCheck := TFDQuery.Create(nil);
  try
    ConnTemp.DriverName := 'PG';
    ConnTemp.Params.Add('Server=' + Host);
    ConnTemp.Params.Add('Database=postgres');
    ConnTemp.Params.Add('User_Name=' + Usuario);
    ConnTemp.Params.Add('Password=' + Senha);
    ConnTemp.Params.Add('Port=5432');
    ConnTemp.Connected := True;

    QryCheck.Connection := ConnTemp;
    QryCheck.SQL.Text := 'SELECT 1 FROM pg_database WHERE datname = :dbname';
    QryCheck.ParamByName('dbname').AsString := DB;
    QryCheck.Open;

    ExisteDB := not QryCheck.IsEmpty;
    QryCheck.Close;

    if not ExisteDB then
    begin
      CriarDB := MessageDlg(
        'O banco de dados "' + DB + '" não foi encontrado. Deseja criá-lo agora?',
        mtConfirmation, [mbYes, mbNo], 0) = mrYes;

      if CriarDB then
      begin
        ConnTemp.ExecSQL('CREATE DATABASE "' + DB + '"');
        ShowMessage('Banco de dados "' + DB + '" criado com sucesso!');
      end
      else
        raise Exception.Create('Conexão cancelada pelo usuário.');
    end;
  finally
    QryCheck.Free;
    ConnTemp.Free;
  end;

  // Conecta ao banco final
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

