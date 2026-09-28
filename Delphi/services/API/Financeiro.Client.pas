unit Financeiro.Client;

interface

uses
  System.Generics.Collections,
  System.JSON,
  System.SysUtils,
  HttpClient.Interfaces,
  HttpClient.Types,
  Financeiro.Interfaces,
  Financeiro.DTOs;

type
  TFinanceiroApiClient = class(TInterfacedObject, IFinanceiroApiClient)
  private
    FHttpClient: IHttpClient;
    FBaseUrl: string;

    function IsSuccessStatusCode(const AStatusCode: Integer): Boolean;
    procedure ValidarResponse(const AResponse: IHttpResponse);
    function ExecuteJsonRequest(const AMethod: THttpMethod;
                               const AResource: string;
                               const ABody: string = ''): TJSONValue;

    function AsObject(const AJsonValue: TJSONValue; const AContext: string): TJSONObject;
    function AsArray(const AJsonValue: TJSONValue; const AContext: string): TJSONArray;
    function AResponseHasContent(const AContent: string): Boolean;
  public
    constructor Create(const AHttpClient: IHttpClient; const ABaseUrl: string);
    class function New(const AHttpClient: IHttpClient; const ABaseUrl: string): IFinanceiroApiClient; static;

    function ClienteListar: TObjectList<TFinanceiroClienteDTO>;
    function ClienteObterPorId(const AId: Integer): TFinanceiroClienteDTO;
    function ClienteCriar(const AJson: string): TFinanceiroClienteDTO;
    function ClienteAtualizar(const AJson: string): TFinanceiroClienteDTO;
    function ClienteExcluir(const AId: Integer): Boolean;

    function ProdutoListar: TObjectList<TFinanceiroProdutoDTO>;
    function ProdutoObterPorId(const AId: Integer): TFinanceiroProdutoDTO;
    function ProdutoCriar(const AJson: string): TFinanceiroProdutoDTO;
    function ProdutoAtualizar(const AJson: string): TFinanceiroProdutoDTO;
    function ProdutoExcluir(const AId: Integer): Boolean;

    function PagamentoListar: TObjectList<TFinanceiroPagamentoDTO>;
    function PagamentoObterPorId(const AId: Integer): TFinanceiroPagamentoDTO;
    function PagamentoCriar(const AJson: string): TFinanceiroPagamentoDTO;
    function PagamentoAtualizar(const AJson: string): TFinanceiroPagamentoDTO;
    function PagamentoExcluir(const AId: Integer): Boolean;

    function VendaListar: TObjectList<TFinanceiroVendaDTO>;
    function VendaObterPorId(const AId: Integer): TFinanceiroVendaDTO;
    function VendaCriar(const AJson: string): TFinanceiroVendaDTO;
    function VendaAtualizar(const AJson: string): TFinanceiroVendaDTO;
    function VendaExcluir(const AId: Integer): Boolean;
    function VendaConfirmacaoPdf(const AId: Integer): TBytes;
    function VendaItensListar(const AVendaId: Integer): TObjectList<TFinanceiroVendaItemDTO>;
    function VendaItemAdicionar(const AVendaId: Integer; const AJson: string): TFinanceiroVendaItemDTO;
    function VendaItemAtualizar(const AJson: string): TFinanceiroVendaItemDTO;
    function VendaItemExcluir(const AId: Integer): Boolean;
  end;

implementation

uses
  Financeiro.Exceptions;

{ TFinanceiroApiClient }

constructor TFinanceiroApiClient.Create(const AHttpClient: IHttpClient; const ABaseUrl: string);
begin
  inherited Create;

  if not Assigned(AHttpClient) then
    raise EArgumentNilException.Create('A interface do cliente HTTP não pode ser nula.');

  FBaseUrl := ABaseUrl.Trim;
  if FBaseUrl.IsEmpty then
    raise EArgumentException.Create('A URL base da API Financeiro não foi informada.');

  FHttpClient := AHttpClient;
end;

