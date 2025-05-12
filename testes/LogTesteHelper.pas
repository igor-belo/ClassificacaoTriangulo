unit LogTesteHelper;

interface

uses
  System.JSON;

procedure LogResultadoDetalhado(
  const NomeDoTeste, Tipo, Rota: string;
  const JsonEnvio: TJSONObject;
  const ResultadoEsperado, ResultadoObtido: string);

procedure LimparArquivoLog;

implementation

uses
  System.SysUtils, System.Classes;

const
  LOG_ARQUIVO = 'tests_results.txt';

procedure LimparArquivoLog;
var
  logFile: TextFile;
begin
  AssignFile(logFile, LOG_ARQUIVO);
  Rewrite(logFile);
  CloseFile(logFile);
end;

procedure LogResultadoDetalhado(
  const NomeDoTeste, Tipo, Rota: string;
  const JsonEnvio: TJSONObject;
  const ResultadoEsperado, ResultadoObtido: string);
var
  logFile: TextFile;
  jsonStr: string;
begin
  AssignFile(logFile, LOG_ARQUIVO);
  if FileExists(LOG_ARQUIVO) then
    Append(logFile)
  else
    Rewrite(logFile);

  if Assigned(JsonEnvio) then
    jsonStr := JsonEnvio.Format(2)
  else
    jsonStr := '[nenhum]';

  Writeln(logFile, '----------------------------------------');
  Writeln(logFile, 'Data/Hora: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now));
  Writeln(logFile, 'Nome do teste: ' + NomeDoTeste);
  Writeln(logFile, 'Tipo: ' + Tipo);
  Writeln(logFile, 'Rota: ' + Rota);
  Writeln(logFile, 'JSON:');
  Writeln(logFile, jsonStr);
  Writeln(logFile, '');
  Writeln(logFile, 'Resultado esperado: ' + ResultadoEsperado);
  Writeln(logFile, 'Resultado obtido: ' + ResultadoObtido);
  Writeln(logFile, '');

  CloseFile(logFile);
end;

end.

