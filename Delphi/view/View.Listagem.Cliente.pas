unit View.Listagem.Cliente;

interface

uses
  Data.DB,
  Datasnap.DBClient,
  System.Classes,
  System.DateUtils,
  System.Generics.Collections,
  System.JSON,
  System.MaskUtils,
  System.StrUtils,
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
  Financeiro.DTOs,
  Winapi.Windows,
  Winapi.Messages;

type
  TfrmListagemCliente = class(TfrmBaseListagem)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cdsListaAfterScroll(DataSet: TDataSet);
  private
    FController: TClienteController;
    function StatusVendaToText(const AStatus: Integer): string;
    function PagoEmToText(const APagoEm: string): string;
    function TotalToCurrencyText(const ATotal: Double): string;
    procedure InicializarCDS;
    procedure InicializarDBGrid;
    procedure InicializarCDSDetalhes;
    procedure InicializarDBGridDetalhes;
    procedure UTCtoDateTimeDef(const AUTCTime: string;
                               const AField: TField);
    procedure CarregarDetalhesClientes(const AVendas: TObjectList<TFinanceiroVendaResumoDTO>);
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    procedure CarregarClientes;
    { Public declarations }
  end;

var
  frmListagemCliente: TfrmListagemCliente;

implementation

{$R *.dfm}

procedure TfrmListagemCliente.CarregarDetalhesClientes(const AVendas: TObjectList<TFinanceiroVendaResumoDTO>);
var
  LVenda: TFinanceiroVendaResumoDTO;
begin
  cdsDetalhes.EmptyDataSet;
  for LVenda in AVendas do
  begin
    if not Assigned(LVenda) then
      Continue;

    cdsDetalhes.Append;
    cdsDetalhes.FieldByName('id').AsInteger := LVenda.Id;
    UTCtoDateTimeDef(LVenda.CriadoEm, cdsDetalhes.FieldByName('criadoEm'));
    cdsDetalhes.FieldByName('pagoEm').AsString := PagoEmToText(LVenda.PagoEm);
    cdsDetalhes.FieldByName('status').AsString := StatusVendaToText(LVenda.Status);
    cdsDetalhes.FieldByName('total').AsString := TotalToCurrencyText(LVenda.Total);
    cdsDetalhes.Post;
  end;
end;

procedure TfrmListagemCliente.cdsListaAfterScroll(DataSet: TDataSet);
begin
  inherited;
  Tag := cdsLista.FieldByName('id').AsInteger;
  if Tag > 0 then
    CarregarDetalhesClientes(FController.ObterPorId(Tag).Vendas);
end;

constructor TfrmListagemCliente.Create(AOwner: TComponent);
begin
  inherited;
  FController := TClienteController.Create;
end;

procedure TfrmListagemCliente.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FController.Free;
  inherited;
end;

procedure TfrmListagemCliente.FormCreate(Sender: TObject);
begin
  inherited;
  InicializarCDS;
  InicializarDBGrid;
  InicializarCDSDetalhes;
  InicializarDBGridDetalhes;
  CarregarClientes;
end;

function TfrmListagemCliente.StatusVendaToText(const AStatus: Integer): string;
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

function TfrmListagemCliente.PagoEmToText(const APagoEm: string): string;
begin
  Result := 'Não';
  if APagoEm.Trim.IsEmpty then
    Exit;

  if MatchText(APagoEm.ToLower, ['true', 'sim', '1']) then
    Result := 'Sim'
  else if MatchText(APagoEm.ToLower, ['false', 'nao', '0']) then
    Result := 'Não';

  if APagoEm.Trim.ToUpper.Contains('T') then // aqui é se por acaso retorna um tempo UTC
    Result := 'Sim';
end;

function TfrmListagemCliente.TotalToCurrencyText(const ATotal: Double): string;
begin
  Result := FormatFloat('R$ #,##0.00', ATotal);
end;

procedure TfrmListagemCliente.UTCtoDateTimeDef(const AUTCTime: string;
                                               const AField: TField);
begin
  if not AUTCTime.Trim.IsEmpty then
    AField.AsDateTime := ISO8601ToDate(AUTCTime)
  else
    AField.Clear;
end;