class function TFinanceiroApiClient.New(const AHttpClient: IHttpClient; const ABaseUrl: string): IFinanceiroApiClient;
begin
  Result := TFinanceiroApiClient.Create(AHttpClient, ABaseUrl);
end;

function TFinanceiroApiClient.IsSuccessStatusCode(const AStatusCode: Integer): Boolean;
begin
  Result := (AStatusCode >= 200) and (AStatusCode <= 299);
end;

procedure TFinanceiroApiClient.ValidarResponse(const AResponse: IHttpResponse);
begin
  if not Assigned(AResponse) then
    raise EFinanceiroApiException.Create('O cliente HTTP não retornou uma resposta.', 0, '');

  if not IsSuccessStatusCode(AResponse.StatusCode) then
    raise EFinanceiroApiException.Create(Format('A API Financeiro retornou o status HTTP %d.', [AResponse.StatusCode]),
                                         AResponse.StatusCode,
                                         AResponse.Content);
end;

function TFinanceiroApiClient.ExecuteJsonRequest(const AMethod: THttpMethod;
                                                const AResource: string;
                                                const ABody: string): TJSONValue;
var
  LResponse: IHttpResponse;
begin
  Result := nil;

  case AMethod of
    hmGet:
      LResponse := FHttpClient.BaseUrl(FBaseUrl).Get(AResource);
    hmPost:
      LResponse := FHttpClient.BaseUrl(FBaseUrl).Post(AResource, ABody);
    hmPut:
      LResponse := FHttpClient.BaseUrl(FBaseUrl).Put(AResource, ABody);
    hmPatch:
      LResponse := FHttpClient.BaseUrl(FBaseUrl).Patch(AResource, ABody);
    hmDelete:
      LResponse := FHttpClient.BaseUrl(FBaseUrl).Delete(AResource);
  else
    raise EFinanceiroApiException.Create('Método HTTP não suportado para a API Financeiro.', 0, '');
  end;

  ValidarResponse(LResponse);

  if AResponseHasContent(LResponse.Content) then
  begin
    Result := TJSONObject.ParseJSONValue(LResponse.Content);
    if not Assigned(Result) then
      raise EFinanceiroApiException.Create('A API Financeiro retornou um conteúdo não JSON válido.',
                                           LResponse.StatusCode,
                                           LResponse.Content);
  end;
end;

function TFinanceiroApiClient.AsObject(const AJsonValue: TJSONValue; const AContext: string): TJSONObject;
begin
  if not Assigned(AJsonValue) then
    Exit(nil);

  if AJsonValue is TJSONObject then
    Exit(TJSONObject(AJsonValue));

  raise EFinanceiroApiException.Create(Format('A resposta de %s era esperada como objeto JSON, mas chegou em outro formato.', [AContext]),
                                       0,
                                       AJsonValue.ToString);
end;

function TFinanceiroApiClient.AsArray(const AJsonValue: TJSONValue; const AContext: string): TJSONArray;
begin
  if not Assigned(AJsonValue) then
    Exit(nil);

  if AJsonValue is TJSONArray then
    Exit(TJSONArray(AJsonValue));

  raise EFinanceiroApiException.Create(Format('A resposta de %s era esperada como lista JSON, mas chegou em outro formato.', [AContext]),
                                       0,
                                       AJsonValue.ToString);
end;

function TFinanceiroApiClient.AResponseHasContent(const AContent: string): Boolean;
begin
  Result := not AContent.Trim.IsEmpty;
end;

function TFinanceiroApiClient.ClienteListar: TObjectList<TFinanceiroClienteDTO>;
var
  LJson: TJSONValue;
  LArray: TJSONArray;
  I: Integer;
begin
  Result := TObjectList<TFinanceiroClienteDTO>.Create(True);
  LJson := ExecuteJsonRequest(hmGet, '/api/Cliente');
  try
    LArray := AsArray(LJson, 'ClienteListar');
    if not Assigned(LArray) then
      Exit;

    for I := 0 to Pred(LArray.Count) do
    begin
      if not (LArray.Items[I] is TJSONObject) then
        Continue;
      Result.Add(TFinanceiroClienteDTO.FromJson(LArray.Items[I].ToString));
    end;
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.ClienteObterPorId(const AId: Integer): TFinanceiroClienteDTO;
var
  LJson: TJSONValue;
