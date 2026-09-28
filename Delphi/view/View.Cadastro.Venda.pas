unit View.Cadastro.Venda;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
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
  ClienteController,
  ProdutoController,
  VendaController,
  Financeiro.DTOs;

type
  TComboItem = class
  private
    FId: Integer;
    FNome: string;
  public
    constructor Create(const AId: Integer; const ANome: string);
    property Id: Integer read FId;
    property Nome: string read FNome;
  end;

  TfrmCadVenda = class(TForm)
    pnlRodape: TPanel;
    btnCancelar: TButton;
    btnConfirmar: TButton;
    pnlDados: TPanel;
    lblClienteId: TLabel;
    lblStatus: TLabel;
    cmbStatus: TComboBox;
    btnAdicionarItem: TButton;
    btnRemoverItem: TButton;
    grdItens: TDBGrid;
    dsItens: TDataSource;
    cdsItens: TClientDataSet;
    cmbCliente: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnAdicionarItemClick(Sender: TObject);
    procedure btnRemoverItemClick(Sender: TObject);
  private
    FController: TVendaController;
    FClienteController: TClienteController;
    FProdutoController: TProdutoController;
    FVendaId: Integer;
    FClienteId: Integer;
    procedure InicializarCDSItens;
    procedure CarregarClientesAsync;
    procedure PreencherComboClientes(const AClientes: TObjectList<TFinanceiroClienteDTO>);
    function ClienteSelecionadoId: Integer;
    function BuildJsonVenda(const Status: ShortInt): string;
    function BuildItensJson: string;
    function ValidarFormulario: Boolean;
    procedure CarregarVenda(const AId: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure CancelarVenda;
    procedure PagarVenda;
  end;

var
  frmCadVenda: TfrmCadVenda;

implementation

{$R *.dfm}

constructor TfrmCadVenda.Create(AOwner: TComponent);
begin
  inherited;
  FController := TVendaController.Create;
  FClienteController := TClienteController.Create;
  FProdutoController := TProdutoController.Create;
  FClienteId := 0;
  InicializarCDSItens;
  cmbStatus.Items.Clear;
  cmbStatus.Items.Add('Orcamento');
  cmbStatus.Items.Add('Pagamento Pendente');
  cmbStatus.ItemIndex := 0;
end;

destructor TfrmCadVenda.Destroy;
begin
  FProdutoController.Free;
  FClienteController.Free;
  FController.Free;
  inherited;
end;

procedure TfrmCadVenda.FormCreate(Sender: TObject);
begin
  inherited;
  CarregarClientesAsync;
end;

procedure TfrmCadVenda.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadVenda.btnAdicionarItemClick(Sender: TObject);
var
  LProdutoId: Integer;
  LQuantidade: Integer;
  LProduto: TFinanceiroProdutoDTO;
  LProdutoIdText: string;
  LQuantidadeText: string;
begin
  LProduto := nil;
  try
    LProdutoIdText := InputBox('Adicionar item', 'Produto ID:', '');
    if Trim(LProdutoIdText).IsEmpty then
      Exit;

    LProdutoId := StrToIntDef(LProdutoIdText, 0);
    if LProdutoId <= 0 then
      raise Exception.Create('Informe um código de produto válido.');

    LProduto := FProdutoController.ObterPorId(LProdutoId);
    if not Assigned(LProduto) then
      raise Exception.CreateFmt('Produto %d não encontrado.', [LProdutoId]);

    LQuantidadeText := InputBox('Adicionar item', 'Quantidade:', '1');
    LQuantidade := StrToIntDef(LQuantidadeText, 0);
    if LQuantidade <= 0 then
      raise Exception.Create('Informe uma quantidade válida.');

    cdsItens.Append;
    cdsItens.FieldByName('produtoId').AsInteger := LProduto.Id;
    cdsItens.FieldByName('produtoNome').AsString := LProduto.Nome;
    cdsItens.FieldByName('quantidade').AsInteger := LQuantidade;
    cdsItens.FieldByName('valorUnitario').AsFloat := LProduto.Preco;
    cdsItens.Post;
  except
    on E: Exception do
      ShowMessage('Falha ao adicionar item: ' + E.Message);
  end;

  if Assigned(LProduto) then
    LProduto.Free;
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
  try
    FClienteId := ClienteSelecionadoId;
    if FClienteId <= 0 then
      raise Exception.Create('Informe um cliente válido para a venda.');

    if cdsItens.IsEmpty then
      raise Exception.Create('Adicione pelo menos um item à venda.');

    Result := True;
  except
    on E: Exception do
      ShowMessage('Valores inválidos: ' + E.Message);
  end;
end;

function TfrmCadVenda.BuildJsonVenda(const Status: ShortInt): string;
var
  LRoot: TJSONObject;
begin
  LRoot := TJSONObject.Create;
  try
    if FVendaId > 0 then
      LRoot.AddPair('id', TJSONNumber.Create(FVendaId));

    LRoot.AddPair('clienteId', TJSONNumber.Create(FClienteId));
    LRoot.AddPair('status', TJSONNumber.Create(Status));
    if FVendaId = 0 then
      LRoot.AddPair('itens', TJSONObject.ParseJSONValue(BuildItensJson));
    Result := LRoot.ToString;
  finally
    LRoot.Free;
  end;
end;

function TfrmCadVenda.BuildItensJson: string;
var
  LArray: TJSONArray;
  LItem: TJSONObject;
begin
  LArray := TJSONArray.Create;
  try
    cdsItens.First;
    while not cdsItens.Eof do
    begin
      LItem := TJSONObject.Create;
      LItem.AddPair('vendaId', TJSONNumber.Create(FVendaId));
      LItem.AddPair('produtoId', TJSONNumber.Create(cdsItens.FieldByName('produtoId').AsInteger));
      LItem.AddPair('quantidade', TJSONNumber.Create(cdsItens.FieldByName('quantidade').AsInteger));
      LItem.AddPair('valorUnitario', TJSONNumber.Create(cdsItens.FieldByName('valorUnitario').AsFloat));
      LArray.AddElement(LItem);
      cdsItens.Next;
    end;

    Result := LArray.ToString;
  finally
    LArray.Free;
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
    LJson := BuildJsonVenda(cmbStatus.ItemIndex);

    if FVendaId > 0 then
    begin
      LVenda := FController.Atualizar(LJson);
      try
        if Assigned(LVenda) and not cdsItens.IsEmpty then
          FController.ItemAtualizar(BuildItensJson);
      finally
        if Assigned(LVenda) then
          LVenda.Free;
      end;
    end
    else
    begin
      LVenda := FController.Criar(LJson);
      if Assigned(LVenda) then
        LVenda.Free;
    end;

    ShowMessage('Venda salva com sucesso!');
    ModalResult := mrOk;
    Close;
  except
    on E: Exception do
      ShowMessage('Erro ao salvar venda: ' + E.Message);
  end;
end;

procedure TfrmCadVenda.InicializarCDSItens;
begin
  cdsItens.Close;
  cdsItens.FieldDefs.Clear;
  cdsItens.FieldDefs.Add('id', ftInteger);
  cdsItens.FieldDefs.Add('produtoId', ftInteger);
  cdsItens.FieldDefs.Add('produtoNome', ftString, 200);
  cdsItens.FieldDefs.Add('quantidade', ftInteger);
  cdsItens.FieldDefs.Add('valorUnitario', ftFloat);
  cdsItens.CreateDataSet;
  cdsItens.EmptyDataSet;
end;

procedure TfrmCadVenda.CancelarVenda;
var
  LVenda : TFinanceiroVendaDTO;
begin
  try
    LVenda := FController.ObterPorId(Tag);
    FVendaId := LVenda.Id;
    FClienteId := LVenda.ClienteId;
    if Assigned(LVenda) and (LVenda.Status > 1) then
      raise Exception.Create('O status da venda não permite a sua alteração!');
    FController.Atualizar(BuildJsonVenda(3));
    ShowMessage('A venda foi cancelada!');
  except
    on E: Exception do
      ShowMessage('Erro ao cancelar venda: ' + E.Message);
  end;
end;

procedure TfrmCadVenda.CarregarClientesAsync;
begin
  TThread.CreateAnonymousThread(procedure
                                var
                                  LClientes: TObjectList<TFinanceiroClienteDTO>;
                                begin
                                  try
                                    LClientes := FClienteController.Listar;
                                    TThread.Queue(nil,
                                                  procedure
                                                  begin
                                                    PreencherComboClientes(LClientes);
                                                    if Tag > 0 then
                                                      CarregarVenda(Tag);
                                                  end);
                                  except
                                    on E: Exception do
                                      TThread.Queue(nil,
                                                    procedure
                                                    begin
                                                      ShowMessage('Erro ao carregar clientes: ' + E.Message);
                                                    end);
                                  end;
                                end).Start;
end;

procedure TfrmCadVenda.PagarVenda;
var
  LVenda : TFinanceiroVendaDTO;
begin
  try
    LVenda := FController.ObterPorId(Tag);
    FVendaId := LVenda.Id;
    FClienteId := LVenda.ClienteId;
    if Assigned(LVenda) and (LVenda.Status > 1) then
      raise Exception.Create('O status da venda não permite a sua alteração!');
    FController.Atualizar(BuildJsonVenda(2));
    ShowMessage('Pagamento efetuado com sucesso!');
  except
    on E: Exception do
      ShowMessage('Erro ao pagar a venda: ' + E.Message);
  end;
end;

procedure TfrmCadVenda.PreencherComboClientes(const AClientes: TObjectList<TFinanceiroClienteDTO>);
var
  LCliente: TFinanceiroClienteDTO;
  LItem: TComboItem;
begin
  cmbCliente.Items.BeginUpdate;
  try
    cmbCliente.Clear;
    if not Assigned(AClientes) then
      Exit;

    for LCliente in AClientes do
    begin
      if not Assigned(LCliente) then
        Continue;

      LItem := TComboItem.Create(LCliente.Id, LCliente.Nome);
      cmbCliente.Items.AddObject(LCliente.Nome, LItem);
    end;

    if cmbCliente.Items.Count > 0 then
      cmbCliente.ItemIndex := 0;
  finally
    cmbCliente.Items.EndUpdate;
  end;
end;

function TfrmCadVenda.ClienteSelecionadoId: Integer;
var
  LItem: TComboItem;
begin
  Result := 0;
  if (cmbCliente.ItemIndex < 0) or (cmbCliente.ItemIndex >= cmbCliente.Items.Count) then
    Exit;

  if Assigned(cmbCliente.Items.Objects[cmbCliente.ItemIndex]) and (cmbCliente.Items.Objects[cmbCliente.ItemIndex] is TComboItem) then
  begin
    LItem := TComboItem(cmbCliente.Items.Objects[cmbCliente.ItemIndex]);
    Result := LItem.Id;
  end;
end;

procedure TfrmCadVenda.CarregarVenda(const AId: Integer);
var
  LVenda: TFinanceiroVendaDTO;
  LItem: TFinanceiroVendaItemDTO;
  LProduto: TFinanceiroProdutoDTO;
  I: Integer;
  LClienteItem: TComboItem;
begin
  FVendaId := AId;
  LVenda := FController.ObterPorId(AId);
  try
    try
      if not Assigned(LVenda) then
        Exit;

      FClienteId := LVenda.ClienteId;
      for I := 0 to Pred(cmbCliente.Items.Count) do
      begin
        if Assigned(cmbCliente.Items.Objects[I]) and
           (cmbCliente.Items.Objects[I] is TComboItem) then
        begin
          LClienteItem := TComboItem(cmbCliente.Items.Objects[I]);
          if LClienteItem.Id = LVenda.ClienteId then
          begin
            cmbCliente.ItemIndex := I;
            Break;
          end;
        end;
      end;

      cmbStatus.ItemIndex := LVenda.Status;
      cdsItens.EmptyDataSet;
      for LItem in LVenda.Itens do
      begin
        if not Assigned(LItem) then
          Continue;

        LProduto := FProdutoController.ObterPorId(LItem.ProdutoId);
        try
          cdsItens.Append;
          cdsItens.FieldByName('id').AsInteger := LItem.Id;
          cdsItens.FieldByName('produtoId').AsInteger := LItem.ProdutoId;
          cdsItens.FieldByName('produtoNome').AsString := LProduto.Nome;
          cdsItens.FieldByName('quantidade').AsInteger := LItem.Quantidade;
          cdsItens.FieldByName('valorUnitario').AsFloat := LItem.ValorUnitario;
          cdsItens.Post;
        finally
          if Assigned(LProduto) then
            LProduto.Free;
        end;
      end;
    except
      on E: Exception do
      begin
        Close;
        ShowMessage('Erro ao carregar dados da venda: ' + E.Message);
      end;
    end;
  finally
    if Assigned(LVenda) then
      LVenda.Free;
  end;
end;

constructor TComboItem.Create(const AId: Integer; const ANome: string);
begin
  inherited Create;
  FId := AId;
  FNome := ANome;
end;

end.
