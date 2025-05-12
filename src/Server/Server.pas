unit Server;

interface

procedure StartServer;

implementation

uses
  Horse,
  Horse.Jhonson,
  TriangulosController;

procedure StartServer;
begin
  THorse.Use(Jhonson);

  THorse.Post('/triangulos', PostTriangulo);
  THorse.Get('/contagem', GetContagemTriangulos);
  THorse.Get('/triangulos', GetRegistrosTriangulos);

  THorse.Listen(9000);
end;

end.