begin
  LJson := ExecuteJsonRequest(hmGet, '/api/Cliente/' + AId.ToString);
  try
    Result := TFinanceiroClienteDTO.FromJson(AsObject(LJson, 'ClienteObterPorId').ToString);
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.ClienteCriar(const AJson: string): TFinanceiroClienteDTO;
var
  LJson: TJSONValue;
  LObject: TJSONObject;
begin
  Result := nil;
  LJson := ExecuteJsonRequest(hmPost, '/api/Cliente', AJson);
  try
    if not Assigned(LJson) then
      Exit;

    LObject := AsObject(LJson, 'ClienteCriar');
    if Assigned(LObject) then
      Result := TFinanceiroClienteDTO.FromJson(LObject.ToString);
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.ClienteAtualizar(const AJson: string): TFinanceiroClienteDTO;
var
  LJson: TJSONValue;
  LObject: TJSONObject;
begin
  Result := nil;
  LJson := ExecuteJsonRequest(hmPut, '/api/Cliente', AJson);
  try
    if not Assigned(LJson) then
      Exit;

    LObject := AsObject(LJson, 'ClienteAtualizar');
    if Assigned(LObject) then
      Result := TFinanceiroClienteDTO.FromJson(LObject.ToString);
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.ClienteExcluir(const AId: Integer): Boolean;
begin
  ExecuteJsonRequest(hmDelete, '/api/Cliente/' + AId.ToString);
  Result := True;
end;

function TFinanceiroApiClient.ProdutoListar: TObjectList<TFinanceiroProdutoDTO>;
var
  LJson: TJSONValue;
  LArray: TJSONArray;
  I: Integer;
begin
  Result := TObjectList<TFinanceiroProdutoDTO>.Create(True);
  LJson := ExecuteJsonRequest(hmGet, '/api/Produto');
  try
    LArray := AsArray(LJson, 'ProdutoListar');
    if not Assigned(LArray) then
      Exit;

    for I := 0 to Pred(LArray.Count) do
    begin
      if not (LArray.Items[I] is TJSONObject) then
        Continue;
      Result.Add(TFinanceiroProdutoDTO.FromJson(LArray.Items[I].ToString));
    end;
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.ProdutoObterPorId(const AId: Integer): TFinanceiroProdutoDTO;
var
  LJson: TJSONValue;
begin
  LJson := ExecuteJsonRequest(hmGet, '/api/Produto/' + AId.ToString);
  try
    Result := TFinanceiroProdutoDTO.FromJson(AsObject(LJson, 'ProdutoObterPorId').ToString);
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.ProdutoCriar(const AJson: string): TFinanceiroProdutoDTO;
var
  LJson: TJSONValue;
  LObject: TJSONObject;
begin
  Result := nil;
  LJson := ExecuteJsonRequest(hmPost, '/api/Produto', AJson);
  try
    if not Assigned(LJson) then
      Exit;

    LObject := AsObject(LJson, 'ProdutoCriar');
    if Assigned(LObject) then
      Result := TFinanceiroProdutoDTO.FromJson(LObject.ToString);
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.ProdutoAtualizar(const AJson: string): TFinanceiroProdutoDTO;
var
  LJson: TJSONValue;
  LObject: TJSONObject;
begin
  Result := nil;
  LJson := ExecuteJsonRequest(hmPut, '/api/Produto', AJson);
  try
    if not Assigned(LJson) then
      Exit;

    LObject := AsObject(LJson, 'ProdutoAtualizar');
    if Assigned(LObject) then
      Result := TFinanceiroProdutoDTO.FromJson(LObject.ToString);
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.ProdutoExcluir(const AId: Integer): Boolean;
begin
  ExecuteJsonRequest(hmDelete, '/api/Produto/' + AId.ToString);
  Result := True;
