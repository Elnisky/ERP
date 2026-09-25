unit Financeiro.DTOs;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.JSON,
  System.SysUtils;

type
  TFinanceiroVendaResumoDTO = class
  private
    FId: Integer;
    FCriadoEm: string;
    FPagoEm: string;
    FClienteId: Integer;
    FStatus: Integer;
    FTotal: Double;
  public
    class function FromJson(const AContent: string): TFinanceiroVendaResumoDTO; static;
    function ToJson: string;

    property Id: Integer read FId write FId;
    property CriadoEm: string read FCriadoEm write FCriadoEm;
    property PagoEm: string read FPagoEm write FPagoEm;
    property ClienteId: Integer read FClienteId write FClienteId;
    property Status: Integer read FStatus write FStatus;
    property Total: Double read FTotal write FTotal;
  end;

  TFinanceiroClienteDTO = class
  private
    FId: Integer;
    FNome: string;
    FCpf: string;
    FEmail: string;
    FTelefone: string;
    FDataCadastro: string;
    FVendas: TObjectList<TFinanceiroVendaResumoDTO>;
  public
    constructor Create;
    destructor Destroy; override;

    class function FromJson(const AContent: string): TFinanceiroClienteDTO; static;
    class function GetJson(const ANome, ACpf, AEmail, ATelefone, AId: string): string; static;
    function ToJson: string;

    property Id: Integer read FId write FId;
    property Nome: string read FNome write FNome;
    property Cpf: string read FCpf write FCpf;
    property Email: string read FEmail write FEmail;
    property Telefone: string read FTelefone write FTelefone;
    property DataCadastro: string read FDataCadastro write FDataCadastro;
    property Vendas: TObjectList<TFinanceiroVendaResumoDTO> read FVendas;
  end;

  TFinanceiroProdutoDTO = class
  private
    FId: Integer;
    FNome: string;
    FPreco: Double;
    FQuantidadeEstoque: Integer;
  public
    class function FromJson(const AContent: string): TFinanceiroProdutoDTO; static;
    class function GetJson(const ANome, APreco, AQuantidadeEstoque, AId: string): string; static;
    function ToJson: string;

    property Id: Integer read FId write FId;
    property Nome: string read FNome write FNome;
    property Preco: Double read FPreco write FPreco;
    property QuantidadeEstoque: Integer read FQuantidadeEstoque write FQuantidadeEstoque;
  end;

  TFinanceiroPagamentoDTO = class
  private
    FId: Integer;
    FVendaId: Integer;
    FValor: Double;
    FTipo: Integer;
    FStatus: Integer;
    FCompletedAt: string;
    FTransacaoId: string;
  public
    class function FromJson(const AContent: string): TFinanceiroPagamentoDTO; static;
    function ToJson: string;

    property Id: Integer read FId write FId;
    property VendaId: Integer read FVendaId write FVendaId;
    property Valor: Double read FValor write FValor;
    property Tipo: Integer read FTipo write FTipo;
    property Status: Integer read FStatus write FStatus;
    property CompletedAt: string read FCompletedAt write FCompletedAt;
    property TransacaoId: string read FTransacaoId write FTransacaoId;
  end;

  TFinanceiroVendaItemDTO = class
  private
    FId: Integer;
    FVendaId: Integer;
    FProdutoId: Integer;
    FQuantidade: Integer;
    FValorUnitario: Double;
  public
    class function FromJson(const AContent: string): TFinanceiroVendaItemDTO; static;
    function ToJson: string;

    property Id: Integer read FId write FId;
    property VendaId: Integer read FVendaId write FVendaId;
    property ProdutoId: Integer read FProdutoId write FProdutoId;
    property Quantidade: Integer read FQuantidade write FQuantidade;
    property ValorUnitario: Double read FValorUnitario write FValorUnitario;
  end;

  TFinanceiroVendaDTO = class
  private
    FId: Integer;
    FClienteId: Integer;
    FStatus: Integer;
    FPagoEm: string;
    FTotal: Double;
    FItens: TObjectList<TFinanceiroVendaItemDTO>;
  public
    constructor Create;
    destructor Destroy; override;

    class function FromJson(const AContent: string): TFinanceiroVendaDTO; static;
    function ToJson: string;

    property Id: Integer read FId write FId;
    property ClienteId: Integer read FClienteId write FClienteId;
    property Status: Integer read FStatus write FStatus;
    property PagoEm: string read FPagoEm write FPagoEm;
    property Total: Double read FTotal write FTotal;
    property Itens: TObjectList<TFinanceiroVendaItemDTO> read FItens;
  end;

