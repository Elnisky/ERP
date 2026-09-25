unit View.Cadastro.Venda;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.StrUtils,
  System.UITypes,
  Data.DB,
  Datasnap.DBClient,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.StdCtrls,
  VendaController,
  Financeiro.DTOs;

type
  TfrmCadVenda = class(TForm)
    pnlRodape: TPanel;
    btnCancelar: TButton;
    btnConfirmar: TButton;
    pnlDados: TPanel;
    lblClienteId: TLabel;
    edtClienteId: TEdit;
    lblStatus: TLabel;
    cmbStatus: TComboBox;
    btnAdicionarItem: TButton;
    btnRemoverItem: TButton;
    grdItens: TDBGrid;
    dsItens: TDataSource;
    cdsItens: TClientDataSet;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnAdicionarItemClick(Sender: TObject);
    procedure btnRemoverItemClick(Sender: TObject);
  private
    FController: TVendaController;
    FVendaId: Integer;
    procedure InicializarCDSItens;
    function BuildJson: string;
    function ValidarFormulario: Boolean;
    procedure CarregarVenda(const AId: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frmCadVenda: TfrmCadVenda;

implementation

{$R *.dfm}

constructor TfrmCadVenda.Create(AOwner: TComponent);
begin
  inherited;
  FController := TVendaController.Create;
  InicializarCDSItens;
  cmbStatus.Items.Clear;
  cmbStatus.Items.Add('Orcamento');
  cmbStatus.Items.Add('PagamentoPendente');
  cmbStatus.Items.Add('Pago');
  cmbStatus.Items.Add('Cancelado');
  cmbStatus.ItemIndex := 0;
end;

destructor TfrmCadVenda.Destroy;
begin
  FController.Free;
  inherited;
end;

procedure TfrmCadVenda.FormCreate(Sender: TObject);
begin
  inherited;
  if Tag > 0 then
    CarregarVenda(Tag);
end;

procedure TfrmCadVenda.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadVenda.btnAdicionarItemClick(Sender: TObject);
var
  LProdutoId: Integer;
  LQuantidade: Integer;
  LValorUnitario: Double;
  LProdutoIdText: string;
  LQuantidadeText: string;
  LValorText: string;
begin
  LProdutoIdText := InputBox('Adicionar item', 'Produto ID:', '');
  if Trim(LProdutoIdText).IsEmpty then
    Exit;

  LProdutoId := StrToIntDef(LProdutoIdText, 0);
  if LProdutoId <= 0 then
  begin
    ShowMessage('Informe um código de produto válido.');
    Exit;
  end;

  LQuantidadeText := InputBox('Adicionar item', 'Quantidade:', '1');
  LQuantidade := StrToIntDef(LQuantidadeText, 0);
  if LQuantidade <= 0 then
  begin
    ShowMessage('Informe uma quantidade válida.');
    Exit;
  end;

  LValorText := InputBox('Adicionar item', 'Valor unitário:', '0,00');
  LValorText := StringReplace(LValorText, '.', ',', [rfReplaceAll]);
  LValorUnitario := StrToFloatDef(LValorText, 0);
  if LValorUnitario <= 0 then
  begin
    ShowMessage('Informe um valor unitário válido.');
    Exit;
  end;

  cdsItens.Append;
  cdsItens.FieldByName('produtoId').AsInteger := LProdutoId;
  cdsItens.FieldByName('quantidade').AsInteger := LQuantidade;
  cdsItens.FieldByName('valorUnitario').AsFloat := LValorUnitario;
  cdsItens.Post;
end;

procedure TfrmCadVenda.btnRemoverItemClick(Sender: TObject);
begin
  if cdsItens.IsEmpty then
    Exit;

  if MessageDlg('Deseja remover o item selecionado?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    cdsItens.Delete;
  end;
end;

function TfrmCadVenda.ValidarFormulario: Boolean;
begin
  Result := False;

  if Trim(edtClienteId.Text).IsEmpty then
  begin
    ShowMessage('Informe o cliente da venda.');
    Exit;
  end;

  if StrToIntDef(edtClienteId.Text, 0) <= 0 then
  begin
    ShowMessage('Informe um cliente válido.');
    Exit;
  end;

  if cdsItens.IsEmpty then
  begin
    ShowMessage('Adicione pelo menos um item à venda.');
    Exit;
  end;

  Result := True;
end;

function TfrmCadVenda.BuildJson: string;
var
  LRoot: TJSONObject;
  LItens: TJSONArray;
  LItem: TJSONObject;
begin
  LRoot := TJSONObject.Create;
  LItens := TJSONArray.Create;
  try
    if FVendaId > 0 then
      LRoot.AddPair('id', TJSONNumber.Create(FVendaId));

    LRoot.AddPair('clienteId', TJSONNumber.Create(StrToIntDef(edtClienteId.Text, 0)));
    LRoot.AddPair('status', TJSONNumber.Create(cmbStatus.ItemIndex));

    if FVendaId <= 0 then
    begin
      cdsItens.First;
      while not cdsItens.Eof do
      begin
        LItem := TJSONObject.Create;
        LItem.AddPair('produtoId', TJSONNumber.Create(cdsItens.FieldByName('produtoId').AsInteger));
        LItem.AddPair('quantidade', TJSONNumber.Create(cdsItens.FieldByName('quantidade').AsInteger));
        LItem.AddPair('valorUnitario', TJSONNumber.Create(cdsItens.FieldByName('valorUnitario').AsFloat));
        LItens.AddElement(LItem);
        cdsItens.Next;
      end;

      LRoot.AddPair('itens', LItens);
    end;

    Result := LRoot.ToString;
  finally
    LRoot.Free;
  end;
end;

procedure TfrmCadVenda.btnConfirmarClick(Sender: TObject);
var
  LJson: string;
  LVenda: TFinanceiroVendaDTO;
begin
  if not ValidarFormulario then
    Exit;

  try
    LJson := BuildJson;

    if FVendaId > 0 then
      LVenda := FController.Atualizar(LJson)
    else
      LVenda := FController.Criar(LJson);

    try
      if Assigned(LVenda) then
      begin
        ShowMessage('Venda salva com sucesso!');
        ModalResult := mrOk;
        Close;
      end;
    finally
      if Assigned(LVenda) then
        LVenda.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao salvar venda: ' + E.Message);
  end;
end;

procedure TfrmCadVenda.InicializarCDSItens;
begin
  cdsItens.Close;
  cdsItens.FieldDefs.Clear;
  cdsItens.FieldDefs.Add('produtoId', ftInteger);
  cdsItens.FieldDefs.Add('quantidade', ftInteger);
  cdsItens.FieldDefs.Add('valorUnitario', ftFloat);
  cdsItens.CreateDataSet;
  cdsItens.EmptyDataSet;
end;

procedure TfrmCadVenda.CarregarVenda(const AId: Integer);
var
  LVenda: TFinanceiroVendaDTO;
  LItem: TFinanceiroVendaItemDTO;
begin
  FVendaId := AId;
  LVenda := FController.ObterPorId(AId);
  try
    if not Assigned(LVenda) then
      Exit;

    edtClienteId.Text := LVenda.ClienteId.ToString;
    cmbStatus.ItemIndex := LVenda.Status;

    cdsItens.EmptyDataSet;
    for LItem in LVenda.Itens do
    begin
      if not Assigned(LItem) then
        Continue;

      cdsItens.Append;
      cdsItens.FieldByName('produtoId').AsInteger := LItem.ProdutoId;
      cdsItens.FieldByName('quantidade').AsInteger := LItem.Quantidade;
      cdsItens.FieldByName('valorUnitario').AsFloat := LItem.ValorUnitario;
      cdsItens.Post;
    end;
  finally
    if Assigned(LVenda) then
      LVenda.Free;
  end;
end;

end.
