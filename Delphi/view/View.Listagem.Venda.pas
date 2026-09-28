unit View.Listagem.Venda;

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
  ClienteController,
  ProdutoController,
  VendaController,
  Financeiro.DTOs,
  Winapi.Windows,
  Winapi.Messages;

type
  TOnVendaSelecionada = procedure(Sender: TObject; const AStatusId: Integer; const AVendaId: Integer) of object;

  TfrmListagemVenda = class(TfrmBaseListagem)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cdsListaAfterScroll(DataSet: TDataSet);
  private
    FController: TVendaController;
    FClienteController: TClienteController;
    FProdutoController: TProdutoController;
    FOnVendaSelecionada: TOnVendaSelecionada;
    function StatusVendaToText(const AStatus: Integer): string;
    function PagoEmToText(const APagoEm: string): string;
    function TotalToCurrencyText(const ATotal: Double): string;
    function ValorItemToCurrencyText(const AValor: Double): string;
    function NomeClientePorId(const AClienteId: Integer): string;
    function NomeProdutoPorId(const AProdutoId: Integer): string;
    procedure DoVendaSelecionada;
    procedure InicializarCDS;
    procedure InicializarDBGrid;
    procedure InicializarCDSDetalhes;
    procedure InicializarDBGridDetalhes;
    procedure CarregarVendas;
    procedure CarregarItensVenda(const AVendaId: Integer);
    procedure CarregarItensLista(const AItens: TObjectList<TFinanceiroVendaItemDTO>);
  public
    constructor Create(AOwner: TComponent); override;
    property OnVendaSelecionada: TOnVendaSelecionada read FOnVendaSelecionada write FOnVendaSelecionada;
  end;

var
  frmListagemVenda: TfrmListagemVenda;

implementation

{$R *.dfm}

constructor TfrmListagemVenda.Create(AOwner: TComponent);
begin
  inherited;
  FController := TVendaController.Create;
  FClienteController := TClienteController.Create;
  FProdutoController := TProdutoController.Create;
end;

procedure TfrmListagemVenda.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FProdutoController.Free;
  FClienteController.Free;
  FController.Free;
  inherited;
end;

procedure TfrmListagemVenda.FormCreate(Sender: TObject);
begin
  inherited;
  InicializarCDS;
  InicializarDBGrid;
  InicializarCDSDetalhes;
  InicializarDBGridDetalhes;
  CarregarVendas;
end;

procedure TfrmListagemVenda.cdsListaAfterScroll(DataSet: TDataSet);
begin
  inherited;
  if not cdsLista.Active or cdsLista.IsEmpty then
  begin
    Tag := 0;
    DoVendaSelecionada;
    Exit;
  end;

  Tag := cdsLista.FieldByName('id').AsInteger;
  DoVendaSelecionada;
  CarregarItensVenda(Tag);
end;

procedure TfrmListagemVenda.DoVendaSelecionada;
begin
  if Assigned(FOnVendaSelecionada) then
    FOnVendaSelecionada(Self, cdsLista.FieldByName('statusId').AsInteger, Tag);
end;

function TfrmListagemVenda.StatusVendaToText(const AStatus: Integer): string;
begin
  case AStatus of
    0: Result := 'Orcamento';
    1: Result := 'PagamentoPendente';
    2: Result := 'Pago';
    3: Result := 'Cancelado';
  else
    Result := 'Desconhecido';
  end;
end;

function TfrmListagemVenda.PagoEmToText(const APagoEm: string): string;
begin
  Result := 'Não';
  if APagoEm.Trim.IsEmpty then
    Exit;

  if APagoEm.Trim.ToUpper.Contains('T') then
    Result := 'Sim';
end;

function TfrmListagemVenda.TotalToCurrencyText(const ATotal: Double): string;
begin
  Result := FormatFloat('R$ #,##0.00', ATotal);
end;

function TfrmListagemVenda.ValorItemToCurrencyText(const AValor: Double): string;
begin
  Result := FormatFloat('R$ #,##0.00', AValor);
end;