implementation

function JsonString(const AJsonObject: TJSONObject; const AName: string; const ADefault: string = ''): string;
var
  LValue: TJSONValue;
begin
  Result := ADefault;
  if not Assigned(AJsonObject) then
    Exit;

  LValue := AJsonObject.GetValue(AName);
  if Assigned(LValue) and not (LValue is TJSONNull) then
    Result := LValue.Value;
end;

function JsonInteger(const AJsonObject: TJSONObject; const AName: string; const ADefault: Integer = 0): Integer;
var
  LValue: TJSONValue;
begin
  Result := ADefault;
  if not Assigned(AJsonObject) then
    Exit;

  LValue := AJsonObject.GetValue(AName);
  if Assigned(LValue) and not (LValue is TJSONNull) then
    Result := StrToIntDef(LValue.Value, ADefault);
end;

function JsonDouble(const AJsonObject: TJSONObject; const AName: string; const ADefault: Double = 0): Double;
var
  LValue: TJSONValue;
  FS: TFormatSettings;
begin
  Result := ADefault;
  if not Assigned(AJsonObject) then
    Exit;

  FS := TFormatSettings.Create;
  FS.DecimalSeparator := '.';
  LValue := AJsonObject.GetValue(AName);
  if Assigned(LValue) and not (LValue is TJSONNull) then
    Result := StrToFloatDef(LValue.Value, ADefault, FS);
end;

function ParseObject(const AContent: string; const AContext: string): TJSONObject;
begin
  if Trim(AContent).IsEmpty then
    raise EConvertError.CreateFmt('O conteúdo JSON de %s está vazio.', [AContext]);

  Result := TJSONObject.ParseJSONValue(AContent) as TJSONObject;
  if not Assigned(Result) then
    raise EConvertError.CreateFmt('O conteúdo JSON de %s não é um objeto válido.', [AContext]);
end;

{ TFinanceiroVendaResumoDTO }

class function TFinanceiroVendaResumoDTO.FromJson(const AContent: string): TFinanceiroVendaResumoDTO;
var
  LJsonObject: TJSONObject;
begin
  LJsonObject := ParseObject(AContent, 'VendaResumo');
  try
    Result := TFinanceiroVendaResumoDTO.Create;
    Result.Id := JsonInteger(LJsonObject, 'id');
    Result.CriadoEm := JsonString(LJsonObject, 'criadoEm');
    Result.PagoEm := JsonString(LJsonObject, 'pagoEm');
    Result.ClienteId := JsonInteger(LJsonObject, 'clienteId');
    Result.Status := JsonInteger(LJsonObject, 'status');
    Result.Total := JsonDouble(LJsonObject, 'total');
  finally
    LJsonObject.Free;
  end;
end;

function TFinanceiroVendaResumoDTO.ToJson: string;
var
  LJsonObject: TJSONObject;
begin
  LJsonObject := TJSONObject.Create;
  try
    LJsonObject.AddPair('id', TJSONNumber.Create(FId));
    LJsonObject.AddPair('criadoEm', FCriadoEm);
    if FPagoEm.Trim <> '' then
      LJsonObject.AddPair('pagoEm', FPagoEm)
    else
      LJsonObject.AddPair('pagoEm', TJSONNull.Create);
    LJsonObject.AddPair('clienteId', TJSONNumber.Create(FClienteId));
    LJsonObject.AddPair('status', TJSONNumber.Create(FStatus));
    LJsonObject.AddPair('total', TJSONNumber.Create(FTotal));
    Result := LJsonObject.ToString;
  finally
    LJsonObject.Free;
  end;
