unit View.Listagem.Produto;

interface

uses
  Data.DB,
  Datasnap.DBClient,
  System.Classes,
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,
  System.Variants,
  Vcl.Controls,
  Vcl.DBGrids,
  Vcl.Dialogs,
  Vcl.Forms,
  Vcl.Grids,
  Vcl.Graphics,
  Vcl.StdCtrls,
  View.Base.Listagem,
  ProdutoController,
  Financeiro.DTOs,
  Winapi.Windows,
  Winapi.Messages;

type
  TfrmProdutoListagem = class(TfrmBaseListagem)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cdsListaAfterScroll(DataSet: TDataSet);
  private
    FController: TProdutoController;
    procedure CarregarProdutos;
    procedure InicializarCDS;
    procedure InicializarDBGrid;
    function ValorUnitarioToCurrencyText(const ATotal: Double): string;
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    { Public declarations }
  end;

var
  frmProdutoListagem: TfrmProdutoListagem;

implementation

{$R *.dfm}

procedure TfrmProdutoListagem.CarregarProdutos;
var
  LProdutos: TObjectList<TFinanceiroProdutoDTO>;
  LProduto: TFinanceiroProdutoDTO;
begin
  try
    LProdutos := FController.Listar;
    try
      if not Assigned(LProdutos) then
        Exit;

      cdsLista.EmptyDataSet;

      for LProduto in LProdutos do
      begin
        if not Assigned(LProduto) then
          Continue;

        cdsLista.Append;
        cdsLista.FieldByName('id').AsInteger := LProduto.Id;
        cdsLista.FieldByName('nome').AsString := LProduto.Nome;
        cdsLista.FieldByName('preco').AsString := ValorUnitarioToCurrencyText(LProduto.Preco);
        cdsLista.FieldByName('quantidadeEstoque').AsInteger := LProduto.QuantidadeEstoque;
        cdsLista.Post;
      end;
    finally
      if Assigned(LProdutos) then
        LProdutos.Free;

      cdsLista.First;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao listar clientes: ' + E.Message);
  end;
end;

procedure TfrmProdutoListagem.cdsListaAfterScroll(DataSet: TDataSet);
begin
  inherited;
  Tag := cdsLista.FieldByName('id').AsInteger;
end;

constructor TfrmProdutoListagem.Create(AOwner: TComponent);
begin
  inherited;
  FController := TProdutoController.Create;
end;

procedure TfrmProdutoListagem.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FController.Free;
  inherited;
end;

procedure TfrmProdutoListagem.FormCreate(Sender: TObject);
begin
  inherited;
  lblDetalhes.Visible := False;
  grdDetalhes.Visible := False;
  InicializarCDS;
  InicializarDBGrid;
  CarregarProdutos;
end;

procedure TfrmProdutoListagem.InicializarCDS;
begin
  cdsLista.Close;
  cdsLista.FieldDefs.Clear;

  cdsLista.FieldDefs.Add('id', ftInteger);
  cdsLista.FieldDefs.Add('nome', ftString, 200);
  cdsLista.FieldDefs.Add('preco', ftString, 20);
  cdsLista.FieldDefs.Add('quantidadeEstoque', ftInteger);

  cdsLista.CreateDataSet;
  cdsLista.EmptyDataSet;
end;

procedure TfrmProdutoListagem.InicializarDBGrid;
var
  col: TColumn;
begin
  grdListagem.Columns.Clear;

  col := grdListagem.Columns.Add;
  col.FieldName := 'id';
  col.Title.Caption := 'ID';
  col.Width := 50;
  col.Alignment := taRightJustify;
  col.ReadOnly := True;

  col := grdListagem.Columns.Add;
  col.FieldName := 'nome';
  col.Title.Caption := 'Nome';
  col.Width := 200;

  col := grdListagem.Columns.Add;
  col.FieldName := 'preco';
  col.Title.Caption := 'Vlr Unitário';
  col.Width := 120;

  col := grdListagem.Columns.Add;
  col.FieldName := 'quantidadeEstoque';
  col.Title.Caption := 'Total Estoque';
  col.Width := 120;
end;

function TfrmProdutoListagem.ValorUnitarioToCurrencyText(const ATotal: Double): string;
begin
  Result := FormatFloat('R$ #,##0.00', ATotal);
end;

end.
