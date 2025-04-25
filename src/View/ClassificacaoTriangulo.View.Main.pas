unit ClassificacaoTriangulo.View.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.jpeg, System.ImageList, Vcl.ImgList, uConexao;

type
  TfrmTriangulo = class(TForm)
    edtLadoA: TEdit;
    edtLadoB: TEdit;
    edtLadoC: TEdit;
    btnVerificar: TButton;
    lblResultado: TLabel;
    imgTriangulo: TImage;
    ImageList1: TImageList;
    lblLadoA: TLabel;
    lblLadoB: TLabel;
    lblLadoC: TLabel;
    procedure btnVerificarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTriangulo: TfrmTriangulo;

implementation

{$R *.dfm}

procedure TfrmTriangulo.FormCreate(Sender: TObject);
begin
  DMConexao.Conectar;  // Conectar ao banco de dados
  DMConexao.VerificarOuCriarTabela;  // Verificar e criar a tabela se necessário
end;

procedure TfrmTriangulo.btnVerificarClick(Sender: TObject);
var
  a, b, c: Double;
  tipo: String;
  indiceImagem: Integer;
  bmp: TBitmap;
begin
  a := StrToFloatDef(edtLadoA.Text, 0);
  b := StrToFloatDef(edtLadoB.Text, 0);
  c := StrToFloatDef(edtLadoC.Text, 0);

  if (edtLadoA.Text = '') or (edtLadoB.Text = '') or (edtLadoC.Text = '') then
  begin
    ShowMessage('Insira um valor em todos os campos.');
    Exit;
  end;

  if (a <= 0) or (b <= 0) or (c <= 0) then
  begin
    ShowMessage('Insira valores maiores que zero.');
    Exit;
  end;

  if (a + b <= c) or (a + c <= b) or (b + c <= a) then
  begin
    tipo := 'Não é um triângulo';
    indiceImagem := 0;
  end
  else if (a = b) and (b = c) then
  begin
    tipo := 'Equilátero';
    indiceImagem := 1;
  end
  else if (a = b) or (a = c) or (b = c) then
  begin
    tipo := 'Isósceles';
    indiceImagem := 2;
  end
  else
  begin
    tipo := 'Escaleno';
    indiceImagem := 3;
  end;

  lblResultado.Caption := tipo;

  bmp := TBitmap.Create;
  try
    ImageList1.GetBitmap(indiceImagem, bmp);
    imgTriangulo.Picture.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

end.