end;

{ TFinanceiroClienteDTO }

constructor TFinanceiroClienteDTO.Create;
begin
  inherited Create;
  FVendas := TObjectList<TFinanceiroVendaResumoDTO>.Create(True);
end;

destructor TFinanceiroClienteDTO.Destroy;
begin
  FVendas.Free;
  inherited;
end;

class function TFinanceiroClienteDTO.FromJson(const AContent: string): TFinanceiroClienteDTO;
var
  LJsonObject: TJSONObject;
  LArray: TJSONArray;
  I: Integer;
  LValue: TJSONValue;
  LVenda: TFinanceiroVendaResumoDTO;
begin
  LJsonObject := ParseObject(AContent, 'Cliente');
  try
    Result := TFinanceiroClienteDTO.Create;
    Result.Id := JsonInteger(LJsonObject, 'id');
    Result.Nome := JsonString(LJsonObject, 'nome');
    Result.Cpf := JsonString(LJsonObject, 'cpf');
    Result.Email := JsonString(LJsonObject, 'email');
    Result.Telefone := JsonString(LJsonObject, 'telefone');
    Result.DataCadastro := JsonString(LJsonObject, 'dataCadastro');

    LValue := LJsonObject.GetValue('vendas');
    if Assigned(LValue) and (LValue is TJSONArray) then
    begin
      LArray := TJSONArray(LValue);
      for I := 0 to Pred(LArray.Count) do
      begin
        if not (LArray.Items[I] is TJSONObject) then
          Continue;

        LVenda := TFinanceiroVendaResumoDTO.FromJson(LArray.Items[I].ToString);
        Result.FVendas.Add(LVenda);
      end;
    end;
  finally
    LJsonObject.Free;
  end;
end;

class function TFinanceiroClienteDTO.GetJson(const ANome, ACpf, AEmail, ATelefone, AId: string): string;
var
  LJsonObject: TJSONObject;
begin
  LJsonObject := TJSONObject.Create;
  try
    if not AId.Trim.IsEmpty and (StrToIntDef(AId, 0) > 0) then
      LJsonObject.AddPair('id', AId.ToInteger);

    if not ANome.Trim.IsEmpty then
      LJsonObject.AddPair('nome', ANome);

    if not ACpf.Trim.IsEmpty then
      LJsonObject.AddPair('cpf', ACpf);

    if not AEmail.Trim.IsEmpty then
      LJsonObject.AddPair('email', AEmail);

    if not ATelefone.Trim.IsEmpty then
      LJsonObject.AddPair('telefone', ATelefone);

    Result := LJsonObject.ToString;
  finally
    LJsonObject.Free;
  end;
end;

function TFinanceiroClienteDTO.ToJson: string;
var
  LJsonObject: TJSONObject;
  LArray: TJSONArray;
  I: Integer;
begin
  LJsonObject := TJSONObject.Create;
  LArray := TJSONArray.Create;
  try
    LJsonObject.AddPair('id', TJSONNumber.Create(FId));
    LJsonObject.AddPair('nome', FNome);
    LJsonObject.AddPair('cpf', FCpf);
    LJsonObject.AddPair('email', FEmail);
    LJsonObject.AddPair('telefone', FTelefone);

    for I := 0 to Pred(FVendas.Count) do
      LArray.AddElement(TJSONObject.ParseJSONValue(FVendas[I].ToJson));

    LJsonObject.AddPair('vendas', LArray);
    Result := LJsonObject.ToString;
  finally
    LJsonObject.Free;
  end;
end;

{ TFinanceiroProdutoDTO }

class function TFinanceiroProdutoDTO.FromJson(const AContent: string): TFinanceiroProdutoDTO;
var
  LJsonObject: TJSONObject;