procedure TfrmListagemCliente.CarregarClientes;
var
  LClientes: TObjectList<TFinanceiroClienteDTO>;
  LCliente: TFinanceiroClienteDTO;
begin
  try
    LClientes := FController.Listar;
    try
      if not Assigned(LClientes) then
        Exit;

      cdsLista.EmptyDataSet;
      for LCliente in LClientes do
      begin
        if not Assigned(LCliente) then
          Continue;

        cdsLista.Append;
        cdsLista.FieldByName('id').AsInteger := LCliente.Id;
        cdsLista.FieldByName('nome').AsString := LCliente.Nome;
        cdsLista.FieldByName('cpf').AsString := FormatMaskText('000.000.000-00;0;_', LCliente.Cpf);
        cdsLista.FieldByName('email').AsString := LCliente.Email;
        cdsLista.FieldByName('telefone').AsString := FormatMaskText('(00)00000-0000;0;_', LCliente.Telefone);
        UTCtoDateTimeDef(LCliente.DataCadastro, cdsLista.FieldByName('dataCadastro'));
        cdsLista.Post;

        CarregarDetalhesClientes(LCliente.Vendas);
      end;
    finally
      if Assigned(LClientes) then
        LClientes.Free;

      cdsLista.First;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao listar clientes: ' + E.Message);
  end;
end;

procedure TfrmListagemCliente.InicializarCDS;
begin
  cdsLista.Close;
  cdsLista.FieldDefs.Clear;

  cdsLista.FieldDefs.Add('id', ftInteger);
  cdsLista.FieldDefs.Add('nome', ftString, 200);
  cdsLista.FieldDefs.Add('cpf', ftString, 20);
  cdsLista.FieldDefs.Add('email', ftString, 200);
  cdsLista.FieldDefs.Add('telefone', ftString, 30);
  cdsLista.FieldDefs.Add('dataCadastro', ftDateTime);

  cdsLista.CreateDataSet;
  cdsLista.EmptyDataSet;
end;

procedure TfrmListagemCliente.InicializarCDSDetalhes;
begin
  cdsDetalhes.Close;
  cdsDetalhes.FieldDefs.Clear;

  cdsDetalhes.FieldDefs.Add('id', ftInteger);
  cdsDetalhes.FieldDefs.Add('criadoEm', ftString, 50);
  cdsDetalhes.FieldDefs.Add('pagoEm', ftString, 50);
  cdsDetalhes.FieldDefs.Add('status', ftString, 40);
  cdsDetalhes.FieldDefs.Add('total', ftString, 30);

  cdsDetalhes.CreateDataSet;
  cdsDetalhes.EmptyDataSet;
end;

procedure TfrmListagemCliente.InicializarDBGrid;
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
  col.FieldName := 'cpf';
  col.Title.Caption := 'CPF';
  col.Width := 120;

  col := grdListagem.Columns.Add;
  col.FieldName := 'email';
  col.Title.Caption := 'E-mail';
  col.Width := 200;

  col := grdListagem.Columns.Add;
  col.FieldName := 'telefone';
  col.Title.Caption := 'Telefone';
  col.Width := 120;

  col := grdListagem.Columns.Add;
  col.FieldName := 'dataCadastro';
  col.Title.Caption := 'Data Cadastro';
  col.Width := 140;
end;

procedure TfrmListagemCliente.InicializarDBGridDetalhes;
var
  col: TColumn;
begin
  grdDetalhes.Columns.Clear;

  col := grdDetalhes.Columns.Add;
  col.FieldName := 'id';
  col.Title.Caption := 'Cod. Venda';
  col.Width := 70;
  col.ReadOnly := True;

  col := grdDetalhes.Columns.Add;
  col.FieldName := 'criadoEm';
  col.Title.Caption := 'Data Venda';
  col.Width := 150;

  col := grdDetalhes.Columns.Add;
  col.FieldName := 'pagoEm';
  col.Title.Caption := 'Pago';
  col.Width := 80;

  col := grdDetalhes.Columns.Add;
  col.FieldName := 'status';
  col.Title.Caption := 'Status';
  col.Width := 180;

  col := grdDetalhes.Columns.Add;
  col.FieldName := 'total';
  col.Title.Caption := 'Total';
  col.Width := 110;
end;

end.