function TfrmListagemVenda.NomeClientePorId(const AClienteId: Integer): string;
var
  LCliente: TFinanceiroClienteDTO;
begin
  Result := 'Cliente ' + IntToStr(AClienteId);
  if AClienteId <= 0 then
    Exit;

  LCliente := FClienteController.ObterPorId(AClienteId);
  try
    if Assigned(LCliente) then
      Result := LCliente.Nome;
  finally
    if Assigned(LCliente) then
      LCliente.Free;
  end;
end;

function TfrmListagemVenda.NomeProdutoPorId(const AProdutoId: Integer): string;
var
  LProduto: TFinanceiroProdutoDTO;
begin
  Result := 'Produto ' + IntToStr(AProdutoId);
  if AProdutoId <= 0 then
    Exit;

  LProduto := FProdutoController.ObterPorId(AProdutoId);
  try
    if Assigned(LProduto) then
      Result := LProduto.Nome;
  finally
    if Assigned(LProduto) then
      LProduto.Free;
  end;
end;

procedure TfrmListagemVenda.CarregarItensLista(const AItens: TObjectList<TFinanceiroVendaItemDTO>);
var
  LItem: TFinanceiroVendaItemDTO;
begin
  cdsDetalhes.EmptyDataSet;
  if not Assigned(AItens) then
    Exit;

  for LItem in AItens do
  begin
    if not Assigned(LItem) then
      Continue;

    cdsDetalhes.Append;
    cdsDetalhes.FieldByName('id').AsInteger := Succ(cdsDetalhes.RecordCount);
    cdsDetalhes.FieldByName('vendaId').AsInteger := LItem.VendaId;
    cdsDetalhes.FieldByName('produtoId').AsInteger := LItem.ProdutoId;
    cdsDetalhes.FieldByName('produtoNome').AsString := NomeProdutoPorId(LItem.ProdutoId);
    cdsDetalhes.FieldByName('quantidade').AsInteger := LItem.Quantidade;
    cdsDetalhes.FieldByName('valorUnitario').AsString := ValorItemToCurrencyText(LItem.ValorUnitario);
    cdsDetalhes.Post;
  end;
end;

procedure TfrmListagemVenda.CarregarItensVenda(const AVendaId: Integer);
begin
  try
    if AVendaId <= 0 then
    begin
      cdsDetalhes.EmptyDataSet;
      Exit;
    end;

    CarregarItensLista(FController.ListarItens(AVendaId));
  except
    on E: Exception do
      ShowMessage('Erro ao listar itens da venda: ' + E.Message);
  end;
end;

procedure TfrmListagemVenda.CarregarVendas;
var
  LVendas: TObjectList<TFinanceiroVendaDTO>;
  LVenda: TFinanceiroVendaDTO;
begin
  try
    LVendas := FController.Listar;
    try
      if not Assigned(LVendas) then
        Exit;

      cdsLista.EmptyDataSet;
      for LVenda in LVendas do
      begin
        if not Assigned(LVenda) then
          Continue;

        cdsLista.Append;
        cdsLista.FieldByName('id').AsInteger := LVenda.Id;
        cdsLista.FieldByName('clienteId').AsInteger := LVenda.ClienteId;
        cdsLista.FieldByName('clienteNome').AsString := NomeClientePorId(LVenda.ClienteId);
        cdsLista.FieldByName('statusId').AsInteger := LVenda.Status;
        cdsLista.FieldByName('status').AsString := StatusVendaToText(LVenda.Status);
        cdsLista.FieldByName('pagoEm').AsString := PagoEmToText(LVenda.PagoEm);
        cdsLista.FieldByName('total').AsString := TotalToCurrencyText(LVenda.Total);
        cdsLista.Post;
      end;

      cdsLista.First;
      if not cdsLista.IsEmpty then
        cdsListaAfterScroll(cdsLista);
    finally
      if Assigned(LVendas) then
        LVendas.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao listar vendas: ' + E.Message);
  end;
end;