begin
  LJsonObject := ParseObject(AContent, 'Produto');
  try
    Result := TFinanceiroProdutoDTO.Create;
    Result.Id := JsonInteger(LJsonObject, 'id');
    Result.Nome := JsonString(LJsonObject, 'nome');
    Result.Preco := JsonDouble(LJsonObject, 'preco');
    Result.QuantidadeEstoque := JsonInteger(LJsonObject, 'quantidadeEstoque');
  finally
    LJsonObject.Free;
  end;
end;

class function TFinanceiroProdutoDTO.GetJson(const ANome, APreco, AQuantidadeEstoque, AId: string): string;
var
  LJsonObject: TJSONObject;
begin
  LJsonObject := TJSONObject.Create;
  try
    if not AId.Trim.IsEmpty and (StrToIntDef(AId, 0) > 0) then
      LJsonObject.AddPair('id', AId.ToInteger);

    if not ANome.Trim.IsEmpty then
      LJsonObject.AddPair('nome', ANome);

    if not APreco.Trim.IsEmpty then
      LJsonObject.AddPair('preco', APreco.ToDouble);

    if not AQuantidadeEstoque.Trim.IsEmpty then
      LJsonObject.AddPair('quantidadeEstoque', AQuantidadeEstoque.ToInteger);

    Result := LJsonObject.ToString;
  finally
    LJsonObject.Free;
  end;
end;

function TFinanceiroProdutoDTO.ToJson: string;
var
  LJsonObject: TJSONObject;
begin
  LJsonObject := TJSONObject.Create;
  try
    LJsonObject.AddPair('id', TJSONNumber.Create(FId));
    LJsonObject.AddPair('nome', FNome);
    LJsonObject.AddPair('preco', TJSONNumber.Create(FPreco));
    LJsonObject.AddPair('quantidadeEstoque', TJSONNumber.Create(FQuantidadeEstoque));
    Result := LJsonObject.ToString;
  finally
    LJsonObject.Free;
  end;
end;

{ TFinanceiroPagamentoDTO }

class function TFinanceiroPagamentoDTO.FromJson(const AContent: string): TFinanceiroPagamentoDTO;
var
  LJsonObject: TJSONObject;
begin
  LJsonObject := ParseObject(AContent, 'Pagamento');
  try
    Result := TFinanceiroPagamentoDTO.Create;
    Result.Id := JsonInteger(LJsonObject, 'id');
    Result.VendaId := JsonInteger(LJsonObject, 'vendaId');
    Result.Valor := JsonDouble(LJsonObject, 'valor');
    Result.Tipo := JsonInteger(LJsonObject, 'type');
    Result.Status := JsonInteger(LJsonObject, 'status');
    Result.CompletedAt := JsonString(LJsonObject, 'completedAt');
    Result.TransacaoId := JsonString(LJsonObject, 'transacaoId');
  finally
    LJsonObject.Free;
  end;
end;

function TFinanceiroPagamentoDTO.ToJson: string;
var
  LJsonObject: TJSONObject;
begin
  LJsonObject := TJSONObject.Create;
  try
    LJsonObject.AddPair('id', TJSONNumber.Create(FId));
    LJsonObject.AddPair('vendaId', TJSONNumber.Create(FVendaId));
    LJsonObject.AddPair('valor', TJSONNumber.Create(FValor));
    LJsonObject.AddPair('type', TJSONNumber.Create(FTipo));
    LJsonObject.AddPair('status', TJSONNumber.Create(FStatus));
    if FCompletedAt.Trim <> '' then
      LJsonObject.AddPair('completedAt', FCompletedAt)
    else
      LJsonObject.AddPair('completedAt', TJSONNull.Create);
    if FTransacaoId.Trim <> '' then
      LJsonObject.AddPair('transacaoId', FTransacaoId)
    else
      LJsonObject.AddPair('transacaoId', TJSONNull.Create);
    Result := LJsonObject.ToString;
  finally
    LJsonObject.Free;
  end;
end;

{ TFinanceiroVendaItemDTO }