end;

function TFinanceiroApiClient.PagamentoListar: TObjectList<TFinanceiroPagamentoDTO>;
var
  LJson: TJSONValue;
  LArray: TJSONArray;
  I: Integer;
begin
  Result := TObjectList<TFinanceiroPagamentoDTO>.Create(True);
  LJson := ExecuteJsonRequest(hmGet, '/api/Pagamento');
  try
    LArray := AsArray(LJson, 'PagamentoListar');
    if not Assigned(LArray) then
      Exit;

    for I := 0 to Pred(LArray.Count) do
    begin
      if not (LArray.Items[I] is TJSONObject) then
        Continue;
      Result.Add(TFinanceiroPagamentoDTO.FromJson(LArray.Items[I].ToString));
    end;
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.PagamentoObterPorId(const AId: Integer): TFinanceiroPagamentoDTO;
var
  LJson: TJSONValue;
begin
  LJson := ExecuteJsonRequest(hmGet, '/api/Pagamento/' + AId.ToString);
  try
    Result := TFinanceiroPagamentoDTO.FromJson(AsObject(LJson, 'PagamentoObterPorId').ToString);
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.PagamentoCriar(const AJson: string): TFinanceiroPagamentoDTO;
var
  LJson: TJSONValue;
  LObject: TJSONObject;
begin
  Result := nil;
  LJson := ExecuteJsonRequest(hmPost, '/api/Pagamento', AJson);
  try
    if not Assigned(LJson) then
      Exit;

    LObject := AsObject(LJson, 'PagamentoCriar');
    if Assigned(LObject) then
      Result := TFinanceiroPagamentoDTO.FromJson(LObject.ToString);
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.PagamentoAtualizar(const AJson: string): TFinanceiroPagamentoDTO;
var
  LJson: TJSONValue;
  LObject: TJSONObject;
begin
  Result := nil;
  LJson := ExecuteJsonRequest(hmPut, '/api/Pagamento', AJson);
  try
    if not Assigned(LJson) then
      Exit;

    LObject := AsObject(LJson, 'PagamentoAtualizar');
    if Assigned(LObject) then
      Result := TFinanceiroPagamentoDTO.FromJson(LObject.ToString);
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.PagamentoExcluir(const AId: Integer): Boolean;
begin
  ExecuteJsonRequest(hmDelete, '/api/Pagamento/' + AId.ToString);
  Result := True;
end;

function TFinanceiroApiClient.VendaListar: TObjectList<TFinanceiroVendaDTO>;
var
  LJson: TJSONValue;
  LArray: TJSONArray;
  I: Integer;
begin
  Result := TObjectList<TFinanceiroVendaDTO>.Create(True);
  LJson := ExecuteJsonRequest(hmGet, '/api/Venda');
  try
    LArray := AsArray(LJson, 'VendaListar');
    if not Assigned(LArray) then
      Exit;

    for I := 0 to Pred(LArray.Count) do
    begin
      if not (LArray.Items[I] is TJSONObject) then
        Continue;
      Result.Add(TFinanceiroVendaDTO.FromJson(LArray.Items[I].ToString));
    end;
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.VendaObterPorId(const AId: Integer): TFinanceiroVendaDTO;
var
  LJson: TJSONValue;
begin
  LJson := ExecuteJsonRequest(hmGet, '/api/Venda/' + AId.ToString);
  try
    Result := TFinanceiroVendaDTO.FromJson(AsObject(LJson, 'VendaObterPorId').ToString);
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.VendaCriar(const AJson: string): TFinanceiroVendaDTO;
var
  LJson: TJSONValue;
  LObject: TJSONObject;