procedure TfrmListagemVenda.InicializarCDS;
begin
  cdsLista.Close;
  cdsLista.FieldDefs.Clear;

  cdsLista.FieldDefs.Add('id', ftInteger);
  cdsLista.FieldDefs.Add('clienteId', ftInteger);
  cdsLista.FieldDefs.Add('clienteNome', ftString, 200);
  cdsLista.FieldDefs.Add('statusId', ftInteger);
  cdsLista.FieldDefs.Add('status', ftString, 40);
  cdsLista.FieldDefs.Add('pagoEm', ftString, 20);
  cdsLista.FieldDefs.Add('total', ftString, 30);

  cdsLista.CreateDataSet;
  cdsLista.EmptyDataSet;
end;

procedure TfrmListagemVenda.InicializarCDSDetalhes;
begin
  cdsDetalhes.Close;
  cdsDetalhes.FieldDefs.Clear;

  cdsDetalhes.FieldDefs.Add('id', ftInteger);
  cdsDetalhes.FieldDefs.Add('vendaId', ftInteger);
  cdsDetalhes.FieldDefs.Add('produtoId', ftInteger);
  cdsDetalhes.FieldDefs.Add('produtoNome', ftString, 200);
  cdsDetalhes.FieldDefs.Add('quantidade', ftInteger);
  cdsDetalhes.FieldDefs.Add('valorUnitario', ftString, 30);

  cdsDetalhes.CreateDataSet;
  cdsDetalhes.EmptyDataSet;
end;

procedure TfrmListagemVenda.InicializarDBGrid;
var
  col: TColumn;
begin
  grdListagem.Columns.Clear;

  col := grdListagem.Columns.Add;
  col.FieldName := 'id';
  col.Title.Caption := 'ID';
  col.Width := 60;
  col.Alignment := taRightJustify;
  col.ReadOnly := True;
  col.Visible := False;

  col := grdListagem.Columns.Add;
  col.FieldName := 'clienteId';
  col.Title.Caption := 'Cliente ID';
  col.Width := 80;
  col.ReadOnly := True;
  col.Visible := False;

  col := grdListagem.Columns.Add;
  col.FieldName := 'clienteNome';
  col.Title.Caption := 'Cliente';
  col.Width := 220;
  col.ReadOnly := True;

  col := grdListagem.Columns.Add;
  col.FieldName := 'statusId';
  col.Title.Caption := 'Status ID';
  col.Width := 80;
  col.ReadOnly := True;
  col.Visible := False;

  col := grdListagem.Columns.Add;
  col.FieldName := 'status';
  col.Title.Caption := 'Status';
  col.Width := 180;
  col.ReadOnly := True;

  col := grdListagem.Columns.Add;
  col.FieldName := 'pagoEm';
  col.Title.Caption := 'Pago';
  col.Width := 80;
  col.ReadOnly := True;

  col := grdListagem.Columns.Add;
  col.FieldName := 'total';
  col.Title.Caption := 'Total';
  col.Width := 120;
  col.ReadOnly := True;
end;

procedure TfrmListagemVenda.InicializarDBGridDetalhes;
var
  col: TColumn;
begin
  grdDetalhes.Columns.Clear;

  col := grdDetalhes.Columns.Add;
  col.FieldName := 'id';
  col.Title.Caption := 'Item';
  col.Width := 60;
  col.ReadOnly := True;

  col := grdDetalhes.Columns.Add;
  col.FieldName := 'produtoId';
  col.Title.Caption := 'Produto ID';
  col.Width := 100;
  col.ReadOnly := True;
  col.Visible := False;

  col := grdDetalhes.Columns.Add;
  col.FieldName := 'produtoNome';
  col.Title.Caption := 'Produto';
  col.Width := 220;
  col.ReadOnly := True;

  col := grdDetalhes.Columns.Add;
  col.FieldName := 'quantidade';
  col.Title.Caption := 'Qtd';
  col.Width := 80;
  col.ReadOnly := True;

  col := grdDetalhes.Columns.Add;
  col.FieldName := 'valorUnitario';
  col.Title.Caption := 'Vlr. Unitário';
  col.Width := 120;
  col.ReadOnly := True;
end;

end.
