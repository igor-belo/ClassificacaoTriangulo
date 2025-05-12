unit TesteMain;

interface

uses
  SysUtils, Classes, TestFramework,
  // Units de teste:
  TestePostTriangulo, TesteConfiguracao, TesteGetTriangulos;

function RunAllTests: Boolean;

implementation

function RunAllTests: Boolean;
var
  suite: ITest;
  testResult: TTestResult;
  totalTests, failCount, errorCount: Integer;
  i: Integer;
  fileName: string;
  failure: TTestFailure;
  err: TTestFailure;
  logFile: TextFile;
begin
  suite := RegisteredTests;
  if suite = nil then
  begin
    Result := True;
    Exit;
  end;

  testResult := TTestResult.Create;
  try
    suite.Run(testResult);

    totalTests := testResult.RunCount;
    failCount := testResult.FailureCount;
    errorCount := testResult.ErrorCount;

    fileName := ExtractFilePath(ParamStr(0)) + 'tests_results.txt';

    AssignFile(logFile, fileName);
    if FileExists(fileName) then
      Append(logFile)
    else
      Rewrite(logFile);

    Writeln(logFile, '========================================');
    Writeln(logFile, 'Resumo dos Testes');
    Writeln(logFile, 'Data/Hora: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now));
    Writeln(logFile, '----------------------------------------');
    Writeln(logFile, Format('Total de testes: %d', [totalTests]));
    Writeln(logFile, Format('Falhas: %d', [failCount]));
    Writeln(logFile, Format('Erros: %d', [errorCount]));
    Writeln(logFile, Format('Passaram: %d', [totalTests - failCount - errorCount]));
    Writeln(logFile, '');

    if errorCount > 0 then
    begin
      Writeln(logFile, 'Erros:');
      for i := 0 to errorCount - 1 do
      begin
        err := testResult.Errors[i];
        Writeln(logFile, Format('  %d) %s: %s: %s', [
          i + 1,
          err.FailedTest.Name,
          err.ThrownExceptionName,
          err.ThrownExceptionMessage
        ]));
      end;
      Writeln(logFile, '');
    end;

    if failCount > 0 then
    begin
      Writeln(logFile, 'Falhas:');
      for i := 0 to failCount - 1 do
      begin
        failure := testResult.Failures[i];
        if failure.ThrownExceptionMessage <> '' then
          Writeln(logFile, Format('  %d) %s: %s', [
            i + 1,
            failure.FailedTest.Name,
            failure.ThrownExceptionMessage
          ]))
        else
          Writeln(logFile, Format('  %d) %s', [
            i + 1,
            failure.FailedTest.Name
          ]));
      end;
      Writeln(logFile, '');
    end;

    Writeln(logFile, '');
    CloseFile(logFile);

    Result := (failCount = 0) and (errorCount = 0);
  finally
    testResult.Free;
  end;
end;

end.