begin
  Result := nil;
  LJson := ExecuteJsonRequest(hmPost, '/api/Venda', AJson);
  try
    if not Assigned(LJson) then
      Exit;

    LObject := AsObject(LJson, 'VendaCriar');
    if Assigned(LObject) then
    begin
      if Assigned(LObject.GetValue('venda')) and (LObject.GetValue('venda') is TJSONObject) then
        LObject := TJSONObject(LObject.GetValue('venda'));

      Result := TFinanceiroVendaDTO.FromJson(LObject.ToString);
    end;
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.VendaAtualizar(const AJson: string): TFinanceiroVendaDTO;
var
  LJson: TJSONValue;
  LObject: TJSONObject;
begin
  Result := nil;
  LJson := ExecuteJsonRequest(hmPut, '/api/Venda', AJson);
  try
    if not Assigned(LJson) then
      Exit;

    LObject := AsObject(LJson, 'VendaAtualizar');
    if Assigned(LObject) then
    begin
      if Assigned(LObject.GetValue('venda')) and (LObject.GetValue('venda') is TJSONObject) then
        LObject := TJSONObject(LObject.GetValue('venda'));

      Result := TFinanceiroVendaDTO.FromJson(LObject.ToString);
    end;
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.VendaExcluir(const AId: Integer): Boolean;
begin
  ExecuteJsonRequest(hmDelete, '/api/Venda/' + AId.ToString);
  Result := True;
end;

function TFinanceiroApiClient.VendaConfirmacaoPdf(const AId: Integer): TBytes;
var
  LResponse: IHttpResponse;
begin
  LResponse := FHttpClient.BaseUrl(FBaseUrl).Get('/api/vendas/' + AId.ToString + '/confirmacao-pdf');
  ValidarResponse(LResponse);

  Result := LResponse.ContentBytes;
  if Length(Result) = 0 then
    raise EFinanceiroApiException.Create('A API Financeiro retornou um PDF vazio para a confirmação da venda.',
                                         LResponse.StatusCode,
                                         LResponse.Content);
end;

function TFinanceiroApiClient.VendaItensListar(const AVendaId: Integer): TObjectList<TFinanceiroVendaItemDTO>;
var
  LJson: TJSONValue;
  LArray: TJSONArray;
  I: Integer;
begin
  Result := TObjectList<TFinanceiroVendaItemDTO>.Create(True);
  LJson := ExecuteJsonRequest(hmGet, '/api/Venda/' + AVendaId.ToString + '/itens');
  try
    LArray := AsArray(LJson, 'VendaItensListar');
    if not Assigned(LArray) then
      Exit;

    for I := 0 to Pred(LArray.Count) do
    begin
      if not (LArray.Items[I] is TJSONObject) then
        Continue;
      Result.Add(TFinanceiroVendaItemDTO.FromJson(LArray.Items[I].ToString));
    end;
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.VendaItemAdicionar(const AVendaId: Integer; const AJson: string): TFinanceiroVendaItemDTO;
var
  LJson: TJSONValue;
  LObject: TJSONObject;
begin
  Result := nil;
  LJson := ExecuteJsonRequest(hmPost, '/api/Venda/' + AVendaId.ToString + '/itens', AJson);
  try
    if not Assigned(LJson) then
      Exit;

    LObject := AsObject(LJson, 'VendaItemAdicionar');
    if Assigned(LObject) then
      Result := TFinanceiroVendaItemDTO.FromJson(LObject.ToString);
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.VendaItemAtualizar(const AJson: string): TFinanceiroVendaItemDTO;
var
  LJson: TJSONValue;
  LObject: TJSONObject;
begin
  Result := nil;
  LJson := ExecuteJsonRequest(hmPut, '/api/Venda/itens', AJson);
  try
    if not Assigned(LJson) then
      Exit;

    LObject := AsObject(LJson, 'VendaItemAtualizar');
    if Assigned(LObject) then
      Result := TFinanceiroVendaItemDTO.FromJson(LObject.ToString);
  finally
    LJson.Free;
  end;
end;

function TFinanceiroApiClient.VendaItemExcluir(const AId: Integer): Boolean;
begin
  ExecuteJsonRequest(hmDelete, '/api/Venda/itens/' + AId.ToString);
  Result := True;
end;

end.