class function TFinanceiroVendaItemDTO.FromJson(const AContent: string): TFinanceiroVendaItemDTO;
var
  LJsonObject: TJSONObject;
begin
  LJsonObject := ParseObject(AContent, 'VendaItem');
  try
    Result := TFinanceiroVendaItemDTO.Create;
    Result.Id := JsonInteger(LJsonObject, 'id');
    Result.VendaId := JsonInteger(LJsonObject, 'vendaId');
    Result.ProdutoId := JsonInteger(LJsonObject, 'produtoId');
    Result.Quantidade := JsonInteger(LJsonObject, 'quantidade');
    Result.ValorUnitario := JsonDouble(LJsonObject, 'valorUnitario');
  finally
    LJsonObject.Free;
  end;
end;

function TFinanceiroVendaItemDTO.ToJson: string;
var
  LJsonObject: TJSONObject;
begin
  LJsonObject := TJSONObject.Create;
  try
    LJsonObject.AddPair('id', TJSONNumber.Create(FId));
    LJsonObject.AddPair('vendaId', TJSONNumber.Create(FVendaId));
    LJsonObject.AddPair('produtoId', TJSONNumber.Create(FProdutoId));
    LJsonObject.AddPair('quantidade', TJSONNumber.Create(FQuantidade));
    LJsonObject.AddPair('valorUnitario', TJSONNumber.Create(FValorUnitario));
    Result := LJsonObject.ToString;
  finally
    LJsonObject.Free;
  end;
end;

{ TFinanceiroVendaDTO }

constructor TFinanceiroVendaDTO.Create;
begin
  inherited Create;
  FItens := TObjectList<TFinanceiroVendaItemDTO>.Create(True);
end;

destructor TFinanceiroVendaDTO.Destroy;
begin
  FItens.Free;
  inherited;
end;

class function TFinanceiroVendaDTO.FromJson(const AContent: string): TFinanceiroVendaDTO;
var
  LJsonObject: TJSONObject;
  LArray: TJSONArray;
  I: Integer;
  LItem: TFinanceiroVendaItemDTO;
  LValue: TJSONValue;
begin
  LJsonObject := ParseObject(AContent, 'Venda');
  try
    Result := TFinanceiroVendaDTO.Create;
    Result.Id := JsonInteger(LJsonObject, 'id');
    Result.ClienteId := JsonInteger(LJsonObject, 'clienteId');
    Result.Status := JsonInteger(LJsonObject, 'status');
    Result.PagoEm := JsonString(LJsonObject, 'pagoEm');
    Result.Total := JsonDouble(LJsonObject, 'total');

    LValue := LJsonObject.GetValue('itens');
    if Assigned(LValue) and (LValue is TJSONArray) then
    begin
      LArray := TJSONArray(LValue);
      for I := 0 to Pred(LArray.Count) do
      begin
        LItem := TFinanceiroVendaItemDTO.FromJson(LArray.Items[I].ToString);
        Result.FItens.Add(LItem);
      end;
    end;
  finally
    LJsonObject.Free;
  end;
end;

function TFinanceiroVendaDTO.ToJson: string;
var
  LJsonObject: TJSONObject;
  LArray: TJSONArray;
  I: Integer;
begin
  LJsonObject := TJSONObject.Create;
  LArray := TJSONArray.Create;
  try
    LJsonObject.AddPair('id', TJSONNumber.Create(FId));
    LJsonObject.AddPair('clienteId', TJSONNumber.Create(FClienteId));
    LJsonObject.AddPair('status', TJSONNumber.Create(FStatus));
    if FPagoEm.Trim <> '' then
      LJsonObject.AddPair('pagoEm', FPagoEm)
    else
      LJsonObject.AddPair('pagoEm', TJSONNull.Create);

    for I := 0 to Pred(FItens.Count) do
      LArray.AddElement(TJSONObject.ParseJSONValue(FItens[I].ToJson));

    LJsonObject.AddPair('itens', LArray);
    Result := LJsonObject.ToString;
  finally
    LJsonObject.Free;
  end;
end;

end.
